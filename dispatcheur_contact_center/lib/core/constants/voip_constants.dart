class VoipConstants {
  // SIP Configuration
  static const int defaultSipPort = 5060;
  static const int defaultSipPortTLS = 5061;
  static const String defaultUserAgent = 'DispatcheurCC Flutter';

  // STUN Servers
  static const List<Map<String, String>> defaultIceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
  ];

  // Call States
  static const String callStateConnecting = 'connecting';
  static const String callStateRinging = 'ringing';
  static const String callStateEstablished = 'established';
  static const String callStateHeld = 'held';
  static const String callStateEnded = 'ended';

  // Call Directions
  static const String callDirectionIncoming = 'incoming';
  static const String callDirectionOutgoing = 'outgoing';

  // Connection States
  static const String connectionStateConnected = 'connected';
  static const String connectionStateConnecting = 'connecting';
  static const String connectionStateDisconnected = 'disconnected';
  static const String connectionStateFailed = 'failed';

  // Registration States
  static const String registrationStateRegistered = 'registered';
  static const String registrationStateRegistering = 'registering';
  static const String registrationStateUnregistered = 'unregistered';
  static const String registrationStateFailed = 'failed';

  // DTMF Digits
  static const List<String> dtmfDigits = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '*',
    '0',
    '#',
  ];

  // Audio Codecs
  static const List<String> preferredAudioCodecs = [
    'opus',
    'PCMU',
    'PCMA',
    'G729',
  ];

  // Network
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration registrationRefreshInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 5;
}
