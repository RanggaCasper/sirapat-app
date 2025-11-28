import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';

class ChatMeetPage extends StatefulWidget {
  final int? meetingId;

  const ChatMeetPage({Key? key, this.meetingId}) : super(key: key);

  @override
  State<ChatMeetPage> createState() => _ChatMeetPageState();
}

class _ChatMeetPageState extends State<ChatMeetPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Dummy data untuk chat messages
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'sender': 'User A',
      'message':
          'Lorem ipsum dolor sit amet, consectetur adipiscing do tempor incididunt ulamco quis nostrud exercitation',
      'isMe': false,
      'timestamp': '10:30',
    },
    {
      'id': '2',
      'sender': 'Me',
      'message':
          'Lorem ipsum dolor sit amet, consectetur adipiscing do tempor incididunt ulamco quis nostrud exercitation',
      'isMe': true,
      'timestamp': '10:32',
    },
    {
      'id': '3',
      'sender': 'Me',
      'message':
          'Lorem ipsum dolor sit amet, consectetur adipiscing do tempor incididunt ulamco quis nostrud exercitation',
      'isMe': true,
      'timestamp': '10:33',
    },
    {
      'id': '4',
      'sender': 'User B',
      'message':
          'Lorem ipsum dolor sit amet, consectetur adipiscing do tempor incididunt ulamco quis nostrud exercitation',
      'isMe': false,
      'timestamp': '10:35',
    },
    {
      'id': '5',
      'sender': 'Me',
      'message':
          'Lorem ipsum dolor sit amet, consectetur adipiscing do tempor incididunt ulamco quis nostrud exercitation',
      'isMe': true,
      'timestamp': '10:36',
    },
    {
      'id': '6',
      'sender': 'User B',
      'message':
          'Lorem ipsum dolor sit amet, consectetur adipiscing do tempor incididunt ulamco quis nostrud exercitation',
      'isMe': false,
      'timestamp': '10:38',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Handler untuk mengirim pesan
  void _onSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'sender': 'Me',
        'message': text,
        'isMe': true,
        'timestamp': TimeOfDay.now().format(context),
      });
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            image: const AssetImage('assets/pattern.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.85),
              BlendMode.dstATop,
            ),
            onError: (exception, stackTrace) {},
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: AppElevation.sm,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
        onPressed: () {
          Get.back();
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rapat Koordinasi', style: AppTextStyles.title),
          const SizedBox(height: 2),
          Text(
            '8 peserta',
            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  // Widget untuk List Pesan
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: AppSpacing.paddingLG,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  // Widget untuk Message Bubble
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildSenderName(message['sender']),
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
                  child: Text(
                    message['message'],
                    style: AppTextStyles.body.copyWith(
                      color: isMe ? Colors.white : AppColors.textDark,
                      height: 1.4,
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
            Expanded(child: _buildTextField()),
            SizedBox(width: AppSpacing.md),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  // Widget untuk Text Field
  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: TextField(
        controller: _messageController,
        decoration: InputDecoration(
          hintText: 'Ketik notulensi',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _onSendMessage(),
      ),
    );
  }

  // Widget untuk Tombol Kirim
  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _onSendMessage,
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
}
