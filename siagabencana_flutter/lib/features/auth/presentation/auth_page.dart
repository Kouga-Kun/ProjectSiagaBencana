import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/auth_session_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    required this.isRegistration,
    required this.onOpenSection,
    required this.authService,
    required this.onAuthenticated,
    this.noticeMessage,
    super.key,
  });

  final bool isRegistration;
  final ValueChanged<AppSection> onOpenSection;
  final AuthSessionService authService;
  final ValueChanged<AuthUser> onAuthenticated;
  final String? noticeMessage;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _passwordIsVisible = false;
  bool _confirmationIsVisible = false;
  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email wajib diisi.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi wajib diisi.';
    if (widget.isRegistration && value.length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });
    try {
      final user = widget.isRegistration
          ? await widget.authService.register(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              passwordConfirmation: _confirmationController.text,
            )
          : await widget.authService.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      _passwordController.clear();
      _confirmationController.clear();
      widget.onAuthenticated(user);
    } on AuthSessionException catch (error) {
      if (mounted) {
        setState(() => _submissionError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegistration = widget.isRegistration;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        48,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiagaPageHeader(
                  eyebrow: 'AKUN SIAGABENCANA',
                  title: isRegistration ? 'Daftar akun warga' : 'Masuk ke akun',
                  description: isRegistration
                      ? 'Buat akun untuk mengakses pelaporan bencana, Edukasi Bencana, dan layanan darurat SOS.'
                      : 'Masuk untuk membuka profil, fitur pelaporan, layanan SOS, dan Edukasi Bencana.',
                  icon: isRegistration
                      ? Icons.person_add_alt_1_outlined
                      : Icons.login_rounded,
                ),
                if (widget.noticeMessage != null &&
                    widget.noticeMessage!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SiagaNotice(
                    title: 'Login Diperlukan',
                    message: widget.noticeMessage!,
                    tone: SiagaTone.warning,
                    icon: Icons.lock_outline_rounded,
                  ),
                ],
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final form = _AuthFormCard(
                      isRegistration: isRegistration,
                      onOpenSection: widget.onOpenSection,
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmationController: _confirmationController,
                      passwordIsVisible: _passwordIsVisible,
                      confirmationIsVisible: _confirmationIsVisible,
                      submissionError: _submissionError,
                      isSubmitting: _isSubmitting,
                      validateEmail: _validateEmail,
                      validatePassword: _validatePassword,
                      onTogglePassword: () => setState(
                        () => _passwordIsVisible = !_passwordIsVisible,
                      ),
                      onToggleConfirmation: () => setState(
                        () => _confirmationIsVisible = !_confirmationIsVisible,
                      ),
                      onSubmit: _submit,
                    );

                    if (constraints.maxWidth < 780) {
                      return form;
                    }

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(flex: 4, child: _AuthSidePanel()),
                          const SizedBox(width: 20),
                          Expanded(flex: 6, child: form),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.isRegistration,
    required this.onOpenSection,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmationController,
    required this.passwordIsVisible,
    required this.confirmationIsVisible,
    required this.submissionError,
    required this.isSubmitting,
    required this.validateEmail,
    required this.validatePassword,
    required this.onTogglePassword,
    required this.onToggleConfirmation,
    required this.onSubmit,
  });

  final bool isRegistration;
  final ValueChanged<AppSection> onOpenSection;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmationController;
  final bool passwordIsVisible;
  final bool confirmationIsVisible;
  final String? submissionError;
  final bool isSubmitting;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmation;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isRegistration ? 'Informasi akun baru' : 'Selamat datang kembali',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              isRegistration
                  ? 'Lengkapi data berikut untuk mendaftar sebagai pengguna SiagaBencana.'
                  : 'Masukkan email dan kata sandi akun SiagaBencana Anda.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isRegistration) ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLength: 255,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 19),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap wajib diisi.';
                  }
                  if (value.trim().length > 255) {
                    return 'Nama maksimal 255 karakter.';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 19),
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: !passwordIsVisible,
              textInputAction: isRegistration
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: isRegistration ? null : (_) => onSubmit(),
              autofillHints: [
                isRegistration
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              decoration: InputDecoration(
                labelText: isRegistration
                    ? 'Kata sandi (minimal 8 karakter)'
                    : 'Kata sandi',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                suffixIcon: IconButton(
                  tooltip: passwordIsVisible
                      ? 'Sembunyikan kata sandi'
                      : 'Tampilkan kata sandi',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    passwordIsVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 19,
                  ),
                ),
              ),
              validator: validatePassword,
            ),
            if (isRegistration) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmationController,
                obscureText: !confirmationIsVisible,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi kata sandi',
                  prefixIcon: const Icon(Icons.lock_reset_outlined, size: 19),
                  suffixIcon: IconButton(
                    tooltip: confirmationIsVisible
                        ? 'Sembunyikan kata sandi'
                        : 'Tampilkan kata sandi',
                    onPressed: onToggleConfirmation,
                    icon: Icon(
                      confirmationIsVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 19,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi kata sandi wajib diisi.';
                  }
                  if (value != passwordController.text) {
                    return 'Konfirmasi kata sandi tidak cocok.';
                  }
                  return null;
                },
              ),
            ],
            if (submissionError != null) ...[
              const SizedBox(height: 16),
              SiagaNotice(
                title: 'Belum dapat melanjutkan',
                message: submissionError!,
                tone: SiagaTone.danger,
                icon: Icons.error_outline_rounded,
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              height: 46,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox.square(
                        dimension: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isRegistration
                            ? Icons.person_add_alt_1_rounded
                            : Icons.login_rounded,
                        size: 18,
                      ),
                label: Text(
                  isSubmitting
                      ? 'Mohon tunggu...'
                      : isRegistration
                      ? 'Buat akun'
                      : 'Masuk',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => onOpenSection(
                  isRegistration ? AppSection.login : AppSection.registration,
                ),
                child: Text(
                  isRegistration
                      ? 'Sudah punya akun? Login'
                      : 'Belum punya akun? Daftar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthSidePanel extends StatelessWidget {
  const _AuthSidePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: SiagaColors.navy,
        borderRadius: BorderRadius.circular(SiagaRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SiagaRadius.md),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Satu akun terpadu untuk kesiapsiagaan bencana',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Akses penuh ke modul Edukasi Bencana, pelaporan kejadian warga, dan sinyal darurat SOS dengan data tersinkronisasi per akun.',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 22),
              SiagaBullet(
                text: 'Progres belajar dan nilai kuis tersimpan per akun.',
                icon: Icons.check_circle_outline_rounded,
                color: Color(0xFF34D399),
                textColor: Color(0xFFE2E8F0),
              ),
              SiagaBullet(
                text: 'Autentikasi sesi terlindungi CSRF dan hak akses peran.',
                icon: Icons.verified_user_outlined,
                color: Color(0xFF93C5FD),
                textColor: Color(0xFFE2E8F0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
