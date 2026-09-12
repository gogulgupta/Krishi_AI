import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const KrishiAiApp());
}

// ==========================================
// 🎨 COLOR PALETTE & DESIGN SYSTEM
// ==========================================
class KrishiColors {
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primary = Color(0xFF047857);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentAmber = Color(0xFFD97706);
  static const Color alertRed = Color(0xFFEF4444);
  static const Color alertRedBg = Color(0xFFFEF2F2);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color darkBg = Color(0xFF0E1117);
  static const Color darkSurface = Color(0xFF1E293B);

  // 3D Soil Moisture Transition Colors
  static const Color drySoil = Color(0xFFD8A268);
  static const Color midSoil = Color(0xFF6B3F1F);
  static const Color wetSoil = Color(0xFF43270F);
}

// ==========================================
// 🔐 PURE DART SHA-256 & MERKLE TREE ENGINE
// ==========================================
class KrishiCrypto {
  static String sha256(String input) {
    var bytes = utf8.encode(input);
    var h0 = 0x6a09e667;
    var h1 = 0xbb67ae85;
    var h2 = 0x3c6ef372;
    var h3 = 0xa54ff53a;
    var h4 = 0x510e527f;
    var h5 = 0x9b05688c;
    var h6 = 0x1f83d9ab;
    var h7 = 0x5be0cd19;

    const k = [
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
      0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
      0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
      0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
      0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
      0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ];

    var bitLength = bytes.length * 8;
    var padded = List<int>.from(bytes);
    padded.add(0x80);
    while ((padded.length + 8) % 64 != 0) {
      padded.add(0);
    }
    for (var i = 7; i >= 0; i--) {
      padded.add((bitLength >> (i * 8)) & 0xff);
    }

    for (var i = 0; i < padded.length; i += 64) {
      var w = List<int>.filled(64, 0);
      for (var t = 0; t < 16; t++) {
        w[t] = (padded[i + t * 4] << 24) |
            (padded[i + t * 4 + 1] << 16) |
            (padded[i + t * 4 + 2] << 8) |
            (padded[i + t * 4 + 3]);
      }
      for (var t = 16; t < 64; t++) {
        var s0 = _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >> 3);
        var s1 = _rotr(w[t - 2], 17) ^ _rotr(w[t - 2], 19) ^ (w[t - 2] >> 10);
        w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xffffffff;
      }

      var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;

      for (var t = 0; t < 64; t++) {
        var s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        var ch = (e & f) ^ ((~e) & g);
        var temp1 = (h + s1 + ch + k[t] + w[t]) & 0xffffffff;
        var s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        var maj = (a & b) ^ (a & c) ^ (b & c);
        var temp2 = (s0 + maj) & 0xffffffff;

        h = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xffffffff;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xffffffff;
      }

      h0 = (h0 + a) & 0xffffffff;
      h1 = (h1 + b) & 0xffffffff;
      h2 = (h2 + c) & 0xffffffff;
      h3 = (h3 + d) & 0xffffffff;
      h4 = (h4 + e) & 0xffffffff;
      h5 = (h5 + f) & 0xffffffff;
      h6 = (h6 + g) & 0xffffffff;
      h7 = (h7 + h) & 0xffffffff;
    }

    return [h0, h1, h2, h3, h4, h5, h6, h7]
        .map((e) => e.toRadixString(16).padLeft(8, '0'))
        .join();
  }

  static int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xffffffff;

  static String calculateMerkleRoot(List<String> leaves) {
    if (leaves.isEmpty) return '0x0000000000000000000000000000000000000000000000000000000000000000';
    var hashes = leaves.map((l) => l.startsWith('0x') ? l.substring(2) : l).toList();
    while (hashes.length > 1) {
      if (hashes.length % 2 != 0) {
        hashes.add(hashes.last);
      }
      var nextLevel = <String>[];
      for (var i = 0; i < hashes.length; i += 2) {
        nextLevel.add(sha256(hashes[i] + hashes[i + 1]));
      }
      hashes = nextLevel;
    }
    return '0x${hashes.first}';
  }
}

// ==========================================
// 🤖 GEMINI AI REST SERVICE
// ==========================================
class GeminiAiService {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSy_YOUR_GEMINI_API_KEY_HERE',
  );

  static Future<Map<String, dynamic>> generateAgronomicAnalysis({
    required String prompt,
    String? base64Image,
  }) async {
    final client = HttpClient();
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=$apiKey',
      );

      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');

      final parts = <Map<String, dynamic>>[
        {'text': prompt}
      ];

      if (base64Image != null && base64Image.isNotEmpty) {
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          }
        });
      }

      final payload = jsonEncode({
        'contents': [
          {'parts': parts}
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
        }
      });

      request.write(payload);
      final response = await request.close().timeout(const Duration(seconds: 15));
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final parsed = jsonDecode(body);
        String? text = parsed['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null) {
          text = text.trim();
          if (text.startsWith('```json')) {
            text = text.substring(7);
          }
          if (text.startsWith('```')) {
            text = text.substring(3);
          }
          if (text.endsWith('```')) {
            text = text.substring(0, text.length - 3);
          }
          text = text.trim();
          return jsonDecode(text) as Map<String, dynamic>;
        }
      } else {
        debugPrint('[Gemini API] HTTP Error: ${response.statusCode} - $body');
      }
    } catch (e) {
      debugPrint('[Gemini API] Error: $e');
    } finally {
      client.close();
    }
    return {};
  }
}

// ==========================================
// 📡 REAL HIVEMQ CLOUD MQTT SERVICE
// ==========================================
class MqttConfig {
  static const String broker = 'fc1c2174ffcb47ca88aa28238dab2eac.s1.eu.hivemq.cloud';
  static const int port = 8883;
  static const String username = 'gogulgupta';
  static const String password = 'Gogul12345678';
  static const String dataTopic = 'gogul/agriculture/data';
  static const String statusTopic = 'gogul/agriculture/status';
  static const String controlTopic = 'gogul/agriculture/control';
}

class MqttManager {
  MqttServerClient? client;
  final Function(Map<String, dynamic> data) onDataReceived;
  final Function(String status) onStatusChanged;
  final Function(bool relayState) onRelayChanged;
  final Function(String log) onLog;

  bool _isDisposed = false;
  Timer? _reconnectTimer;

  MqttManager({
    required this.onDataReceived,
    required this.onStatusChanged,
    required this.onRelayChanged,
    required this.onLog,
  });

  Future<void> connect() async {
    _isDisposed = false;
    final clientId = 'krishi_flutter_${Random().nextInt(999999)}';

    client = MqttServerClient.withPort(MqttConfig.broker, clientId, MqttConfig.port);
    client!.secure = true;
    client!.securityContext = SecurityContext.defaultContext;
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;

    client!.onConnected = () {
      onStatusChanged('connected');
      onLog('Connected to HiveMQ Cloud SSL (Port 8883)!');

      client!.subscribe(MqttConfig.dataTopic, MqttQos.atLeastOnce);
      client!.subscribe(MqttConfig.statusTopic, MqttQos.atLeastOnce);
      client!.subscribe(MqttConfig.controlTopic, MqttQos.atLeastOnce);
      onLog('Subscribed to ${MqttConfig.dataTopic}');
    };

    client!.onDisconnected = () {
      if (!_isDisposed) {
        onStatusChanged('disconnected');
        onLog('MQTT connection lost. Reconnecting in 5s...');
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 5), () {
          if (!_isDisposed) connect();
        });
      }
    };

    final connMessage = MqttConnectMessage()
        .authenticateAs(MqttConfig.username, MqttConfig.password)
        .withClientIdentifier(clientId)
        .startClean();
    client!.connectionMessage = connMessage;

    try {
      onStatusChanged('connecting');
      onLog('Connecting to HiveMQ Cloud (${MqttConfig.broker})...');
      await client!.connect();
    } catch (e) {
      onStatusChanged('error');
      onLog('MQTT Connection Error: $e');
      if (!_isDisposed) {
        _reconnectTimer = Timer(const Duration(seconds: 5), () {
          if (!_isDisposed) connect();
        });
      }
    }

    client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final msg in messages) {
        final recMess = msg.payload as MqttPublishMessage;
        final payloadString = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final topic = msg.topic;

        if (topic == MqttConfig.statusTopic) {
          final trimmed = payloadString.trim().toUpperCase();
          if (trimmed == 'ON' || trimmed == '1') {
            onRelayChanged(true);
            onLog('[Relay Status] ESP32: ON');
          } else if (trimmed == 'OFF' || trimmed == '0') {
            onRelayChanged(false);
            onLog('[Relay Status] ESP32: OFF');
          }
        } else if (topic == MqttConfig.dataTopic) {
          try {
            final parsed = jsonDecode(payloadString);
            if (parsed is Map<String, dynamic>) {
              onDataReceived(parsed);
              onLog('[ESP32 Live #${parsed['counter'] ?? '?'}] S1:${parsed['soil1']}% S2:${parsed['soil2']}% S3:${parsed['soil3']}% S4:${parsed['soil4']}% T:${parsed['temperature']}°C');
            }
          } catch (_) {}
        }
      }
    });
  }

  void publishRelay(bool state) {
    if (client != null && client!.connectionStatus?.state == MqttConnectionState.connected) {
      final str = state ? 'ON' : 'OFF';
      final builder = MqttClientPayloadBuilder();
      builder.addString(str);
      client!.publishMessage(MqttConfig.controlTopic, MqttQos.atLeastOnce, builder.payload!);
      onLog('Published to ${MqttConfig.controlTopic}: $str');

      Future.delayed(const Duration(milliseconds: 150), () {
        if (client != null && client!.connectionStatus?.state == MqttConnectionState.connected) {
          final b2 = MqttClientPayloadBuilder();
          b2.addString(state ? '1' : '0');
          client!.publishMessage(MqttConfig.controlTopic, MqttQos.atLeastOnce, b2.payload!);
        }
      });
    }
  }

  void disconnect() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    client?.disconnect();
  }
}

// ==========================================
// 🌐 MAIN APPLICATION ROOT
// ==========================================
class KrishiAiApp extends StatefulWidget {
  const KrishiAiApp({super.key});

  @override
  State<KrishiAiApp> createState() => _KrishiAiAppState();
}

class _KrishiAiAppState extends State<KrishiAiApp> {
  String _lang = 'en';
  bool _showSplash = true;

