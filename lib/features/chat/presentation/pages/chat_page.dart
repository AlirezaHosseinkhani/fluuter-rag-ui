// features/chat/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/scroll_to_bottom_button.dart';
import '../widgets/info_card.dart';
import '../../domain/entities/message.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ChatBloc>()..add(ChatStarted()),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final showButton = _scrollController.offset <
          _scrollController.position.maxScrollExtent - 100;
      if (showButton != _showScrollButton) {
        setState(() => _showScrollButton = showButton);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollToBottomInstant() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  bool _isLandscapeOrDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    return kIsWeb && orientation == Orientation.landscape || size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = _isLandscapeOrDesktop(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceColor,
        appBar: isLandscape ? null : _buildAppBar(context),
        body: isLandscape
            ? _buildLandscapeLayout(context)
            : _buildPortraitLayout(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            AppConstants.poweredByRobit,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth < 1200 ? 320.0 : 360.0;

    return Row(
      children: [
        _buildSidebar(context, sidebarWidth),
        Expanded(
          child: Column(
            children: [
              _buildChatHeader(context),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1500),
                  child: _buildChatContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: AppTheme.surfaceColor,
            width: 1,
          ),
        ),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    icon: Icons.rocket_launch_outlined,
                    title: AppConstants.poweredByRobit,
                    content: 'قدرت گرفته از هوش مصنوعی پیشرفته',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.travel_explore_outlined,
                    title: 'وب‌سایت طرح و پردازش غدیر',
                    content: 'مراجعه به وب‌سایت طرح و پردازش غدیر',
                    onTap: () => launchUrl(
                      Uri.parse('https://ghadir.co/'),
                      mode: LaunchMode.platformDefault,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.workspaces,
                    title: 'وب‌سایت اطلس',
                    content: 'مشاهده و بررسی وبسایت اطلس',
                    onTap: () => launchUrl(
                      Uri.parse('https://atlasco.org/'),
                      mode: LaunchMode.platformDefault,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.info_outline,
                    title: 'تماس ما',
                    content: 'پاسخگویی به سوالات و خرید محصولات',
                    onTap: () => launchUrl(
                      Uri.parse('https://ghadir.co/contact/'),
                      mode: LaunchMode.platformDefault,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.surfaceColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.surfaceColor,
                  Colors.grey.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Image.asset(
              'assets/images/ghadir.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'همراه ۲۴ ساعته شما',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.surfaceColor,
            width: 1,
          ),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.mark_unread_chat_alt,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'گفتگو با دستیار هوشمند',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
          _buildOnlineStatus(),
        ],
      ),
    );
  }

  Widget _buildOnlineStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'آنلاین',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return _buildChatContent(context);
  }

  Widget _buildChatContent(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded) {
          _scrollToBottomInstant();
        }
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatInitial) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          );
        }

        if (state is ChatLoaded) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    _buildMessageList(context, state),
                    if (_showScrollButton)
                      ScrollToBottomButton(
                        onPressed: _scrollToBottom,
                        isLandscape: _isLandscapeOrDesktop(context),
                      ),
                  ],
                ),
              ),
              MessageInput(
                onSend: (content) {
                  context.read<ChatBloc>().add(MessageSent(content));
                },
                enabled: !state.isTyping,
                isLandscape: _isLandscapeOrDesktop(context),
              ),
            ],
          );
        }

        return Center(
          child: Text(
            'خطایی رخ داده است',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageList(BuildContext context, ChatLoaded state) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: Image.asset(
                'assets/images/ghadir.png',
                fit: BoxFit.none,
                // repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          // Messages
          ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(_isLandscapeOrDesktop(context) ? 32 : 16),
            itemCount: state.messages.length + (state.isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.messages.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, top: 8),
                    child: TypingIndicator(),
                  ),
                );
              }

              final message = state.messages[index];
              final isWelcomeMessage = message.id == 'welcome';

              return MessageBubble(
                message: message,
                isLandscape: _isLandscapeOrDesktop(context),
                onLike: !message.isUser && !isWelcomeMessage
                    ? () => context.read<ChatBloc>().add(
                  FeedbackSent(message.id, FeedbackType.like),
                )
                    : null,
                onDislike: !message.isUser && !isWelcomeMessage
                    ? () => context.read<ChatBloc>().add(
                  FeedbackSent(message.id, FeedbackType.dislike),
                )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
