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
  late ScrollController _scrollController;
  late FocusNode _focusNode;
  bool _isAtBottom = true;
  double _lastKeyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _controller = Get.find<ChatController>();

    // Listen to focus changes
    _focusNode.addListener(_onFocusChange);

    // Listen to scroll position
    _scrollController.addListener(_updateScrollPosition);

    // Initialize chat when page is opened
    if (widget.meetingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.initializeChat(meetingId: widget.meetingId!);
        Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
      });
    }

    // Listen to message changes and scroll to bottom
    ever(_controller.messages, (_) {
      if (_isAtBottom) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_focusNode.hasFocus) {
            _scrollWithOffset();
          } else {
            _scrollToBottom();
          }
        });
      }
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Auto scroll to bottom saat input difokuskan
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients && _focusNode.hasFocus) {
          _scrollWithOffset();
        }
      });

      // Juga scroll lagi saat keyboard fully appeared
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_scrollController.hasClients && _focusNode.hasFocus) {
          _scrollWithOffset();
        }
      });
    }
  }

  void _updateScrollPosition() {
    if (_scrollController.hasClients) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.offset;
      _isAtBottom = (currentScroll >= maxScroll - 50);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.removeListener(_updateScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollWithOffset() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent +
            MediaQuery.of(context).viewInsets.bottom,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect keyboard height changes
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Trigger scroll when keyboard appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (keyboardHeight > 0 && keyboardHeight != _lastKeyboardHeight) {
        _lastKeyboardHeight = keyboardHeight;
        if (_focusNode.hasFocus && _scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollWithOffset();
          });
        }
      } else if (keyboardHeight == 0 && _lastKeyboardHeight > 0) {
        _lastKeyboardHeight = keyboardHeight;
        if (_scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        }
      }
    });

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
              child: CircularProgressIndicator(color: AppColors.primary),
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

          return Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildMessageInput(),
            ],
          );
        }),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  // Widget untuk App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: AppElevation.sm,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 12),
              Text(
                'Belum ada pesan',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        );
      }

      // Sort messages by timestamp
      final sortedMessages = List.from(messages);
      sortedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Scroll ke bawah setelah build jika user di posisi bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isAtBottom && _scrollController.hasClients) {
          _scrollToBottom();
        }
      });

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        itemCount: sortedMessages.length,
        itemBuilder: (context, index) {
          final message = sortedMessages[index];
          final showDateDivider = index == 0 ||
              !_isSameDay(
                sortedMessages[index - 1].timestamp,
                message.timestamp,
              );

          return Column(
            children: [
              if (showDateDivider) _buildDateDivider(message.timestamp),
              _buildMessageBubble(message),
            ],
          );
        },
      );
    });
  }

  // Widget untuk Date Divider
  Widget _buildDateDivider(DateTime timestamp) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.borderLight,
              thickness: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              _formatDateGroup(timestamp),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.borderLight,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateGroup(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Hari ini';
    } else if (messageDate == yesterday) {
      return 'Kemarin';
    } else if (messageDate.year == today.year) {
      return _formatDateWithDay(messageDate);
    } else {
      return _formatDateWithYear(messageDate);
    }
  }

  String _formatDateWithDay(DateTime date) {
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _formatDateWithYear(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Widget untuk Message Bubble
  Widget _buildMessageBubble(dynamic message) {
    final isMe = message.isMe;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildSenderName(message.senderName),
          if (!isMe) const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.cardBackground,
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
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
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
    return SafeArea(
      child: Container(
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
        focusNode: _focusNode,
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
            _messageController.clear();
            Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
          }
        },
      ),
    );
  }

  // Widget untuk Tombol Kirim
  Widget _buildSendButton() {
    return GestureDetector(
      onTap: () {
        final message = _messageController.text.trim();
        if (message.isNotEmpty && widget.meetingId != null) {
          _controller.sendMessage(message, widget.meetingId!);
          _messageController.clear();
          Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
        }
      },
      child: Container(
        width: AppIconSize.xl,
        height: AppIconSize.xl,
        decoration: BoxDecoration(
          color: AppColors.primary,
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
