import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/wessless_logo_mark.dart';

class UmkmRegistrationScreen extends StatefulWidget {
  const UmkmRegistrationScreen({super.key});

  @override
  State<UmkmRegistrationScreen> createState() => _UmkmRegistrationScreenState();
}

class _UmkmRegistrationScreenState extends State<UmkmRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _umkmNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _umkmNameController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.saveUmkmProfile(
        umkmName: _umkmNameController.text,
        whatsappNumber: _whatsappController.text,
        address: _addressController.text,
      );
    } on AuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: WessLessTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            const Center(child: WessLessLogoMark(size: 78)),
            const SizedBox(height: 18),
            if (user != null)
              Text(
                'Halo, ${user.fullName}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WessLessTheme.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: WessLessTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Lengkapi Data UMKM',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Data ini membantu WessLess menyiapkan dashboard dan laporan usahamu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _umkmNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama UMKM',
                        prefixIcon: Icon(Icons.storefront_rounded),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Nama UMKM wajib diisi.';
                        if (text.length < 3) {
                          return 'Nama UMKM minimal 3 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp UMKM',
                        prefixIcon: Icon(Icons.chat_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Nomor WhatsApp UMKM wajib diisi.';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
                          return 'Nomor WhatsApp hanya boleh angka.';
                        }
                        if (text.length < 10) {
                          return 'Nomor WhatsApp minimal 10 digit.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressController,
                      minLines: 3,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Alamat UMKM / Outlet',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Alamat UMKM / Outlet wajib diisi.';
                        }
                        if (text.length < 5) {
                          return 'Alamat UMKM / Outlet minimal 5 karakter.';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ErrorMessage(message: _errorMessage!),
                    ],
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan dan Lanjutkan'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WessLessTheme.error.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WessLessTheme.error.withAlpha(50)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: WessLessTheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
