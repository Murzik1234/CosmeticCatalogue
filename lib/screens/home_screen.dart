import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/account_screen.dart';
import 'package:untitled/screens/favorites_cart.dart';
import 'package:untitled/screens/login_screen.dart';
import 'package:untitled/screens/product_details.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../CardItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CardItem> cardItems = [];
  String searchText = '';


  @override
  void initState() {
    super.initState();
    loadCardItems();
  }

  Future<void> loadCardItems() async {
    try {

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();


      List<CardItem> items = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;


        items.add(CardItem(
          id: data['id'],
          title: data['name'],
          price: data['cost'],
          description: data['description'],
          images: List<String>.from(data['images']),
        ));
      });

      setState(() {
        cardItems = items;
      });
    } catch (e) {
      print('Error loading card items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Главная страница'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? Colors.white : Colors.pink[400],
            ),
          ),
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Favorites(),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.favorite_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: (user == null)
              ?  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Упс, Вы не авторизованы :( ',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'Авторизоваться',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
              : Column(
                  children: [
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Поиск',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  border: InputBorder.none,
                                  icon: Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            mainAxisSpacing: 3.0,
                            crossAxisSpacing: 3.0,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: cardItems
                                .where((cardItem) => cardItem.title
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))
                                .map((cardItem) {
                              return buildCard(cardItem);
                            }).toList()),
                      ),
                    ),
                  ],
                ),
        ),


      ),
    );
  }

  Widget buildCard(CardItem cardItem) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProductDetail(cardItem: cardItem)));
      },
      child: Card(

        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height/ 4,
              //height: 300,
              child: PageView.builder(
                  itemCount: cardItem.images.length,
                  onPageChanged: (int index) {
                    setState(() {
                      cardItem.currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      cardItem.images[index],
                    );
                  }),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(cardItem.images.length,
                  (int circleIndex) {
                return Padding(
                  padding: EdgeInsets.all(4.0),
                  child: CircleAvatar(
                      radius: 4,
                      backgroundColor: circleIndex == cardItem.currentIndex
                          ? Colors.grey[500]
                          : Colors.grey[300]),
                );
              }),
            ),
            ListTile(
              title: Text(
                cardItem.title,
                style: TextStyle(color: Colors.black),
              ),
              subtitle: Text(cardItem.price),
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text(
                    '  Премиум  ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


