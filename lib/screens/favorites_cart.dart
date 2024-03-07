import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../CardItem.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  late List<String> favoriteProductIds = [];
  late List<CardItem> favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      List<dynamic> favorites =
          (userDoc.data() as Map<String, dynamic>)['favorites'] ?? [];
      if (favorites != null) {
        setState(() {
          favoriteProductIds = List<String>.from(favorites);
          // Fetch and load details when you have favoriteProductIds
          getFavoriteProductsDetails(favoriteProductIds);
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([productId]),
      });
      print('Товар удален из избранного');
    } catch (e) {
      print('Ошибка при удалении товара из избранного: $e');
    }
  }

  Future<void> getFavoriteProductsDetails(List<String> productIds) async {
    try {
      for (String productId in productIds) {
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        Map<String, dynamic>? data =
        productDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          CardItem item = CardItem(
            id: data['id'],
            title: data['name'],
            price: data['cost'],
            description: data['description'],
            images: List<String>.from(data['images']),
          );
          setState(() {
            favoriteProducts.add(item);
          });
        }
      }
    } catch (e) {
      print('Error loading favorite products details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        title: const Text('Избранное'),
      ),
      body: Container(
          color: Colors.grey[300],
      child : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: favoriteProducts.length,
                  itemBuilder: (context, index) {
                    CardItem product = favoriteProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            product.images.isNotEmpty
                                ? product.images[0]
                                : '',
                            height: 90,
                            width: 90,
                          ),
                          const SizedBox(width: 15.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title ?? 'No Title',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                product.price,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  String userId = FirebaseAuth.instance.currentUser!.uid;
                                  await removeFromFavorites(userId, product.id);
                                  setState(() {
                                    favoriteProducts.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete_forever),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}