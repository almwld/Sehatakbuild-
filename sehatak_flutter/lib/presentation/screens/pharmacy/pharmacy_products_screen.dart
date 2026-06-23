import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'cart_screen.dart';

class PharmacyProductsScreen extends StatefulWidget {
  final String pharmacyId;
  const PharmacyProductsScreen({super.key, required this.pharmacyId});
  @override
  State<PharmacyProductsScreen> createState() => _PharmacyProductsScreenState();
}

class _PharmacyProductsScreenState extends State<PharmacyProductsScreen> {
  final List<Map<String, dynamic>> _cart = [];
  String _category = 'الكل';
  final List<String> _cats = ['الكل', 'مسكنات', 'مضادات حيوية', 'فيتامينات', 'قلب', 'سكري', 'تنفسي', 'مضادات حموضة', 'حساسية', 'كريمات', 'مغذيات', 'أطفال', 'أعشاب'];

  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'cat': 'مسكنات', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200'},
    {'name': 'إيبوبروفين 400mg', 'price': 800, 'cat': 'مسكنات', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200'},
    {'name': 'ديكلوفيناك 50mg', 'price': 600, 'cat': 'مسكنات', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200'},
    {'name': 'ترامادول أمبول', 'price': 1500, 'cat': 'مسكنات', 'type': 'أمبول', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200'},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'cat': 'مضادات حيوية', 'type': 'كبسول', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200'},
    {'name': 'أزيثرومايسين 500mg', 'price': 3500, 'cat': 'مضادات حيوية', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=200'},
    {'name': 'سيفترياكسون أمبول', 'price': 2500, 'cat': 'مضادات حيوية', 'type': 'أمبول', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200'},
    {'name': 'فيتامين د3', 'price': 1200, 'cat': 'فيتامينات', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200'},
    {'name': 'فيتامين سي 1000mg', 'price': 600, 'cat': 'فيتامينات', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200'},
    {'name': 'فيتامين ب12 أمبول', 'price': 800, 'cat': 'فيتامينات', 'type': 'أمبول', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200'},
    {'name': 'أوميغا 3', 'price': 4000, 'cat': 'فيتامينات', 'type': 'كبسول', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=200'},
    {'name': 'كالسيوم + مغنيسيوم', 'price': 1800, 'cat': 'فيتامينات', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1563213126-4276a5b3e1d7?w=200'},
    {'name': 'أملوديبين 5mg', 'price': 2000, 'cat': 'قلب', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200'},
    {'name': 'أسبرين 100mg', 'price': 400, 'cat': 'قلب', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200'},
    {'name': 'ميتفورمين 500mg', 'price': 1000, 'cat': 'سكري', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200'},
    {'name': 'مونتيلوكاست 10mg', 'price': 2500, 'cat': 'تنفسي', 'type': 'تابز', 'inStock': false, 'img': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200'},
    {'name': 'أوميبرازول 20mg', 'price': 2500, 'cat': 'مضادات حموضة', 'type': 'كبسول', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=200'},
    {'name': 'سيتريزين 10mg', 'price': 900, 'cat': 'حساسية', 'type': 'تابز', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200'},
    {'name': 'فيوسيدين كريم', 'price': 1800, 'cat': 'كريمات', 'type': 'كريم', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200'},
    {'name': 'محلول ملح 0.9%', 'price': 1500, 'cat': 'مغذيات', 'type': 'مغذي', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200'},
    {'name': 'باراسيتامول شراب', 'price': 400, 'cat': 'أطفال', 'type': 'شراب', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200'},
    {'name': 'زيت حبة البركة', 'price': 1200, 'cat': 'أعشاب', 'type': 'زيت', 'inStock': true, 'img': 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=200'},
  ];

  List<Map<String, dynamic>> get _filtered => _category == 'الكل' ? _products : _products.where((p) => p['cat'] == _category).toList();

  void _addToCart(Map<String, dynamic> p) {
    setState(() {
      final e = _cart.indexWhere((i) => i['name'] == p['name']);
      if (e >= 0) { _cart[e]['qty'] = (_cart[e]['qty'] ?? 1) + 1; }
      else { _cart.add({...p, 'qty': 1}); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المنتجات'), actions: [
        Stack(children: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
          if (_cart.isNotEmpty) Positioned(right: 4, top: 4, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Text('${_cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10)))),
        ]),
      ]),
      body: Column(children: [
        SizedBox(height: 44, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), itemCount: _cats.length, itemBuilder: (_, i) {
          final sel = _category == _cats[i];
          return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: () => setState(() => _category = _cats[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.lightGrey, borderRadius: BorderRadius.circular(20)), child: Text(_cats[i], style: TextStyle(color: sel ? Colors.white : AppColors.darkGrey, fontWeight: FontWeight.bold, fontSize: 12)))));
        })),
        Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: _filtered.length, itemBuilder: (_, i) {
          final p = _filtered[i];
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: CachedNetworkImage(imageUrl: p['img'], height: 100, width: double.infinity, fit: BoxFit.cover, placeholder: (_, __) => Container(height: 100, color: AppColors.lightGrey), errorWidget: (_, __, ___) => Container(height: 100, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.medication, color: AppColors.primary, size: 40)))),
              Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                Row(children: [Text(p['type'], style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)), const Spacer(), Text(p['cat'], style: const TextStyle(color: AppColors.grey, fontSize: 10))]),
                SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${p['price']} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                  GestureDetector(onTap: p['inStock'] ? () => _addToCart(p) : null, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: p['inStock'] ? AppColors.primary : AppColors.grey, borderRadius: BorderRadius.circular(8)), child: Icon(p['inStock'] ? Icons.add_shopping_cart : Icons.block, color: Colors.white, size: 18))),
                ]),
              ])),
            ]),
          );
        })),
      ]),
    );
  }
}
