import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController patronymicController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController profileDescriptionController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();
  final TextEditingController petController = TextEditingController();
  String? selectedEducation;
  String? selectedGender;
  bool isMale = false;

  List<String> educationOptions = ['Высшее', 'Среднее', 'Начальное'];
  List<String> genderOptions = ['Мужской', 'Женский']; // Added gender options


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTime.now()) {
      dobController.text = picked.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удаление аккаунта'),
          content: Text('Вы уверены, что хотите удалить свой аккаунт? Вся ваша информация будет потеряна.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалоговое окно
              },
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAccount(); // Вызов метода удаления аккаунта
                Navigator.of(context).pop(); // Закрыть диалоговое окно
              },
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  Future<void> _loadUserDataFromDatabase() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          nameController.text = userSnapshot['name'] ?? '';
          surnameController.text = userSnapshot['surname'] ?? '';
          patronymicController.text = userSnapshot['patronymic'] ?? '';
          dobController.text = userSnapshot['dob'] ?? '';
          selectedGender = userSnapshot['gender'] ?? '';
          profileDescriptionController.text = userSnapshot['profileDescription'] ?? '';
          interestsController.text = userSnapshot['interests'] ?? '';
          selectedEducation = userSnapshot['education'] ?? '';
          petController.text = userSnapshot['pet'] ?? '';
        });
      } else {
        print('Данные пользователя не найдены в базе данных.');
      }
    } catch (e) {
      print('Ошибка при загрузке пользовательских данных: $e');
    }
  }

  Future<void> _saveUserDataToDatabase() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': nameController.text,
        'surname': surnameController.text,
        'patronymic': patronymicController.text,
        'dob': dobController.text,
        'gender': selectedGender,
        'profileDescription': profileDescriptionController.text,
        'interests': interestsController.text,
        'education': selectedEducation,
        'pet': petController.text,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Данные успешно сохранены!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Перенаправление на домашнюю страницу
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Handle any errors that occur during the save process
      print('Error saving user data: $e');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      await FirebaseAuth.instance.currentUser!.delete();

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error deleting account: $e');

    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserDataFromDatabase();
    selectedGender = genderOptions.first;
    selectedEducation = educationOptions.last;
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
        title: const Text('Аккаунт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () => _signOut(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Удалить аккаунт',
            onPressed: () => _showDeleteAccountDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ваш Email: ${user?.email}'),
              const SizedBox(height: 20.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: surnameController,
                decoration: const InputDecoration(labelText: 'Фамилия'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: patronymicController,
                decoration: const InputDecoration(labelText: 'Отчество'),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () => _selectDate(context),
                child: TextField(
                  controller: dobController,
                  enabled: false,
                  decoration:
                  const InputDecoration(labelText: 'Дата рождения'),
                ),
              ),
              const SizedBox(height: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Пол', style: TextStyle(fontSize: 16.0)),
                  Row(
                    children: genderOptions.map((gender) => Row(
                      children: [
                        Radio<String>(
                          value: gender,
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                        ),
                        Text(gender),
                      ],
                    )).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: profileDescriptionController,
                maxLines: 3,
                decoration:
                const InputDecoration(labelText: 'Описание профиля'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: interestsController,
                decoration: const InputDecoration(labelText: 'Интересы'),
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: selectedEducation,
                items: educationOptions.map((education) {
                  return DropdownMenuItem<String>(
                    value: education,
                    child: Text(education),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEducation = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Образование',
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: petController,
                decoration: const InputDecoration(labelText: 'Домашнее животное'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _saveUserDataToDatabase();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                ),
                child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () => _signOut(),
                child: const Text('Выйти', style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
