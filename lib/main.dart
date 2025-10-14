// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AtlasChatApp());
}

class AtlasChatApp extends StatelessWidget {
  const AtlasChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  bool _isLandscapeOrDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    return kIsWeb || orientation == Orientation.landscape || size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = _isLandscapeOrDesktop(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: isLandscape
                ? const ChatPage()
                : Column(
              children: [
                const SizedBox(height: 16),
                _buildPortraitHeader(context),
                const SizedBox(height: 8),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ChatPage(),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_rounded,
              size: 22,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'پاسخگویی به سوالات مربوط به انواع دستگاه ها و اخبار سایت',
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
