import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_chat_service.dart';
import '../theme/app_theme.dart';

class AiChatFloatingWidget extends StatefulWidget {
  const AiChatFloatingWidget({super.key});

  @override
  State<AiChatFloatingWidget> createState() => _AiChatFloatingWidgetState();
}

class _AiChatFloatingWidgetState extends State<AiChatFloatingWidget> {
  bool _isOpen = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final message = presetText ?? _textController.text;
    if (message.trim().isEmpty) return;

    _textController.clear();
    AiChatService.instance.sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;

    return Stack(
      children: [
        if (_isOpen)
          Positioned(
            right: isDesktop ? 20 : 12,
            bottom: isDesktop ? 80 : 12,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
              child: Container(
                width: isDesktop ? 390 : screenWidth - 24,
                height: isDesktop ? 580 : MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 31, 63, 0.18),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Bar
                    _buildHeader(context),

                    // Quick Suggestion Chips
                    _buildSuggestionChips(),

                    const Divider(height: 1),

                    // Chat Messages List
                    Expanded(child: _buildMessageList()),

                    // Input Bar
                    _buildInputBar(),
                  ],
                ),
              ),
            ),
          ),

        // Floating Action Button
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _isOpen = !_isOpen;
              });
              if (_isOpen) {
                _scrollToBottom();
              }
            },
            backgroundColor: AppColors.primary,
            elevation: 6,
            icon: Icon(
              _isOpen ? Icons.close : Icons.smart_toy,
              color: Colors.white,
            ),
            label: Text(
              _isOpen ? 'Close' : 'AI Coach',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.anchor, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maritime AI Coach ⚓',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Online • Session History Saved',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
            tooltip: 'Clear Chat History',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Chat History?'),
                  content: const Text('This will reset your current AI conversation session.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        AiChatService.instance.clearHistory();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 24),
            onPressed: () {
              setState(() {
                _isOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'Gate Valve 🔧',
      'Purifier vs Clarifier ⚙️',
      'Scavenge Fire 🚨',
      'Blackout Recovery ⚡',
      'COLREG Rule 15 & 19 📜',
      'OWS 15 PPM Rules 🌊',
    ];

    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions.map((text) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                label: Text(
                  text,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.surfaceContainerHigh,
                side: const BorderSide(color: AppColors.outlineVariant),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                onPressed: () => _handleSend(text),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return AnimatedBuilder(
      animation: AiChatService.instance,
      builder: (context, _) {
        final messages = AiChatService.instance.messages;
        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, idx) {
            final msg = messages[idx];
            final isUser = msg.sender == ChatSender.user;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.actionBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.smart_toy,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primary
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        border: isUser
                            ? null
                            : Border.all(color: AppColors.outlineVariant),
                      ),
                      child: SelectableText(
                        msg.text,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: isUser ? Colors.white : AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  if (isUser) const SizedBox(width: 4),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    return AnimatedBuilder(
      animation: AiChatService.instance,
      builder: (context, _) {
        final isGenerating = AiChatService.instance.isGenerating;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(19)),
            border: Border(
              top: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: !isGenerating,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ask any Maritime or Interview question...',
                    hintStyle:
                        TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: isGenerating ? null : () => _handleSend(),
                icon: isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.actionBlue,
                        ),
                      )
                    : const Icon(Icons.send, color: AppColors.actionBlue, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
