import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key});
  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this); }

  Stream<QuerySnapshot> _get(String status) {
    final q = _firestore.collection('appointments').where('patientId', isEqualTo: _auth.currentUser?.uid ?? '').orderBy('createdAt', descending: true);
    return status == 'upcoming' ? q.where('status', whereIn: ['pending', 'confirmed']).snapshots() : q.where('status', whereIn: ['completed', 'cancelled']).snapshots();
  }

  Future<void> _cancel(String id) async => await _firestore.collection('appointments').doc(id).update({'status': 'cancelled'});

  Color _sc(String? s) {
    switch (s) { case 'pending': return AppColors.warning; case 'confirmed': return AppColors.success; case 'completed': return AppColors.info; case 'cancelled': return AppColors.error; default: return AppColors.grey; }
  }

  String _st(String? s) {
    switch (s) { case 'pending': return 'قيد الانتظار'; case 'confirmed': return 'مؤكد'; case 'completed': return 'مكتمل'; case 'cancelled': return 'ملغي'; default: return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مواعيدي'), bottom: TabBar(controller: _tabCtrl, labelColor: AppColors.primary, tabs: const [Tab(text: 'القادمة'), Tab(text: 'السابقة')])),
      body: TabBarView(controller: _tabCtrl, children: [_list('upcoming'), _list('past')]),
    );
  }

  Widget _list(String s) => StreamBuilder<QuerySnapshot>(
    stream: _get(s),
    builder: (_, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_busy, size: 60, color: AppColors.grey.withOpacity(0.5)), const SizedBox(height: 12), Text(s == 'upcoming' ? 'لا توجد مواعيد قادمة' : 'لا توجد مواعيد سابقة', style: const TextStyle(color: AppColors.grey, fontSize: 16))]));
      return ListView.builder(padding: const EdgeInsets.all(14), itemCount: docs.length, itemBuilder: (_, i) {
        final a = docs[i].data() as Map<String, dynamic>;
        final up = s == 'upcoming' && a['status'] != 'cancelled';
        return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]), child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: _sc(a['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(a['status'] == 'cancelled' ? Icons.cancel : Icons.calendar_today, color: _sc(a['status']), size: 26)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['doctorName'] ?? 'طبيب', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4), Row(children: [const Icon(Icons.calendar_today, size: 14, color: AppColors.grey), const SizedBox(width: 4), Text('${a['date']}', style: const TextStyle(color: AppColors.grey, fontSize: 12))]),
            Row(children: [const Icon(Icons.access_time, size: 14, color: AppColors.grey), const SizedBox(width: 4), Text(a['time'] ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 12))]),
          ])),
          Column(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _sc(a['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(_st(a['status']), style: TextStyle(color: _sc(a['status']), fontSize: 11, fontWeight: FontWeight.bold))),
            if (up) ...[const SizedBox(height: 8), TextButton(onPressed: () => _cancel(docs[i].id), child: const Text('إلغاء', style: TextStyle(color: AppColors.error, fontSize: 12)))],
          ]),
        ]));
      });
    },
  );
}
