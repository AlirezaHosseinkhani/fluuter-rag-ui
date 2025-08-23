import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';
import '../../domain/entities/message.dart';
import '../../../../core/constants/app_constants.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
        backgroundColor: const Color(0xFFF8FAFC),
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
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            size: 12,
          ),
          const SizedBox(width: 8),
          const Text(
            AppConstants.poweredByRobit,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth < 1200 ? 300.0 : 350.0;

    return Row(
      children: [
        // Sidebar
        Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sidebar Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child:Image.asset(
                        'assets/images/ghadir.png',
                        width: 35,
                        height: 35,
                        // color: Theme.of(context).colorScheme.primary, // optional tint
                      )
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'همراه ۲۴ ساعته شما',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beta Version 0.1.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              // Info Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        icon: Icons.rocket_launch_outlined,
                        title: AppConstants.poweredByRobit,
                        content: 'قدرت گرفته از هوش مصنوعی پیشرفته',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.travel_explore_outlined,
                        title: 'وب‌سایت طرح و پردازش غدیر',
                        content: 'مراجعه به وب‌سایت طرح و پردازش غدیر',
                        onTap: () {
                          launchUrl(Uri.parse('https://ghadir.co/'), mode: LaunchMode.externalApplication);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.workspaces,
                        title: 'وب‌سایت اطلس',
                        content: 'مشاهده و بررسی وبسایت اطلس',
                        onTap: () {
                          launchUrl(Uri.parse('https://atlasco.org/'), mode: LaunchMode.externalApplication);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.info_outline,
                        title: 'تماس ما',
                        content: 'پاسخگویی به سوالات و خرید محصولات',
                        onTap: () {
                          launchUrl(Uri.parse('https://ghadir.co/contact/'), mode: LaunchMode.externalApplication);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Chat Area
        Expanded(
          child: Column(
            children: [
              // Chat App Bar
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 0.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_unread_chat_alt,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'گفتگو با دستیار هوشمند',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green.shade400,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'آنلاین',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Chat Content
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _buildChatContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return _buildChatContent(context);
  }

  Widget _buildChatContent(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded) {
          _scrollToBottom();
        }
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ChatLoaded) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF8FAFC),
                        Colors.grey.shade50,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/ghadir.png',
                          width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
                        ),
                      ),
                      ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(_isLandscapeOrDesktop(context) ? 24 : 16),
                        itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.messages.length) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
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

        return const Center(
          child: Text('خطایی رخ داده است'),
        );
      },
    );
  }

  Widget _buildInfoCard({
    IconData? icon, // optional now
    String? imageAsset, // optional, path to asset image
    required String title,
    required String content,
    VoidCallback? onTap, // optional function to execute on tap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                if (imageAsset != null)
                  Image.asset(
                    imageAsset,
                    width: 20,
                    height: 20,
                    color: Theme.of(context).colorScheme.primary, // optional tint
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

}