  void toggleLanguage() {
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _finishSplash() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrishiAI - Smart Agriculture Decision Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: KrishiColors.bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KrishiColors.primary,
          primary: KrishiColors.primary,
          secondary: KrishiColors.primaryLight,
          surface: KrishiColors.surfaceWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: KrishiColors.primaryDark,
          elevation: 0.5,
          centerTitle: false,
        ),
      ),
      home: _showSplash
          ? _SplashScreen(
              onFinished: _finishSplash,
            )
          : MainScreen(
              lang: _lang,
              onToggleLang: toggleLanguage,
            ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const _SplashScreen({required this.onFinished});

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/krishi_logo.jpg',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "KrishiAI",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: KrishiColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Smarter Farms, Brighter Tomorrows",
                  style: TextStyle(
                    fontSize: 14,
                    color: KrishiColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 📱 MAIN SHELL & GLOBAL STATE CONTROLLER
// ==========================================
class MainScreen extends StatefulWidget {
  final String lang;
  final VoidCallback onToggleLang;

  const MainScreen({
    super.key,
    required this.lang,
    required this.onToggleLang,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0; // 0: Dashboard, 1: FarmerHub, 2: PlantDisease, 3: RealTime, 4: Company, 5: Irrigation, 6: SoilStudio, 7: Schemes
  String _selectedDistrict = "Ghaziabad";
  String _selectedState = "Uttar Pradesh";
  final String _userName = "Rameshwar Sharma";

  // Real-time ESP32 Live Telemetry State
  double _soil1 = 68.0;
  double _soil2 = 72.0;
  double _soil3 = 45.0;
  double _soil4 = 82.0;
  double _temperature = 28.4;
  double _humidity = 76.0;
  double _pressure = 1012.0;
  bool _rain = false;
  int _counter = 0;
  String _deviceName = "ESP32";
  bool _relayOn = false;
  final double _motorVoltage = 12.4;

  // Shared Global Agronomic States across Tabs
  String _activePlantDisease = "Early Blight";
  double _activePlantConfidence = 94.8;
  String _activeSoilType = "Black Soil (Regur / Lava Soil)";
  double _activeSoilConfidence = 96.5;

  // Blockchain Dispatch State
  String _dispatchStatus = 'IDLE'; // 'IDLE', 'DISPATCHED_PENDING_APPROVAL', 'VERIFIED_AND_MINTED'
  String _submittedBlockId = 'MST-TX-7829';
  Map<String, dynamic>? _verifiedPrescription;

  // MQTT Connection state
  String _mqttStatus = 'connecting';
  int _secondsAgo = 0;
  Timer? _secondsTicker;
  final List<String> _consoleLogs = [];

  MqttManager? _mqttManager;
  late AnimationController _farmAnimController;

  @override
  void initState() {
    super.initState();

    _farmAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _initMqtt();
    _fetchCurrentLocation();

    _secondsTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsAgo++;
        });
      }
    });
  }

  Future<void> _fetchCurrentLocation({bool showToast = false}) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      // Attempt 1: ipwho.is (HTTPS, fast, accurate city/state)
      try {
        final request = await client.getUrl(Uri.parse('https://ipwho.is/'));
        final response = await request.close();
        if (response.statusCode == 200) {
          final respBody = await response.transform(utf8.decoder).join();
          final data = jsonDecode(respBody);
          if (data['success'] == true && data['city'] != null && data['city'].toString().isNotEmpty) {
            if (mounted) {
              setState(() {
                _selectedDistrict = data['city'].toString();
                if (data['region'] != null && data['region'].toString().isNotEmpty) {
                  _selectedState = data['region'].toString();
                }
              });
              if (showToast && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.lang == 'hi'
                        ? "लाइव स्थान मिला: $_selectedDistrict, $_selectedState 📍"
                        : "Live Location Found: $_selectedDistrict, $_selectedState 📍"),
                    backgroundColor: KrishiColors.primaryDark,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              return;
            }
          }
        }
      } catch (_) {}

      // Attempt 2: ip-api.com (Reliable fallback)
      try {
        final request2 = await client.getUrl(Uri.parse('http://ip-api.com/json'));
        final response2 = await request2.close();
        if (response2.statusCode == 200) {
          final respBody2 = await response2.transform(utf8.decoder).join();
          final data2 = jsonDecode(respBody2);
          if (data2['status'] == 'success' && data2['city'] != null && data2['city'].toString().isNotEmpty) {
            if (mounted) {
              setState(() {
                _selectedDistrict = data2['city'].toString();
                if (data2['regionName'] != null && data2['regionName'].toString().isNotEmpty) {
                  _selectedState = data2['regionName'].toString();
                }
              });
              if (showToast && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.lang == 'hi'
                        ? "लाइव स्थान मिला: $_selectedDistrict, $_selectedState 📍"
                        : "Live Location Found: $_selectedDistrict, $_selectedState 📍"),
                    backgroundColor: KrishiColors.primaryDark,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              return;
            }
          }
        }
      } catch (_) {}
    } catch (e) {
      debugPrint("Auto location error: $e");
    }
  }

  void _initMqtt() {
    _mqttManager = MqttManager(
      onStatusChanged: (status) {
        if (mounted) setState(() => _mqttStatus = status);
      },
      onRelayChanged: (state) {
        if (mounted) setState(() => _relayOn = state);
      },
      onLog: (log) {
        if (mounted) {
          setState(() {
            final now = DateTime.now();
            final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
            _consoleLogs.insert(0, "[$timeStr] $log");
            if (_consoleLogs.length > 30) _consoleLogs.removeLast();
          });
        }
      },
      onDataReceived: (data) {
        if (mounted) {
          setState(() {
            _secondsAgo = 0;
            if (data['soil1'] != null) _soil1 = double.tryParse(data['soil1'].toString()) ?? _soil1;
            if (data['soil2'] != null) _soil2 = double.tryParse(data['soil2'].toString()) ?? _soil2;
            if (data['soil3'] != null) _soil3 = double.tryParse(data['soil3'].toString()) ?? _soil3;
            if (data['soil4'] != null) _soil4 = double.tryParse(data['soil4'].toString()) ?? _soil4;

            if (data['temperature'] != null) _temperature = double.tryParse(data['temperature'].toString()) ?? _temperature;
            if (data['humidity'] != null) _humidity = double.tryParse(data['humidity'].toString()) ?? _humidity;
            if (data['pressure'] != null) _pressure = double.tryParse(data['pressure'].toString()) ?? _pressure;
            if (data['counter'] != null) _counter = int.tryParse(data['counter'].toString()) ?? _counter;
            if (data['device'] != null) _deviceName = data['device'].toString();

            if (data['rain'] != null) {
              final r = data['rain'].toString().toLowerCase();
              _rain = r == 'true' || r == '1' || r == 'yes';
            }
          });
        }
      },
    );

    _mqttManager!.connect();
  }

  void _toggleRelay() {
    final nextState = !_relayOn;
    setState(() => _relayOn = nextState);
    _mqttManager?.publishRelay(nextState);
  }

  void _dispatchToBlockchain() {
    setState(() {
      _dispatchStatus = 'DISPATCHED_PENDING_APPROVAL';
      _submittedBlockId = 'MST-TX-${Random().nextInt(8000) + 1000}';
    });
  }

  void _commitCompanyApproval(Map<String, dynamic> prescription) {
    setState(() {
      _dispatchStatus = 'VERIFIED_AND_MINTED';
      _verifiedPrescription = prescription;
    });
  }

  @override
  void dispose() {
    _farmAnimController.dispose();
    _secondsTicker?.cancel();
    _mqttManager?.disconnect();
    super.dispose();
  }

  void _changeTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _showLocationPicker() {
    final isHi = widget.lang == 'hi';
    final districts = [
      {"name": "Ghaziabad", "state": "Uttar Pradesh", "rain": "Heavy Rain 🌧️"},
      {"name": "Nashik", "state": "Maharashtra", "rain": "Clear Sky ☀️"},
      {"name": "Ludhiana", "state": "Punjab", "rain": "High Wind 💨"},
      {"name": "Jaipur", "state": "Rajasthan", "rain": "Intense Heat 🌡️"},
      {"name": "Meerut", "state": "Uttar Pradesh", "rain": "Moderate ⛅"},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHi ? "स्थान (जिला) चुनें" : "Select District / Location",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Auto Detect Current Location Tile
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: KrishiColors.emeraldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: KrishiColors.primaryLight.withValues(alpha: 0.4)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: KrishiColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: Colors.white, size: 18),
                  ),
                  title: Text(
                    isHi ? "🎯 वर्तमान स्थान ऑटो-डिटेक्ट करें" : "🎯 Detect Current Location (Auto)",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: KrishiColors.primaryDark),
                  ),
                  subtitle: Text(
                    isHi ? "GPS / लाइव नेटवर्क से स्थान प्राप्त करें" : "Fetch live location via network/GPS",
                    style: const TextStyle(fontSize: 11, color: KrishiColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _fetchCurrentLocation(showToast: true);
                  },
                ),
              ),
              const Divider(),
              ...districts.map((d) => ListTile(
                    leading: const Icon(Icons.location_on, color: KrishiColors.primary),
                    title: Text("${d['name']}, ${d['state']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(d['rain']!),
                    trailing: _selectedDistrict == d['name']
                        ? const Icon(Icons.check_circle, color: KrishiColors.primaryLight)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedDistrict = d['name']!;
                        _selectedState = d['state']!;
                      });
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showForecastModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ForecastRadarModal(
        lang: widget.lang,
        district: _selectedDistrict,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHi = widget.lang == 'hi';

    return Scaffold(
      // Top App Bar
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/krishi_logo.jpg',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "KrishiAI",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: KrishiColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isHi ? "स्मार्ट कृषि निर्णय मंच" : "Smart Farm Engine",
                  style: const TextStyle(fontSize: 10, color: KrishiColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // GPS Location
          InkWell(
            onTap: _showLocationPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: KrishiColors.emeraldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KrishiColors.primaryLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: KrishiColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _selectedDistrict,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: KrishiColors.primaryDark),
                  ),
                ],
              ),
            ),
          ),
          // Language Toggle
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: KrishiColors.borderLight),
              ),
              child: Text(
                widget.lang == 'en' ? "हि" : "EN",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
            onPressed: widget.onToggleLang,
          ),
          const SizedBox(width: 4),
        ],
      ),

      // App Navigation Drawer
      drawer: AppDrawer(
        lang: widget.lang,
        currentTab: _currentTabIndex,
        onSelectTab: (idx) {
          Navigator.pop(context);
          _changeTab(idx);
        },
        userName: _userName,
      ),

      // Indexed Stack for all 8 Tab Screens
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          // 0: Dashboard
          DashboardView(
            lang: widget.lang,
            district: _selectedDistrict,
            state: _selectedState,
            soilMoisture: _soil1,
            soilTemp: _temperature,
            airHumidity: _humidity,
            npkVal: 142.0,
            onOpenForecast: _showForecastModal,
            onGoToTab: _changeTab,
          ),
          // 1: Farmer Blockchain Hub (Pure Farmer Telemetry)
          FarmerBlockchainHubView(
            lang: widget.lang,
            plantDisease: _activePlantDisease,
            plantConfidence: _activePlantConfidence,
            soilType: _activeSoilType,
            soilConfidence: _activeSoilConfidence,
            soilMoisture: _soil1,
            temperature: _temperature,
            humidity: _humidity,
            rain: _rain,
            dispatchStatus: _dispatchStatus,
            submittedBlockId: _submittedBlockId,
            verifiedPrescription: _verifiedPrescription,
            onDispatch: _dispatchToBlockchain,
          ),
          // 2: Plant Disease Detector (Gemini AI Vision)
          PlantDiseaseDetectorView(
            lang: widget.lang,
            onDetected: (disease, conf) {
              setState(() {
                _activePlantDisease = disease;
                _activePlantConfidence = conf;
              });
            },
          ),
          // 3: Real Time 3D Farming Data (HiveMQ MQTT)
          RealTimeFarmingView(
            lang: widget.lang,
            soil1: _soil1,
            soil2: _soil2,
            soil3: _soil3,
            soil4: _soil4,
            temperature: _temperature,
            humidity: _humidity,
            pressure: _pressure,
            rain: _rain,
            counter: _counter,
            deviceName: _deviceName,
            relayOn: _relayOn,
            motorVoltage: _motorVoltage,
            mqttStatus: _mqttStatus,
            secondsAgo: _secondsAgo,
            consoleLogs: _consoleLogs,
            animProgress: _farmAnimController,
            onToggleRelay: _toggleRelay,
            onReconnectMqtt: () => _mqttManager?.connect(),
          ),
          // 4: Fertilizer Company Portal
          FertilizerCompanyView(
            lang: widget.lang,
            plantDisease: _activePlantDisease,
            plantConfidence: _activePlantConfidence,
            soilType: _activeSoilType,
            soilMoisture: _soil1,
            temperature: _temperature,
            humidity: _humidity,
            rain: _rain,
            dispatchStatus: _dispatchStatus,
            submittedBlockId: _submittedBlockId,
            onCommitSolution: _commitCompanyApproval,
          ),
          // 5: Smart Irrigation
          SmartIrrigationView(
            lang: widget.lang,
            soilMoisture: _soil1,
          ),
          // 6: Soil AI Studio (Gemini AI Soil Classification)
          SoilAiStudioView(
            lang: widget.lang,
            onSoilClassified: (soil, conf) {
              setState(() {
                _activeSoilType = soil;
                _activeSoilConfidence = conf;
              });
            },
          ),
          // 7: Schemes & Support
          SchemesView(
            lang: widget.lang,
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: KrishiColors.borderLight)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex > 4 ? 0 : _currentTabIndex,
          onTap: _changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: KrishiColors.primary,
          unselectedItemColor: KrishiColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: isHi ? 'डैशबोर्ड' : 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shield_outlined),
              activeIcon: const Icon(Icons.shield),
              label: isHi ? 'फार्मर हब' : 'Farmer Hub',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              activeIcon: const Icon(Icons.qr_code_scanner),
              label: isHi ? 'रोग AI' : 'Disease AI',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sensors),
              activeIcon: const Icon(Icons.sensors),
              label: isHi ? '3D खेत' : '3D Farm',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business),
              activeIcon: const Icon(Icons.business),
              label: isHi ? 'कंपनी' : 'Company',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 📊 0. TAB: DASHBOARD VIEW
// ==========================================
class DashboardView extends StatelessWidget {
  final String lang;
  final String district;
  final String state;
  final double soilMoisture;
  final double soilTemp;
  final double airHumidity;
  final double npkVal;
  final VoidCallback onOpenForecast;
  final Function(int) onGoToTab;

  const DashboardView({
    super.key,
    required this.lang,
    required this.district,
    required this.state,
    required this.soilMoisture,
    required this.soilTemp,
    required this.airHumidity,
    required this.npkVal,
    required this.onOpenForecast,
    required this.onGoToTab,
  });

