import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
import '../models/call_state.dart';

class VoipService {
  static final VoipService _instance = VoipService._internal();
  factory VoipService() => _instance;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  WebSocketChannel? _wsChannel;
  final _callStateController = StreamController<CallStateInfo>.broadcast();
  bool _isMicrophoneEnabled = true;
  bool _isSpeakerEnabled = true;

  Stream<CallStateInfo> get onCallStateChanged => _callStateController.stream;

  VoipService._internal();

  Future<void> initialize() async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };

    Map<String, dynamic> constraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': false,
      },
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    _peerConnection = await createPeerConnection(configuration, constraints);

    // Configuration audio optimisée pour la VoIP
    Map<String, dynamic> mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        'sampleRate': 16000,
        'channelCount': 1,
      },
      'video': false
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localStream!.getAudioTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _setupPeerConnectionHandlers();
  }

  void _setupPeerConnectionHandlers() {
    _peerConnection!.onIceCandidate = (candidate) {
      if (_wsChannel != null) {
        _wsChannel!.sink.add(jsonEncode({
          'type': 'ice_candidate',
          'candidate': candidate.toMap(),
        }));
      }
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _updateCallState(CallState.connected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _updateCallState(CallState.failed);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _updateCallState(CallState.ended);
          break;
        default:
          break;
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'audio') {
        _setupRemoteAudio(event.streams[0]);
      }
    };
  }

  void _setupRemoteAudio(MediaStream stream) {
    // Configuration du flux audio distant
    final audioTrack = stream.getAudioTracks().first;
    audioTrack.enableSpeakerphone(_isSpeakerEnabled);

    // Réglage du volume si nécessaire
    audioTrack.setVolume(1.0);
  }

  Future<void> makeCall(String phoneNumber) async {
    try {
      // Connexion WebSocket
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.1.28:8088/ws'),
      );

      // Écoute des messages WebSocket
      _wsChannel!.stream.listen(
        (message) => _handleSignalingMessage(jsonDecode(message)),
        onError: (error) {
          _updateCallState(CallState.failed);
          _cleanupCall();
        },
        onDone: () {
          _updateCallState(CallState.ended);
          _cleanupCall();
        },
      );

      // Création de l'offre WebRTC
      RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });

      await _peerConnection!.setLocalDescription(offer);

      // Envoi de la requête d'appel
      _wsChannel!.sink.add(jsonEncode({
        'type': 'call_request',
        'phone_number': phoneNumber,
        'sdp': offer.toMap(),
      }));

      _updateCallState(CallState.calling);
    } catch (e) {
      print('Erreur lors de l\'appel: $e');
      _updateCallState(CallState.failed);
      _cleanupCall();
    }
  }

  void _handleSignalingMessage(Map<String, dynamic> message) async {
    try {
      switch (message['type']) {
        case 'answer':
          final answer = RTCSessionDescription(
            message['sdp']['sdp'],
            message['sdp']['type'],
          );
          await _peerConnection!.setRemoteDescription(answer);
          break;

        case 'ice_candidate':
          if (message['candidate'] != null) {
            final candidate = RTCIceCandidate(
              message['candidate']['candidate'],
              message['candidate']['sdpMid'],
              message['candidate']['sdpMLineIndex'],
            );
            await _peerConnection!.addCandidate(candidate);
          }
          break;

        case 'call_status':
          switch (message['status']) {
            case 'ringing':
              _updateCallState(CallState.ringing);
              break;
            case 'connected':
              _updateCallState(CallState.connected);
              break;
            case 'failed':
              _updateCallState(CallState.failed);
              _cleanupCall();
              break;
            case 'ended':
              _updateCallState(CallState.ended);
              _cleanupCall();
              break;
          }
          break;
      }
    } catch (e) {
      print('Erreur traitement message signalisation: $e');
      _updateCallState(CallState.failed);
      _cleanupCall();
    }
  }

  void _updateCallState(CallState state) {
    _callStateController.add(CallStateInfo(
      state: state,
      phoneNumber: '', // À remplir avec le numéro actuel
      startTime: DateTime.now(),
    ));
  }

  void toggleMicrophone() {
    _isMicrophoneEnabled = !_isMicrophoneEnabled;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = _isMicrophoneEnabled;
    });
  }

  void toggleSpeaker() {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    _peerConnection?.getRemoteStreams().forEach((stream) {
      stream.getAudioTracks().forEach((track) {
        track.enableSpeakerphone(_isSpeakerEnabled);
      });
    });
  }

  Future<void> endCall() async {
    // Envoyer la demande de fin d'appel au serveur
    if (_wsChannel != null) {
      _wsChannel!.sink.add(jsonEncode({
        'type': 'hangup',
      }));
    }

    _cleanupCall();
  }

  void _cleanupCall() async {
    // Nettoyage des ressources
    await _localStream?.dispose();
    _localStream = null;

    await _peerConnection?.close();
    _peerConnection = null;

    _wsChannel?.sink.close();
    _wsChannel = null;
  }

  void dispose() {
    _cleanupCall();
    _callStateController.close();
  }
}
