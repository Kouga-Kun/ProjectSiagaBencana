import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../../auth/data/auth_session_service.dart';
import '../data/profile_photo_picker.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({
    required this.user,
    required this.authService,
    required this.onUserUpdated,
    required this.onBack,
    required this.onOpenSection,
    this.photoPicker = pickProfilePhotoFromDevice,
    super.key,
  });

  final AuthUser? user;
  final AuthSessionService? authService;
  final ValueChanged<AuthUser> onUserUpdated;
  final VoidCallback onBack;
  final ValueChanged<AppSection> onOpenSection;
  final ProfilePhotoPicker photoPicker;

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  static const int _maxPhotoBytes = 2 * 1024 * 1024;
  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  AuthUser? _currentUser;
  PickedProfilePhoto? _selectedPhoto;
  bool _isSaving = false;
  bool _isRefreshing = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _nameController = TextEditingController(text: _currentUser?.name ?? '');
    _emailController = TextEditingController(text: _currentUser?.email ?? '');
    _phoneController = TextEditingController(text: _currentUser?.phone ?? '');
    _addressController = TextEditingController(
      text: _currentUser?.address ?? '',
    );

    if (_currentUser != null && widget.authService != null) {
      unawaited(_loadLatestProfile());
    }
  }

  @override
  void didUpdateWidget(covariant ProfileInfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user && widget.user != null) {
      _applyUser(widget.user!, syncControllers: !_isSaving);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestProfile() async {
    final service = widget.authService;
    if (service == null) return;

    setState(() => _isRefreshing = true);
    try {
      final freshUser = await service.fetchProfile();
      if (!mounted) return;
      _applyUser(freshUser, syncControllers: true);
      widget.onUserUpdated(freshUser);
    } on AuthSessionException {
      // Gunakan data sesi saat ini apabila pengambilan awal gagal.
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _applyUser(AuthUser user, {required bool syncControllers}) {
    setState(() {
      _currentUser = user;
      if (syncControllers) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
      }
    });
  }

  Future<void> _handlePickPhoto() async {
    if (_isSaving) return;

    final picked = await widget.photoPicker();
    if (!mounted || picked == null) return;

    final extension = _extractExtension(picked.fileName);
    if (!_allowedExtensions.contains(extension)) {
      _showFeedback(
        isSuccess: false,
        message: 'Format foto profil harus JPG, JPEG, PNG, atau WEBP.',
      );
      return;
    }

    if (picked.sizeInBytes > _maxPhotoBytes) {
      _showFeedback(
        isSuccess: false,
        message: 'Ukuran foto profil maksimal 2 MB.',
      );
      return;
    }

    setState(() {
      _selectedPhoto = picked;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }

  void _resetChanges() {
    final user = _currentUser;
    if (user == null) return;
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    setState(() {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _selectedPhoto = null;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Nama lengkap wajib diisi.';
    if (trimmed.length < 2) return 'Nama lengkap minimal 2 karakter.';
    if (trimmed.length > 255) return 'Nama lengkap maksimal 255 karakter.';
    return null;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Nomor telepon wajib diisi.';
    if (trimmed.length < 8) return 'Nomor telepon minimal 8 karakter.';
    if (trimmed.length > 30) return 'Nomor telepon maksimal 30 karakter.';
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(trimmed)) {
      return 'Masukkan nomor telepon yang valid (angka, +, -, spasi).';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Alamat wajib diisi.';
    if (trimmed.length < 5) return 'Alamat minimal 5 karakter.';
    if (trimmed.length > 500) return 'Alamat maksimal 500 karakter.';
    return null;
  }

  void _showFeedback({required bool isSuccess, required String message}) {
    setState(() {
      if (isSuccess) {
        _successMessage = message;
        _errorMessage = null;
      } else {
        _errorMessage = message;
        _successMessage = null;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isSuccess ? SiagaColors.safe : SiagaColors.danger,
          content: Text(message),
        ),
      );
  }

  Future<void> _submitProfile() async {
    FocusScope.of(context).unfocus();
    if (_isSaving || _currentUser == null) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showFeedback(
        isSuccess: false,
        message: 'Mohon periksa kembali input yang belum sesuai.',
      );
      return;
    }

    final service = widget.authService;
    if (service == null) {
      _showFeedback(
        isSuccess: false,
        message: 'Layanan profil belum terhubung. Coba lagi nanti.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await service.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        photoBytes: _selectedPhoto?.bytes,
        photoFileName: _selectedPhoto?.fileName,
      );

      if (!mounted) return;
      setState(() {
        _currentUser = result.user;
        _selectedPhoto = null;
        _nameController.text = result.user.name;
        _emailController.text = result.user.email;
        _phoneController.text = result.user.phone ?? '';
        _addressController.text = result.user.address ?? '';
      });
      widget.onUserUpdated(result.user);
      _showFeedback(isSuccess: true, message: result.message);
    } on AuthSessionException catch (error) {
      if (!mounted) return;
      _showFeedback(isSuccess: false, message: error.message);
    } catch (_) {
      if (!mounted) return;
      _showFeedback(
        isSuccess: false,
        message: 'Terjadi kendala saat menyimpan perubahan profil.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);
    final user = _currentUser;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        20,
        horizontalPadding,
        44,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 17),
            label: const Text('Kembali ke Profil'),
          ),
        ),
        const SizedBox(height: 8),
        const SiagaPageHeader(
          eyebrow: 'INFORMASI PROFIL',
          title: 'Informasi Profil Pengguna',
          description:
              'Kelola foto profil, nama lengkap, nomor telepon, dan alamat akun SiagaBencana Anda.',
          icon: Icons.manage_accounts_outlined,
        ),
        const SizedBox(height: 22),
        if (_isRefreshing) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 14),
        ],
        if (user == null)
          SiagaEmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Silakan masuk untuk mengelola informasi profil',
            message:
                'Login menggunakan akun SiagaBencana untuk mengubah foto profil, nama lengkap, nomor telepon, serta alamat.',
            action: Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => widget.onOpenSection(AppSection.login),
                  icon: const Icon(Icons.login_rounded, size: 17),
                  label: const Text('Login'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      widget.onOpenSection(AppSection.registration),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 17),
                  label: const Text('Daftar akun'),
                ),
              ],
            ),
          )
        else ...[
          if (_successMessage != null) ...[
            SiagaNotice(
              title: 'Perubahan berhasil disimpan',
              message: _successMessage!,
              tone: SiagaTone.success,
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 16),
          ],
          if (_errorMessage != null) ...[
            SiagaNotice(
              title: 'Perubahan belum berhasil disimpan',
              message: _errorMessage!,
              tone: SiagaTone.danger,
              icon: Icons.error_outline_rounded,
            ),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final overviewColumn = Column(
                children: [
                  _buildPhotoCard(user),
                  const SizedBox(height: 16),
                  _buildAccountSummaryCard(user),
                ],
              );
              final editCard = _buildEditFormCard(user);

              if (constraints.maxWidth < 900) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    overviewColumn,
                    const SizedBox(height: 18),
                    editCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: overviewColumn),
                  const SizedBox(width: 20),
                  Expanded(flex: 6, child: editCard),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoCard(AuthUser user) {
    final hasPreview = _selectedPhoto != null;
    final remotePhotoUrl = user.profilePhotoUrl;

    return SiagaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Foto Profil',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (hasPreview)
                const SiagaBadge(
                  label: 'Preview Baru',
                  tone: SiagaTone.warning,
                  compact: true,
                )
              else if (remotePhotoUrl != null)
                const SiagaBadge(
                  label: 'Tersimpan',
                  tone: SiagaTone.success,
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                _ProfileAvatarPreview(
                  previewPhoto: _selectedPhoto,
                  remotePhotoUrl: remotePhotoUrl,
                  userName: user.name,
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (hasPreview) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Dipilih: ${_selectedPhoto!.fileName} (${_formatFileSize(_selectedPhoto!.sizeInBytes)})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: SiagaColors.warningText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _handlePickPhoto,
                      icon: const Icon(Icons.photo_camera_outlined, size: 17),
                      label: Text(
                        hasPreview || remotePhotoUrl != null
                            ? 'Ganti Foto'
                            : 'Pilih Foto',
                      ),
                    ),
                    if (hasPreview)
                      TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => setState(() => _selectedPhoto = null),
                        style: TextButton.styleFrom(
                          foregroundColor: SiagaColors.danger,
                        ),
                        child: const Text('Batalkan'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'JPG, JPEG, PNG, atau WEBP (Maks. 2 MB)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSummaryCard(AuthUser user) {
    final phone = user.phone?.trim();
    final address = user.address?.trim();

    return SiagaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Akun', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _AccountInfoTile(
            icon: Icons.person_outline_rounded,
            label: 'Nama Lengkap',
            value: user.name,
          ),
          const Divider(height: 20),
          _AccountInfoTile(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: user.email,
          ),
          const Divider(height: 20),
          _AccountInfoTile(
            icon: Icons.phone_outlined,
            label: 'Nomor Telepon',
            value: (phone != null && phone.isNotEmpty)
                ? phone
                : 'Belum dilengkapi',
            isPlaceholder: phone == null || phone.isEmpty,
          ),
          const Divider(height: 20),
          _AccountInfoTile(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: (address != null && address.isNotEmpty)
                ? address
                : 'Belum dilengkapi',
            isPlaceholder: address == null || address.isEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildEditFormCard(AuthUser user) {
    return SiagaCard(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 26),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Informasi Profil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Perbarui nama lengkap, nomor telepon aktif (untuk koordinasi darurat SOS), dan alamat tempat tinggal.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('profile_name_field'),
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Nama lengkap',
                hintText: 'Masukkan nama lengkap Anda',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 19),
                counterText: '',
              ),
              validator: _validateName,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('profile_email_field'),
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 19),
                fillColor: SiagaColors.surfaceMuted,
                helperText:
                    'Email terhubung dengan akun aktif dan tidak dapat diubah.',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('profile_phone_field'),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: 'Nomor telepon',
                hintText: 'Contoh: 081234567890',
                prefixIcon: Icon(Icons.phone_outlined, size: 19),
                counterText: '',
              ),
              validator: _validatePhone,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('profile_address_field'),
              controller: _addressController,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.newline,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Alamat lengkap',
                hintText: 'Masukkan alamat tempat tinggal Anda di Kota Padang',
                prefixIcon: Icon(Icons.location_on_outlined, size: 19),
                alignLabelWithHint: true,
              ),
              validator: _validateAddress,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  key: const Key('save_profile_button'),
                  onPressed: _isSaving ? null : _submitProfile,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _resetChanges,
                  icon: const Icon(Icons.restart_alt_rounded, size: 17),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatarPreview extends StatelessWidget {
  const _ProfileAvatarPreview({
    required this.previewPhoto,
    required this.remotePhotoUrl,
    required this.userName,
  });

  final PickedProfilePhoto? previewPhoto;
  final String? remotePhotoUrl;
  final String userName;

  @override
  Widget build(BuildContext context) {
    const double size = 104;

    Widget avatarContent;
    if (previewPhoto != null) {
      avatarContent = Image.memory(
        previewPhoto!.bytes,
        key: ValueKey(
          'preview_${previewPhoto!.fileName}_${previewPhoto!.sizeInBytes}',
        ),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultAvatar(size),
      );
    } else if (remotePhotoUrl != null && remotePhotoUrl!.trim().isNotEmpty) {
      avatarContent = Image.network(
        remotePhotoUrl!,
        key: ValueKey(remotePhotoUrl),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultAvatar(size),
      );
    } else {
      avatarContent = _defaultAvatar(size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SiagaColors.primarySoft,
        border: Border.all(
          color: previewPhoto != null
              ? SiagaColors.warning
              : SiagaColors.border,
          width: 2.5,
        ),
      ),
      child: ClipOval(child: avatarContent),
    );
  }

  Widget _defaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      color: SiagaColors.primarySoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 46,
        color: SiagaColors.navy,
      ),
    );
  }
}

class _AccountInfoTile extends StatelessWidget {
  const _AccountInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: SiagaColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isPlaceholder ? SiagaColors.textSubtle : SiagaColors.ink,
                  fontSize: 13.8,
                  fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                  fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