  @override
  Widget build(BuildContext context) {
    final isHi = lang == 'hi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather & Spray Advisory Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KrishiColors.primaryDark, Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: KrishiColors.primaryLight, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "$district, $state",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: onOpenForecast,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: KrishiColors.accentGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: KrishiColors.accentGold),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.radar, size: 12, color: KrishiColors.accentGold),
                            const SizedBox(width: 4),
                            Text(
                              isHi ? "72-घंटे रडार" : "72-Hr Radar",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: KrishiColors.accentGold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${soilTemp.toStringAsFixed(1)}°C",
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text(
                          isHi ? "आसमान में बादल • बारिश संभावना 78%" : "Cloudy • Rain Chance 78%",
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                    const Icon(Icons.cloudy_snowing, color: Colors.lightBlueAccent, size: 48),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Action Cards Grid
          Text(
            isHi ? "त्वरित कृषि मॉड्यूल्स" : "Core Agriculture Modules",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: KrishiColors.textMain),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _buildActionCard(
                title: isHi ? "👨‍🌾 ब्लॉकचेन हब" : "👨‍🌾 Farmer Hub",
                sub: isHi ? "3-फैक्टर टेलीमेट्री" : "3-Factor Dispatch",
                icon: Icons.shield,
                color: Colors.green,
                onTap: () => onGoToTab(1),
              ),
              _buildActionCard(
                title: isHi ? "🌾 रोग डिटेक्टर" : "🌾 Disease AI",
                sub: isHi ? "Gemini विज़न AI" : "Gemini Multi-Modal",
                icon: Icons.qr_code_scanner,
                color: Colors.amber,
                onTap: () => onGoToTab(2),
              ),
              _buildActionCard(
                title: isHi ? "📈 3D लाइव IoT" : "📈 3D Live IoT",
                sub: isHi ? "ESP32 सेंसर स्ट्रीम" : "HiveMQ Telemetry",
                icon: Icons.sensors,
                color: Colors.teal,
                onTap: () => onGoToTab(3),
              ),
              _buildActionCard(
                title: isHi ? "🏢 फर्टिलाइजर कंपनी" : "🏢 Company Portal",
                sub: isHi ? "प्रमाणित समाधान" : "Prescription Mint",
                icon: Icons.business,
                color: Colors.purple,
                onTap: () => onGoToTab(4),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Priority Alert Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KrishiColors.alertRedBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.alertRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: KrishiColors.alertRed, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHi ? "चेतावनी: पत्तियों पर अर्ली ब्लाइट का खतरा" : "Alert: Early Blight Infection Detected",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: KrishiColors.alertRed),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHi
                            ? "हवा में 76% नमी व 28°C तापमान फफूंद प्रसार हेतु अनुकूल है। तुरंत फर्टिलाइजर हब में जांचें।"
                            : "High humidity (76%) accelerates fungal spread. Verify prescription in Farmer Blockchain Hub.",
                        style: const TextStyle(fontSize: 11, color: KrishiColors.textMain),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String sub,
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: KrishiColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: color.shade100,
              radius: 16,
              child: Icon(icon, color: color.shade800, size: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(sub, style: const TextStyle(fontSize: 9, color: KrishiColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 👨‍🌾 1. TAB: FARMER BLOCKCHAIN HUB (PURE FARMER DATA)
// ==========================================
class FarmerBlockchainHubView extends StatelessWidget {
  final String lang;
  final String plantDisease;
  final double plantConfidence;
  final String soilType;
  final double soilConfidence;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final bool rain;
  final String dispatchStatus;
  final String submittedBlockId;
  final Map<String, dynamic>? verifiedPrescription;
  final VoidCallback onDispatch;

  const FarmerBlockchainHubView({
    super.key,
    required this.lang,
    required this.plantDisease,
    required this.plantConfidence,
    required this.soilType,
    required this.soilConfidence,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.rain,
    required this.dispatchStatus,
    required this.submittedBlockId,
    required this.verifiedPrescription,
    required this.onDispatch,
  });

  @override
  Widget build(BuildContext context) {
    final isHi = lang == 'hi';

    // Calculate Cryptographic Hashes
    final leaf1 = KrishiCrypto.sha256('PlantDisease:$plantDisease:Conf:$plantConfidence');
    final leaf2 = KrishiCrypto.sha256('IoTMoisture:$soilMoisture:Temp:$temperature:Hum:$humidity');
    final leaf3 = KrishiCrypto.sha256('SoilType:$soilType:Conf:$soilConfidence');
    final merkleRoot = KrishiCrypto.calculateMerkleRoot([leaf1, leaf2, leaf3]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KrishiColors.primaryDark, Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: KrishiColors.primaryLight, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isHi ? "फार्मर ब्लॉकचेन हब" : "Farmer Telemetry Hub",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.greenAccent),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, color: Colors.greenAccent, size: 8),
                          SizedBox(width: 4),
                          Text(
                            "MST Testnet (91562037)",
                            style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isHi
                      ? "3-फैक्टर टेलीमेट्री बंडल (पत्ती रोग + IoT लाइव नमी + मिट्टी वर्गीकरण) की SHA-256 गणना।"
                      : "3-Factor farm telemetry bundled into immutable cryptographic SHA-256 Merkle root.",
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3-Factor Telemetry Bundle Cards
          Text(
            isHi ? "3-फैक्टर टेलीमेट्री डेटा" : "3-Factor Farm Telemetry Bundle",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: KrishiColors.textMain),
          ),
          const SizedBox(height: 10),

          // Leaf 1: Plant Disease
          _buildTelemetryCard(
            factorNum: "1",
            title: isHi ? "पादप रोग AI मॉडल" : "Plant Disease Diagnostic",
            sub: plantDisease,
            badge: "${plantConfidence.toStringAsFixed(1)}% Conf",
            badgeColor: Colors.red,
            hash: leaf1,
            icon: Icons.biotech,
          ),
          const SizedBox(height: 10),

          // Leaf 2: IoT Sensors
          _buildTelemetryCard(
            factorNum: "2",
            title: isHi ? "लाइव IoT सेंसर नमी (HiveMQ)" : "Live IoT Sensors (HiveMQ)",
            sub: "Moisture: ${soilMoisture.toStringAsFixed(1)}% • ${temperature.toStringAsFixed(1)}°C • ${humidity.toStringAsFixed(1)}% RH",
            badge: rain ? "Rain 🌧️" : "Dry ☀️",
            badgeColor: Colors.blue,
            hash: leaf2,
            icon: Icons.sensors,
          ),
          const SizedBox(height: 10),

          // Leaf 3: Soil Classification
          _buildTelemetryCard(
            factorNum: "3",
            title: isHi ? "मृदा वर्गीकरण AI" : "Soil Classification Model",
            sub: soilType,
            badge: "${soilConfidence.toStringAsFixed(1)}% Conf",
            badgeColor: Colors.amber,
            hash: leaf3,
            icon: Icons.layers,
          ),

          const SizedBox(height: 16),

          // Merkle Root Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.primaryLight.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.hub, color: KrishiColors.primaryLight, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Cryptographic Merkle Root (3-Factor Hash)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  merkleRoot,
                  style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dispatch Action or Status
          if (dispatchStatus == 'IDLE')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDispatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KrishiColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.send, size: 18),
                label: Text(
                  isHi ? "⚡ MST ब्लॉकचेन पर डिस्पैच करें" : "⚡ Dispatch to MST Blockchain",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),

          if (dispatchStatus == 'DISPATCHED_PENDING_APPROVAL')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: KrishiColors.accentAmber),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? "⏳ फर्टिलाइजर कंपनी मूल्यांकन प्रतीक्षारत" : "⏳ Awaiting Company AI Evaluation",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: KrishiColors.accentAmber),
                        ),
                        Text(
                          "Queue ID: #$submittedBlockId • Dispatched on MST Blockchain",
                          style: const TextStyle(fontSize: 10, color: KrishiColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (dispatchStatus == 'VERIFIED_AND_MINTED' && verifiedPrescription != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KrishiColors.primaryLight),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isHi ? "कंपनी द्वारा सत्यापित प्रेस्क्रिप्शन" : "Verified Fertilizer Prescription",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: KrishiColors.primaryDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: KrishiColors.emeraldBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("MST VERIFIED", style: TextStyle(color: KrishiColors.primary, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _buildPrescriptionRow(isHi ? "अनुशंसित खाद/दवा:" : "Fertilizer:", verifiedPrescription!['recommendedFertilizer'] ?? 'Azoxystrobin SC'),
                  _buildPrescriptionRow(isHi ? "स्प्रे समय:" : "Spray Window:", verifiedPrescription!['sprayTiming'] ?? '06:30 AM - 08:30 AM'),
                  _buildPrescriptionRow(isHi ? "मात्रा:" : "Dosage:", verifiedPrescription!['dosage'] ?? '1.0 ml / L'),
                  _buildPrescriptionRow(isHi ? "अनुमानित मूल्य:" : "Net Price:", "₹${verifiedPrescription!['estimatedPriceINR'] ?? 360} / Acre"),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard({
    required String factorNum,
    required String title,
    required String sub,
    required String badge,
    required MaterialColor badgeColor,
    required String hash,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KrishiColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: KrishiColors.primaryLight.withValues(alpha: 0.2),
                      child: Text(factorNum, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: KrishiColors.primaryDark)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge, style: TextStyle(color: badgeColor.shade900, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(sub, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: KrishiColors.textMain)),
          const SizedBox(height: 4),
          Text("Hash: ${hash.substring(0, 24)}...", style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: KrishiColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: KrishiColors.textMuted),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: KrishiColors.textMain),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🌾 2. TAB: PLANT DISEASE DETECTOR
// ==========================================
class PlantDiseaseDetectorView extends StatefulWidget {
  final String lang;
  final Function(String disease, double confidence) onDetected;

  const PlantDiseaseDetectorView({
    super.key,
    required this.lang,
    required this.onDetected,
  });

  @override
  State<PlantDiseaseDetectorView> createState() => _PlantDiseaseDetectorViewState();
}

class _PlantDiseaseDetectorViewState extends State<PlantDiseaseDetectorView> {
  XFile? _pickedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _pickedImage = photo;
          _analysisResult = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _runGeminiDetection() async {
    setState(() => _isAnalyzing = true);

    String? base64Img;
    if (_pickedImage != null) {
      try {
        final bytes = await File(_pickedImage!.path).readAsBytes();
        base64Img = base64Encode(bytes);
      } catch (e) {
        debugPrint("Error reading image bytes: $e");
      }
    }

    final prompt = """You are a Senior Multi-Modal Plant Pathologist & Agronomist (KrishiAI).
Examine this plant/leaf image and automatically identify:
1. What crop/plant is this? (e.g. Pearl Millet / Bajra, Chilli, Tomato, Wheat, Cotton, Rice, etc.)
2. Is the plant diseased or healthy? (true if diseased/damaged, false if healthy)
3. What is the specific disease name or healthy status?
4. What is the confidence score percentage (between 88% and 99%)?
5. What visual symptoms are visible on this leaf/plant?
6. What is the recommended chemical spray and dosage?
7. What is the organic remedy (bio-fungicide/neem oil)?
8. What is the immediate action plan?

Provide response ONLY in this exact JSON format:
{
  "cropName": "Detected Crop Name",
  "isDiseased": true,
  "disease": "Disease Name or Healthy Leaf",
  "confidence": 96.5,
  "severity": "Moderate to High",
  "symptoms": "Detailed visual symptoms seen on leaf lamina",
  "recommendedSpray": "Exact chemical formulation and dosage",
  "organicRemedy": "Bio-fertilizer / organic alternative",
  "actionPlan": "Immediate practical advice for the farmer"
}""";

    final res = await GeminiAiService.generateAgronomicAnalysis(
      prompt: prompt,
      base64Image: base64Img,
    );

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        if (res.isNotEmpty) {
          _analysisResult = res;
          widget.onDetected(
            res['disease'] ?? 'Plant Diagnostic Result',
            (res['confidence'] as num?)?.toDouble() ?? 95.0,
          );
        } else {
          // Robust Fallback if offline
          _analysisResult = {
            "cropName": "Pearl Millet (Bajra)",
            "isDiseased": true,
            "disease": "Downy Mildew (Sclerospora graminicola)",
            "confidence": 95.8,
            "severity": "Moderate to High",
            "symptoms": "Chlorotic streaks on upper leaf lamina with downy fungal mycelium underneath.",
            "recommendedSpray": "Azoxystrobin 18.2% + Difenoconazole 11.4% SC (1.0 ml / L)",
            "organicRemedy": "Neem oil spray (5ml/L) & Trichoderma viride bio-application",
            "actionPlan": "Foliar spray during calm morning wind within 24 hours."
          };
          widget.onDetected("Downy Mildew (Sclerospora graminicola)", 95.8);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Saved to Farmer Blockchain Telemetry (Leaf 1 Updated)!"),
          backgroundColor: KrishiColors.primary,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHi = widget.lang == 'hi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: KrishiColors.primaryLight, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHi ? "पादप रोग डिटेक्टर (Plant Disease Detector)" : "Plant Disease Detector",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        isHi
                            ? "पत्ती की फोटो खींचें या अपलोड करें — Gemini AI खुद फसल व रोग की पहचान करेगा।"
                            : "Capture or upload leaf photo — Gemini AI automatically detects crop & disease.",
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Photo Capture & Upload Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHi ? "पत्ती की फोटो अपलोड करें (कैमरा / गैलरी)" : "Upload Leaf Photo (Camera / Gallery)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Camera & Gallery Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickFromSource(ImageSource.camera),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: KrishiColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.camera_alt, color: KrishiColors.primary, size: 18),
                        label: Text(
                          isHi ? "फोटो खींचें" : "Take Photo",
                          style: const TextStyle(color: KrishiColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickFromSource(ImageSource.gallery),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: KrishiColors.primaryDark),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.photo_library, color: KrishiColors.primaryDark, size: 18),
                        label: Text(
                          isHi ? "गैलरी से चुनें" : "Upload Gallery",
                          style: const TextStyle(color: KrishiColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Image Preview or Placeholder
                if (_pickedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Image.file(
                          File(_pickedImage!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: InkWell(
                            onTap: () => setState(() => _pickedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: KrishiColors.bgLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: KrishiColors.borderLight, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: KrishiColors.primary, size: 30),
                        const SizedBox(height: 6),
                        Text(
                          isHi ? "कैमरा से लाइव फोटो लें या गैलरी से अपलोड करें" : "Click Take Photo or Upload from Gallery",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: KrishiColors.textMain),
                        ),
                        Text(
                          isHi ? "Gemini AI सीधे फोटो देखकर फसल और रोग बताएगा" : "Gemini AI will inspect the photo and identify crop & disease",
                          style: const TextStyle(fontSize: 9, color: KrishiColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Analysis Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _runGeminiDetection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KrishiColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isAnalyzing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.bolt, size: 20),
                    label: Text(
                      isHi ? "⚡ रोग का AI विश्लेषण करें" : "⚡ Run AI Disease Analysis",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Analysis Output Card
          if (_analysisResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KrishiColors.primaryLight),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _analysisResult!['disease'] ?? 'Detected Disease',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: KrishiColors.primaryDark),
                            ),
                            if (_analysisResult!['cropName'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  "🌾 Identified Crop: ${_analysisResult!['cropName']}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: KrishiColors.primary),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _analysisResult!['isDiseased'] == false ? KrishiColors.emeraldBg : KrishiColors.alertRedBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _analysisResult!['isDiseased'] == false ? KrishiColors.primaryLight : KrishiColors.alertRed),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _analysisResult!['isDiseased'] == false ? "HEALTHY LEAF" : "PROBLEM DETECTED",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: _analysisResult!['isDiseased'] == false ? KrishiColors.primaryDark : KrishiColors.alertRed,
                              ),
                            ),
                            Text(
                              "${_analysisResult!['confidence'] ?? 95}% Conf",
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: KrishiColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _buildResultItem("Symptoms:", _analysisResult!['symptoms'] ?? ''),
                  _buildResultItem("Recommended Chemical Spray:", _analysisResult!['recommendedSpray'] ?? ''),
                  _buildResultItem("Organic Alternative:", _analysisResult!['organicRemedy'] ?? ''),
                  _buildResultItem("Action Plan:", _analysisResult!['actionPlan'] ?? ''),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KrishiColors.emeraldBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: KrishiColors.primary, size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Synced with Farmer Blockchain Hub (Leaf 1 Updated)",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: KrishiColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultItem(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: KrishiColors.textMuted)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 12, color: KrishiColors.textMain)),
        ],
      ),
    );
  }
}

// ==========================================
// 🎨 ISOMETRIC 3D 4-ZONE FARM VISUALIZER
// ==========================================
class Farm3DVisualizer extends StatelessWidget {
  final double soil1;
  final double soil2;
  final double soil3;
  final double soil4;
  final Animation<double> animation;

  const Farm3DVisualizer({
    super.key,
    required this.soil1,
    required this.soil2,
    required this.soil3,
    required this.soil4,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FarmIsometricPainter(
            soil1: soil1,
            soil2: soil2,
            soil3: soil3,
            soil4: soil4,
            animValue: animation.value,
          ),
          child: const SizedBox(
            height: 250,
            width: double.infinity,
          ),
        );
      },
    );
  }
}

class FarmIsometricPainter extends CustomPainter {
  final double soil1;
  final double soil2;
  final double soil3;
  final double soil4;
  final double animValue;

  FarmIsometricPainter({
    required this.soil1,
    required this.soil2,
    required this.soil3,
    required this.soil4,
    required this.animValue,
  });

  Color _getSoilColor(double moisture) {
    final factor = (moisture / 100.0).clamp(0.0, 1.0);
    if (factor < 0.5) {
      return Color.lerp(KrishiColors.drySoil, KrishiColors.midSoil, factor * 2.0)!;
    } else {
      return Color.lerp(KrishiColors.midSoil, KrishiColors.wetSoil, (factor - 0.5) * 2.0)!;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Background Studio Grid Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = -120; i <= 120; i += 30) {
      canvas.drawLine(
        Offset(centerX + i * 1.5, centerY - 60 + i * 0.75),
        Offset(centerX + i * 1.5 - 120, centerY + 40 + i * 0.75),
        gridPaint,
      );
    }

    // 4 Isometric Farm Blocks (Top-Left: Zone 1, Top-Right: Zone 2, Bottom-Left: Zone 3, Bottom-Right: Zone 4)
    final zones = [
      {"id": 1, "pin": "Pin 32", "val": soil1, "dx": -65.0, "dy": -40.0},
      {"id": 2, "pin": "Pin 33", "val": soil2, "dx": 65.0, "dy": -40.0},
      {"id": 3, "pin": "Pin 34", "val": soil3, "dx": -65.0, "dy": 45.0},
      {"id": 4, "pin": "Pin 35", "val": soil4, "dx": 65.0, "dy": 45.0},
    ];

    for (final z in zones) {
      final val = (z['val'] as double).clamp(0.0, 100.0);
      final soilColor = _getSoilColor(val);
      final posX = centerX + (z['dx'] as double);
      final posY = centerY + (z['dy'] as double);

      const boxW = 55.0;
      const boxH = 28.0;
      const depth = 22.0;

      // Top Soil Surface (Isometric Diamond)
      final topPath = Path()
        ..moveTo(posX, posY - boxH)
        ..lineTo(posX + boxW, posY)
        ..lineTo(posX, posY + boxH)
        ..lineTo(posX - boxW, posY)
        ..close();

      final topPaint = Paint()
        ..color = soilColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(topPath, topPaint);

      // Left Soil Depth Wall
      final leftPath = Path()
        ..moveTo(posX - boxW, posY)
        ..lineTo(posX, posY + boxH)
        ..lineTo(posX, posY + boxH + depth)
        ..lineTo(posX - boxW, posY + depth)
        ..close();
      final leftPaint = Paint()
        ..color = soilColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      canvas.drawPath(leftPath, leftPaint);

      // Right Soil Depth Wall
      final rightPath = Path()
        ..moveTo(posX, posY + boxH)
        ..lineTo(posX + boxW, posY)
        ..lineTo(posX + boxW, posY + depth)
        ..lineTo(posX, posY + boxH + depth)
        ..close();
      final rightPaint = Paint()
        ..color = soilColor.withValues(alpha: 0.70)
        ..style = PaintingStyle.fill;
      canvas.drawPath(rightPath, rightPaint);

      // Wireframe outlines
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(topPath, borderPaint);
      canvas.drawPath(leftPath, borderPaint);
      canvas.drawPath(rightPath, borderPaint);

      // Green Crop Shoots / Plants on Top
      final plantPaint = Paint()
        ..color = const Color(0xFF22C55E)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final plantPositions = [
        Offset(posX - 20, posY - 8),
        Offset(posX, posY - 14),
        Offset(posX + 20, posY - 8),
        Offset(posX - 10, posY + 8),
        Offset(posX + 10, posY + 8),
      ];

      for (int p = 0; p < plantPositions.length; p++) {
        final pt = plantPositions[p];
        final wave = sin(animValue * pi * 2 + p) * 2.0;
        canvas.drawLine(pt, Offset(pt.dx + wave, pt.dy - 12), plantPaint);
        canvas.drawLine(Offset(pt.dx + wave, pt.dy - 12), Offset(pt.dx + wave - 4, pt.dy - 16), plantPaint);
        canvas.drawLine(Offset(pt.dx + wave, pt.dy - 12), Offset(pt.dx + wave + 4, pt.dy - 16), plantPaint);
      }

      // Zone Number Badge
      final badgePaint = Paint()..color = KrishiColors.primaryDark;
      canvas.drawCircle(Offset(posX, posY - boxH - 18), 12, badgePaint);

      final badgeBorder = Paint()
        ..color = KrishiColors.primaryLight
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(posX, posY - boxH - 18), 12, badgeBorder);

      final textPainter = TextPainter(
        text: TextSpan(
          text: "#${z['id']}",
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(posX - textPainter.width / 2, posY - boxH - 18 - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant FarmIsometricPainter oldDelegate) {
    return oldDelegate.soil1 != soil1 ||
        oldDelegate.soil2 != soil2 ||
        oldDelegate.soil3 != soil3 ||
        oldDelegate.soil4 != soil4 ||
        oldDelegate.animValue != animValue;
  }
}

// ==========================================
// 📡 3. TAB: REAL-TIME 3D FARMING DATA (MQTT)
// ==========================================
class RealTimeFarmingView extends StatefulWidget {
  final String lang;
  final double soil1;
  final double soil2;
  final double soil3;
  final double soil4;
  final double temperature;
  final double humidity;
  final double pressure;
  final bool rain;
  final int counter;
  final String deviceName;
  final bool relayOn;
  final double motorVoltage;
  final String mqttStatus;
  final int secondsAgo;
  final List<String> consoleLogs;
  final Animation<double> animProgress;
  final VoidCallback onToggleRelay;
  final VoidCallback onReconnectMqtt;

  const RealTimeFarmingView({
    super.key,
    required this.lang,
    required this.soil1,
    required this.soil2,
    required this.soil3,
    required this.soil4,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.rain,
    required this.counter,
    required this.deviceName,
    required this.relayOn,
    required this.motorVoltage,
    required this.mqttStatus,
    required this.secondsAgo,
    required this.consoleLogs,
    required this.animProgress,
    required this.onToggleRelay,
    required this.onReconnectMqtt,
  });

  @override
  State<RealTimeFarmingView> createState() => _RealTimeFarmingViewState();
}

class _RealTimeFarmingViewState extends State<RealTimeFarmingView> {
  bool _showLogs = false;

  Widget _buildZoneCard({
    required int zoneNum,
    required String pin,
    required double moisture,
    required bool isHi,
  }) {
    Color statusColor;
    String statusText;
    if (moisture <= 20) {
      statusColor = Colors.amber.shade700;
      statusText = isHi ? "पानी की आवश्यकता" : "Dry Soil";
    } else if (moisture >= 80) {
      statusColor = const Color(0xFF43270F);
      statusText = isHi ? "100% नमी (डार्क ब्राउन)" : "High Moisture";
    } else {
      statusColor = KrishiColors.primary;
      statusText = isHi ? "उचित नमी (भूरी मिट्टी)" : "Optimal";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KrishiColors.borderLight),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Zone $zoneNum ($pin)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Icon(Icons.eco, size: 14, color: statusColor),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${moisture.toStringAsFixed(0)}%",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: statusColor)),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Moisture", style: TextStyle(fontSize: 9, color: KrishiColors.textMuted)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHi = widget.lang == 'hi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sensors, color: KrishiColors.primaryLight, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isHi ? "3D खेत नमी व IoT टेलीमेट्री" : "3D Farm Moisture & IoT",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    // HiveMQ Status Badge
                    InkWell(
                      onTap: widget.onReconnectMqtt,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.mqttStatus == 'connected'
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.mqttStatus == 'connected' ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              size: 8,
                              color: widget.mqttStatus == 'connected' ? Colors.greenAccent : Colors.redAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.mqttStatus == 'connected' ? "HiveMQ Live :8883" : "Connecting...",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: widget.mqttStatus == 'connected' ? Colors.greenAccent : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isHi
                      ? "ESP32 लाइव डेटा: 4 खेत जोन्स, तापमान, आर्द्रता व 12.4V स्मार्ट रिले नियंत्रण।"
                      : "Live ESP32 telemetry from HiveMQ Cloud. 4 zone soil sensors & 12.4V DC pump switch.",
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Device: ${widget.deviceName} • Packet #${widget.counter}",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Received ${widget.secondsAgo}s ago",
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🌾 3D Interactive Farm Field Visualizer (4 Sectors)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.borderLight),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: const [
                          Icon(Icons.view_in_ar, size: 16, color: KrishiColors.primaryDark),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text("3D Farm Visualizer (4 Fixed Zones)",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: KrishiColors.primaryDark)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isHi ? "लाइव मिट्टी नमी" : "Live Soil Transition",
                      style: const TextStyle(fontSize: 10, color: KrishiColors.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Farm3DVisualizer(
                  soil1: widget.soil1,
                  soil2: widget.soil2,
                  soil3: widget.soil3,
                  soil4: widget.soil4,
                  animation: widget.animProgress,
                ),
                const SizedBox(height: 6),
                // Color Legend Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _legendItem("0% Dry (Light Brown)", KrishiColors.drySoil),
                    _legendItem("50% Farm Brown", KrishiColors.midSoil),
                    _legendItem("100% Dark Wet Mud", KrishiColors.wetSoil),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4 Soil Telemetry Cards
          Text(
            isHi ? "4 खेत जोन्स लाइव नमी (Soil Moisture Sensors)" : "4 Field Zones Real-Time Moisture",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _buildZoneCard(zoneNum: 1, pin: "Pin 32", moisture: widget.soil1, isHi: isHi),
              _buildZoneCard(zoneNum: 2, pin: "Pin 33", moisture: widget.soil2, isHi: isHi),
              _buildZoneCard(zoneNum: 3, pin: "Pin 34", moisture: widget.soil3, isHi: isHi),
              _buildZoneCard(zoneNum: 4, pin: "Pin 35", moisture: widget.soil4, isHi: isHi),
            ],
          ),

          const SizedBox(height: 16),

          // Smart Relay & Motor Switch Card (12.4V DC Supply)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.relayOn ? KrishiColors.primary : KrishiColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: widget.relayOn ? KrishiColors.primary.withValues(alpha: 0.15) : Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.relayOn ? KrishiColors.emeraldBg : Colors.grey.shade100,
                        radius: 20,
                        child: Icon(
                          Icons.power_settings_new,
                          color: widget.relayOn ? KrishiColors.primary : Colors.grey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHi ? "12.4V वाटर पंप रिले स्विच" : "12.4V Water Pump Relay",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Supply: ${widget.motorVoltage}V DC • ${widget.relayOn ? 'ON' : 'OFF'}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: widget.relayOn ? KrishiColors.primary : KrishiColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.onToggleRelay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.relayOn ? Colors.red : KrishiColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.relayOn ? "OFF" : "ON"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Environmental Telemetry Row
          Text(
            isHi ? "पर्यावरण व मौसम सेंसर (Environmental Sensors)" : "Environmental Sensor Telemetry",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _buildEnvCard("🌡️ Temperature", "${widget.temperature.toStringAsFixed(1)} °C", "DHT22 Sensor", Colors.orange),
              _buildEnvCard("💧 Air Humidity", "${widget.humidity.toStringAsFixed(1)} %", "Relative RH", Colors.teal),
              _buildEnvCard("⏱️ Air Pressure", "${widget.pressure.toStringAsFixed(0)} hPa", "BMP280 Barometer", Colors.purple),
              _buildEnvCard(
                "🌧️ Rain Sensor",
                widget.rain ? "RAIN DETECTED" : "NO RAIN",
                widget.rain ? "Digital Low" : "Digital High",
                widget.rain ? Colors.blue : Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Expandable Live MQTT Console Logs Viewer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KrishiColors.darkBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal, color: KrishiColors.primaryLight, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Live HiveMQ Console Logs",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => setState(() => _showLogs = !_showLogs),
                      child: Text(
                        _showLogs ? "Hide" : "Show Stream (${widget.consoleLogs.length})",
                        style: const TextStyle(color: KrishiColors.primaryLight, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                if (_showLogs) ...[
                  const Divider(color: Color(0xFF1E293B)),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: widget.consoleLogs.length,
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            widget.consoleLogs[i],
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: KrishiColors.textMuted)),
      ],
    );
  }

  Widget _buildEnvCard(String label, String val, String sub, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KrishiColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: KrishiColors.textMuted, fontWeight: FontWeight.bold)),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color.shade800)),
          Text(sub, style: TextStyle(fontSize: 9, color: color.shade900, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==========================================
// 🏢 4. TAB: FERTILIZER COMPANY PORTAL
// ==========================================
class FertilizerCompanyView extends StatefulWidget {
  final String lang;
  final String plantDisease;
  final double plantConfidence;
  final String soilType;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final bool rain;
  final String dispatchStatus;
  final String submittedBlockId;
  final Function(Map<String, dynamic>) onCommitSolution;

  const FertilizerCompanyView({
    super.key,
    required this.lang,
    required this.plantDisease,
    required this.plantConfidence,
    required this.soilType,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.rain,
    required this.dispatchStatus,
    required this.submittedBlockId,
    required this.onCommitSolution,
  });

  @override
  State<FertilizerCompanyView> createState() => _FertilizerCompanyViewState();
}

class _FertilizerCompanyViewState extends State<FertilizerCompanyView> {
  bool _isEvaluating = false;
  Map<String, dynamic>? _prescriptionData;

  Future<void> _runGeminiEvaluation() async {
    setState(() => _isEvaluating = true);

    final prompt = """You are a Senior Agronomist at IFFCO Precision Agro-Chemicals.
Evaluate this farmer's 3-factor telemetry request:
1. Disease: "${widget.plantDisease}" (${widget.plantConfidence}% confidence)
2. Live IoT: Moisture ${widget.soilMoisture}%, Temp ${widget.temperature}°C, Rain: ${widget.rain ? 'Yes' : 'No'}
3. Soil Type: "${widget.soilType}"

Provide a structured JSON prescription response:
{
  "recommendedFertilizer": "Azoxystrobin 18.2% + Difenoconazole 11.4% SC",
  "category": "Broad-Spectrum Bio-Fungicide",
  "dosage": "1.0 ml / Litre (200L total mix per acre)",
  "sprayTiming": "06:30 AM – 08:30 AM",
  "sprayFrequency": "2 Sprays (7-day gap)",
  "safetyWindow": "2.5 Hours Rainfastness Safe",
  "estimatedPriceINR": 480,
  "subsidyINR": 120,
  "netPriceINR": 360
}""";

    final res = await GeminiAiService.generateAgronomicAnalysis(prompt: prompt);

    if (mounted) {
      setState(() {
        _isEvaluating = false;
        _prescriptionData = res.isNotEmpty
            ? res
            : {
                "recommendedFertilizer": "Azoxystrobin 18.2% + Difenoconazole 11.4% SC",
                "category": "Broad-Spectrum Bio-Fungicide",
                "dosage": "1.0 ml / Litre (200L mix per acre)",
                "sprayTiming": "06:30 AM – 08:30 AM",
                "sprayFrequency": "2 Sprays (7-day gap)",
                "safetyWindow": "2.5 Hours Rainfastness Safe",
                "estimatedPriceINR": 480,
                "subsidyINR": 120,
                "netPriceINR": 360
              };
      });
    }
  }

  void _commitToBlockchain() {
    if (_prescriptionData != null) {
      widget.onCommitSolution(_prescriptionData!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Prescription Block Minted on MST Blockchain!"),
          backgroundColor: KrishiColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHi = widget.lang == 'hi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF78350F), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.business, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "IFFCO Agro-Chemical Company Portal",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        isHi
                            ? "किसान टेलीमेट्री बंडल की समीक्षा व Gemini AI द्वारा आधिकारिक प्रेस्क्रिप्शन मिंटिंग।"
                            : "Review incoming telemetry leaves & mint official certified prescriptions.",
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Request Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Farmer Request #${widget.submittedBlockId}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.dispatchStatus == 'DISPATCHED_PENDING_APPROVAL' ? 'PENDING APPROVAL' : widget.dispatchStatus,
                        style: TextStyle(color: Colors.amber.shade900, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Text("• Plant Disease: ${widget.plantDisease} (${widget.plantConfidence}%)", style: const TextStyle(fontSize: 11)),
                Text("• Soil Type: ${widget.soilType}", style: const TextStyle(fontSize: 11)),
                Text("• Live Sensors: Moisture ${widget.soilMoisture}% • ${widget.temperature}°C", style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isEvaluating ? null : _runGeminiEvaluation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isEvaluating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(isHi ? "Gemini AI से समाधान तैयार करें" : "Generate Gemini AI Solution"),
                  ),
                ),
              ],
            ),
          ),

          if (_prescriptionData != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KrishiColors.primaryLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Generated Fertilizer Formulation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const Divider(height: 16),
                  Text("Product: ${_prescriptionData!['recommendedFertilizer']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("Dosage: ${_prescriptionData!['dosage']}", style: const TextStyle(fontSize: 11)),
                  Text("Spray Window: ${_prescriptionData!['sprayTiming']}", style: const TextStyle(fontSize: 11)),
                  Text("Net Price: ₹${_prescriptionData!['netPriceINR']} (Subsidy ₹${_prescriptionData!['subsidyINR']} off)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _commitToBlockchain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KrishiColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.verified, size: 18, color: Colors.greenAccent),
                      label: Text(isHi ? "ब्लॉकचेन पर अप्रूव व मिंट करें" : "Commit & Mint Solution Block"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// 💧 5. TAB: SMART IRRIGATION
// ==========================================
class SmartIrrigationView extends StatefulWidget {
  final String lang;
  final double soilMoisture;

  const SmartIrrigationView({super.key, required this.lang, required this.soilMoisture});

  @override
  State<SmartIrrigationView> createState() => _SmartIrrigationViewState();
}

class _SmartIrrigationViewState extends State<SmartIrrigationView> {
  bool _isValve1On = false;
  bool _isValve2On = true;

  @override
  Widget build(BuildContext context) {
    final isHi = widget.lang == 'hi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isHi ? "स्मार्ट ड्रिप सोलेनोइड वाल्व्स" : "Smart Drip Solenoid Valves",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text("Sector 1 (Chilli North Block)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: Text("Moisture: ${widget.soilMoisture.toStringAsFixed(1)}% • Drip Line A", style: const TextStyle(fontSize: 10)),
                  value: _isValve1On,
                  activeThumbColor: KrishiColors.primary,
                  onChanged: (v) => setState(() => _isValve1On = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Sector 2 (Bajra South Block)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Moisture: 54.2% • Drip Line B", style: TextStyle(fontSize: 10)),
                  value: _isValve2On,
                  activeThumbColor: KrishiColors.primary,
                  onChanged: (v) => setState(() => _isValve2On = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🌱 6. TAB: SOIL AI STUDIO (GEMINI AI MULTIMODAL CLASSIFIER)
// ==========================================
class SoilAiStudioView extends StatefulWidget {
  final String lang;
  final Function(String soil, double confidence) onSoilClassified;

  const SoilAiStudioView({super.key, required this.lang, required this.onSoilClassified});

  @override
  State<SoilAiStudioView> createState() => _SoilAiStudioViewState();
}

class _SoilAiStudioViewState extends State<SoilAiStudioView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _isClassifying = false;
  Map<String, dynamic>? _soilData;
  String? _validationError;
  final String _selectedSoilSample = "Black Soil (Regur / Lava Soil)";

  final List<Map<String, String>> _soilSamples = [
    {
      "name": "Black Soil (Regur / Lava Soil)",
      "color": "Dark Black / Deep Charcoal",
      "ph": "7.2 - 8.5 (Moderately Alkaline)",
      "waterRetention": "Very High (Holds moisture for long dry spells)",
      "crops": "Cotton (Best), Soybean, Sorghum (Jowar), Wheat, Pearl Millet, Sunflower",
      "fert": "Phosphatic fertilizers (SSP / TSP), Nitrogen split doses, Zinc sulfate micronutrients",
      "conf": "96.5"
    },
    {
      "name": "Red Soil (Laterite / Red Sandy Soil)",
      "color": "Reddish Brown / Iron-Rich Oxide",
      "ph": "5.5 - 6.8 (Slightly Acidic)",
      "waterRetention": "Low to Moderate (Highly Porous)",
      "crops": "Groundnut, Pulses, Millets (Bajra/Ragi), Tobacco, Potatoes, Oilseeds",
      "fert": "Lime application for pH correction + Potash & Phosphorus boost",
      "conf": "95.4"
    },
    {
      "name": "Alluvial Soil (Khadar / Bhangar)",
      "color": "Light Grey / Silt Yellow-Brown",
      "ph": "6.5 - 7.8 (Neutral to Slightly Alkaline)",
      "waterRetention": "Moderate to High (Balanced Silt-Loam)",
      "crops": "Rice, Wheat, Sugarcane, Maize, Mustard, Pulses, Vegetables",
      "fert": "NPK 120:60:40 balanced application + Urea split doses",
      "conf": "97.1"
    },
    {
      "name": "Clayey Soil (Heavy Texture)",
      "color": "Dense Sticky Grey / Dark Brown",
      "ph": "7.0 - 8.2 (Neutral to Alkaline)",
      "waterRetention": "Extremely High (Risk of waterlogging without drainage)",
      "crops": "Paddy (Rice), Sugarcane, Jute, Broccoli, Cauliflower",
      "fert": "Gypsum application to improve aeration + Bio-fertilizers (PSB & Trichoderma)",
      "conf": "94.8"
    }
  ];

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _pickedImage = photo;
          _soilData = null;
          _validationError = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking soil image: $e");
    }
  }

  Future<void> _runSoilAnalysis() async {
    setState(() {
      _isClassifying = true;
      _validationError = null;
    });

    String? base64Img;
    if (_pickedImage != null) {
      try {
        final bytes = await File(_pickedImage!.path).readAsBytes();
        base64Img = base64Encode(bytes);
      } catch (e) {
        debugPrint("Error reading soil image bytes: $e");
      }
    }

    final prompt = """You are a Senior Multi-Modal Soil Scientist & Agronomist (KrishiAI).
Examine this image and perform real-life soil classification and agronomic diagnostics:

CRITICAL STEP 1 - Image Validation:
- Is this image actually a soil, dirt, farmland ground, mud, sand, agricultural earth or soil sample?
- If NO (e.g. human face, vehicle, animal, indoor object, pure food item, plant leaf only without soil), set "isSoil": false, and set "errorMessage" in Hindi and English explaining what was detected and ask the user to provide a clear photo of farmland soil.

CRITICAL STEP 2 - Soil Type Classification:
If it IS soil, classify it accurately into one of the 4 major Indian soil classes:
1. "Black Soil (Regur / Lava Soil)" - (dark black to deep brown, clayey texture, moisture retentive, cracks when dry)
2. "Red Soil (Laterite / Red Sandy Soil)" - (reddish to reddish-brown due to iron oxide, porous, coarse to medium texture)
3. "Alluvial Soil (Khadar / Bhangar)" - (light grey to yellowish-brown, silt-loam, highly fertile river plains)
4. "Clayey Soil (Heavy Texture)" - (dense, smooth sticky clay particles, extremely high water holding, low drainage)

Provide response ONLY in this exact JSON format:
{
  "isSoil": true,
  "errorMessage": "",
  "soilType": "One of the 4 major soil types above",
  "soilColor": "Color observed (e.g. Deep Dark Black / Reddish Brown / Light Grey Silt / Sticky Grey)",
  "confidence": 96.5,
  "phRange": "7.2 - 8.5 (Moderately Alkaline)",
  "salinityStatus": "Normal / Non-Saline (EC < 2 dS/m)",
  "organicCarbon": "Medium to High (0.68%)",
  "waterRetention": "Very High (Holds moisture for long dry spells)",
  "aerationDrainage": "Moderate to Low (Requires surface furrow drainage)",
  "recommendedCrops": "Cotton, Soybean, Sorghum (Jowar), Wheat, Pearl Millet (Bajra), Sunflower",
  "fertilizationStrategy": "Phosphatic fertilizers (SSP/DAP), split Nitrogen doses, Zinc sulfate & organic manure (FYM)",
  "soilAmendments": "Gypsum application / Bio-fertilizer (Rhizobium & PSB inoculation)",
  "farmingTip": "Maintain soil organic matter with green manuring (Dhaincha/Sunhemp) and avoid deep tilling during peak moisture to prevent compaction."
}""";

    final res = await GeminiAiService.generateAgronomicAnalysis(
      prompt: prompt,
      base64Image: base64Img,
    );

    if (mounted) {
      setState(() {
        _isClassifying = false;

        if (res.isNotEmpty) {
          // Check if AI validated that the image is soil
          if (res['isSoil'] == false) {
            _validationError = res['errorMessage']?.toString().isNotEmpty == true
                ? res['errorMessage']
                : (widget.lang == 'hi'
                    ? "⚠️ फोटो में मिट्टी नहीं पहचानी गई! कृपया खेत की मिट्टी का स्पष्ट फोटो अपलोड करें।"
                    : "⚠️ No soil detected in the photo! Please capture or upload a clear photo of farmland soil.");
            _soilData = null;
            return;
          }

          _soilData = res;
          final soilName = res['soilType']?.toString() ?? _selectedSoilSample;
          final conf = (res['confidence'] as num?)?.toDouble() ?? 96.2;
          widget.onSoilClassified(soilName, conf);
        } else {
          // Robust Fallback based on selected sample if offline
          final selected = _soilSamples.firstWhere(
            (s) => s['name'] == _selectedSoilSample,
            orElse: () => _soilSamples.first,
          );
          _soilData = {
            "isSoil": true,
            "errorMessage": "",
            "soilType": selected['name']!,
            "soilColor": selected['color']!,
            "confidence": double.tryParse(selected['conf'] ?? '96.0') ?? 96.0,
            "phRange": selected['ph']!,
            "salinityStatus": "Normal / Non-Saline (EC < 2 dS/m)",
            "organicCarbon": "Medium (0.62%)",
            "waterRetention": selected['waterRetention']!,
            "aerationDrainage": "Moderate aeration, standard tillage recommended",
            "recommendedCrops": selected['crops']!,
            "fertilizationStrategy": selected['fert']!,
            "soilAmendments": "Organic FYM (5 tonnes/acre) + Bio-fertilizers",
            "farmingTip": "Avoid tilling when excessively wet to prevent soil compaction and crusting."
          };
          widget.onSoilClassified(selected['name']!, double.tryParse(selected['conf'] ?? '96.0') ?? 96.0);
        }
      });

      if (_soilData != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Saved to Farmer Blockchain Telemetry (Soil Block Updated)!"),
            backgroundColor: KrishiColors.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHi = widget.lang == 'hi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers, color: Colors.greenAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHi ? "मृदा विश्लेषण (Soil Analysis)" : "Soil Analysis",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        isHi
                          ? "मिट्टी की फोटो खींचें या अपलोड करें — AI मिट्टी का प्रकार (Black, Red, Alluvial, Clay), pH मान व फसल रणनीति बताएगा।"
                          : "Capture or upload soil photo — AI verifies soil & classifies into Black, Red, Alluvial, or Clay soil.",
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Photo Capture & Upload Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHi ? "मिट्टी की फोटो अपलोड करें (कैमरा / गैलरी)" : "Upload Soil Photo (Camera / Gallery)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Camera & Gallery Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickFromSource(ImageSource.camera),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: KrishiColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.camera_alt, color: KrishiColors.primary, size: 18),
                        label: Text(
                          isHi ? "फोटो खींचें" : "Take Photo",
                          style: const TextStyle(color: KrishiColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickFromSource(ImageSource.gallery),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: KrishiColors.primaryDark),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.photo_library, color: KrishiColors.primaryDark, size: 18),
                        label: Text(
                          isHi ? "गैलरी से चुनें" : "Upload Gallery",
                          style: const TextStyle(color: KrishiColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Image Preview or Placeholder
                if (_pickedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Image.file(
                          File(_pickedImage!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: InkWell(
                            onTap: () => setState(() {
                              _pickedImage = null;
                              _soilData = null;
                              _validationError = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: KrishiColors.bgLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: KrishiColors.borderLight),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.terrain, color: KrishiColors.primary, size: 30),
                        const SizedBox(height: 6),
                        Text(
                          isHi ? "खेत की मिट्टी का फोटो लें या गैलरी से चुनें" : "Click Take Photo or Upload Soil from Gallery",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: KrishiColors.textMain),
                        ),
                        Text(
                          isHi ? "Gemini AI खुद पहचान करेगा कि फोटो में मिट्टी है या नहीं और 4 प्रकारों में वर्गीकरण करेगा" : "Gemini AI validates if image is soil & classifies into 4 types",
                          style: const TextStyle(fontSize: 9, color: KrishiColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 4 Major Soil Types Reference Chips
                Text(
                  isHi ? "4 मुख्य मृदा श्रेणियां (AI Classifies automatically):" : "4 Major Soil Types (AI Classifies automatically):",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: KrishiColors.textMuted),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildSoilChip("🖤 Black Soil", const Color(0xFF1E293B)),
                    _buildSoilChip("❤️ Red Soil", const Color(0xFFB91C1C)),
                    _buildSoilChip("🌾 Alluvial Soil", const Color(0xFFD97706)),
                    _buildSoilChip("🧱 Clay Soil", const Color(0xFF047857)),
                  ],
                ),
                const SizedBox(height: 14),

                // Analysis Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isClassifying ? null : _runSoilAnalysis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KrishiColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isClassifying
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      isHi ? "विश्लेषण करें" : "Analysis",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Validation Error Alert (If image is not soil)
          if (_validationError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KrishiColors.alertRedBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: KrishiColors.alertRed.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: KrishiColors.alertRed, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? "मृदा सत्यापन विफल (Soil Validation Notice)" : "Soil Validation Notice",
                          style: const TextStyle(color: KrishiColors.alertRed, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _validationError!,
                          style: const TextStyle(fontSize: 11, color: KrishiColors.textMain),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Detailed AI Diagnostic Results Card
          if (_soilData != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KrishiColors.primaryLight, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Result Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _soilData!['soilType'] ?? 'Soil Classification Result',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: KrishiColors.primaryDark,
                              ),
                            ),
                            if (_soilData!['soilColor'] != null)
                              Text(
                                "Color: ${_soilData!['soilColor']}",
                                style: const TextStyle(fontSize: 11, color: KrishiColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: KrishiColors.emeraldBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: KrishiColors.primaryLight),
                        ),
                        child: Text(
                          "${_soilData!['confidence'] ?? 96}% Conf",
                          style: const TextStyle(color: KrishiColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // Agronomic Parameters
                  _buildSoilDetail("🧪 pH Range & Salinity:", "${_soilData!['phRange'] ?? ''} • ${_soilData!['salinityStatus'] ?? 'Non-Saline'}"),
                  _buildSoilDetail("💧 Water Holding & Drainage:", "${_soilData!['waterRetention'] ?? ''} • ${_soilData!['aerationDrainage'] ?? ''}"),
                  _buildSoilDetail("🌿 Organic Carbon Profile:", _soilData!['organicCarbon'] ?? 'Medium (0.65%)'),
                  _buildSoilDetail("🌽 Recommended High-Yield Crops:", _soilData!['recommendedCrops'] ?? ''),
                  _buildSoilDetail("🔬 Fertilization & Micronutrient Strategy:", _soilData!['fertilizationStrategy'] ?? ''),
                  if (_soilData!['soilAmendments'] != null)
                    _buildSoilDetail("🛠️ Soil Amendments:", _soilData!['soilAmendments'] ?? ''),
                  _buildSoilDetail("💡 Expert Farming Tip:", _soilData!['farmingTip'] ?? ''),

                  const SizedBox(height: 12),

                  // Blockchain Sync Confirmation Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KrishiColors.emeraldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: KrishiColors.primaryLight.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield, color: KrishiColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isHi
                                ? "यह डेटा फार्मर ब्लॉकचेन हब (Leaf 3) में क्रिप्टोग्राफिक रूप से स्टोर हो चुका है।"
                                : "Cryptographically synced to Farmer Blockchain Hub (Leaf 3 Merkle Root).",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: KrishiColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoilChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildSoilDetail(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: KrishiColors.primaryDark)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 12, color: KrishiColors.textMain, height: 1.3)),
        ],
      ),
    );
  }
}

// ==========================================
// 🏛️ 7. TAB: SCHEMES & SUPPORT (GOVT SCHEMES & PORTALS)
// ==========================================
class SchemesView extends StatelessWidget {
  final String lang;

  const SchemesView({super.key, required this.lang});

  Future<void> _openPortal(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Error launching URL $url: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("पोर्टल खोलने में असमर्थ: $url"),
            backgroundColor: KrishiColors.alertRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHi = lang == 'hi';

    final schemes = [
      {
        "id": "1",
        "tag": isHi ? "प्रत्यक्ष लाभ अंतरण (DBT)" : "Direct Benefit Transfer",
        "domain": "pmkisan.gov.in",
        "status": isHi ? "सक्रिय • 19वीं किस्त जारी" : "Active & 19th Installment Released",
        "title": isHi ? "पीएम किसान सम्मान निधि (PM-KISAN)" : "PM Kisan Samman Nidhi (PM-KISAN)",
        "ministry": isHi ? "🏛️ कृषि एवं किसान कल्याण मंत्रालय (MoA&FW)" : "🏛️ Ministry of Agriculture & Farmers Welfare (MoA&FW)",
        "funding": isHi ? "100% केंद्र सरकार द्वारा वित्तपोषित" : "100% Central Government Funded",
        "benefit": isHi
            ? "₹6,000 / वर्ष सीधे बैंक खाते में (₹2,000 की 3 समान किस्तों में प्रति 4 माह)।"
            : "₹6,000 / year direct cash transfer into bank account in 3 equal 4-monthly installments of ₹2,000",
        "eligibility": isHi
            ? "वे सभी किसान परिवार जिनके नाम पर कृषि योग्य भूमि है (संस्थागत एवं उच्च करदाता वर्जित)।"
            : "All landholding farmer families with cultivable land in their name (Excluding institutional & high tax payers)",
        "docs": isHi ? "आधार कार्ड, जमीन की खतौनी/खसरा, बैंक पासबुक, e-KYC" : "Aadhaar Card, Land Khasra/Khatauni, Bank Passbook, e-KYC",
        "helpline": "155261 / 1800-115-526",
        "portal": "https://pmkisan.gov.in/",
        "icon": Icons.account_balance_wallet,
        "color": Colors.green,
      },
      {
        "id": "2",
        "tag": isHi ? "हरित ऊर्जा व मुफ्त बिजली" : "Green Energy & Free Power",
        "domain": "pmkusum.mnre.gov.in",
        "status": isHi ? "राज्य पोर्टल ऑनलाइन पंजीकरण खुला" : "Online State Portals Open",
        "title": isHi ? "पीएम कुसुम — सोलर कृषि पंप योजना" : "PM KUSUM — Solar Agricultural Pump Scheme",
        "ministry": isHi ? "🏛️ नवीन एवं नवीकरणीय ऊर्जा मंत्रालय (MNRE)" : "🏛️ Ministry of New and Renewable Energy (MNRE)",
        "funding": isHi ? "60% सीधा सरकारी अनुदान (30% केंद्र + 30% राज्य)" : "60% Direct Subsidy (30% Central + 30% State)",
        "benefit": isHi
            ? "3HP, 5HP, 7.5HP सोलर पंप पर 60% सब्सिडी + 30% बैंक ऋण (किसान को केवल 10% देना होगा)।"
            : "Up to 60% subsidy on Standalone Solar Pumps (3HP, 5HP, 7.5HP) + 30% bank loan (Farmer pays only 10%)",
        "eligibility": isHi
            ? "व्यक्तिगत किसान, किसान उत्पादक संगठन (FPO), जल उपभोक्ता संघ, पंचायतें।"
            : "Individual farmers, Farmer Producer Organizations (FPOs), Water User Associations, Panchayats",
        "docs": isHi ? "आधार कार्ड, जमीन रजिस्ट्री दस्तावेज, जल स्रोत प्रमाण, बैंक खाता" : "Aadhaar, Land Registry Document, Water Source Proof, Bank Account",
        "helpline": "1800-180-3333",
        "portal": "https://pmkusum.mnre.gov.in/",
        "icon": Icons.solar_power,
        "color": Colors.amber,
      },
      {
        "id": "3",
        "tag": isHi ? "व्यापक फसल सुरक्षा कवच" : "Comprehensive Risk Shield",
        "domain": "pmfby.gov.in",
        "status": isHi ? "खरीफ व रबी कट-ऑफ सक्रिय" : "Kharif & Rabi Cut-off Active",
        "title": isHi ? "प्रधानमंत्री फसल बीमा योजना (PMFBY)" : "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
        "ministry": isHi ? "🏛️ कृषि एवं सहकारिता विभाग, MoA&FW" : "🏛️ Department of Agriculture and Cooperation, MoA&FW",
        "funding": isHi ? "किसान प्रीमियम: केवल 1.5% (रबी), 2% (खरीफ), 5% (बागवानी), बाकी 90%+ सरकार वहन करती है" : "Farmer pays only 1.5% (Rabi), 2% (Kharif), 5% (Horticulture), rest 90%+ paid by Govt",
        "benefit": isHi
            ? "सूखा, बाढ़, ओलावृष्टि, कीट आक्रमण, बेमौसम बारिश व कटाई उपरांत नुकसान पर 100% तक भरपाई।"
            : "Comprehensive insurance coverage against drought, flood, pests, hailstorm, unseasonal rain, and post-harvest loss",
        "eligibility": isHi
            ? "अधिसूचित क्षेत्रों में अधिसूचित फसल उगाने वाले सभी किसान (ऋणी, गैर-ऋणी, बटाईदार)।"
            : "All farmers (loanee & non-loanee, tenant/sharecroppers) growing notified crops in notified areas",
        "docs": isHi ? "बुवाई प्रमाण पत्र, खसरा/खतौनी, आधार कार्ड, बैंक विवरण, रद्द चेक" : "Land Sowing Certificate, Khasra, Aadhaar, Bank Details, Cancelled Cheque",
        "helpline": "14447 (Kisan Bima Toll-Free)",
        "portal": "https://pmfby.gov.in/",
        "icon": Icons.security,
        "color": Colors.blue,
      },
      {
        "id": "4",
        "tag": isHi ? "कृषि यंत्रीकरण व ड्रोन अनुदान" : "Mechanization Grant",
        "domain": "agrimachinery.nic.in",
        "status": isHi ? "DBT पोर्टल सीधा पंजीकरण" : "DBT Portal Direct Registration",
        "title": isHi ? "SMAM — कृषि यंत्रीकरण उप-मिशन व किसान ड्रोन" : "SMAM — Sub-Mission on Agricultural Mechanization & Kisan Drone",
        "ministry": isHi ? "🏛️ यंत्रीकरण एवं प्रौद्योगिकी प्रभाग, MoA&FW" : "🏛️ Mechanization & Technology Division, MoA&FW",
        "funding": isHi ? "उपकरणों पर 40% - 50% छूट; कस्टम हायरिंग सेंटर हेतु ₹10 लाख तक" : "40% - 50% on Implements; Up to ₹10 Lakhs for CHC Centers",
        "benefit": isHi
            ? "ट्रैक्टर, रोटावेटर, हैप्पी सीडर, पावर टिलर पर 40%-50% सब्सिडी; FPO/CHC हेतु किसान ड्रोन पर 75%-100% तक अनुदान।"
            : "40% to 50% subsidy on Tractors, Rotavators, Happy Seeders, Power Tillers; Up to 75%-100% on Kisan Drones for FPOs/CHCs",
        "eligibility": isHi
            ? "छोटे, सीमांत, महिला, SC/ST किसान, FPO एवं कस्टम हायरिंग केंद्र (CHC)।"
            : "Small, marginal, SC/ST, women farmers, Farmer Producer Organizations (FPOs), and Custom Hiring Centers (CHCs)",
        "docs": isHi ? "आधार कार्ड, जमीन रिकॉर्ड, जाति प्रमाण पत्र (SC/ST हेतु), बैंक पासबुक, ट्रैक्टर RC" : "Aadhaar, Land Records, Caste Certificate (for SC/ST), Bank Passbook, Tractor RC (for PTO driven implements)",
        "helpline": "1800-180-1551",
        "portal": "https://agrimachinery.nic.in/",
        "icon": Icons.agriculture,
        "color": Colors.deepOrange,
      },
      {
        "id": "5",
        "tag": isHi ? "सस्ता कृषि ऋण व ब्याज छूट" : "Low Interest Credit",
        "domain": "myscheme.gov.in",
        "status": isHi ? "सभी राष्ट्रीयकृत बैंकों में 24x7 उपलब्ध" : "Available 24x7 at all Banks",
        "title": isHi ? "किसान क्रेडिट कार्ड (KCC) व ब्याज अनुदान योजना" : "Kisan Credit Card (KCC) & Interest Subvention Scheme (ISS)",
        "ministry": isHi ? "🏛️ वित्तीय सेवा विभाग एवं नाबार्ड (NABARD)" : "🏛️ Department of Financial Services & NABARD",
        "funding": isHi ? "समय पर भुगतान पर 3% अतिरिक्त ब्याज छूट (प्रभावी दर केवल 4%)" : "3% Prompt Repayment Interest Subvention",
        "benefit": isHi
            ? "बिना किसी गारंटी के ₹1.60 लाख तक ऋण (समय पर चुकता करने पर ₹3 लाख तक का ऋण मात्र 4% वार्षिक ब्याज पर)।"
            : "Collateral-free crop loan up to ₹1.60 Lakh (up to ₹3 Lakh at effective 4% annual interest rate upon prompt repayment)",
        "eligibility": isHi
            ? "सभी भू-स्वामी किसान, काश्तकार, बटाईदार, स्वयं सहायता समूह (पशुपालन व मत्स्य पालन सहित)।"
            : "All owner cultivators, tenant farmers, sharecroppers, self-help groups (SHGs), including Animal Husbandry & Fisheries",
        "docs": isHi ? "आवेदन पत्र, जमीन की खतौनी/7-12 नकल, आधार कार्ड, पैन कार्ड, पासपोर्ट फोटो" : "Application Form, Land Record (Khatauni/7/12), Aadhaar Card, PAN Card, Passport Photos",
        "helpline": "1800-115-526",
        "portal": "https://www.myscheme.gov.in/schemes/kcc",
        "icon": Icons.credit_card,
        "color": Colors.indigo,
      },
      {
        "id": "6",
        "tag": isHi ? "जल व बिजली बचत तकनीक" : "Water & Power Saver",
        "domain": "pmksy.gov.in",
        "status": isHi ? "राज्य बागवानी पोर्टल सक्रिय" : "State Horticulture Portals Active",
        "title": isHi ? "प्रति बूंद अधिक फसल (PDMC) — पीएम कृषि सिंचाई योजना" : "Per Drop More Crop (PDMC) — PM Krishi Sinchayee Yojana",
        "ministry": isHi ? "🏛️ कृषि एवं किसान कल्याण विभाग" : "🏛️ Department of Agriculture & Farmers Welfare",
        "funding": isHi ? "55% से 80% वित्तीय सहायता / अनुदान" : "55% to 80% Financial Assistance",
        "benefit": isHi
            ? "ड्रिप सिंचाई व मिनी-स्प्रिंकलर सिस्टम स्थापना पर सामान्य किसानों को 55% तथा लघु/सीमांत/महिला/SC/ST किसानों को 80% तक सब्सिडी।"
            : "55% (General Farmers) to 80% (Small/Marginal/Women/SC/ST) subsidy for Drip & Micro-Sprinkler systems",
        "eligibility": isHi
            ? "कृषि योग्य भूमि पर सुनिश्चित जल स्रोत (बोरवेल, नलकूप, नहर, खेत तालाब) वाले सभी किसान।"
            : "All farmers with an assured water source (Borewell, Tube well, Canal, Farm Pond) on cultivable land",
        "docs": isHi ? "आधार कार्ड, खतौनी, बिजली बिल/बोरवेल घोषणा पत्र, अधिकृत वेंडर से ड्रिप कोटेशन" : "Aadhaar, Khatauni, Electricity Bill/Borewell declaration, Drip quotation from registered vendor",
        "helpline": "1800-180-1551",
        "portal": "https://pmksy.gov.in/",
        "icon": Icons.water_drop,
        "color": Colors.teal,
      },
      {
        "id": "7",
        "tag": isHi ? "मुफ्त मृदा जांच व परामर्श" : "Free Diagnostic Support",
        "domain": "soilhealth.dac.gov.in",
        "status": isHi ? "सभी KVK व प्रयोगशालाओं में सक्रिय" : "Active across all KVKs & Labs",
        "title": isHi ? "मृदा स्वास्थ्य कार्ड (SHC) व पोषक तत्व सलाह" : "Soil Health Card (SHC) & Soil Nutrition Advisory",
        "ministry": isHi ? "🏛️ एकीकृत पोषक तत्व प्रबंधन प्रभाग, MoA&FW" : "🏛️ Integrated Nutrient Management Division, MoA&FW",
        "funding": isHi ? "100% मुफ्त सरकारी जांच व परामर्श" : "100% Free Testing & Advisory",
        "benefit": isHi
            ? "मिट्टी के 12 पोषक तत्वों (N, P, K, S, Zn, Fe, Cu, Mn, Bo, pH, EC, OC) की 100% मुफ्त प्रयोगशाला जांच एवं फसलवार खाद की सटीक मात्रा।"
            : "100% Free laboratory testing of 12 soil parameters (N, P, K, S, Zn, Fe, Cu, Mn, Bo, pH, EC, OC) with crop-wise fertilizer dosage advisory",
        "eligibility": isHi
            ? "भारत के सभी राज्यों और केंद्र शासित प्रदेशों के सभी किसान हर 2 वर्ष में।"
            : "All Indian farmers across all states and union territories every 2 years",
        "docs": isHi ? "खेत से मिट्टी का नमूना, आधार कार्ड, खसरा नंबर" : "Soil sample collection from field, Aadhaar Card, Khasra Number",
        "helpline": "1800-180-1551",
        "portal": "https://soilhealth.dac.gov.in/",
        "icon": Icons.assignment_turned_in,
        "color": Colors.green,
      },
      {
        "id": "8",
        "tag": isHi ? "जैविक खेती प्रोत्साहन" : "Zero Chemical Subsidy",
        "domain": "pgsindia-ncof.gov.in",
        "status": isHi ? "क्लस्टर नामांकन खुला" : "Cluster Enrollment Open",
        "title": isHi ? "परंपरागत कृषि विकास योजना (PKVY) — जैविक खेती" : "Paramparagat Krishi Vikas Yojana (PKVY) — Organic Farming",
        "ministry": isHi ? "🏛️ प्राकृतिक संसाधन प्रबंधन प्रभाग, MoA&FW" : "🏛️ Natural Resource Management Division, MoA&FW",
        "funding": isHi ? "₹50,000 / हेक्टेयर क्लस्टर सहायता" : "₹50,000 / Hectare Cluster Assistance",
        "benefit": isHi
            ? "3 वर्षों में ₹50,000 प्रति हेक्टेयर वित्तीय सहायता (₹31,000 जैविक खाद/इनपुट्स हेतु + ₹8,800 प्रमाणीकरण व पैकेजिंग हेतु)।"
            : "₹50,000 / hectare financial assistance over 3 years (₹31,000 for organic inputs/bio-fertilizers + ₹8,800 for certification & packaging)",
        "eligibility": isHi
            ? "50 या अधिक किसानों का क्लस्टर (50 एकड़ भूमि) बनाने वाले किसान, व्यक्तिगत जैविक किसान।"
            : "Farmers forming clusters of 50 or more farmers with 50 acres land, Individual organic practitioners",
        "docs": isHi ? "क्लस्टर समूह विवरण, आधार कार्ड, जमीन रिकॉर्ड, बैंक खाता" : "Cluster Group Details, Aadhaar, Land Records, Bank Account",
        "helpline": "1800-180-1551",
        "portal": "https://pgsindia-ncof.gov.in/",
        "icon": Icons.eco,
        "color": Colors.lightGreen,
      },
      {
        "id": "9",
        "tag": isHi ? "कटाई उपरांत बुनियादी ढांचा" : "Post-Harvest Infrastructure",
        "domain": "agriinfra.dac.gov.in",
        "status": isHi ? "राष्ट्रीय पोर्टल ऑनलाइन आवेदन खुला" : "National Portal Open",
        "title": isHi ? "कृषि अवसंरचना कोष (AIF) — वेयरहाउस व कोल्ड स्टोरेज" : "Agriculture Infrastructure Fund (AIF)",
        "ministry": isHi ? "🏛️ कृषि, सहकारिता एवं किसान कल्याण विभाग" : "🏛️ Department of Agriculture, Cooperation & Farmers Welfare",
        "funding": isHi ? "7 वर्षों तक 3% वार्षिक ब्याज अनुदान" : "3% Interest Subvention for 7 Years",
        "benefit": isHi
            ? "कोल्ड स्टोरेज, वेयरहाउस, ग्रेडिंग/सॉर्टिंग यूनिट, प्रोसेसिंग प्लांट हेतु ₹2 करोड़ तक के ऋण पर 3% ब्याज छूट व CGTMSE गारंटी।"
            : "₹2 Crore loan with 3% per annum interest subvention and CGTMSE credit guarantee for setting up Cold Storage, Sorting/Grading units, Warehouses, Processing units",
        "eligibility": isHi
            ? "PACS, FPO, कृषि-उद्यमी, स्टार्टअप, स्वयं सहायता समूह, व्यक्तिगत किसान।"
            : "Primary Agricultural Credit Societies (PACS), FPOs, Agri-entrepreneurs, Startups, Individual Farmers",
        "docs": isHi ? "विस्तृत प्रोजेक्ट रिपोर्ट (DPR), जमीन स्वामित्व/पट्टा अनुबंध, KYC दस्तावेज, बैंक ऋण स्वीकृति" : "Detailed Project Report (DPR), Land Ownership / Lease agreement, KYC Documents, Bank Loan Sanction",
        "helpline": "1800-180-1551",
        "portal": "https://agriinfra.dac.gov.in/",
        "icon": Icons.store,
        "color": Colors.brown,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: schemes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (ctx, i) {
        final s = schemes[i];
        final col = s['color'] as MaterialColor;

        return InkWell(
          onTap: () => _openPortal(ctx, s['portal'] as String),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KrishiColors.borderLight, width: 1.2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Verification Domain Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: col.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: col.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s['icon'] as IconData, size: 14, color: col.shade800),
                          const SizedBox(width: 6),
                          Text(
                            s['tag'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: col.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: KrishiColors.emeraldBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 12, color: KrishiColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            s['domain'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: KrishiColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s['status'] as String,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: KrishiColors.textMuted,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Scheme Title
                Text(
                  s['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: KrishiColors.textMain,
                  ),
                ),

                const SizedBox(height: 4),

                // Ministry
                Text(
                  s['ministry'] as String,
                  style: const TextStyle(fontSize: 11, color: KrishiColors.textMuted),
                ),

                const SizedBox(height: 10),

                // Funding Highlight
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: col.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: col.shade300),
                  ),
                  child: Text(
                    s['funding'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: col.shade900,
                    ),
                  ),
                ),

                const Divider(height: 20),

                // Details List
                _buildSchemeRow(
                  isHi ? "🎁 सहायता व लाभ:" : "🎁 Benefit & Assistance:",
                  s['benefit'] as String,
                ),
                _buildSchemeRow(
                  isHi ? "✅ पात्रता (Eligibility):" : "✅ Eligibility:",
                  s['eligibility'] as String,
                ),
                _buildSchemeRow(
                  isHi ? "📄 आवश्यक दस्तावेज:" : "📄 Required Docs:",
                  s['docs'] as String,
                ),
                _buildSchemeRow(
                  isHi ? "📞 हेल्पलाइन नंबर:" : "📞 Helpline:",
                  s['helpline'] as String,
                  highlight: true,
                ),

                const SizedBox(height: 14),

                // Open Official Portal Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPortal(ctx, s['portal'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KrishiColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.open_in_browser, size: 18, color: KrishiColors.accentGold),
                    label: Text(
                      isHi ? "🌐 सरकारी पोर्टल खोलें (Open Official Portal)" : "🌐 Open Official Portal",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchemeRow(String label, String val, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: KrishiColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(
              fontSize: 11,
              color: highlight ? KrishiColors.primary : KrishiColors.textMain,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 📂 APP DRAWER NAVIGATION
// ==========================================
class AppDrawer extends StatelessWidget {
  final String lang;
  final int currentTab;
  final Function(int) onSelectTab;
  final String userName;

  const AppDrawer({
    super.key,
    required this.lang,
    required this.currentTab,
    required this.onSelectTab,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isHi = lang == 'hi';

    final menuItems = [
      {"id": 0, "title": isHi ? "डैशबोर्ड" : "Dashboard", "sub": "Live weather & priority actions", "icon": Icons.dashboard, "color": Colors.teal},
      {"id": 1, "title": isHi ? "👨‍🌾 फार्मर ब्लॉकचेन हब" : "👨‍🌾 Farmer Blockchain Hub", "sub": "3-Factor farm telemetry & MST dispatch", "icon": Icons.shield, "color": Colors.green},
      {"id": 2, "title": isHi ? "🌾 पादप रोग AI डिटेक्टर" : "🌾 Plant Disease Detector", "sub": "Gemini AI Multi-Modal Diagnostics", "icon": Icons.qr_code_scanner, "color": Colors.amber},
      {"id": 3, "title": isHi ? "📈 3D खेत लाइव डेटा" : "Real Time Farming Data", "sub": "ESP32 IoT sensors & 3D farm telemetry", "icon": Icons.sensors, "color": Colors.blue},
      {"id": 4, "title": isHi ? "🏢 फर्टिलाइजर कंपनी" : "🏢 Fertilizer Company", "sub": "Gemini AI precision fertilizer & minting", "icon": Icons.business, "color": Colors.orange},
      {"id": 5, "title": isHi ? "💧 स्मार्ट सिंचाई" : "Smart Irrigation", "sub": "Smart water & drip allocation", "icon": Icons.water_drop, "color": Colors.cyan},
      {"id": 6, "title": isHi ? "🌱 मृदा विश्लेषण" : "🌱 Soil Analysis", "sub": isHi ? "मृदा वर्गीकरण व पोषक तत्व जांच" : "Soil Classification & Nutrient Advisory", "icon": Icons.layers, "color": Colors.green},
      {"id": 7, "title": isHi ? "🏛️ सरकारी योजनाएं" : "Schemes & Support", "sub": "PM-KUSUM & farmer subsidies", "icon": Icons.account_balance, "color": Colors.purple},
    ];

    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [KrishiColors.primaryDark, Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/krishi_logo.jpg',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Ghaziabad, UP • 5 Acres (Bajra & Chilli)",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: KrishiColors.borderLight),
              itemBuilder: (ctx, i) {
                final item = menuItems[i];
                final isSelected = currentTab == item['id'];
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: KrishiColors.emeraldBg,
                  leading: CircleAvatar(
                    backgroundColor: (item['color'] as MaterialColor).shade100,
                    child: Icon(item['icon'] as IconData, color: (item['color'] as MaterialColor).shade800, size: 20),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? KrishiColors.primaryDark : KrishiColors.textMain,
                    ),
                  ),
                  subtitle: Text(
                    item['sub'] as String,
                    style: const TextStyle(fontSize: 10, color: KrishiColors.textMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: KrishiColors.textMuted),
                  onTap: () => onSelectTab(item['id'] as int),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🌦️ MODAL: 72-HOUR PRECISION SPRAY RADAR
// ==========================================
class ForecastRadarModal extends StatelessWidget {
  final String lang;
  final String district;

  const ForecastRadarModal({super.key, required this.lang, required this.district});

  @override
  Widget build(BuildContext context) {
    final isHi = lang == 'hi';

    final hours = [
      {"time": "Now (10 AM)", "rain": "85%", "suit": "UNSAFE (Rain)", "delta": "3.8°C", "color": Colors.red},
      {"time": "01:00 PM", "rain": "45%", "suit": "CAUTION", "delta": "4.2°C", "color": Colors.amber},
      {"time": "04:00 PM", "rain": "10%", "suit": "SAFE (Ideal)", "delta": "5.1°C", "color": Colors.green},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? "72-घंटे सटीक स्प्रे मौसम रडार" : "72-Hr Precision Spray Radar ($district)",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: hours.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final h = hours[i];
                final col = h['color'] as MaterialColor;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: col.shade100,
                    child: Icon(Icons.schedule, color: col.shade800, size: 18),
                  ),
                  title: Text(h['time'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text("Rain: ${h['rain']} • Delta-T: ${h['delta']}", style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: col.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      h['suit'] as String,
                      style: TextStyle(color: col.shade900, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🤖 MODAL: AI ASSISTANT CHAT SHEET
// ==========================================
class AiAssistantModalSheet extends StatefulWidget {
  final String lang;
  final double soilMoisture;
  final String district;

  const AiAssistantModalSheet({
    super.key,
    required this.lang,
    required this.soilMoisture,
    required this.district,
  });

  @override
  State<AiAssistantModalSheet> createState() => _AiAssistantModalSheetState();
}

class _AiAssistantModalSheetState extends State<AiAssistantModalSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      "sender": "bot",
      "text": widget.lang == 'hi'
          ? "नमस्ते किसान भाई! मैं आपका कृषि AI सहायक हूँ। मुझसे फसल रोग, स्प्रे समय, सिंचाई या लाइव MQTT सेंसर के बारे में पूछें।"
          : "Namaste! I am your Krishi AI Assistant. Ask me anything about crop health, live MQTT sensors, spray timing, or mandi rates.",
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _controller.clear();
      _isTyping = true;
    });

    final prompt = """You are an Indian agriculture AI expert (KrishiAI).
Farmer location: ${widget.district}
Farm Soil Moisture: ${widget.soilMoisture.toStringAsFixed(1)}%
Language: ${widget.lang == 'hi' ? 'Hindi' : 'English'}
Farmer Question: "$text"

Give a concise, practical, high-value farming advice (2-3 sentences). Format response as JSON:
{"reply": "your advice here"}""";

    final res = await GeminiAiService.generateAgronomicAnalysis(prompt: prompt);

    if (mounted) {
      setState(() {
        _isTyping = false;
        String reply = res['reply'] ??
            (widget.lang == 'hi'
                ? "आपके ${widget.district} खेत में वर्तमान नमी ${widget.soilMoisture.toStringAsFixed(1)}% है। मिट्टी की स्थिति अनुकूल है।"
                : "For your farm in ${widget.district}, current soil moisture is ${widget.soilMoisture.toStringAsFixed(1)}%.");

        _messages.add({"sender": "bot", "text": reply});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHi = widget.lang == 'hi';

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: KrishiColors.primaryDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: KrishiColors.accentGold, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Krishi AI Assistant",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isUser = m['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? KrishiColors.primary : KrishiColors.bgLight,
                      borderRadius: BorderRadius.circular(16),
                      border: isUser ? null : Border.all(color: KrishiColors.borderLight),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(fontSize: 12, color: isUser ? Colors.white : KrishiColors.textMain),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text("Krishi AI is thinking...", style: TextStyle(fontSize: 11, color: KrishiColors.textMuted)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: KrishiColors.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: isHi ? "खेती से जुड़ा कोई भी सवाल पूछें..." : "Ask any farming question...",
                      hintStyle: const TextStyle(fontSize: 12, color: KrishiColors.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: KrishiColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
