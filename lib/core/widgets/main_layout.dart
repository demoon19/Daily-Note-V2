import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../../features/chat_assistant/providers/chat_providers.dart';
import '../email/providers/email_providers.dart';
import '../../features/chat_assistant/presentation/screens/chat_screen.dart' show isListeningProvider, speechToTextServiceProvider;

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final TextEditingController _aiController = TextEditingController();

  void _sendAiInput() {
    final text = _aiController.text.trim();
    if (text.isEmpty) return;
    
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
    _aiController.clear();
    
    // Pindah ke tab chat jika belum berada di sana
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (currentRoute != AppRoutes.chat) {
      context.go(AppRoutes.chat);
    }
  }

  Future<void> _toggleMic() async {
    final service = ref.read(speechToTextServiceProvider);
    final isListening = ref.read(isListeningProvider);
    if (isListening) {
      await service.stopListening();
      ref.read(isListeningProvider.notifier).state = false;
      return;
    }
    ref.read(isListeningProvider.notifier).state = true;
    await service.startListening(
      onResult: (text) => _aiController.text = text,
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.chat)) return 1;
    if (location.startsWith(AppRoutes.calendar)) return 2;
    if (location.startsWith(AppRoutes.todo)) return 3;
    if (location.startsWith(AppRoutes.expense)) return 4;
    return 0; // default home
  }

  void _onNavTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.chat);
        break;
      case 2:
        context.go(AppRoutes.calendar);
        break;
      case 3:
        context.go(AppRoutes.todo);
        break;
      case 4:
        context.go(AppRoutes.expense);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan gmail auth dan polling tetap hidup selama aplikasi berjalan
    ref.watch(gmailAuthStatusProvider);
    
    final isListening = ref.watch(isListeningProvider);
    final selectedIndex = _getSelectedIndex(context);

    // Hapus AI bar jika keyboard muncul (tergantung preferensi, atau angkat ke atas keyboard)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Latar belakang utama
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, -0.9),
                radius: 1.5,
                colors: [
                  Color(0x142DD4BF), // teal
                  Colors.transparent,
                ],
                stops: [0.0, 0.4],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, 0.9),
                radius: 1.5,
                colors: [
                  Color(0x1438BDF8), // cyan
                  Colors.transparent,
                ],
                stops: [0.0, 0.4],
              ),
            ),
          ),
          
          // Konten Layar (Child)
          Positioned.fill(
            bottom: bottomInset > 0 ? bottomInset : 0,
            child: widget.child,
          ),

          // Floating AI Input Bar (Signature Element)
          // Tampil di atas layar
          if (selectedIndex == 0) // Hanya tampilkan di Home
            Positioned(
              left: 20,
              right: 20,
              bottom: bottomInset > 0 ? bottomInset + 14 : 14,
              child: _buildAiBar(isListening),
            ),
        ],
      ),
      bottomNavigationBar: bottomInset > 0 
        ? null 
        : _buildBottomNav(selectedIndex, context),
    );
  }

  Widget _buildAiBar(bool isListening) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 12, top: 11, bottom: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 8),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _aiController,
              onSubmitted: (_) => _sendAiInput(),
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ketik atau ucapkan sesuatu…',
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendAiInput,
            onLongPress: _toggleMic,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.teal, AppColors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  isListening ? Icons.mic : Icons.send,
                  color: const Color(0xFF04121A),
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(int selectedIndex, BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.85),
            border: const Border(top: BorderSide(color: AppColors.line)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 14,
            top: 10,
            left: 8,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBtn(icon: Icons.home_outlined, label: 'Home', isSelected: selectedIndex == 0, onTap: () => _onNavTap(0, context)),
              _NavBtn(icon: Icons.chat_bubble_outline, label: 'Asisten', isSelected: selectedIndex == 1, onTap: () => _onNavTap(1, context)),
              _NavBtn(icon: Icons.calendar_today_outlined, label: 'Jadwal', isSelected: selectedIndex == 2, onTap: () => _onNavTap(2, context)),
              _NavBtn(icon: Icons.check_circle_outline, label: 'Todo', isSelected: selectedIndex == 3, onTap: () => _onNavTap(3, context)),
              _NavBtn(icon: Icons.attach_money_outlined, label: 'Uang', isSelected: selectedIndex == 4, onTap: () => _onNavTap(4, context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.teal : AppColors.textDisabled;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
