/// ai_chat_widget.dart
///
/// The always-visible AI shopping assistant panel for customer_home_screen.
/// Renders as an iMessage/WhatsApp-style chat already open inline on the
/// home screen (not a hidden FAB/modal) — per the brief, the AI should
/// feel like part of the shopping experience, not a hidden feature.
///
/// This widget is intentionally dumb about AI logic: it takes a message
/// list + onSend callback. Wire `onSend` to your existing AI endpoint in
/// api_client.dart / app_bloc.dart — nothing about how the AI actually
/// responds changes.
///
/// ```dart
/// AiChatWidget(
///   messages: aiMessages, // List<AiChatMessage>
///   isTyping: aiBloc.isResponding,
///   suggestions: const ['Surprise me 🎲', 'Something under 10 BAM', 'High protein'],
///   onSend: (text) => aiBloc.sendMessage(text),
///   onSuggestionTap: (s) => aiBloc.sendMessage(s),
/// )
/// ```
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'blurred_container.dart';

enum AiChatRole { user, ai }

class AiChatMessage {
  const AiChatMessage({required this.role, required this.text, this.timestamp});
  final AiChatRole role;
  final String text;
  final DateTime? timestamp;
}

class AiChatWidget extends StatefulWidget {
  const AiChatWidget({
    super.key,
    required this.messages,
    required this.onSend,
    this.isTyping = false,
    this.suggestions = const [],
    this.onSuggestionTap,
    this.title = 'AI Shopping Assistant',
    this.subtitle = 'Ask for anything — I\'ll find it',
    this.collapsedHeight = 260,
    this.expandable = true,
  });

  final List<AiChatMessage> messages;
  final ValueChanged<String> onSend;
  final bool isTyping;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestionTap;
  final String title;
  final String subtitle;

  /// Initial visible height when collapsed (it's always open, just sized
  /// small until the user engages — never fully hidden).
  final double collapsedHeight;
  final bool expandable;

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant AiChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
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
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    if (!_expanded) setState(() => _expanded = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = _expanded ? 460.0 : widget.collapsedHeight;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.glow(AppColors.accentViolet, opacity: 0.18),
      ),
      child: BlurredContainer(
        blur: AppBlur.lg,
        borderRadius: AppRadius.xlRadius,
        gradientBorder: true,
        padding: EdgeInsets.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          height: height,
          child: Column(
            children: [
              _Header(
                title: widget.title,
                subtitle: widget.subtitle,
                expanded: _expanded,
                expandable: widget.expandable,
                onToggle: () => setState(() => _expanded = !_expanded),
              ),
              const Divider(height: 1),
              Expanded(
                child: widget.messages.isEmpty
                    ? _EmptyState(isDark: isDark)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: widget.messages.length + (widget.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == widget.messages.length) {
                            return const _TypingBubble();
                          }
                          return _MessageBubble(message: widget.messages[index]);
                        },
                      ),
              ),
              if (widget.suggestions.isNotEmpty && widget.messages.isEmpty)
                _SuggestionRow(
                  suggestions: widget.suggestions,
                  onTap: widget.onSuggestionTap ?? widget.onSend,
                ),
              _InputBar(controller: _controller, onSend: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.expandable,
    required this.onToggle,
  });
  final String title;
  final String subtitle;
  final bool expanded;
  final bool expandable;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(gradient: AppColors.aiGradient, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.bodyEmphasis(isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                Text(subtitle, style: AppTypography.footnote(isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ],
            ),
          ),
          if (expandable)
            IconButton(
              onPressed: onToggle,
              icon: AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Try "something spicy under 15 BAM" or "surprise me"',
          textAlign: TextAlign.center,
          style: AppTypography.subheadline(isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestions, required this.onTap});
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => onTap(suggestions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.accentViolet.withOpacity(0.12),
                borderRadius: AppRadius.pillRadius,
                border: Border.all(color: AppColors.accentViolet.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Text(suggestions[i], style: AppTypography.footnote(AppColors.accentViolet)),
            ),
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiChatRole.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.65),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.accentGradient : null,
          color: isUser ? null : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.md),
            topRight: const Radius.circular(AppRadius.md),
            bottomLeft: Radius.circular(isUser ? AppRadius.md : 4),
            bottomRight: Radius.circular(isUser ? 4 : AppRadius.md),
          ),
        ),
        child: Text(
          message.text,
          style: AppTypography.callout(
            isUser ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.md),
            topRight: Radius.circular(AppRadius.md),
            bottomRight: Radius.circular(AppRadius.md),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_controller.value - i * 0.2) % 1.0;
                final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0, 1).toDouble();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: AppColors.accentViolet, shape: BoxShape.circle),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                borderRadius: AppRadius.pillRadius,
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                style: AppTypography.callout(isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ask the AI assistant…',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(gradient: AppColors.accentGradient, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
