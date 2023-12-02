import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class Contact {
  int? id;
  String firstName;
  String lastName;
  String mobileNumber;
  String email;
  String address;

  Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'email': email,
      'address': address,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        mobileNumber TEXT,
        email TEXT,
        address TEXT
      )
    ''');
  }

  Future<int> insertContact(Contact contact) async {
    Database db = await instance.database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        firstName: maps[i]['firstName'],
        lastName: maps[i]['lastName'],
        mobileNumber: maps[i]['mobileNumber'],
        email: maps[i]['email'],
        address: maps[i]['address'],
      );
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactList(),
    );
  }
}

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final dbHelper = DatabaseHelper.instance;
 // List<Contact> contacts = [];
  List<Contact> contacts = [
  Contact(
  firstName: 'Nila',
  lastName: 'D',
  mobileNumber: '1234567890',
  email: 'nila@gmail.com',
  address: '123 Main St',
  ),
  Contact(
  firstName: 'Rev',
  lastName: 'P',
  mobileNumber: '9876543210',
  email: 'rev@gmail.com',
  address: '456 Elm St',
  ),
  ];

  @override
  void initState() {
    super.initState();
    _refreshContactList();
  }

  Future<void> _refreshContactList() async {
    List<Contact> tempContacts = await dbHelper.getAllContacts();
    setState(() {
      contacts = tempContacts;
    });
  }

  void _navigateToAddContactScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddContactScreen()),
    );

    if (result != null && result is Contact) {
      await dbHelper.insertContact(result);
      _refreshContactList(); // Refresh the contact list after adding a new contact
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('First Name')),
            DataColumn(label: Text('Last Name')),
            DataColumn(label: Text('Mobile Number')),
          ],
          rows: contacts.map((contact) {
            return DataRow(cells: [
              DataCell(Text(contact.firstName)),
              DataCell(Text(contact.lastName)),
              DataCell(Text(contact.mobileNumber)),
            ]);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddContactScreen,
        child: Icon(Icons.add),
      ),
    );
  }
}




class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter first name';
                  }
                  return null;
                },

              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: mobileNumberController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Contact newContact = Contact(
                      firstName: firstNameController.text ?? '',
                      lastName: lastNameController.text ?? '',
                      mobileNumber: mobileNumberController.text ?? '',
                      email: emailController.text ?? '',
                      address: addressController.text ?? '',
                    );
                    Navigator.pop(context, newContact); // Return new contact data
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Contact Saved'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Save'),
              ),



            ],
          ),
        ),
      ),
    );
  }
}
