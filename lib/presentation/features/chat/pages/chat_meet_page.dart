import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/chat_controller.dart';

class ChatMeetPage extends StatefulWidget {
  final int? meetingId;

  const ChatMeetPage({super.key, this.meetingId});

  @override
  State<ChatMeetPage> createState() => _ChatMeetPageState();
}

class _ChatMeetPageState extends State<ChatMeetPage> {
  late TextEditingController _messageController;
  late ChatController _controller;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _controller = Get.find<ChatController>();

    // Initialize chat when page is opened
    if (widget.meetingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.initializeChat(meetingId: widget.meetingId!);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.35),
              BlendMode.dstATop,
            ),
            onError: (exception, stackTrace) {},
          ),
        ),
        child: Obx(() {
          if (_controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }

          if (!_controller.isConnected.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: AppIconSize.xxl,
                    color: AppColors.gray,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Tidak terhubung ke chat',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_controller.errorMessage.value.isNotEmpty)
                    Text(
                      _controller.errorMessage.value,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(child: _buildMessageList()),
                _buildMessageInput(),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Widget untuk App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: AppElevation.sm,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),

          const SizedBox(width: 4),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rapat Koordinasi',
                style: AppTextStyles.title.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  '${_controller.messages.length} pesan',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk List Pesan
  Widget _buildMessageList() {
    return Obx(() {
      final messages = _controller.messages;

      if (messages.isEmpty) {
        return Center(
          child: Text(
            'Belum ada pesan',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textLight),
          ),
        );
      }

      return ListView.builder(
        padding: AppSpacing.paddingLG,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildMessageBubble(message);
        },
      );
    });
  }

  // Widget untuk Message Bubble
  Widget _buildMessageBubble(dynamic message) {
    final isMe = message.isMe;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildSenderName(message.senderName),
          if (!isMe) const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primaryDark
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(
                        isMe ? AppRadius.lg : AppRadius.sm,
                      ),
                      bottomRight: Radius.circular(
                        isMe ? AppRadius.sm : AppRadius.lg,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: AppElevation.sm,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: AppTextStyles.body.copyWith(
                          color: isMe ? Colors.white : AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatTime(message.timestamp),
                        style: AppTextStyles.caption.copyWith(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk Nama Pengirim
  Widget _buildSenderName(String sender) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.sm),
      child: Text(
        sender,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  // Widget untuk Input Pesan
  Widget _buildMessageInput() {
    final messageController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: AppElevation.sm,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(child: _buildTextField(messageController)),
            SizedBox(width: AppSpacing.md),
            _buildSendButton(messageController),
          ],
        ),
      ),
    );
  }

  // Widget untuk Text Field
  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Ketik pesan...',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (text) {
          if (widget.meetingId != null && text.trim().isNotEmpty) {
            _controller.sendMessage(text, widget.meetingId!);
            controller.clear();
          }
        },
      ),
    );
  }

  // Widget untuk Tombol Kirim
  Widget _buildSendButton(TextEditingController messageController) {
    return GestureDetector(
      onTap: () {
        final message = messageController.text.trim();
        if (message.isNotEmpty && widget.meetingId != null) {
          // Send message via controller
          _controller.sendMessage(message, widget.meetingId!);
          messageController.clear();
        }
      },
      child: Container(
        width: AppIconSize.xl,
        height: AppIconSize.xl,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.send,
          color: AppColors.cardBackground,
          size: AppIconSize.sm,
        ),
      ),
    );
  }

  // Format timestamp
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
