import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';

class InAppBannerOverlay extends StatefulWidget {
  final Widget child;
  const InAppBannerOverlay({super.key, required this.child});

  @override
  State<InAppBannerOverlay> createState() => _InAppBannerOverlayState();
}

class _InAppBannerOverlayState extends State<InAppBannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  bool _visible = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _offset = Tween(begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _show() {
    if (_visible) return;
    setState(() => _visible = true);
    _ctrl.forward();
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (!mounted || !_visible) return;
    _ctrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _visible = false);
      context.read<NotificationProvider>().dismissBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        if (provider.showBanner && !_visible) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _show());
        }

        return Stack(
          children: [
            widget.child,
            if (_visible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: SlideTransition(
                    position: _offset,
                    child: _Banner(
                      onTap: () {
                        _dismiss();
                        provider.markAsRead();
                        NotificationService.navigatorKey.currentState
                            ?.pushNamedAndRemoveUntil('/', (_) => false);
                      },
                      onClose: _dismiss,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _Banner({required this.onTap, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Material(
          elevation: 12,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF050A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🌎', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Global News Report',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '오늘의 글로벌 리포트가 도착했습니다',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '시장 분위기: 밝음 · 테마: 친환경 & AI 기술',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
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
