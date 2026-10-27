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
    super.key,
  });

  final bool isRegistration;
  final ValueChanged<AppSection> onOpenSection;
  final AuthSessionService authService;
  final ValueChanged<AuthUser> onAuthenticated;

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

    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }

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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: SiagaColors.border),
    );

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: SiagaColors.muted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFCFDFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: outline,
      enabledBorder: outline,
      focusedBorder: outline.copyWith(
        borderSide: const BorderSide(color: SiagaColors.navyHover, width: 1.5),
      ),
      errorBorder: outline.copyWith(
        borderSide: const BorderSide(color: SiagaColors.danger),
      ),
      focusedErrorBorder: outline.copyWith(
        borderSide: const BorderSide(color: SiagaColors.danger, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRegistration = widget.isRegistration;
    final horizontalPadding = MediaQuery.sizeOf(context).width < 600
        ? 18.0
        : 30.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        44,
      ),
      children: [
        SiagaPageHeader(
          eyebrow: 'AKUN SIAGABENCANA',
          title: isRegistration ? 'Daftar akun warga' : 'Masuk ke akun',
          description: isRegistration
              ? 'Buat akun untuk menggunakan fitur SiagaBencana.'
              : 'Masuk untuk membuka profil dan fitur pelaporan.',
          icon: isRegistration
              ? Icons.person_add_alt_1_rounded
              : Icons.login_rounded,
        ),
        const SizedBox(height: 24),
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
              inputDecoration: _inputDecoration,
              validateEmail: _validateEmail,
              validatePassword: _validatePassword,
              onTogglePassword: () {
                setState(() {
                  _passwordIsVisible = !_passwordIsVisible;
                });
              },
              onToggleConfirmation: () {
                setState(() {
                  _confirmationIsVisible = !_confirmationIsVisible;
                });
              },
              onSubmit: _submit,
            );

            if (constraints.maxWidth < 850) {
              return form;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: _AuthSidePanel()),
                const SizedBox(width: 22),
                Expanded(flex: 5, child: form),
              ],
            );
          },
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
    required this.inputDecoration,
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
  final InputDecoration Function({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  })
  inputDecoration;
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
              isRegistration ? 'Informasi akun' : 'Selamat datang kembali',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 7),
            Text(
              isRegistration
                  ? 'Lengkapi data berikut untuk membuat akun.'
                  : 'Masukkan email dan kata sandi untuk masuk.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isRegistration) ...[
              const SizedBox(height: 22),
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLength: 255,
                decoration: inputDecoration(
                  label: 'Nama lengkap',
                  icon: Icons.person_outline_rounded,
                ).copyWith(counterText: ''),
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
              decoration: inputDecoration(
                label: 'Email',
                icon: Icons.alternate_email_rounded,
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
              autofillHints: [
                isRegistration
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              decoration: inputDecoration(
                label: isRegistration
                    ? 'Kata sandi (minimal 8 karakter)'
                    : 'Kata sandi',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  tooltip: passwordIsVisible
                      ? 'Sembunyikan kata sandi'
                      : 'Tampilkan kata sandi',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    passwordIsVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
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
                decoration: inputDecoration(
                  label: 'Konfirmasi kata sandi',
                  icon: Icons.lock_reset_outlined,
                  suffixIcon: IconButton(
                    tooltip: confirmationIsVisible
                        ? 'Sembunyikan kata sandi'
                        : 'Tampilkan kata sandi',
                    onPressed: onToggleConfirmation,
                    icon: Icon(
                      confirmationIsVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
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
              const SizedBox(height: 18),
              SiagaNotice(
                title: 'Belum dapat melanjutkan',
                message: submissionError!,
                tone: SiagaTone.info,
                icon: Icons.info_outline_rounded,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isRegistration
                            ? Icons.person_add_alt_1_rounded
                            : Icons.login_rounded,
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
            const SizedBox(height: 12),
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
      constraints: const BoxConstraints(minHeight: 330),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: SiagaColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaIconTile(
            icon: Icons.shield_rounded,
            color: Colors.white,
            backgroundColor: Color(0x24FFFFFF),
            size: 58,
          ),
          SizedBox(height: 22),
          Text(
            'Satu akun untuk layanan SiagaBencana',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          SizedBox(height: 11),
          Text(
            'Akun warga pada website lama digunakan untuk membuka profil dan mengirim laporan. Akses petugas dibatasi untuk proses verifikasi.',
            style: TextStyle(
              color: Color(0xFFE0E7FF),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          SizedBox(height: 22),
          SiagaBullet(
            text: 'Data akun diperiksa dengan aman.',
            icon: Icons.check_circle_outline_rounded,
            color: Color(0xFF86EFAC),
          ),
          SiagaBullet(
            text: 'Hak akses akun ditentukan oleh sistem',
            icon: Icons.verified_user_outlined,
            color: Color(0xFFBFDBFE),
          ),
        ],
      ),
    );
  }
}
