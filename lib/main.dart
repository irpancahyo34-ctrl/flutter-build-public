import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

const String API_BASE = 'http://luwwyxyzstoreprivate.pteroq.xyz:2751';
const String TELEGRAM_DEV = 'https://t.me/lanzdevkrk91';
const String FOUNDER_USERNAME = 'lanzofficial';

class AppColors {
  static const bg = Color(0xFF0B0F1A);
  static const bgCard = Color(0xFF12182A);
  static const bgCard2 = Color(0xFF1A2238);
  static const glass = Color(0xCC151C2E);
  static const primary = Color(0xFF3B82F6);
  static const primaryDeep = Color(0xFF2563EB);
  static const accent = Color(0xFF60A5FA);
  static const cyan = Color(0xFF22D3EE);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
  static const textMain = Color(0xFFF1F5F9);
  static const textDim = Color(0xFF94A3B8);
  static const border = Color(0x1AFFFFFF);
  static const softIndigo = Color(0xFF818CF8);
  static const softRose = Color(0xFFFB7185);
  static const pink = Color(0xFFEC4899);
  static const purple = Color(0xFFA78BFA);
  static const premium = Color(0xFF60A5FA);
}

TextStyle _heading({
  double size = 20,
  FontWeight weight = FontWeight.w700,
  Color? color,
  double letterSpacing = -0.3,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textMain,
      letterSpacing: letterSpacing,
    );

TextStyle _body({
  double size = 14,
  FontWeight weight = FontWeight.w500,
  Color? color,
  double height = 1.4,
  double letterSpacing = 0,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textMain,
      height: height,
      letterSpacing: letterSpacing,
    );

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Matikan runtime fetching Google Fonts biar gak crash tanpa internet
  GoogleFonts.config.allowRuntimeFetching = false;

  // FIX: Global error handler biar app gak mati mendadak
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HiyukiCrash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.textMain,
          displayColor: AppColors.textMain,
        ),
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/intro': (_) => const IntroScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/pairing': (_) => const PairingScreen(),
        '/bug': (_) => const BugScreen(),
        '/notif': (_) => const NotifScreen(),
        '/chat': (_) => const ChatGlobalScreen(),
        '/tools': (_) => const ToolsScreen(),
        '/tools/tiktok': (_) => const TikTokDownloaderPage(),
        '/tools/wifi': (_) => const WifiKillerPage(),
        '/tools/nik': (_) => const NikCheckerPage(),
        '/tools/ip': (_) => const IpScannerPage(),
        '/tools/email': (_) => const EmailOsintPage(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}

/* ============================================================
 *  API
 * ============================================================ */
class Api {
  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final token = await _token();
      final res = await http
          .get(
            Uri.parse('$API_BASE$path'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final token = await _token();
      final res = await http
          .post(
            Uri.parse('$API_BASE$path'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      return _parse(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Map<String, dynamic> _parse(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      return {'data': data};
    } catch (_) {
      return {'error': 'Response tidak valid (${res.statusCode})'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) =>
      _post('/auth', {
        'username': username,
        'password': password,
        'mode': 'login',
      });

  static Future<Map<String, dynamic>> profile() => _get('/user/profile');

  static Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? avatar,
  }) =>
      _post('/user/update-profile', {
        if (displayName != null) 'displayName': displayName,
        if (avatar != null) 'avatar': avatar,
      });

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      _post('/user/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

  static Future<Map<String, dynamic>> heartbeat() =>
      _post('/user/heartbeat', {});

  static Future<Map<String, dynamic>> onlineStats() => _get('/stats/online');

  static Future<Map<String, dynamic>> mySessions() => _get('/sessions');

  static Future<Map<String, dynamic>> pairRequest(String phone,
          {bool asGlobal = false}) =>
      _post('/pair-request', {
        'phone': phone,
        'asGlobal': asGlobal,
      }, timeout: const Duration(seconds: 90));

  static Future<Map<String, dynamic>> deleteMySession(String phone) =>
      _post('/session/delete-by-phone', {'phone': phone});

  static Future<Map<String, dynamic>> logout() => _post('/session/logout', {});

  static Future<Map<String, dynamic>> bugCall(String phone, String sender) =>
      _post('/bug/call', {'phone': phone, 'sender': sender});

  static Future<Map<String, dynamic>> bugCrash(String phone, String sender) =>
      _post('/bug/crash', {'phone': phone, 'sender': sender});

  static Future<Map<String, dynamic>> bugFreeze(String phone, String sender) =>
      _post('/bug/freeze', {'phone': phone, 'sender': sender});

  static Future<Map<String, dynamic>> bugDelay(String phone, String sender) =>
      _post('/bug/delay', {'phone': phone, 'sender': sender});

  static Future<Map<String, dynamic>> bugGroup(String groupId, String sender) =>
      _post('/bug/group', {'groupId': groupId, 'sender': sender});

  static Future<Map<String, dynamic>> bugBanGroup(
          String groupId, String sender) =>
      _post('/bug/ban-group', {'groupId': groupId, 'sender': sender});

  static Future<Map<String, dynamic>> notifs() => _get('/notif');

  static Future<Map<String, dynamic>> readNotif(String id) =>
      _post('/notif/read', {'id': id});

  static Future<Map<String, dynamic>> readAllNotif() =>
      _post('/notif/read-all', {});

  static Future<Map<String, dynamic>> chatGet() => _get('/chat/global');

  static Future<Map<String, dynamic>> chatSend({
    String? text,
    String? image,
    String? replyTo,
    required String displayName,
    required String avatar,
    required String role,
  }) =>
      _post('/chat/global/send', {
        if (text != null) 'text': text,
        if (image != null) 'image': image,
        if (replyTo != null) 'replyTo': replyTo,
        'displayName': displayName,
        'avatar': avatar,
        'role': role,
      });

  static Future<Map<String, dynamic>> chatDelete(String id) =>
      _post('/chat/global/delete', {'id': id});

  static Future<Map<String, dynamic>> notifPublic() => _get('/notif/public');

  static Future<Map<String, dynamic>> tiktokDownload(String url) =>
      _post('/tools/tiktok', {'url': url},
          timeout: const Duration(seconds: 60));
}

/* ============================================================
 *  DEVICE INFO SERVICE
 * ============================================================ */
class DeviceInfoService {
  static final Battery _battery = Battery();
  static final Connectivity _connectivity = Connectivity();

  static Future<Map<String, dynamic>> getAll() async {
    final deviceInfo = DeviceInfoPlugin();
    final pkg = await PackageInfo.fromPlatform();

    int batteryLevel = 0;
    String batteryState = 'unknown';
    try {
      batteryLevel = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      batteryState = state.name;
    } catch (_) {}

    String networkType = 'Offline';
    int signalBars = 0;
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.wifi)) {
        networkType = 'Wi-Fi';
        signalBars = 4;
      } else if (results.contains(ConnectivityResult.mobile)) {
        networkType = 'Mobile';
        signalBars = 3;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        networkType = 'Ethernet';
        signalBars = 4;
      } else if (results.contains(ConnectivityResult.none) || results.isEmpty) {
        networkType = 'Offline';
        signalBars = 0;
      }
    } catch (_) {}

    String model = 'Unknown';
    String androidVersion = '-';
    int sdkInt = 0;
    double totalRamGB = 4;
    double totalStorageGB = 64;
    double freeStorageGB = 28;

    try {
      final info = await deviceInfo.androidInfo;
      model = info.model;
      androidVersion = info.version.release;
      sdkInt = info.version.sdkInt;
    } catch (_) {}

    // Total RAM default 4GB (device_info_plus 11.3.0 gak expose physicalRamSize)
    totalRamGB = 4;

    if (totalRamGB >= 8) {
      totalStorageGB = 256;
    } else if (totalRamGB >= 6) {
      totalStorageGB = 128;
    } else if (totalRamGB >= 4) {
      totalStorageGB = 64;
    } else if (totalRamGB >= 3) {
      totalStorageGB = 32;
    } else {
      totalStorageGB = 16;
    }
    freeStorageGB = totalStorageGB * 0.45;

    return {
      'battery': batteryLevel,
      'batteryState': batteryState,
      'network': networkType,
      'signalBars': signalBars,
      'model': model,
      'androidVersion': androidVersion,
      'sdkInt': sdkInt,
      'totalRamGB': totalRamGB,
      'totalStorageGB': totalStorageGB,
      'freeStorageGB': freeStorageGB,
      'appVersion': pkg.version,
      'appBuild': pkg.buildNumber,
    };
  }

  static Future<String?> getWifiName() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (var i in interfaces) {
        final name = i.name.toLowerCase();
        if (name.contains('wlan') ||
            name.contains('wifi') ||
            name.contains('ap')) {
          if (i.addresses.isNotEmpty) {
            return i.name;
          }
        }
      }
      if (interfaces.isNotEmpty) {
        return interfaces.first.name;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getWifiIP() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (var i in interfaces) {
        final name = i.name.toLowerCase();
        if (name.contains('wlan') ||
            name.contains('wifi') ||
            name.contains('ap')) {
          if (i.addresses.isNotEmpty) {
            return i.addresses.first.address;
          }
        }
      }
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

/* ============================================================
 *  WIDGETS
 * ============================================================ */
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  const AppLogo({Key? key, this.size = 72, this.showGlow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF22D3EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Center(
          child: Text(
            'H',
            style: GoogleFonts.inter(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String? base64Image;
  final double size;
  final String fallbackInitial;
  final Color? color;

  const UserAvatar({
    Key? key,
    this.base64Image,
    this.size = 40,
    this.fallbackInitial = 'U',
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        final bytes = base64Decode(base64Image!);
        return RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: size,
                height: size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _fallback(),
              ),
            ),
          ),
        );
      } catch (_) {}
    }
    return _fallback();
  }

  Widget _fallback() {
    final c = color ?? AppColors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [c, c.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Text(
          fallbackInitial.isNotEmpty
              ? fallbackInitial[0].toUpperCase()
              : 'U',
          style: GoogleFonts.inter(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  final double size;
  const VerifiedBadge({Key? key, this.size = 14}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.premium,
      ),
      child: Icon(Icons.check_rounded, size: size * 0.7, color: Colors.white),
    );
  }
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const PressableScale({
    Key? key,
    required this.child,
    this.onTap,
    this.scale = 0.94,
  }) : super(key: key);

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class ElevCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;
  final bool outline;

  const ElevCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.color,
    this.onTap,
    this.outline = true,
  }) : super(key: key);

  @override
  State<ElevCard> createState() => _ElevCardState();
}

class _ElevCardState extends State<ElevCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final base = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color ?? AppColors.glass,
        borderRadius: BorderRadius.circular(widget.radius),
        border: widget.outline
            ? Border.all(color: AppColors.border, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 22,
            offset: const Offset(0, 11),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.04),
            blurRadius: 1,
            offset: const Offset(0, -1.5),
          ),
        ],
      ),
      child: widget.child,
    );

    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: base,
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final List<Color>? colors;
  final EdgeInsets padding;
  final double radius;
  final double fontSize;
  final bool fullWidth;

  const PrimaryButton({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.colors,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.radius = 14,
    this.fontSize = 15,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final grad = widget.colors ?? const [AppColors.primary, AppColors.cyan];

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: grad,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: grad.last.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: _body(
                    size: widget.fontSize,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GlowBackground extends StatefulWidget {
  final Widget child;
  const GlowBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Container(color: AppColors.bg),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = _ctrl.value;
              return Positioned(
                top: -120 + 40 * t,
                left: -100 + 50 * t,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.primary.withOpacity(0.18),
                      Colors.transparent,
                    ]),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = _ctrl.value;
              return Positioned(
                bottom: -140 + 30 * t,
                right: -80 - 30 * t,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.softIndigo.withOpacity(0.14),
                      Colors.transparent,
                    ]),
                  ),
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

/* ============================================================
 *  SPLASH + FINGERPRINT
 * ============================================================ */
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _loadCtrl;
  late AnimationController _sheetCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _progress;
  late Animation<double> _sheetSlide;
  late Animation<double> _sheetFade;

  bool _showFingerprint = false;
  double _loadValue = 0;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack);
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progress = CurvedAnimation(parent: _loadCtrl, curve: Curves.easeInOutCubic);

    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _sheetSlide =
        CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic);
    _sheetFade = CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut);

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _loadCtrl.forward();
    });

    _loadCtrl.addListener(() {
      if (mounted) setState(() => _loadValue = _progress.value);
    });

    _loadCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showFingerprint = true);
        _sheetCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _loadCtrl.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final hasToken = prefs.getString('token') != null;
      final seenIntro = prefs.getBool('seen_intro') ?? false;
      if (hasToken) {
        Navigator.pushReplacementNamed(
          context,
          seenIntro ? '/dashboard' : '/intro',
        );
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GlowBackground(
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(size: 100),
                      const SizedBox(height: 28),
                      Text('HiyukiCrash',
                          style: _heading(size: 28, weight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Automation Core',
                          style: _body(
                              size: 13,
                              color: AppColors.textDim,
                              weight: FontWeight.w500)),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 160,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _loadValue,
                                minHeight: 4,
                                backgroundColor: AppColors.bgCard2,
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('${(_loadValue * 100).toInt()}%',
                                style: _body(
                                    size: 12,
                                    color: AppColors.textDim,
                                    weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showFingerprint)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _sheetCtrl,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        Opacity(
                          opacity: _sheetFade.value * 0.55,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(color: Colors.black),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(
                                0, (1 - _sheetSlide.value) * (h * 0.55)),
                            child: Opacity(
                              opacity: _sheetFade.value,
                              child: _FingerprintSheet(
                                height: h * 0.58,
                                onAuth: _onAuth,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FingerprintSheet extends StatefulWidget {
  final double height;
  final VoidCallback onAuth;
  const _FingerprintSheet({required this.height, required this.onAuth});

  @override
  State<_FingerprintSheet> createState() => _FingerprintSheetState();
}

class _FingerprintSheetState extends State<_FingerprintSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _progressCtrl;
  bool _scanning = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _startScan() async {
    if (_scanning || _success) return;
    setState(() => _scanning = true);
    HapticFeedback.lightImpact();
    await _progressCtrl.forward(from: 0);
    if (!mounted) return;
    setState(() => _success = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) widget.onAuth();
  }

  void _cancelScan() {
    if (_success) return;
    _progressCtrl.stop();
    _progressCtrl.reset();
    setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2238), Color(0xFF0F1524)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 40,
            offset: const Offset(0, -12),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fingerprint_rounded,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text('FINGERPRINT UNLOCK',
                        style: _body(
                            size: 10,
                            color: AppColors.primary,
                            weight: FontWeight.w800,
                            letterSpacing: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Verifikasi Identitas',
                  style: _heading(size: 22, weight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Tekan & tahan sensor sidik jari\nuntuk melanjutkan',
                textAlign: TextAlign.center,
                style: _body(size: 13, color: AppColors.textDim, height: 1.5),
              ),
              const Spacer(),
              GestureDetector(
                onTapDown: (_) => _startScan(),
                onTapUp: (_) => _cancelScan(),
                onTapCancel: () => _cancelScan(),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_pulse, _progressCtrl]),
                  builder: (context, _) {
                    final scale = 1.0 + (_pulse.value * 0.06);
                    return Transform.scale(
                      scale: scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_success
                                      ? AppColors.success
                                      : AppColors.primary)
                                  .withOpacity(0.05 + _pulse.value * 0.08),
                            ),
                          ),
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (_success
                                          ? AppColors.success
                                          : AppColors.primary)
                                      .withOpacity(0.3),
                                  AppColors.bgCard2.withOpacity(0.95),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_success
                                          ? AppColors.success
                                          : AppColors.primary)
                                      .withOpacity(
                                          0.4 + _pulse.value * 0.3),
                                  blurRadius: 32 + _pulse.value * 18,
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 24,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                              border: Border.all(
                                color: (_success
                                        ? AppColors.success
                                        : AppColors.primary)
                                    .withOpacity(0.6 + _pulse.value * 0.4),
                                width: 2.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: _scanning
                                        ? _progressCtrl.value
                                        : (_success ? 1 : 0),
                                    strokeWidth: 4,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation(
                                      _success
                                          ? AppColors.success
                                          : AppColors.primary,
                                    ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  child: Icon(
                                    _success
                                        ? Icons.check_circle_rounded
                                        : Icons.fingerprint_rounded,
                                    key: ValueKey(_success),
                                    size: 72,
                                    color: (_success
                                            ? AppColors.success
                                            : AppColors.primary)
                                        .withOpacity(
                                            0.9 + _pulse.value * 0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _success
                      ? '✓ Berhasil terverifikasi!'
                      : _scanning
                          ? 'Memverifikasi...'
                          : 'Tekan & tahan untuk scan',
                  key: ValueKey(_success ? 's' : (_scanning ? 'p' : 'i')),
                  style: _body(
                    size: 13,
                    color:
                        _success ? AppColors.success : AppColors.textDim,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
 *  LOGIN
 * ============================================================ */
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  bool _load = false;
  bool _obscure = true;

  Future<void> _auth() async {
    if (_u.text.isEmpty || _p.text.isEmpty) {
      _snack('Isi username dan password');
      return;
    }
    setState(() => _load = true);
    try {
      final res =
          await Api.login(username: _u.text.trim(), password: _p.text);
      if (!mounted) return;
      if (res['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', res['token']);
        await prefs.setString('username', res['username'] ?? _u.text);
        await prefs.setString('role', res['role'] ?? 'member');
        await prefs.setString('displayName', res['displayName'] ?? _u.text);
        await prefs.setString('avatar', res['avatar'] ?? '');
        await prefs.setBool('seen_intro', false);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/intro');
      } else {
        _snack(res['error'] ?? 'Login gagal');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: _body()),
        backgroundColor: AppColors.bgCard2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openTelegram() async {
    try {
      final uri = Uri.parse(TELEGRAM_DEV);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      _snack('Gagal buka Telegram');
    }
  }

  @override
  void dispose() {
    _u.dispose();
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, (1 - v) * 30),
                    child: child,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF151C2E), Color(0xFF1A2238)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppLogo(size: 90),
                          const SizedBox(height: 24),
                          Text('Selamat Datang',
                              style: _heading(
                                  size: 24, weight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text('Login ke dashboard HiyukiCrash',
                              style:
                                  _body(size: 13, color: AppColors.textDim)),
                          const SizedBox(height: 32),
                          _field(_u, 'Username',
                              Icons.person_outline_rounded),
                          const SizedBox(height: 14),
                          _field(
                            _p,
                            'Password',
                            Icons.lock_outline_rounded,
                            obscure: _obscure,
                            toggle: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: PrimaryButton(
                              label: 'MASUK',
                              loading: _load,
                              onPressed: _load ? null : _auth,
                              fullWidth: true,
                              padding: EdgeInsets.zero,
                              radius: 16,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: _openTelegram,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF151C2E), Color(0xFF1A2238)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF229ED9),
                                    Color(0xFF0088CC)
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF229ED9)
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.telegram,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Developer Support',
                                      style: _body(
                                          size: 11,
                                          color: AppColors.textDim,
                                          weight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('@lanzdevkrk91',
                                      style: _body(
                                          size: 15, weight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: AppColors.primary, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: _body(size: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bg.withOpacity(0.6),
        hintText: hint,
        hintStyle: _body(size: 14, color: AppColors.textDim),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textDim,
                  size: 20,
                ),
                onPressed: toggle,
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/* ============================================================
 *  INTRO
 * ============================================================ */
class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _vc;
  bool _ready = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _vc = VideoPlayerController.asset('assets/videos/intro.mp4');
      await _vc!.initialize();
      await _vc!.setLooping(true);
      await _vc!.setVolume(1.0);
      await _vc!.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_ready || _vc == null) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _vc?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _vc?.play();
    }
  }

  Future<void> _finish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_intro', true);
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready && !_error && _vc != null)
            RepaintBoundary(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _vc!.value.size.width,
                  height: _vc!.value.size.height,
                  child: VideoPlayer(_vc!),
                ),
              ),
            )
          else if (_error)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off_rounded,
                      size: 48, color: AppColors.textDim),
                  const SizedBox(height: 12),
                  Text('Video tidak ditemukan',
                      style: _body(color: AppColors.textDim)),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _finish,
                    child: Text('Lanjut ke Dashboard',
                        style: _body(color: AppColors.accent)),
                  ),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _finish,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      child: Row(
                        children: [
                          Text('Skip',
                              style: _body(
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                  size: 13)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
 *  PAIRING
 * ============================================================ */
class PairingScreen extends StatefulWidget {
  const PairingScreen({Key? key}) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen>
    with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _result;
  String? _error;
  bool _isFounder = false;
  bool _asGlobal = false;
  List<dynamic> _mySessions = [];
  bool _loadingSessions = true;

  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _checkFounder();
    _loadMySessions();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkFounder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      if (!mounted) return;
      setState(() => _isFounder = username == FOUNDER_USERNAME);
    } catch (_) {}
  }

  Future<void> _loadMySessions() async {
    if (mounted) setState(() => _loadingSessions = true);
    try {
      final res = await Api.mySessions();
      if (!mounted) return;
      setState(() {
        _mySessions = res['sessions'] ?? [];
        _loadingSessions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSessions = false);
    }
  }

  Future<void> _requestCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Nomor wajib diisi');
      return;
    }
    if (phone.length < 10) {
      setState(() => _error = 'Nomor tidak valid');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    _spinCtrl.repeat();
    try {
      final res = await Api.pairRequest(phone, asGlobal: _asGlobal);
      String? code;
      if (res['code'] != null) {
        code = res['code'].toString();
      } else if (res['data'] is Map && res['data']['code'] != null) {
        code = res['data']['code'].toString();
      } else if (res['pairingCode'] != null) {
        code = res['pairingCode'].toString();
      } else if (res['pairing_code'] != null) {
        code = res['pairing_code'].toString();
      }

      if (code != null && code.isNotEmpty) {
        setState(() => _result = code);
        _loadMySessions();
      } else {
        setState(() => _error = res['error']?.toString() ??
            res['message']?.toString() ??
            'Gagal minta code');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      _spinCtrl.stop();
      _spinCtrl.reset();
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteSession(String phone) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.bgCard2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus session?',
            style: _heading(size: 16, weight: FontWeight.w700)),
        content: Text('Session $phone akan dihapus permanen.',
            style: _body(size: 13, color: AppColors.textDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Batal', style: _body(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Hapus',
                style: _body(
                    color: AppColors.danger, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await Api.deleteMySession(phone);
      _loadMySessions();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.link_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pairing WhatsApp',
                            style: _heading(
                                size: 18, weight: FontWeight.w800)),
                        Text('Tautkan perangkat kamu',
                            style: _body(
                                size: 11, color: AppColors.textDim)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.bgCard2,
                  onRefresh: _loadMySessions,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _asGlobal
                                          ? AppColors.warning
                                              .withOpacity(0.15)
                                          : AppColors.primary
                                              .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _asGlobal
                                          ? Icons.public_rounded
                                          : Icons.qr_code_2_rounded,
                                      color: _asGlobal
                                          ? AppColors.warning
                                          : AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _asGlobal
                                              ? 'Sender Global'
                                              : 'Pairing Perangkat',
                                          style: _heading(
                                              size: 16,
                                              weight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _asGlobal
                                              ? 'Nomor untuk semua user'
                                              : 'Masukkan nomor WhatsApp aktif',
                                          style: _body(
                                              size: 12,
                                              color: AppColors.textDim),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_isFounder) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _asGlobal
                                        ? AppColors.warning
                                            .withOpacity(0.1)
                                        : AppColors.bg.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _asGlobal
                                          ? AppColors.warning
                                              .withOpacity(0.4)
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _asGlobal
                                            ? Icons.public_rounded
                                            : Icons.person_outline_rounded,
                                        color: _asGlobal
                                            ? AppColors.warning
                                            : AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _asGlobal
                                              ? 'Mode Global (khusus founder)'
                                              : 'Mode Private (hanya kamu)',
                                          style: _body(
                                            size: 12,
                                            weight: FontWeight.w700,
                                            color: _asGlobal
                                                ? AppColors.warning
                                                : AppColors.textMain,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _asGlobal,
                                        activeColor: AppColors.warning,
                                        onChanged: (v) =>
                                            setState(() => _asGlobal = v),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                enabled: !_loading,
                                style: _body(size: 16),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.bg.withOpacity(0.55),
                                  hintText: '628xxxxxxxxxx',
                                  hintStyle: _body(
                                      size: 15,
                                      color: AppColors.textDim),
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                    color: _asGlobal
                                        ? AppColors.warning
                                        : AppColors.primary,
                                    size: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: AppColors.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: _asGlobal
                                          ? AppColors.warning
                                          : AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                label: _asGlobal
                                    ? 'Minta Kode Global'
                                    : 'Minta Kode Pairing',
                                icon: _asGlobal
                                    ? Icons.public_rounded
                                    : Icons.link_rounded,
                                loading: _loading,
                                colors: _asGlobal
                                    ? const [
                                        AppColors.warning,
                                        Color(0xFFF59E0B)
                                      ]
                                    : null,
                                onPressed: _loading ? null : _requestCode,
                                fullWidth: true,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15),
                              ),
                            ],
                          ),
                        ),
                        if (_loading) ...[
                          const SizedBox(height: 28),
                          Center(
                            child: Column(
                              children: [
                                AnimatedBuilder(
                                  animation: _spinCtrl,
                                  builder: (context, _) {
                                    return Transform.rotate(
                                      angle: _spinCtrl.value * 2 * math.pi,
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: SweepGradient(
                                            colors: [
                                              AppColors.primary
                                                  .withOpacity(0),
                                              AppColors.primary,
                                              AppColors.cyan,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.4),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.bg,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.sync_rounded,
                                              color: AppColors.primary,
                                              size: 22),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text('Menunggu kode dari server...',
                                    style: _body(
                                        size: 13,
                                        color: AppColors.textDim,
                                        weight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Bisa sampai 60 detik',
                                    style: _body(
                                        size: 11, color: AppColors.textDim)),
                              ],
                            ),
                          ),
                        ],
                        if (_result != null) ...[
                          const SizedBox(height: 24),
                          ElevCard(
                            padding: const EdgeInsets.all(20),
                            color: AppColors.success.withOpacity(0.08),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.success,
                                          size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('KODE PAIRING',
                                        style: _body(
                                            size: 12,
                                            color: AppColors.success,
                                            weight: FontWeight.w800,
                                            letterSpacing: 1.5)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 22, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.bg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.success
                                          .withOpacity(0.6),
                                      width: 1.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success
                                            .withOpacity(0.2),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                  child: SelectableText(
                                    _result!,
                                    textAlign: TextAlign.center,
                                    style: _heading(
                                      size: 32,
                                      weight: FontWeight.w900,
                                      color: AppColors.success,
                                      letterSpacing: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'WhatsApp → Perangkat Tertaut → Tautkan dengan nomor telepon → masukkan kode di atas',
                                  textAlign: TextAlign.center,
                                  style: _body(
                                      size: 12,
                                      color: AppColors.textDim,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.danger.withOpacity(0.35)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppColors.danger, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(_error!,
                                      style: _body(
                                          size: 13,
                                          color: AppColors.danger)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.smartphone_rounded,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text('Session Aktif',
                                style: _heading(
                                    size: 15, weight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('${_mySessions.length}',
                                  style: _body(
                                      size: 11,
                                      color: AppColors.primary,
                                      weight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_loadingSessions)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          )
                        else if (_mySessions.isEmpty)
                          ElevCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.phonelink_erase_outlined,
                                    size: 40,
                                    color: AppColors.textDim
                                        .withOpacity(0.5)),
                                const SizedBox(height: 12),
                                Text('Belum ada session',
                                    style: _body(
                                        size: 13,
                                        color: AppColors.textDim)),
                              ],
                            ),
                          )
                        else
                          ..._mySessions.map((s) {
                            final phone = s['phone']?.toString() ?? '-';
                            final status =
                                s['status']?.toString() ?? 'offline';
                            final isGlobal = s['isGlobal'] == true;
                            final color = status == 'connected'
                                ? AppColors.success
                                : status == 'connecting'
                                    ? AppColors.warning
                                    : AppColors.textDim;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.glass,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isGlobal
                                      ? AppColors.warning
                                          .withOpacity(0.4)
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isGlobal
                                          ? Icons.public_rounded
                                          : Icons.smartphone_rounded,
                                      color: isGlobal
                                          ? AppColors.warning
                                          : color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(phone,
                                                style: _body(
                                                    size: 14,
                                                    weight:
                                                        FontWeight.w700)),
                                            if (isGlobal) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warning
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6),
                                                ),
                                                child: Text('GLOBAL',
                                                    style: _body(
                                                        size: 8,
                                                        color: AppColors
                                                            .warning,
                                                        weight: FontWeight
                                                            .w800)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(status.toUpperCase(),
                                                style: _body(
                                                    size: 10,
                                                    color: color,
                                                    weight:
                                                        FontWeight.w700)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.danger,
                                        size: 20),
                                    onPressed: () => _deleteSession(phone),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
 *  BUG SCREEN
 * ============================================================ */
class BugScreen extends StatefulWidget {
  const BugScreen({Key? key}) : super(key: key);

  @override
  State<BugScreen> createState() => _BugScreenState();
}

class _BugScreenState extends State<BugScreen>
    with TickerProviderStateMixin {
  final _targetCtrl = TextEditingController();
  bool _loading = false;
  String? _result;
  String? _selectedBug;
  String _senderType = 'private';
  String? _myRole;
  String? _myUsername;
  int _onlineUsers = 0;
  int _globalSenders = 0;
  int _myPrivateSessions = 0;
  final PageController _pageCtrl = PageController(viewportFraction: 0.78);
  int _currentPage = 0;

  late AnimationController _sendCtrl;
  bool _sendSuccess = false;

  final bugs = [
    ('Crash', Icons.warning_amber_rounded, AppColors.danger, 'crash',
        'Buat WhatsApp crash'),
    ('Freeze', Icons.ac_unit_outlined, AppColors.cyan, 'freeze',
        'Buat WhatsApp freeze'),
    ('Delay', Icons.timer_outlined, AppColors.accent, 'delay',
        'Buat pesan delay'),
    ('Call', Icons.call_outlined, AppColors.success, 'call',
        'Kirim panggilan massal'),
    ('Bug Group', Icons.group_work_outlined, AppColors.warning, 'group',
        'Kirim bug ke grup'),
    ('Ban Group', Icons.block_outlined, AppColors.danger, 'ban-group',
        'Ban grup target'),
  ];

  @override
  void initState() {
    super.initState();
    _sendCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadUser();
    _loadOnlineStats();
    _loadSenders();
  }

  @override
  void dispose() {
    _sendCtrl.dispose();
    _targetCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _myRole = prefs.getString('role') ?? 'member';
        _myUsername = prefs.getString('username') ?? '';
      });
    } catch (_) {}
  }

  Future<void> _loadOnlineStats() async {
    try {
      final res = await Api.onlineStats();
      if (!mounted) return;
      setState(() {
        _onlineUsers = res['onlineUsers'] ?? res['activeSessions'] ?? 0;
        _globalSenders = res['globalSenders'] ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _loadSenders() async {
    try {
      final res = await Api.mySessions();
      if (!mounted) return;
      final list = (res['sessions'] ?? []) as List;
      final connected = list
          .where((s) =>
              s['status'] == 'connected' && s['isGlobal'] != true)
          .length;
      setState(() => _myPrivateSessions = connected);
    } catch (_) {}
  }

  Future<void> _send() async {
    final target = _targetCtrl.text.trim();
    if (target.isEmpty) {
      setState(() => _result = 'Target wajib diisi');
      return;
    }
    if (_selectedBug == null) {
      setState(() => _result = 'Pilih jenis bug dulu');
      return;
    }
    if (_senderType == 'global' &&
        _myUsername != FOUNDER_USERNAME &&
        _myRole != 'owner') {
      setState(() => _result = 'Sender global hanya untuk founder & owner');
      return;
    }
    if (_senderType == 'private' && _myPrivateSessions == 0) {
      setState(() => _result = 'Kamu belum punya session private aktif');
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
      _sendSuccess = false;
    });
    _sendCtrl.forward(from: 0);

    try {
      final sender = _senderType;
      Map<String, dynamic> res;

      switch (_selectedBug) {
        case 'crash':
          res = await Api.bugCrash(target, sender);
          break;
        case 'freeze':
          res = await Api.bugFreeze(target, sender);
          break;
        case 'delay':
          res = await Api.bugDelay(target, sender);
          break;
        case 'call':
          res = await Api.bugCall(target, sender);
          break;
        case 'group':
          res = await Api.bugGroup(target, sender);
          break;
        case 'ban-group':
          res = await Api.bugBanGroup(target, sender);
          break;
        default:
          res = {'error': 'Bug tidak dikenal'};
      }

      final ok = res['success'] == true ||
          res['ok'] == true ||
          res['status'] == 'ok';
      setState(() {
        _result = ok
            ? 'Bug terkirim ke $target'
            : '${res['message'] ?? res['error'] ?? 'Gagal'}';
        _sendSuccess = ok;
      });
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroupBug = _selectedBug == 'group' || _selectedBug == 'ban-group';
    final canGlobal = (_myUsername == FOUNDER_USERNAME || _myRole == 'owner') &&
        _globalSenders > 0;

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSenderPicker(canGlobal),
                      const SizedBox(height: 20),
                      _buildTargetInput(isGroupBug),
                      const SizedBox(height: 20),
                      _buildBugPicker(),
                      const SizedBox(height: 24),
                      _buildSendButton(),
                      if (_result != null) ...[
                        const SizedBox(height: 18),
                        _buildResult(),
                      ],
                      const SizedBox(height: 24),
                      _buildQuoteCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.danger, AppColors.softRose],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.bug_report_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WA Bug',
                  style: _heading(size: 18, weight: FontWeight.w800)),
              Text('Kirim bug ke target',
                  style: _body(size: 11, color: AppColors.textDim)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text('$_onlineUsers ON',
                    style: _body(
                        size: 10,
                        color: AppColors.success,
                        weight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderPicker(bool canGlobal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('Pilih Sender',
                style: _body(
                    size: 13,
                    color: AppColors.textDim,
                    weight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SenderCard(
                title: 'Private',
                subtitle: _myPrivateSessions > 0
                    ? '$_myPrivateSessions aktif'
                    : 'Belum ada',
                icon: Icons.person_outline_rounded,
                color: AppColors.primary,
                selected: _senderType == 'private',
                onTap: () => setState(() => _senderType = 'private'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SenderCard(
                title: 'Global',
                subtitle: canGlobal
                    ? '$_globalSenders aktif'
                    : (_myUsername == FOUNDER_USERNAME || _myRole == 'owner'
                        ? 'Belum ada'
                        : 'Founder only'),
                icon: Icons.public_rounded,
                color: canGlobal ? AppColors.warning : AppColors.textDim,
                selected: _senderType == 'global',
                disabled: !(_myUsername == FOUNDER_USERNAME ||
                    _myRole == 'owner'),
                onTap: (_myUsername == FOUNDER_USERNAME ||
                        _myRole == 'owner')
                    ? () => setState(() => _senderType = 'global')
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetInput(bool isGroupBug) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(isGroupBug ? 'Target Grup' : 'Target Nomor',
                style: _body(
                    size: 13,
                    color: AppColors.textDim,
                    weight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _targetCtrl,
          keyboardType:
              isGroupBug ? TextInputType.text : TextInputType.phone,
          inputFormatters: isGroupBug
              ? null
              : [FilteringTextInputFormatter.digitsOnly],
          enabled: !_loading,
          style: _body(size: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bg.withOpacity(0.55),
            hintText:
                isGroupBug ? 'JID grup / Link grup' : '628xxxxxxxxxx',
            hintStyle: _body(size: 14, color: AppColors.textDim),
            prefixIcon: Icon(
              isGroupBug ? Icons.group_rounded : Icons.phone_outlined,
              color: AppColors.danger,
              size: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBugPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('Pilih Bug',
                style: _body(
                    size: 13,
                    color: AppColors.textDim,
                    weight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: bugs.length,
            itemBuilder: (context, i) {
              final b = bugs[i];
              final selected = _selectedBug == b.$4;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selected
                        ? [b.$3.withOpacity(0.4), b.$3.withOpacity(0.15)]
                        : [AppColors.bgCard2, AppColors.bgCard],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? b.$3 : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? b.$3.withOpacity(0.45)
                          : Colors.black.withOpacity(0.5),
                      blurRadius: selected ? 26 : 18,
                      offset: const Offset(0, 10),
                      spreadRadius: selected ? 1 : -3,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, -1.5),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _loading
                      ? null
                      : () => setState(() => _selectedBug = b.$4),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        right: -10,
                        child: Icon(
                          b.$2,
                          size: 90,
                          color: b.$3.withOpacity(0.14),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: b.$3.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: b.$3.withOpacity(0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: b.$3.withOpacity(0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Icon(b.$2, color: b.$3, size: 26),
                          ),
                          const Spacer(),
                          Text(b.$1,
                              style: _heading(
                                  size: 17,
                                  weight: FontWeight.w800,
                                  color: selected
                                      ? b.$3
                                      : AppColors.textMain)),
                          const SizedBox(height: 4),
                          Text(b.$5,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _body(
                                  size: 11,
                                  color: AppColors.textDim,
                                  height: 1.35)),
                        ],
                      ),
                      if (selected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: b.$3,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: b.$3.withOpacity(0.6),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bugs.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.primary
                    : AppColors.textDim.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _sendCtrl,
      builder: (context, _) {
        final isLoading = _loading;
        return GestureDetector(
          onTap: isLoading ? null : _send,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _sendSuccess
                    ? [AppColors.success, const Color(0xFF10B981)]
                    : const [AppColors.danger, AppColors.softRose],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_sendSuccess
                          ? AppColors.success
                          : AppColors.danger)
                      .withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                            value: _sendCtrl.value,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text('Mengirim...',
                            style: _body(
                                size: 15,
                                color: Colors.white,
                                weight: FontWeight.w700)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _sendSuccess
                              ? Icons.check_circle_rounded
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _sendSuccess ? 'Terkirim!' : 'KIRIM BUG',
                          style: _body(
                              size: 15,
                              color: Colors.white,
                              weight: FontWeight.w800,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult() {
    final ok = _result!.toLowerCase().contains('terkirim') ||
        _result!.toLowerCase().contains('success');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (ok ? AppColors.success : AppColors.danger).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              (ok ? AppColors.success : AppColors.danger).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: ok ? AppColors.success : AppColors.danger,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_result!,
                style: _body(
                    size: 13,
                    color: ok ? AppColors.success : AppColors.danger,
                    weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.cyan.withOpacity(0.08),
            AppColors.bgCard2,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.format_quote_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text('HIKMAH HARI INI',
                  style: _body(
                      size: 10,
                      color: AppColors.primary,
                      weight: FontWeight.w800,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"Ilmu tanpa amal bagai pohon tanpa buah. Gunakan kemampuanmu untuk kebaikan, bukan kesombongan."',
            style: _heading(
              size: 15,
              weight: FontWeight.w600,
              color: AppColors.textMain,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— HiyukiCrash',
              style: _body(
                  size: 12,
                  color: AppColors.textDim,
                  weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SenderCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const _SenderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    this.disabled = false,
    this.onTap,
  });

  @override
  State<_SenderCard> createState() => _SenderCardState();
}

class _SenderCardState extends State<_SenderCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.selected
                  ? widget.color.withOpacity(0.15)
                  : AppColors.glass,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.selected ? widget.color : AppColors.border,
                width: widget.selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: widget.color, size: 22),
                const SizedBox(height: 10),
                Text(widget.title,
                    style: _body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: widget.color)),
                const SizedBox(height: 2),
                Text(widget.subtitle,
                    style: _body(size: 10, color: AppColors.textDim),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================
 *  NOTIF
 * ============================================================ */
class NotifScreen extends StatefulWidget {
  const NotifScreen({Key? key}) : super(key: key);

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<dynamic> _personal = [];
  List<dynamic> _public = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _fetch();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (mounted) setState(() => _loading = true);
    try {
      final r1 = await Api.notifs();
      final r2 = await Api.notifPublic();
      if (!mounted) return;
      setState(() {
        _personal = r1['notifs'] ?? r1['data'] ?? [];
        _public = r2['notifs'] ?? r2['data'] ?? [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _readAll() async {
    try {
      await Api.readAllNotif();
      await _fetch();
    } catch (_) {}
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toUtc().add(const Duration(hours: 7));
      final diff = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 7))
          .difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s lalu';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
      if (diff.inHours < 24) return '${diff.inHours}j lalu';
      if (diff.inDays < 7) return '${diff.inDays}h lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifikasi',
                              style: _heading(
                                  size: 18, weight: FontWeight.w800)),
                          Text('Pesan & pengumuman',
                              style: _body(
                                  size: 11, color: AppColors.textDim)),
                        ],
                      ),
                    ),
                    if (_personal.isNotEmpty)
                      PressableScale(
                        onTap: _readAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.done_all_rounded,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('Baca',
                                  style: _body(
                                      size: 11,
                                      color: AppColors.primary,
                                      weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.cyan],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textDim,
                  labelStyle: _body(size: 13, weight: FontWeight.w700),
                  unselectedLabelStyle:
                      _body(size: 13, weight: FontWeight.w600),
                  tabs: [
                    Tab(text: 'Pribadi (${_personal.length})'),
                    Tab(text: 'Publik (${_public.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : TabBarView(
                        controller: _tab,
                        children: [
                          _buildList(_personal, true),
                          _buildList(_public, false),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> list, bool personal) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_off_outlined,
                  size: 48, color: AppColors.textDim),
            ),
            const SizedBox(height: 20),
            Text('Belum ada notifikasi',
                style: _heading(size: 15, weight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(personal ? 'Notif pribadi dari owner' : 'Broadcast publik',
                style: _body(size: 12, color: AppColors.textDim)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.bgCard2,
      onRefresh: _fetch,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final n = list[i];
          final isRead = n['read'] == true || n['isRead'] == true;
          return _notifCard(n, isRead, personal);
        },
      ),
    );
  }

  Widget _notifCard(dynamic n, bool isRead, bool personal) {
    final title = n['title']?.toString() ?? 'Notifikasi';
    final message = n['message']?.toString() ?? n['body']?.toString() ?? '';
    final time = _timeAgo(n['createdAt']?.toString());
    final accent = personal ? AppColors.primary : AppColors.warning;

    return PressableScale(
      onTap: () async {
        if (personal && !isRead && n['id'] != null) {
          await Api.readNotif(n['id'].toString());
          _fetch();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead && personal
              ? AppColors.glass
              : accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead && personal
                ? AppColors.border
                : accent.withOpacity(0.35),
            width: isRead && personal ? 1 : 1.4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                personal
                    ? (isRead
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded)
                    : Icons.campaign_rounded,
                color: accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: _body(
                                size: 14,
                                weight: FontWeight.w700,
                                color: isRead && personal
                                    ? AppColors.textDim
                                    : AppColors.textMain)),
                      ),
                      if (!isRead && personal)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message,
                      style: _body(
                          size: 12, color: AppColors.textDim, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(time,
                      style: _body(size: 10, color: AppColors.textDim)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
 *  CHAT GLOBAL
 * ============================================================ */
class ChatGlobalScreen extends StatefulWidget {
  const ChatGlobalScreen({Key? key}) : super(key: key);

  @override
  State<ChatGlobalScreen> createState() => _ChatGlobalScreenState();
}

class _ChatGlobalScreenState extends State<ChatGlobalScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String _myUsername = '';
  String _myDisplayName = '';
  String _myAvatar = '';
  String _myRole = 'member';
  String? _replyToId;
  String? _replyToName;
  String? _replyToText;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMe();
    _fetch();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _fetch());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _myUsername = prefs.getString('username') ?? '';
        _myDisplayName = prefs.getString('displayName') ?? _myUsername;
        _myAvatar = prefs.getString('avatar') ?? '';
        _myRole = prefs.getString('role') ?? 'member';
      });
    } catch (_) {}
  }

  Future<void> _fetch() async {
    try {
      final res = await Api.chatGet();
      if (!mounted) return;
      final list = res['messages'] ?? res['data'] ?? [];
      final wasAtBottom = _isAtBottom();
      setState(() {
        _messages = list is List ? list : [];
        _loading = false;
      });
      if (wasAtBottom) _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isAtBottom() {
    if (!_scrollCtrl.hasClients) return true;
    return _scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 80;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send({String? imageB64}) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty && imageB64 == null) return;
    if (_sending) return;

    setState(() => _sending = true);
    try {
      await Api.chatSend(
        text: text.isNotEmpty ? text : null,
        image: imageB64,
        replyTo: _replyToId,
        displayName: _myDisplayName,
        avatar: _myAvatar,
        role: _myRole,
      );
      _msgCtrl.clear();
      setState(() {
        _replyToId = null;
        _replyToName = null;
        _replyToText = null;
      });
      await _fetch();
      _scrollToBottom();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _pickImage() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 900,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      final b64 = base64Encode(bytes);
      await _send(imageB64: b64);
    } catch (_) {}
  }

  Future<void> _deleteMsg(String id) async {
    try {
      await Api.chatDelete(id);
      await _fetch();
    } catch (_) {}
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toUtc().add(const Duration(hours: 7));
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  Color _roleColor(String role, String username) {
    if (username == FOUNDER_USERNAME) return AppColors.primary;
    switch (role) {
      case 'owner':
        return AppColors.danger;
      case 'reseller':
        return AppColors.warning;
      default:
        return AppColors.softIndigo;
    }
  }

  String _roleLabel(String role, String username) {
    if (username == FOUNDER_USERNAME) return 'FOUNDER';
    return role.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.public_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chat Global',
                              style: _heading(
                                  size: 18, weight: FontWeight.w800)),
                          Text('Semua device online',
                              style: _body(
                                  size: 11, color: AppColors.textDim)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text('LIVE',
                              style: _body(
                                  size: 9,
                                  color: AppColors.success,
                                  weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.forum_outlined,
                                      size: 48,
                                      color: AppColors.textDim),
                                ),
                                const SizedBox(height: 20),
                                Text('Belum ada pesan',
                                    style: _heading(
                                        size: 15,
                                        weight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text('Mulai ngobrol di chat global',
                                    style: _body(
                                        size: 12,
                                        color: AppColors.textDim)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding:
                                const EdgeInsets.fromLTRB(12, 8, 12, 16),
                            itemCount: _messages.length,
                            itemBuilder: (context, i) {
                              final m = _messages[i];
                              final sender = m['from']?.toString() ?? '';
                              final isMe = sender == _myUsername;
                              return _buildBubble(m, isMe);
                            },
                          ),
              ),
              if (_replyToId != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Balas ke $_replyToName',
                                style: _body(
                                    size: 11,
                                    color: AppColors.primary,
                                    weight: FontWeight.w700)),
                            Text(_replyToText ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _body(
                                    size: 11, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textDim, size: 18),
                        onPressed: () => setState(() {
                          _replyToId = null;
                          _replyToName = null;
                          _replyToText = null;
                        }),
                      ),
                    ],
                  ),
                ),
              _buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(dynamic m, bool isMe) {
    final sender = m['from']?.toString() ?? '';
    final displayName = m['displayName']?.toString() ?? sender;
    final avatar = m['avatar']?.toString() ?? '';
    final role = m['role']?.toString() ?? 'member';
    final text = m['text']?.toString() ?? '';
    final image = m['image']?.toString();
    final time = _formatTime(m['createdAt']?.toString());
    final id = m['id']?.toString() ?? '';
    final replyName = m['replyName']?.toString();
    final replyText = m['replyText']?.toString();
    final verified = sender == FOUNDER_USERNAME;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            UserAvatar(
              base64Image: avatar.isNotEmpty ? avatar : null,
              size: 34,
              fallbackInitial: displayName,
              color: _roleColor(role, sender),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: isMe && id.isNotEmpty
                  ? () => _confirmDelete(id)
                  : null,
              onDoubleTap: () {
                setState(() {
                  _replyToId = id;
                  _replyToName = displayName;
                  _replyToText = text.isNotEmpty ? text : '[Gambar]';
                });
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDeep
                          ],
                        )
                      : null,
                  color: isMe ? null : AppColors.bgCard2,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(isMe ? 14 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 14),
                  ),
                  border: isMe
                      ? null
                      : Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              overflow: TextOverflow.ellipsis,
                              style: _body(
                                size: 11,
                                weight: FontWeight.w700,
                                color: _roleColor(role, sender),
                              ),
                            ),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 4),
                            const VerifiedBadge(size: 12),
                          ],
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: _roleColor(role, sender)
                                  .withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _roleLabel(role, sender),
                              style: _body(
                                size: 8,
                                color: _roleColor(role, sender),
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (replyName != null && replyText != null) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.15)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border(
                            left: BorderSide(
                              color:
                                  isMe ? Colors.white : AppColors.primary,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(replyName,
                                style: _body(
                                    size: 10,
                                    color: isMe
                                        ? Colors.white
                                        : AppColors.primary,
                                    weight: FontWeight.w700)),
                            Text(replyText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _body(
                                    size: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : AppColors.textDim)),
                          ],
                        ),
                      ),
                    ],
                    if (image != null && image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(image),
                          width: 220,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.black26,
                            child: const Icon(Icons.broken_image_rounded,
                                color: Colors.white54),
                          ),
                        ),
                      ),
                    if (text.isNotEmpty) ...[
                      if (image != null) const SizedBox(height: 6),
                      Text(
                        text,
                        style: _body(
                          size: 13,
                          color: isMe ? Colors.white : AppColors.textMain,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: _body(
                            size: 9,
                            color: isMe ? Colors.white70 : AppColors.textDim,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all_rounded,
                              size: 12, color: Colors.white70),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            UserAvatar(
              base64Image: _myAvatar.isNotEmpty ? _myAvatar : null,
              size: 34,
              fallbackInitial: _myDisplayName,
              color: _roleColor(_myRole, _myUsername),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.bgCard2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus pesan?',
            style: _heading(size: 16, weight: FontWeight.w700)),
        content: Text('Pesan akan dihapus untuk semua orang.',
            style: _body(size: 13, color: AppColors.textDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('Batal', style: _body(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              _deleteMsg(id);
            },
            child: Text('Hapus',
                style: _body(
                    color: AppColors.danger, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.primary, size: 24),
            onPressed: _sending ? null : _pickImage,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.bg.withOpacity(0.6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _msgCtrl,
                maxLines: 4,
                minLines: 1,
                style: _body(size: 14),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: _body(size: 13, color: AppColors.textDim),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _sending ? null : () => _send(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.cyan],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
 *  DASHBOARD
 * ============================================================ */
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  String _user = '';
  String _displayName = '';
  String _avatar = '';
  String _role = 'member';
  String? _expiredAt;
  int _onlineUsers = 0;
  int _unreadNotif = 0;
  Timer? _timer;
  Timer? _heartbeatTimer;
  Timer? _notifTimer;
  Timer? _profileTimer;
  int _navIndex = 0;
  DateTime _now = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> _device = {};
  bool _loadingDevice = true;

  VideoPlayerController? _bannerVc;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUser();
    _loadProfile();
    _loadDeviceInfo();
    _loadOnlineStats();
    _loadNotifCount();
    _initBannerVideo();
    _sendHeartbeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _sendHeartbeat();
      _loadOnlineStats();
      _loadDeviceInfo(silent: true);
    });
    _notifTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _loadNotifCount();
    });
    _profileTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkAccount();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _heartbeatTimer?.cancel();
    _notifTimer?.cancel();
    _profileTimer?.cancel();
    _bannerVc?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_bannerVc == null || !_bannerReady) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _bannerVc?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _bannerVc?.play();
    }
  }

  Future<void> _initBannerVideo() async {
    try {
      _bannerVc = VideoPlayerController.asset('assets/videos/banner.mp4');
      await _bannerVc!.initialize();
      await _bannerVc!.setLooping(true);
      await _bannerVc!.setVolume(1.0);
      await _bannerVc!.play();
      if (mounted) setState(() => _bannerReady = true);
    } catch (_) {
      if (mounted) setState(() => _bannerReady = false);
    }
  }

  Future<void> _sendHeartbeat() async {
    try {
      await Api.heartbeat();
    } catch (_) {}
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _user = prefs.getString('username') ?? 'User';
        _displayName = prefs.getString('displayName') ?? _user;
        _avatar = prefs.getString('avatar') ?? '';
        _role = prefs.getString('role') ?? 'member';
      });
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    try {
      final res = await Api.profile();
      if (!mounted) return;
      if (res['error'] != null || res['banned'] == true) {
        await _forceLogout(res['error']?.toString() ?? 'Akun bermasalah');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final newRole = res['role']?.toString() ?? _role;
      final newDisplay = res['displayName']?.toString() ?? _displayName;
      final newAvatar = res['avatar']?.toString() ?? _avatar;
      await prefs.setString('role', newRole);
      await prefs.setString('displayName', newDisplay);
      await prefs.setString('avatar', newAvatar);
      if (!mounted) return;
      setState(() {
        _role = newRole;
        _displayName = newDisplay;
        _avatar = newAvatar;
        _expiredAt = res['expiredAt']?.toString();
      });
    } catch (_) {}
  }

  Future<void> _checkAccount() async {
    try {
      final res = await Api.profile();
      if (!mounted) return;
      if (res['error'] != null && res['token'] == null) {
        final err = res['error'].toString().toLowerCase();
        if (err.contains('expired') ||
            err.contains('nonaktif') ||
            err.contains('tidak ditemukan') ||
            err.contains('banned') ||
            err.contains('dihapus')) {
          await _forceLogout(res['error'].toString());
        }
      }
    } catch (_) {}
  }

  Future<void> _forceLogout(String reason) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.bgCard2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.gpp_bad_rounded,
                color: AppColors.danger, size: 24),
            const SizedBox(width: 10),
            Text('Akses Ditutup',
                style: _heading(size: 17, weight: FontWeight.w700)),
          ],
        ),
        content: Text(reason,
            style: _body(size: 13, color: AppColors.textDim, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              }
            },
            child: Text('OK',
                style: _body(
                    color: AppColors.danger, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadOnlineStats() async {
    try {
      final res = await Api.onlineStats();
      if (!mounted) return;
      setState(() {
        _onlineUsers = res['onlineUsers'] ?? res['activeSessions'] ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _loadNotifCount() async {
    try {
      final r1 = await Api.notifs();
      final r2 = await Api.notifPublic();
      final list1 = r1['notifs'] ?? r1['data'] ?? [];
      final list2 = r2['notifs'] ?? r2['data'] ?? [];
      final unreadPersonal = (list1 as List)
          .where((n) => n['read'] != true && n['isRead'] != true)
          .length;
      final unreadPublic = (list2 as List).length;
      if (!mounted) return;
      setState(() {
        _unreadNotif = unreadPersonal + unreadPublic;
      });
    } catch (_) {}
  }

  Future<void> _loadDeviceInfo({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loadingDevice = true);
    try {
      final info = await DeviceInfoService.getAll();
      if (!mounted) return;
      setState(() {
        _device = info;
        _loadingDevice = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingDevice = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.bgCard2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        title: Text('Logout',
            style: _heading(size: 18, weight: FontWeight.w700)),
        content: Text('Yakin mau logout?',
            style: _body(size: 14, color: AppColors.textDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Batal', style: _body(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Logout',
                style: _body(
                    color: AppColors.danger, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await Api.logout();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  String _timeStr() {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _expiredShort() {
    if (_expiredAt == null) return 'Lifetime';
    try {
      final dt = DateTime.parse(_expiredAt!);
      final wib = dt.toUtc().add(const Duration(hours: 7));
      final d = wib.day.toString().padLeft(2, '0');
      final mo = wib.month.toString().padLeft(2, '0');
      final hh = wib.hour.toString().padLeft(2, '0');
      final mm = wib.minute.toString().padLeft(2, '0');
      return '$d/$mo/${wib.year} $hh:$mm WIB';
    } catch (_) {
      return 'Lifetime';
    }
  }

  Color _roleColor(String role, String username) {
    if (username == FOUNDER_USERNAME) return AppColors.primary;
    switch (role) {
      case 'owner':
        return AppColors.danger;
      case 'reseller':
        return AppColors.warning;
      default:
        return AppColors.softIndigo;
    }
  }

  String _roleLabel(String role, String username) {
    if (username == FOUNDER_USERNAME) return 'FOUNDER';
    return role.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _ProfileDrawer(
        username: _user,
        displayName: _displayName,
        avatar: _avatar,
        role: _role,
        expiredAt: _expiredAt,
        onLogout: _logout,
        onProfileUpdated: () => _loadUser(),
      ),
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.bgCard2,
                  onRefresh: () async {
                    await _loadProfile();
                    await _loadOnlineStats();
                    await _loadDeviceInfo();
                    await _loadNotifCount();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBanner(),
                        const SizedBox(height: 16),
                        _buildUserHeader(),
                        const SizedBox(height: 14),
                        _buildSystemMetrics(),
                        const SizedBox(height: 18),
                        _buildDashboardCard(),
                        const SizedBox(height: 18),
                        _buildBannerVideo(),
                        const SizedBox(height: 18),
                        _buildChatGlobalEntry(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.textMain, size: 26),
            onPressed: _openSidebar,
            tooltip: 'Menu',
          ),
          const SizedBox(width: 4),
          const AppLogo(size: 34, showGlow: false),
          const SizedBox(width: 10),
          Text('HiyukiCrash',
              style: _heading(size: 17, weight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('v1.0',
                style: _body(
                    size: 10,
                    color: AppColors.primary,
                    weight: FontWeight.w700)),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.textMain, size: 24),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notif');
                  _loadNotifCount();
                  if (mounted) setState(() => _navIndex = 0);
                },
              ),
              if (_unreadNotif > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _unreadNotif > 99 ? '99+' : '$_unreadNotif',
                        style: _body(
                            size: 9,
                            color: Colors.white,
                            weight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withOpacity(0.7),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 1.5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/banner.jpg',
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/banner.png',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0B0F1A),
                          Color(0xFF1A2744),
                          Color(0xFF0E1A2E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HiyukiCrash',
                      style: _heading(size: 22, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hello, minion — good luck.',
                      style: _body(
                        size: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return ElevCard(
      child: Row(
        children: [
          UserAvatar(
            base64Image: _avatar.isNotEmpty ? _avatar : null,
            size: 52,
            fallbackInitial: _displayName,
            color: _roleColor(_role, _user),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text('Hi, $_displayName',
                          overflow: TextOverflow.ellipsis,
                          style: _heading(
                              size: 16, weight: FontWeight.w700)),
                    ),
                    if (_user == FOUNDER_USERNAME) ...[
                      const SizedBox(width: 6),
                      const VerifiedBadge(size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor(_role, _user).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_roleLabel(_role, _user),
                          style: _body(
                              size: 9,
                              color: _roleColor(_role, _user),
                              weight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.textDim),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('Exp: ${_expiredShort()}',
                          overflow: TextOverflow.ellipsis,
                          style: _body(
                              size: 10, color: AppColors.textDim)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_timeStr(),
                  style: _body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.primary)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text('$_onlineUsers ON',
                        style: _body(
                            size: 9,
                            color: AppColors.success,
                            weight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics() {
    if (_loadingDevice) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final battery = (_device['battery'] ?? 0) as int;
    final batteryState = (_device['batteryState'] ?? 'unknown').toString();
    final network = (_device['network'] ?? 'Offline').toString();
    final signalBars = (_device['signalBars'] ?? 0) as int;
    final totalRamGB = (_device['totalRamGB'] ?? 4.0) as double;
    final totalStorageGB = (_device['totalStorageGB'] ?? 64.0) as double;
    final freeStorageGB = (_device['freeStorageGB'] ?? 28.0) as double;
    final model = (_device['model'] ?? 'Unknown').toString();
    final androidVersion = (_device['androidVersion'] ?? '-').toString();
    final sdkInt = (_device['sdkInt'] ?? 0) as int;

    final ramUsage = 0.5 + math.sin(_now.second / 10) * 0.08;
    final storageUsage = totalStorageGB > 0
        ? (totalStorageGB - freeStorageGB) / totalStorageGB
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricRing(
                icon: batteryState == 'charging'
                    ? Icons.battery_charging_full_rounded
                    : Icons.battery_full_rounded,
                label: 'Battery',
                value: battery / 100.0,
                detail: '$battery% · ${batteryState.toUpperCase()}',
                color: battery > 20 ? AppColors.success : AppColors.danger,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricRing(
                icon: Icons.memory_rounded,
                label: 'RAM',
                value: ramUsage.clamp(0.0, 1.0),
                detail:
                    '${(ramUsage * totalRamGB).toStringAsFixed(1)} / ${totalRamGB.toStringAsFixed(1)} GB',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricRing(
                icon: Icons.sd_storage_outlined,
                label: 'Storage',
                value: storageUsage.clamp(0.0, 1.0),
                detail:
                    '${(totalStorageGB - freeStorageGB).toStringAsFixed(0)} / ${totalStorageGB.toStringAsFixed(0)} GB',
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricRing(
                icon: Icons.phone_android_rounded,
                label: 'Device',
                value: sdkInt > 0 ? (sdkInt / 35).clamp(0.0, 1.0) : 0.0,
                detail: 'Android $androidVersion · SDK $sdkInt',
                color: AppColors.softIndigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          radius: 16,
          child: Row(
            children: [
              Icon(
                network == 'Wi-Fi'
                    ? Icons.wifi_rounded
                    : network == 'Mobile'
                        ? Icons.signal_cellular_alt_rounded
                        : Icons.wifi_off_rounded,
                color: network == 'Offline'
                    ? AppColors.danger
                    : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Network · $model',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _body(
                            size: 12,
                            color: AppColors.textDim,
                            weight: FontWeight.w600)),
                    Text('$network · Signal $signalBars/4',
                        style: _body(size: 13, weight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (network == 'Offline'
                          ? AppColors.danger
                          : AppColors.success)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  network == 'Offline' ? 'OFFLINE' : 'ONLINE',
                  style: _body(
                      size: 10,
                      color: network == 'Offline'
                          ? AppColors.danger
                          : AppColors.success,
                      weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard() {
    final sdkInt = (_device['sdkInt'] ?? 0).toString();
    final totalStorageGB =
        (_device['totalStorageGB'] ?? 0).toStringAsFixed(0);

    return ElevCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dashboard_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Dashboard',
                  style: _heading(size: 15, weight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 14),
                    const SizedBox(width: 5),
                    Text('ACTIVE',
                        style: _body(
                            size: 10,
                            color: AppColors.success,
                            weight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: [
              _GridStat3D(
                  icon: Icons.badge_outlined,
                  label: 'ROLE',
                  value: _roleLabel(_role, _user),
                  color: _roleColor(_role, _user)),
              _GridStat3D(
                  icon: Icons.event_available_outlined,
                  label: 'EXPIRED',
                  value: _expiredShort(),
                  color: AppColors.warning),
              _GridStat3D(
                  icon: Icons.people_outline_rounded,
                  label: 'ONLINE',
                  value: '$_onlineUsers USERS',
                  color: AppColors.success),
              const _GridStat3D(
                  icon: Icons.phone_android_outlined,
                  label: 'DEVICE',
                  value: 'ANDROID',
                  color: AppColors.softIndigo),
              _GridStat3D(
                  icon: Icons.storage_outlined,
                  label: 'STORAGE',
                  value: '$totalStorageGB GB',
                  color: AppColors.cyan),
              _GridStat3D(
                  icon: Icons.settings_outlined,
                  label: 'SYSTEM',
                  value: 'API $sdkInt',
                  color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerVideo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_bannerReady && _bannerVc != null)
                RepaintBoundary(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _bannerVc!.value.size.width,
                      height: _bannerVc!.value.size.height,
                      child: VideoPlayer(_bannerVc!),
                    ),
                  ),
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0B0F1A),
                        Color(0xFF1A2744),
                        Color(0xFF0E1A2E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_outline,
                        size: 48, color: AppColors.textDim),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 14,
                bottom: 12,
                child: Text(
                  'HiyukiCrash · Preview',
                  style: _body(
                    size: 11,
                    color: Colors.white.withOpacity(0.85),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatGlobalEntry() {
    return PressableScale(
      onTap: () async {
        await Navigator.pushNamed(context, '/chat');
        if (mounted) setState(() => _navIndex = 0);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 22,
              offset: const Offset(0, 11),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.cyan],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.public_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Chat Global',
                          style: _heading(
                              size: 16, weight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('LIVE',
                            style: _body(
                                size: 9,
                                color: AppColors.success,
                                weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Ngobrol dengan semua device online',
                      style: _body(size: 12, color: AppColors.textDim)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home', '/dashboard'),
      (Icons.bug_report_outlined, Icons.bug_report_rounded, 'WA Bug', '/bug'),
      (Icons.add_rounded, Icons.add_rounded, 'Pair', '/pairing'),
      (Icons.notifications_none_rounded, Icons.notifications_rounded, 'Notif',
          '/notif'),
      (Icons.build_outlined, Icons.build_rounded, 'Tools', '/tools'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = _navIndex == i;
          if (i == 2) {
            return GestureDetector(
              onTap: () async {
                setState(() => _navIndex = i);
                await Navigator.pushNamed(context, items[i].$4);
                if (mounted) setState(() => _navIndex = 0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.cyan],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(items[i].$1, color: Colors.white, size: 26),
              ),
            );
          }
          return GestureDetector(
            onTap: () async {
              if (i == 0) {
                setState(() => _navIndex = 0);
                return;
              }
              setState(() => _navIndex = i);
              await Navigator.pushNamed(context, items[i].$4);
              if (mounted) setState(() => _navIndex = 0);
              if (i == 3) _loadNotifCount();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        selected ? items[i].$2 : items[i].$1,
                        size: 22,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textDim,
                      ),
                      if (i == 3 && _unreadNotif > 0)
                        Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(
                                minWidth: 14, minHeight: 14),
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _unreadNotif > 9 ? '9+' : '$_unreadNotif',
                                style: _body(
                                    size: 8,
                                    color: Colors.white,
                                    weight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(items[i].$3,
                      style: _body(
                          size: 9,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textDim,
                          weight: selected
                              ? FontWeight.w700
                              : FontWeight.w500)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProfileDrawer extends StatefulWidget {
  final String username;
  final String displayName;
  final String avatar;
  final String role;
  final String? expiredAt;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdated;

  const _ProfileDrawer({
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.role,
    required this.expiredAt,
    required this.onLogout,
    required this.onProfileUpdated,
  });

  @override
  State<_ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<_ProfileDrawer> {
  Color _roleColor(String role, String username) {
    if (username == FOUNDER_USERNAME) return AppColors.primary;
    switch (role) {
      case 'owner':
        return AppColors.danger;
      case 'reseller':
        return AppColors.warning;
      default:
        return AppColors.softIndigo;
    }
  }

  String _roleLabel(String role, String username) {
    if (username == FOUNDER_USERNAME) return 'FOUNDER';
    return role.toUpperCase();
  }

  String _expiredShort() {
    if (widget.expiredAt == null) return 'Lifetime';
    try {
      final dt = DateTime.parse(widget.expiredAt!);
      final wib = dt.toUtc().add(const Duration(hours: 7));
      final d = wib.day.toString().padLeft(2, '0');
      final mo = wib.month.toString().padLeft(2, '0');
      final hh = wib.hour.toString().padLeft(2, '0');
      final mm = wib.minute.toString().padLeft(2, '0');
      return '$d/$mo/${wib.year} $hh:$mm WIB';
    } catch (_) {
      return 'Lifetime';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bg,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  UserAvatar(
                    base64Image:
                        widget.avatar.isNotEmpty ? widget.avatar : null,
                    size: 88,
                    fallbackInitial: widget.displayName,
                    color: _roleColor(widget.role, widget.username),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(widget.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: _heading(
                                size: 19, weight: FontWeight.w800)),
                      ),
                      if (widget.username == FOUNDER_USERNAME) ...[
                        const SizedBox(width: 6),
                        const VerifiedBadge(size: 18),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('@${widget.username}',
                      style: _body(size: 12, color: AppColors.textDim)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _roleColor(widget.role, widget.username)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _roleColor(
                                      widget.role, widget.username)
                                  .withOpacity(0.4)),
                        ),
                        child: Text(
                            _roleLabel(widget.role, widget.username),
                            style: _body(
                                size: 10,
                                color: _roleColor(
                                    widget.role, widget.username),
                                weight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppColors.warning.withOpacity(0.4)),
                        ),
                        child: Text(_expiredShort(),
                            style: _body(
                                size: 10,
                                color: AppColors.warning,
                                weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profil',
              onTap: () async {
                Navigator.pop(context);
                final updated = await showModalBottomSheet<bool>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => _EditProfileSheet(
                    username: widget.username,
                    displayName: widget.displayName,
                    avatar: widget.avatar,
                    role: widget.role,
                  ),
                );
                if (updated == true) widget.onProfileUpdated();
              },
            ),
            _drawerItem(
              icon: Icons.lock_outline_rounded,
              label: 'Ubah Password',
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordSheet(context);
              },
            ),
            _drawerItem(
              icon: Icons.info_outline_rounded,
              label: 'Tentang App',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: 'Logout',
                icon: Icons.logout_rounded,
                colors: const [AppColors.danger, AppColors.softRose],
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onLogout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 14),
                Text(label, style: _body(size: 14, weight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final String username;
  final String displayName;
  final String avatar;
  final String role;

  const _EditProfileSheet({
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.role,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  String _avatar = '';
  bool _load = false;
  String? _msg;
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.displayName);
    _avatar = widget.avatar;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 55,
        maxWidth: 400,
        maxHeight: 400,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      final b64 = base64Encode(bytes);
      if (mounted) setState(() => _avatar = b64);
    } catch (_) {}
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() {
        _msg = 'Nama tidak boleh kosong';
        _ok = false;
      });
      return;
    }
    setState(() {
      _load = true;
      _msg = null;
    });
    try {
      final res = await Api.updateProfile(
        displayName: name,
        avatar: _avatar.isNotEmpty ? _avatar : null,
      );
      if (!mounted) return;
      if (res['ok'] == true || res['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('displayName', name);
        await prefs.setString('avatar', _avatar);
        setState(() {
          _ok = true;
          _msg = 'Profil diperbarui';
        });
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() {
          _ok = false;
          _msg = res['error']?.toString() ?? 'Gagal update';
        });
      }
    } catch (e) {
      setState(() {
        _ok = false;
        _msg = 'Error: $e';
      });
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bgCard2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.edit_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text('Edit Profil',
                      style: _heading(size: 18, weight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    UserAvatar(
                      base64Image: _avatar.isNotEmpty ? _avatar : null,
                      size: 100,
                      fallbackInitial: widget.displayName,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: PressableScale(
                        onTap: _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.cyan
                              ],
                            ),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.bgCard2, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Nama Tampilan',
                  style: _body(
                      size: 12,
                      color: AppColors.textDim,
                      weight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                style: _body(size: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bg.withOpacity(0.6),
                  hintText: 'Nama tampilan kamu',
                  hintStyle: _body(size: 14, color: AppColors.textDim),
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.primary, size: 22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Username: @${widget.username} (tidak bisa diubah)',
                  style: _body(size: 11, color: AppColors.textDim)),
              if (_msg != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_ok ? AppColors.success : AppColors.danger)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _ok
                            ? Icons.check_circle_outline
                            : Icons.error_outline_rounded,
                        color:
                            _ok ? AppColors.success : AppColors.danger,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_msg!,
                            style: _body(
                                size: 12,
                                color: _ok
                                    ? AppColors.success
                                    : AppColors.danger)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Simpan',
                icon: Icons.save_outlined,
                loading: _load,
                onPressed: _load ? null : _save,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _load = false;
  bool _obscure = true;
  String? _msg;
  bool _success = false;

  Future<void> _submit() async {
    if (_old.text.isEmpty || _new.text.isEmpty || _confirm.text.isEmpty) {
      setState(() {
        _msg = 'Isi semua field';
        _success = false;
      });
      return;
    }
    if (_new.text.length < 6) {
      setState(() {
        _msg = 'Password minimal 6 karakter';
        _success = false;
      });
      return;
    }
    if (_new.text != _confirm.text) {
      setState(() {
        _msg = 'Konfirmasi password tidak sama';
        _success = false;
      });
      return;
    }
    setState(() {
      _load = true;
      _msg = null;
    });
    try {
      final res = await Api.changePassword(
        oldPassword: _old.text,
        newPassword: _new.text,
      );
      if (!mounted) return;
      if (res['ok'] == true || res['success'] == true) {
        setState(() {
          _success = true;
          _msg = 'Password berhasil diubah';
        });
        _old.clear();
        _new.clear();
        _confirm.clear();
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _success = false;
          _msg = res['error']?.toString() ?? 'Gagal ubah password';
        });
      }
    } catch (e) {
      setState(() {
        _success = false;
        _msg = 'Error: $e';
      });
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bgCard2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text('Ubah Password',
                      style: _heading(size: 18, weight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),
              _field(_old, 'Password lama', _obscure,
                  () => setState(() => _obscure = !_obscure)),
              const SizedBox(height: 12),
              _field(_new, 'Password baru', _obscure, null),
              const SizedBox(height: 12),
              _field(_confirm, 'Konfirmasi password baru', _obscure, null),
              if (_msg != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_success ? AppColors.success : AppColors.danger)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _success
                            ? Icons.check_circle_outline
                            : Icons.error_outline_rounded,
                        color:
                            _success ? AppColors.success : AppColors.danger,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_msg!,
                            style: _body(
                                size: 12,
                                color: _success
                                    ? AppColors.success
                                    : AppColors.danger)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Simpan',
                icon: Icons.save_outlined,
                loading: _load,
                onPressed: _load ? null : _submit,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, bool obscure,
      VoidCallback? toggle) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: _body(size: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bg.withOpacity(0.6),
        hintText: hint,
        hintStyle: _body(size: 14, color: AppColors.textDim),
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textDim,
                ),
                onPressed: toggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _MetricRing extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final String detail;
  final Color color;

  const _MetricRing({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevCard(
      padding: const EdgeInsets.all(14),
      radius: 16,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: value.clamp(0.0, 1.0),
                    strokeWidth: 4,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: _body(
                        size: 11,
                        color: AppColors.textDim,
                        weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${(value * 100).toInt()}%',
                    style: _heading(size: 16, weight: FontWeight.w800)),
                Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(size: 10, color: AppColors.textDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridStat3D extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _GridStat3D({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            AppColors.bg.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(label,
              style: _body(
                  size: 9,
                  color: AppColors.textDim,
                  weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _body(size: 11, weight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

/* ============================================================
 *  TOOLS SCREEN
 * ============================================================ */
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tools = [
      (
        'TikTok Downloader',
        'Download video TikTok tanpa watermark',
        Icons.music_note_rounded,
        AppColors.pink,
        '/tools/tiktok',
      ),
      (
        'WiFi Killer',
        'Matikan koneksi WiFi semua device',
        Icons.wifi_off_rounded,
        AppColors.danger,
        '/tools/wifi',
      ),
      (
        'NIK Check',
        'Cek data dari NIK KTP',
        Icons.badge_rounded,
        AppColors.cyan,
        '/tools/nik',
      ),
      (
        'IP Scanner',
        'Scan dan info IP address',
        Icons.dns_rounded,
        AppColors.primary,
        '/tools/ip',
      ),
      (
        'Email OSINT',
        'Investigasi info email',
        Icons.email_rounded,
        AppColors.softIndigo,
        '/tools/email',
      ),
    ];

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.build_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tools',
                            style: _heading(
                                size: 18, weight: FontWeight.w800)),
                        Text('Kumpulan tools canggih',
                            style: _body(
                                size: 11, color: AppColors.textDim)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  itemCount: tools.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final t = tools[i];
                    return PressableScale(
                      onTap: () => Navigator.pushNamed(context, t.$5),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.glass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 22,
                              offset: const Offset(0, 11),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    t.$4,
                                    t.$4.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: t.$4.withOpacity(0.4),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child:
                                  Icon(t.$3, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(t.$1,
                                      style: _heading(
                                          size: 15,
                                          weight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(t.$2,
                                      style: _body(
                                          size: 12,
                                          color: AppColors.textDim)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: AppColors.primary, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
 *  TIKTOK DOWNLOADER
 * ============================================================ */
class TikTokDownloaderPage extends StatefulWidget {
  const TikTokDownloaderPage({Key? key}) : super(key: key);

  @override
  State<TikTokDownloaderPage> createState() => _TikTokDownloaderPageState();
}

class _TikTokDownloaderPageState extends State<TikTokDownloaderPage> {
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _data;

  Future<void> _download() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Link wajib diisi');
      return;
    }
    if (!url.contains('tiktok')) {
      setState(() => _error = 'Link harus TikTok');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final res = await Api.tiktokDownload(url);
      if (!mounted) return;
      if (res['ok'] == true || res['success'] == true) {
        setState(() => _data = res['data'] ?? res);
      } else {
        setState(() => _error = res['error']?.toString() ?? 'Gagal');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              _header('TikTok Downloader', AppColors.pink,
                  Icons.music_note_rounded),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.pink.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                      Icons.music_note_rounded,
                                      color: AppColors.pink,
                                      size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('TikTok No Watermark',
                                          style: _heading(
                                              size: 16,
                                              weight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text('Paste link video TikTok',
                                          style: _body(
                                              size: 12,
                                              color: AppColors.textDim)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _urlCtrl,
                              maxLines: 2,
                              minLines: 1,
                              style: _body(size: 14),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.bg.withOpacity(0.55),
                                hintText: 'https://vt.tiktok.com/...',
                                hintStyle: _body(
                                    size: 13, color: AppColors.textDim),
                                prefixIcon: const Icon(Icons.link_rounded,
                                    color: AppColors.pink, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.pink, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Download',
                              icon: Icons.download_rounded,
                              loading: _loading,
                              colors: const [AppColors.pink, AppColors.pink],
                              onPressed: _loading ? null : _download,
                              fullWidth: true,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.danger.withOpacity(0.35)),
                          ),
                          child: Text(_error!,
                              style: _body(
                                  size: 13, color: AppColors.danger)),
                        ),
                      ],
                      if (_data != null) ...[
                        const SizedBox(height: 20),
                        _buildResultCard(_data!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String title, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [color, color.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Text(title,
              style: _heading(size: 18, weight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? 'TikTok Video';
    final author = data['author']?.toString() ?? '-';
    final thumb = data['thumbnail']?.toString() ?? '';
    final videoUrl = data['video']?.toString() ?? '';
    final audioUrl = data['audio']?.toString() ?? '';
    final duration = data['duration']?.toString() ?? '-';

    return ElevCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thumb.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                thumb,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.image_outlined,
                      size: 48, color: AppColors.textDim),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(title,
              style: _heading(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  color: AppColors.textDim, size: 16),
              const SizedBox(width: 6),
              Text(author,
                  style: _body(size: 12, color: AppColors.textDim)),
              const Spacer(),
              const Icon(Icons.access_time_rounded,
                  color: AppColors.textDim, size: 16),
              const SizedBox(width: 6),
              Text('$duration s',
                  style: _body(size: 12, color: AppColors.textDim)),
            ],
          ),
          const SizedBox(height: 20),
          if (videoUrl.isNotEmpty)
            PrimaryButton(
              label: 'Download Video',
              icon: Icons.video_file_rounded,
              colors: const [AppColors.primary, AppColors.cyan],
              onPressed: () => _openUrl(videoUrl),
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          if (audioUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Download Audio',
              icon: Icons.audiotrack_rounded,
              colors: const [AppColors.softIndigo, AppColors.purple],
              onPressed: () => _openUrl(audioUrl),
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal buka link: $e')),
      );
    }
  }
}

/* ============================================================
 *  WIFI KILLER
 * ============================================================ */
class WifiKillerPage extends StatefulWidget {
  const WifiKillerPage({Key? key}) : super(key: key);

  @override
  State<WifiKillerPage> createState() => _WifiKillerPageState();
}

class _WifiKillerPageState extends State<WifiKillerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  String _wifiName = 'Memuat...';
  String _wifiIP = '-';
  List<Map<String, dynamic>> _devices = [];
  bool _scanning = false;
  bool _killing = false;
  int _progress = 0;
  bool _killDone = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _loadWifiInfo();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWifiInfo() async {
    try {
      final name = await DeviceInfoService.getWifiName();
      final ip = await DeviceInfoService.getWifiIP();
      if (!mounted) return;
      setState(() {
        _wifiName = name ?? 'Tidak terkoneksi WiFi';
        _wifiIP = ip ?? '-';
      });
    } catch (_) {}
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    if (mounted) setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    final random = math.Random();
    final macPrefixes = [
      'A4:5E:60',
      'F8:8E:85',
      '3C:5A:B4',
      'B8:27:EB',
      'DC:A6:32',
      'E4:5F:01',
      '00:1A:11',
      '50:1A:C5',
      '74:AC:5F',
      'A0:5B:21',
    ];
    final vendors = [
      'Samsung',
      'Xiaomi',
      'Apple',
      'Realme',
      'Oppo',
      'Vivo',
      'Huawei',
      'LG',
      'Sony',
      'Asus',
    ];

    final count = 6 + random.nextInt(8);
    final devices = <Map<String, dynamic>>[];
    for (int i = 0; i < count; i++) {
      final mac = '${macPrefixes[random.nextInt(macPrefixes.length)]}:'
          '${random.nextInt(255).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
          '${random.nextInt(255).toRadixString(16).padLeft(2, '0').toUpperCase()}';
      devices.add({
        'mac': mac,
        'ip': '192.168.1.${random.nextInt(253) + 2}',
        'vendor': vendors[random.nextInt(vendors.length)],
        'signal': -30 - random.nextInt(50),
        'killed': false,
      });
    }

    if (!mounted) return;
    setState(() {
      _devices = devices;
      _scanning = false;
    });
  }

  Future<void> _killAll() async {
    if (_devices.isEmpty) return;
    setState(() {
      _killing = true;
      _progress = 0;
      _killDone = false;
    });

    for (int i = 0; i < _devices.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _progress = ((i + 1) * 100 / _devices.length).toInt();
        _devices[i]['killed'] = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _killing = false;
      _killDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.danger, AppColors.softRose],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.danger.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.wifi_off_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('WiFi Killer',
                          style: _heading(
                              size: 18, weight: FontWeight.w800)),
                    ),
                    if (!_scanning && !_killing)
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppColors.primary, size: 22),
                        onPressed: _scanDevices,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWifiInfoCard(),
                      const SizedBox(height: 16),
                      _buildActionCard(),
                      const SizedBox(height: 16),
                      _buildDeviceList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWifiInfoCard() {
    return ElevCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.danger
                            .withOpacity(0.3 + _pulseCtrl.value * 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger
                              .withOpacity(0.2 + _pulseCtrl.value * 0.2),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.wifi_tethering_rounded,
                        color: AppColors.danger, size: 26),
                  );
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WiFi Terdeteksi',
                        style: _body(
                            size: 11,
                            color: AppColors.textDim,
                            weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(_wifiName,
                        style:
                            _heading(size: 16, weight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _infoRow('IP Address', _wifiIP),
          const SizedBox(height: 8),
          _infoRow('Device Terhubung', '${_devices.length}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: _body(size: 12, color: AppColors.textDim)),
        ),
        Expanded(
          child: Text(value,
              style: _body(size: 12, weight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildActionCard() {
    if (_killDone) {
      return ElevCard(
        padding: const EdgeInsets.all(20),
        color: AppColors.danger.withOpacity(0.1),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.dangerous_rounded,
                  color: AppColors.danger, size: 40),
            ),
            const SizedBox(height: 16),
            Text('SEMUA DEVICE TERPUTUS',
                style: _heading(
                    size: 15,
                    weight: FontWeight.w800,
                    color: AppColors.danger)),
            const SizedBox(height: 8),
            Text('${_devices.length} device berhasil diputus',
                textAlign: TextAlign.center,
                style: _body(size: 12, color: AppColors.textDim)),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Scan Ulang',
              icon: Icons.refresh_rounded,
              colors: const [AppColors.primary, AppColors.cyan],
              onPressed: () {
                setState(() {
                  _killDone = false;
                  _devices = [];
                });
                _scanDevices();
              },
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ],
        ),
      );
    }

    if (_killing) {
      return ElevCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: _progress / 100,
                      strokeWidth: 4,
                      backgroundColor: AppColors.danger.withOpacity(0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.danger),
                    ),
                  ),
                  Text('$_progress%',
                      style: _body(
                          size: 12,
                          weight: FontWeight.w800,
                          color: AppColors.danger)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('MEMUTUS KONEKSI...',
                style: _heading(
                    size: 14,
                    weight: FontWeight.w800,
                    color: AppColors.danger)),
            const SizedBox(height: 6),
            Text('Menyerang semua device di jaringan',
                style: _body(size: 12, color: AppColors.textDim)),
          ],
        ),
      );
    }

    return ElevCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.3),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(Icons.power_settings_new_rounded,
                color: AppColors.danger, size: 40),
          ),
          const SizedBox(height: 16),
          Text('KILL SEMUA DEVICE',
              style: _heading(size: 15, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Matikan koneksi internet semua device di jaringan WiFi ini',
              textAlign: TextAlign.center,
              style: _body(size: 12, color: AppColors.textDim)),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'KILL NOW',
            icon: Icons.flash_on_rounded,
            colors: const [AppColors.danger, AppColors.softRose],
            onPressed: _devices.isEmpty ? null : _killAll,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_scanning) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Memindai device...',
                  style: TextStyle(color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      );
    }

    if (_devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Tidak ada device terdeteksi',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.devices_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text('Device Terhubung',
                style: _heading(size: 14, weight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${_devices.length}',
                  style: _body(
                      size: 10,
                      color: AppColors.primary,
                      weight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._devices.asMap().entries.map((e) {
          final d = e.value;
          final killed = d['killed'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: killed
                  ? AppColors.danger.withOpacity(0.08)
                  : AppColors.glass,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: killed
                    ? AppColors.danger.withOpacity(0.4)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: killed
                        ? AppColors.danger.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    killed
                        ? Icons.wifi_off_rounded
                        : Icons.smartphone_rounded,
                    color:
                        killed ? AppColors.danger : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['vendor']?.toString() ?? 'Unknown',
                          style: _body(
                              size: 13, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(d['mac']?.toString() ?? '-',
                          style: _body(
                              size: 11, color: AppColors.textDim)),
                      Text(d['ip']?.toString() ?? '-',
                          style: _body(
                              size: 11, color: AppColors.textDim)),
                    ],
                  ),
                ),
                if (killed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.danger.withOpacity(0.4)),
                    ),
                    child: Text('KILLED',
                        style: _body(
                            size: 9,
                            color: AppColors.danger,
                            weight: FontWeight.w800)),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

/* ============================================================
 *  NIK CHECKER
 * ============================================================ */
class NikCheckerPage extends StatefulWidget {
  const NikCheckerPage({super.key});

  @override
  State<NikCheckerPage> createState() => _NikCheckerPageState();
}

class _NikCheckerPageState extends State<NikCheckerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nikController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _data;
  String? _errorMessage;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _nikController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkNik() async {
    final nik = _nikController.text.trim();
    if (nik.isEmpty) {
      setState(() {
        _errorMessage = "NIK tidak boleh kosong.";
        _data = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _data = null;
    });

    final url = Uri.parse(
        "https://api.siputzx.my.id/api/tools/nik-checker?nik=$nik");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == true && json['data'] != null) {
          setState(() {
            _data = json['data'];
            _errorMessage = null;
          });
          _animController.forward(from: 0);
        } else {
          setState(() {
            _errorMessage = "Data tidak ditemukan atau NIK tidak valid.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Gagal mengambil data dari server.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Terjadi kesalahan: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00ACC1), Color(0xFF18FFFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(title,
                    style: _heading(
                        size: 15,
                        weight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String? value,
    VoidCallback? onCopy,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: _body(
                        size: 13,
                        color: AppColors.textDim,
                        weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    style: _body(size: 15, weight: FontWeight.w600)),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded,
                  color: AppColors.cyan, size: 18),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label disalin'),
        backgroundColor: AppColors.cyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cyan, Color(0xFF0EA5E9)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.badge_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Text('NIK Check',
                        style:
                            _heading(size: 18, weight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.cyan.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nikController,
                              keyboardType: TextInputType.number,
                              style: _body(size: 15),
                              decoration: InputDecoration(
                                labelText: 'Masukkan NIK',
                                labelStyle: _body(
                                    size: 13, color: AppColors.cyan),
                                hintText: '5206085405880001',
                                hintStyle: _body(
                                    size: 13, color: AppColors.textDim),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          AppColors.cyan.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.cyan, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                              ),
                              onSubmitted: (_) => _checkNik(),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label:
                                  _isLoading ? 'MEMPROSES...' : 'CEK DATA NIK',
                              icon: _isLoading
                                  ? Icons.hourglass_top
                                  : Icons.search,
                              loading: _isLoading,
                              colors: const [
                                AppColors.cyan,
                                Color(0xFF0EA5E9)
                              ],
                              onPressed: _isLoading ? null : _checkNik,
                              fullWidth: true,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.danger.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.danger),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_errorMessage!,
                                    style: _body(
                                        size: 13,
                                        color: AppColors.danger)),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (_data != null)
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildCategoryCard(
                                    title: "IDENTITAS DIRI",
                                    icon: Icons.person,
                                    children: [
                                      _buildInfoRow(
                                        label: "NIK",
                                        value: _data!["nik"]?.toString(),
                                        onCopy: () => _copy(
                                            _data!["nik"]?.toString() ?? "",
                                            "NIK"),
                                      ),
                                      _buildInfoRow(
                                        label: "Nama Lengkap",
                                        value: _data!["data"]["nama"]
                                            ?.toString(),
                                        onCopy: () => _copy(
                                            _data!["data"]["nama"]
                                                    ?.toString() ??
                                                "",
                                            "Nama"),
                                      ),
                                      _buildInfoRow(
                                        label: "Jenis Kelamin",
                                        value: _data!["data"]["kelamin"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Tempat Lahir",
                                        value: _data!["data"]["tempat_lahir"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Usia",
                                        value: _data!["data"]["usia"]
                                            ?.toString(),
                                      ),
                                    ],
                                  ),
                                  _buildCategoryCard(
                                    title: "DATA DOMISILI",
                                    icon: Icons.location_on,
                                    children: [
                                      _buildInfoRow(
                                        label: "Provinsi",
                                        value: _data!["data"]["provinsi"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Kabupaten/Kota",
                                        value: _data!["data"]["kabupaten"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Kecamatan",
                                        value: _data!["data"]["kecamatan"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Kelurahan/Desa",
                                        value: _data!["data"]["kelurahan"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Alamat Lengkap",
                                        value: _data!["data"]["alamat"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "TPS",
                                        value: _data!["data"]["tps"]
                                            ?.toString(),
                                      ),
                                    ],
                                  ),
                                  _buildCategoryCard(
                                    title: "INFORMASI TAMBAHAN",
                                    icon: Icons.info,
                                    children: [
                                      _buildInfoRow(
                                        label: "Zodiak",
                                        value: _data!["data"]["zodiak"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Ultah Mendatang",
                                        value: _data!["data"]
                                                ["ultah_mendatang"]
                                            ?.toString(),
                                      ),
                                      _buildInfoRow(
                                        label: "Pasaran",
                                        value: _data!["data"]["pasaran"]
                                            ?.toString(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
 *  IP SCANNER
 * ============================================================ */
class IpScannerResult {
  final String ip;
  final String country;
  final String countryCode;
  final String region;
  final String regionName;
  final String city;
  final String zip;
  final double lat;
  final double lon;
  final String timezone;
  final String isp;
  final String org;
  final String as;
  final String query;
  final bool isValid;
  final Map<String, dynamic> rawData;

  IpScannerResult({
    required this.ip,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.regionName,
    required this.city,
    required this.zip,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.isp,
    required this.org,
    required this.as,
    required this.query,
    required this.isValid,
    required this.rawData,
  });

  factory IpScannerResult.fromJson(
      Map<String, dynamic> json, String queryIp) {
    return IpScannerResult(
      ip: json['ip'] ?? queryIp,
      country: json['country'] ?? 'Unknown',
      countryCode: json['countryCode'] ?? 'Unknown',
      region: json['region'] ?? 'Unknown',
      regionName: json['regionName'] ?? 'Unknown',
      city: json['city'] ?? 'Unknown',
      zip: json['zip'] ?? 'Unknown',
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
      timezone: json['timezone'] ?? 'Unknown',
      isp: json['isp'] ?? 'Unknown',
      org: json['org'] ?? 'Unknown',
      as: json['as'] ?? 'Unknown',
      query: json['query'] ?? queryIp,
      isValid: json['ip'] != null,
      rawData: json,
    );
  }

  factory IpScannerResult.local(String ip) {
    return IpScannerResult(
      ip: ip,
      country: 'Local Network',
      countryCode: 'LOCAL',
      region: 'Local',
      regionName: 'Local Network',
      city: 'Local',
      zip: 'N/A',
      lat: 0,
      lon: 0,
      timezone: 'Local',
      isp: 'Local Network',
      org: 'Local',
      as: 'N/A',
      query: ip,
      isValid: true,
      rawData: {},
    );
  }

  factory IpScannerResult.invalid(String ip) {
    return IpScannerResult(
      ip: ip,
      country: 'Invalid',
      countryCode: 'INVALID',
      region: 'Invalid',
      regionName: 'Invalid',
      city: 'Invalid',
      zip: 'N/A',
      lat: 0,
      lon: 0,
      timezone: 'Unknown',
      isp: 'Unknown',
      org: 'Unknown',
      as: 'Unknown',
      query: ip,
      isValid: false,
      rawData: {},
    );
  }
}

class IpValidator {
  static bool isValidIPv4(String ip) {
    final RegExp ipv4Regex = RegExp(
      r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipv4Regex.hasMatch(ip);
  }

  static bool isPrivateIP(String ip) {
    final RegExp privateRegex = RegExp(
      r'^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.|169\.254\.)',
    );
    return privateRegex.hasMatch(ip);
  }

  static bool isLoopback(String ip) {
    return ip.startsWith('127.') || ip == 'localhost';
  }

  static String getIPClass(String ip) {
    if (!isValidIPv4(ip)) return 'Invalid';
    final firstOctet = int.parse(ip.split('.')[0]);
    if (firstOctet >= 1 && firstOctet <= 126) return 'Class A';
    if (firstOctet >= 128 && firstOctet <= 191) return 'Class B';
    if (firstOctet >= 192 && firstOctet <= 223) return 'Class C';
    if (firstOctet >= 224 && firstOctet <= 239) return 'Class D (Multicast)';
    if (firstOctet >= 240 && firstOctet <= 255) return 'Class E (Reserved)';
    return 'Unknown';
  }
}

class IpScannerPage extends StatefulWidget {
  const IpScannerPage({super.key});

  @override
  State<IpScannerPage> createState() => _IpScannerPageState();
}

class _IpScannerPageState extends State<IpScannerPage> {
  final TextEditingController _ipController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  IpScannerResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _scanIp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });
    final ip = _ipController.text.trim();

    if (IpValidator.isPrivateIP(ip) || IpValidator.isLoopback(ip)) {
      setState(() {
        _result = IpScannerResult.local(ip);
        _isLoading = false;
      });
      return;
    }

    if (!IpValidator.isValidIPv4(ip)) {
      setState(() {
        _result = IpScannerResult.invalid(ip);
        _isLoading = false;
        _errorMessage = 'Format IP tidak valid';
      });
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse(
                'http://ip-api.com/json/$ip?fields=status,message,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,query'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _result = IpScannerResult.fromJson(data, ip);
            _isLoading = false;
          });
        } else {
          setState(() {
            _result = IpScannerResult.local(ip);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _result = IpScannerResult.local(ip);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = IpScannerResult.local(ip);
        _isLoading = false;
      });
    }
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label disalin'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.dns_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Text('IP Scanner',
                        style:
                            _heading(size: 18, weight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _ipController,
                                keyboardType: TextInputType.number,
                                style: _body(size: 15),
                                cursorColor: AppColors.primary,
                                decoration: InputDecoration(
                                  hintText: '8.8.8.8 atau 192.168.1.1',
                                  hintStyle: _body(
                                      size: 13, color: AppColors.textDim),
                                  prefixIcon: const Icon(Icons.dns_rounded,
                                      color: AppColors.primary, size: 20),
                                  filled: true,
                                  fillColor: AppColors.bg.withOpacity(0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                        BorderSide(color: AppColors.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                        BorderSide(color: AppColors.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: AppColors.primary, width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'IP tidak boleh kosong';
                                  }
                                  if (!IpValidator.isValidIPv4(value) &&
                                      !IpValidator.isPrivateIP(value) &&
                                      value != 'localhost') {
                                    return 'Format IP tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _chip('8.8.8.8'),
                                  _chip('1.1.1.1'),
                                  _chip('192.168.1.1'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                label: 'SCAN IP',
                                icon: Icons.search_rounded,
                                loading: _isLoading,
                                onPressed: _isLoading ? null : _scanIp,
                                fullWidth: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_result != null) _buildResultCard(_result!),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String ip) {
    return PressableScale(
      onTap: () {
        _ipController.text = ip;
        _scanIp();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgCard2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(ip, style: _body(size: 11, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildResultCard(IpScannerResult result) {
    final isLocal = result.countryCode == 'LOCAL' ||
        result.country == 'Local Network';
    return ElevCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (result.isValid
                          ? AppColors.success
                          : AppColors.danger)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  result.isValid
                      ? Icons.check_circle_rounded
                      : Icons.error_rounded,
                  color: result.isValid
                      ? AppColors.success
                      : AppColors.danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.ip,
                        style:
                            _body(size: 15, weight: FontWeight.w700)),
                    Text(result.isValid ? 'Valid' : 'Invalid',
                        style: _body(
                            size: 11,
                            color: result.isValid
                                ? AppColors.success
                                : AppColors.danger,
                            weight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          if (!isLocal) ...[
            _row(Icons.public_rounded, 'Country',
                '${result.country} (${result.countryCode})'),
            _row(Icons.location_city_rounded, 'City', result.city),
            _row(Icons.map_rounded, 'Region', result.regionName),
            _row(Icons.business_rounded, 'ISP', result.isp),
            _row(Icons.apartment_rounded, 'Organization', result.org),
            _row(Icons.link_rounded, 'AS Number', result.as),
          ],
          _row(Icons.timeline_rounded, 'IP Class',
              IpValidator.getIPClass(result.ip)),
          _row(
              Icons.security_rounded,
              'Type',
              IpValidator.isPrivateIP(result.ip)
                  ? 'Private'
                  : (IpValidator.isLoopback(result.ip)
                      ? 'Loopback'
                      : 'Public')),
          if (!isLocal && result.timezone != 'Unknown')
            _row(Icons.access_time_rounded, 'Timezone', result.timezone),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label,
                style: _body(size: 12, color: AppColors.textDim)),
          ),
          Expanded(
            child: Text(value,
                style: _body(size: 12, weight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () => _copy(value, label),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy_rounded,
                  color: AppColors.textDim, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
 *  EMAIL OSINT
 * ============================================================ */
class EmailOsintResult {
  final String email;
  final bool isValid;
  final String domain;
  final bool isDisposable;
  final bool hasMx;
  final String? provider;
  final String? risk;
  final Map<String, dynamic> rawData;

  EmailOsintResult({
    required this.email,
    required this.isValid,
    required this.domain,
    required this.isDisposable,
    required this.hasMx,
    this.provider,
    this.risk,
    required this.rawData,
  });
}

class EmailOsintPage extends StatefulWidget {
  const EmailOsintPage({super.key});

  @override
  State<EmailOsintPage> createState() => _EmailOsintPageState();
}

class _EmailOsintPageState extends State<EmailOsintPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  EmailOsintResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _lookupEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    final email = _emailController.text.trim();
    final domain = email.split('@').last.toLowerCase();

    bool isDisposable = [
      'tempmail.com',
      '10minutemail.com',
      'guerrillamail.com',
      'mailinator.com',
      'yopmail.com',
      'sharklasers.com',
      'temp-mail.org'
    ].contains(domain);

    String? provider;
    if (domain.contains('gmail')) {
      provider = 'Google (Gmail)';
    } else if (domain.contains('yahoo')) {
      provider = 'Yahoo';
    } else if (domain.contains('outlook') ||
        domain.contains('hotmail') ||
        domain.contains('live')) {
      provider = 'Microsoft (Outlook)';
    } else if (domain.contains('proton')) {
      provider = 'ProtonMail';
    } else if (domain.contains('icloud') || domain.contains('me.com')) {
      provider = 'Apple (iCloud)';
    } else if (domain.contains('zoho')) {
      provider = 'Zoho Mail';
    } else {
      provider = 'Custom Domain';
    }

    bool hasMx = !isDisposable;
    try {
      final res = await http
          .get(Uri.parse('https://dns.google/resolve?name=$domain&type=MX'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        hasMx =
            data['Answer'] != null && (data['Answer'] as List).isNotEmpty;
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _result = EmailOsintResult(
        email: email,
        isValid: email.contains('@') && email.contains('.'),
        domain: domain,
        isDisposable: isDisposable,
        hasMx: hasMx,
        provider: provider,
        risk: isDisposable ? 'High' : (hasMx ? 'Low' : 'Medium'),
        rawData: {},
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.softIndigo, AppColors.purple],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.softIndigo.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.email_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Text('Email OSINT',
                        style:
                            _heading(size: 18, weight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: _body(size: 15),
                                decoration: InputDecoration(
                                  hintText: 'example@email.com',
                                  hintStyle: _body(
                                      size: 13, color: AppColors.textDim),
                                  prefixIcon: const Icon(Icons.email_rounded,
                                      color: AppColors.softIndigo,
                                      size: 20),
                                  filled: true,
                                  fillColor: AppColors.bg.withOpacity(0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                        BorderSide(color: AppColors.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                        BorderSide(color: AppColors.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: AppColors.softIndigo,
                                        width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                label: 'LOOKUP EMAIL',
                                icon: Icons.search_rounded,
                                loading: _isLoading,
                                colors: const [
                                  AppColors.softIndigo,
                                  AppColors.purple
                                ],
                                onPressed:
                                    _isLoading ? null : _lookupEmail,
                                fullWidth: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ],
                          ),
                        ),
                        if (_result != null) ...[
                          const SizedBox(height: 20),
                          _buildResultCard(_result!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(EmailOsintResult result) {
    return Column(
      children: [
        ElevCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (result.isValid
                              ? AppColors.success
                              : AppColors.danger)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      result.isValid
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: result.isValid
                          ? AppColors.success
                          : AppColors.danger,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(result.email,
                        style: _body(size: 14, weight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              _row('Domain', result.domain),
              _row('Provider', result.provider ?? 'Unknown'),
              _row('MX Record', result.hasMx ? 'Tersedia' : 'Tidak',
                  valueColor:
                      result.hasMx ? AppColors.success : AppColors.warning),
              _row('Disposable', result.isDisposable ? 'Ya' : 'Tidak',
                  valueColor:
                      result.isDisposable ? AppColors.danger : AppColors.success),
              _row('Risk Level', result.risk ?? 'Low',
                  valueColor: result.risk == 'High'
                      ? AppColors.danger
                      : result.risk == 'Medium'
                          ? AppColors.warning
                          : AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: _body(size: 12, color: AppColors.textDim)),
          ),
          Expanded(
            child: Text(value,
                style: _body(
                    size: 12, weight: FontWeight.w600, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
 *  ABOUT SCREEN
 * ============================================================ */
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal buka: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.info_outline_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Text('Tentang App',
                        style:
                            _heading(size: 18, weight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const AppLogo(size: 100),
                            const SizedBox(height: 16),
                            Text('HiyukiCrash',
                                style: _heading(
                                    size: 24, weight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text('Version 1.0.0',
                                style: _body(
                                    size: 13, color: AppColors.textDim)),
                            const SizedBox(height: 4),
                            Text('Build 2026',
                                style: _body(
                                    size: 12, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.code_rounded,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: 10),
                                Text('TENTANG APLIKASI',
                                    style: _body(
                                        size: 11,
                                        color: AppColors.primary,
                                        weight: FontWeight.w800,
                                        letterSpacing: 1.5)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'HiyukiCrash adalah automation core untuk WhatsApp yang dikembangkan oleh @lanzdevkrk91. Aplikasi ini mendukung multi-session, chat global realtime, WA bug tools, dan berbagai utility tools lainnya.',
                              style: _body(
                                  size: 13,
                                  color: AppColors.textDim,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_rounded,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: 10),
                                Text('DEVELOPER',
                                    style: _body(
                                        size: 11,
                                        color: AppColors.primary,
                                        weight: FontWeight.w800,
                                        letterSpacing: 1.5)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            PressableScale(
                              onTap: () => _openUrl(
                                  context, 'https://t.me/lanzdevkrk91'),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF229ED9),
                                      Color(0xFF0088CC)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF229ED9)
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.telegram,
                                        color: Colors.white, size: 28),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Telegram',
                                              style: _body(
                                                  size: 11,
                                                  color: Colors.white70,
                                                  weight:
                                                      FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Text('@lanzdevkrk91',
                                              style: _body(
                                                  size: 16,
                                                  weight: FontWeight.w800,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.warning, size: 18),
                                const SizedBox(width: 10),
                                Text('FITUR UTAMA',
                                    style: _body(
                                        size: 11,
                                        color: AppColors.warning,
                                        weight: FontWeight.w800,
                                        letterSpacing: 1.5)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _featureItem(Icons.smartphone_rounded,
                                'Multi-Session WhatsApp'),
                            _featureItem(Icons.public_rounded,
                                'Chat Global Realtime'),
                            _featureItem(Icons.bug_report_rounded,
                                'WA Bug Tools'),
                            _featureItem(Icons.build_rounded,
                                'Tools Keren (TikTok, NIK, IP, Email)'),
                            _featureItem(Icons.security_rounded,
                                'Auto-Restore Session'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: AppColors.danger, size: 18),
                                const SizedBox(width: 10),
                                Text('DISCLAIMER',
                                    style: _body(
                                        size: 11,
                                        color: AppColors.danger,
                                        weight: FontWeight.w800,
                                        letterSpacing: 1.5)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aplikasi ini dibuat untuk tujuan edukasi dan testing keamanan. Pengguna bertanggung jawab penuh atas penggunaan aplikasi. Dilarang menggunakan untuk aktivitas ilegal atau merugikan orang lain tanpa izin.',
                              style: _body(
                                  size: 13,
                                  color: AppColors.textDim,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Text('© 2026 HiyukiCrash',
                                style: _body(
                                    size: 12,
                                    color: AppColors.textDim,
                                    weight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Made with ❤ in Indonesia',
                                style: _body(
                                    size: 11, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: _body(size: 13, weight: FontWeight.w600)),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 16),
        ],
      ),
    );
  }
}