import 'package:flutter/material.dart';
import 'package:sqlite_crud/db/database.dart';
import 'models/user.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final db = DatabaseHelper.instance;

  bool isEdit = false;
  int? selectedUserId;

  List<User> users = [];

  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final list = await db.getUsers();
    setState(() => users = list);
  }

  Future<void> addUser() async {
    final user = User(
      name: nameCtrl.text,
      age: int.parse(ageCtrl.text),
      email: emailCtrl.text,
    );

    await db.insertUser(user);
    clearForm();
    fetchUsers();
  }

  Future<void> updateUser() async {
    final updatedUser = User(
      id: selectedUserId,
      name: nameCtrl.text,
      age: int.parse(ageCtrl.text),
      email: emailCtrl.text,
    );

    await db.updateUser(updatedUser);
    clearForm();
    fetchUsers();
  }

  void clearForm() {
    nameCtrl.clear();
    ageCtrl.clear();
    emailCtrl.clear();
    isEdit = false;
    selectedUserId = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sqflite CRUD Example")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: ageCtrl,
                  decoration: InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),

                // BUTTON (Add / Update)
                ElevatedButton(
                  onPressed: () {
                    if (isEdit) {
                      updateUser();
                    } else {
                      addUser();
                    }
                  },
                  child: Text(isEdit ? "Update User" : "Add User"),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) {
                final u = users[i];
                return ListTile(
                  title: Text("${u.name} (${u.age})"),
                  subtitle: Text(u.email),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // → Enable Edit Mode
                          isEdit = true;
                          selectedUserId = u.id;

                          // → Fill text fields
                          nameCtrl.text = u.name;
                          ageCtrl.text = u.age.toString();
                          emailCtrl.text = u.email;

                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteUser(u.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(int id) async {
    await db.deleteUser(id);
    fetchUsers();
  }
}
