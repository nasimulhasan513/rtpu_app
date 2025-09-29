import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instituteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _batchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = (user['name'] ?? '').toString();
      _instituteController.text = (user['institute'] ?? '').toString();
      _phoneController.text = (user['phone'] ?? '').toString();
      _batchController.text = (user['hsc_batch'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instituteController.dispose();
    _phoneController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.saveProfile({
      'name': _nameController.text.trim(),
      'institute': _instituteController.text.trim(),
      'phone': _phoneController.text.trim(),
      'hsc_batch': _batchController.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Saved' : (auth.error ?? 'Failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.status != AuthStatus.authenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view profile')),
      );
    }
    final user = auth.user ?? {};
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: auth.busy ? null : auth.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E86FF)]),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: user['image'] != null && user['image'].toString().isNotEmpty
                        ? NetworkImage(user['image'].toString())
                        : null,
                    child: user['image'] == null || user['image'].toString().isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name']?.toString() ?? 'Guest', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text(user['email']?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _instituteController,
                    decoration: const InputDecoration(labelText: 'Institute'),
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _batchController,
                    decoration: const InputDecoration(labelText: 'HSC Batch'),
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: auth.busy ? null : _save,
                    child: auth.busy ? const CircularProgressIndicator() : const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

