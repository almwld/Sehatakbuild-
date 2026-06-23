import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});
  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() { _data = doc.data(); _loading = false; });
      } else {
        setState(() { _data = {'fullName': _auth.currentUser?.displayName ?? _auth.currentUser?.email?.split('@')[0] ?? 'مستخدم', 'email': _auth.currentUser?.email ?? '', 'phone': _auth.currentUser?.phoneNumber ?? ''}; _loading = false; });
      }
    } catch (e) {
      setState(() { _data = {'fullName': _auth.currentUser?.displayName ?? 'مستخدم', 'email': _auth.currentUser?.email ?? ''}; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext c) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final user = _auth.currentUser;
    final name = _data?['fullName'] ?? user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';
    final email = _data?['email'] ?? user?.email ?? '';
    final phone = _data?['phone'] ?? user?.phoneNumber ?? '';
    final avatar = user?.photoURL ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=00796B&color=fff&size=200';

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        Center(child: ClipOval(child: CachedNetworkImage(imageUrl: avatar, width: 100, height: 100, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person, color: AppColors.primary, size: 55))))),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        Text(email, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
        const SizedBox(height: 30),
        _row(Icons.person, 'الاسم', name),
        _row(Icons.email, 'البريد', email),
        _row(Icons.phone, 'الهاتف', phone),
        _row(Icons.credit_card, 'المحفظة', '0 ريال'),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async { await _auth.signOut(); Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const Scaffold()), (r) => false); }, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 14)))),
      ])),
    );
  }

  Widget _row(IconData i, String l, String v) => Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]), child: Row(children: [Icon(i, color: AppColors.primary, size: 22), const SizedBox(width: 12), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 13)), const Spacer(), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]));
}
