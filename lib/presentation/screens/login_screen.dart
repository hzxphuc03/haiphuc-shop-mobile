import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Optimization: Controllers and FocusNodes are kept here to maintain stability
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).login(
        _usernameController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Parent build method MUST NOT watch any state.
    // It only provides the structure.
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Render Isolation: Static Header
                const RepaintBoundary(child: _LoginHeader()),
                const SizedBox(height: 50),
                
                // Render Isolation: Input Fields (Frequent Repaints due to cursor)
                RepaintBoundary(
                  child: _IsolatedInputs(
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    onSubmitted: _handleLogin,
                  ),
                ),
                
                // Render Isolation: Dynamic State (Error/Loading)
                const RepaintBoundary(child: _ErrorMessage()),
                const SizedBox(height: 40),
                
                RepaintBoundary(
                  child: _LoginButton(onPressed: _handleLogin),
                ),
                
                const SizedBox(height: 15),
                RepaintBoundary(
                  child: _GoogleLoginButton(
                    onPressed: () => ref.read(authProvider.notifier).loginWithGoogle(),
                  ),
                ),
                
                const SizedBox(height: 20),
                const RepaintBoundary(child: _RegisterLink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 100,
        ),
        const SizedBox(height: 20),
        const Text('HAIPHUC SHOP', 
          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        SizedBox(height: 10),
        Text('AUTHENTICATION', 
          style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 4)),
      ],
    );
  }
}

class _IsolatedInputs extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmitted;

  const _IsolatedInputs({
    required this.usernameController,
    required this.passwordController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // This widget only rebuilds if the controllers change (which they don't)
    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'TÀI KHOẢN',
            labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD2FF1F))),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tài khoản' : null,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'MẬT KHẨU',
            labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD2FF1F))),
          ),
          validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu tối thiểu 6 ký tự' : null,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmitted(),
        ),
      ],
    );
  }
}

class _ErrorMessage extends ConsumerWidget {
  const _ErrorMessage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Selective listening to isolate rebuilds to this small text widget
    final error = ref.watch(authProvider.select((s) => s.error));
    if (error == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
    );
  }
}

class _LoginButton extends ConsumerWidget {
  final VoidCallback onPressed;
  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Isolated rebuild for the button's loading state
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD2FF1F),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: isLoading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
          : const Text('ĐĂNG NHẬP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {}, 
      child: const Text('BẠN CHƯA CÓ TÀI KHOẢN? ĐĂNG KÝ NGAY', 
        style: TextStyle(color: Colors.grey, fontSize: 10))
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleLoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Căn giữa thu nhỏ theo nội dung
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png', // Link chính chủ Google
              height: 22,
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text('ĐĂNG NHẬP VỚI GOOGLE', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13),
                overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
