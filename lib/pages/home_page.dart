import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  // Open a dialog box
  void openNoteBox({String? docID, String? existingText}) {
    textController.text = existingText ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(docID == null ? 'Add Note' : 'Update Note'),
            content: Form(
              // key: _formKey,
              child: TextFormField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter your note here'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  final text = textController.text.trim();
                  Navigator.pop(context);

                  // Decide whether to add or update
                  if (docID == null) {
                    firestoreService.addNote(text);
                  } else {
                    firestoreService.updateNote(docID, text);
                  }
                  // Reset the form
                  textController.clear();
                },
                child: Text(docID == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    ).then((_) {
      // Reset if user taps outside dialog
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        backgroundColor: Colors.pinkAccent[100],
      ),
      body: Column(
        children: [
          // Display account information and logout button

          // Notes list
          Expanded(
            child: StreamBuilder(
              stream: firestoreService.getNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List notesList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notesList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = notesList[index];
                      String docID = document.id;

                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['note'];

                      return ListTile(
                        title: Text(noteText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.settings),
                              onPressed:
                                  () => openNoteBox(
                                    docID: docID,
                                    existingText: noteText,
                                  ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed:
                                  () => firestoreService.deleteNote(docID),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Text("No notes...");
                }
              },
            ),
          ),
          Align(
            alignment:
                Alignment
                    .bottomRight, // Align the button to the bottom-right corner
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Add padding for spacing
              child: FloatingActionButton(
                onPressed: openNoteBox,
                child: const Icon(Icons.add),
                backgroundColor: Colors.pinkAccent[100],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          AccountInfo(),
        ],
      ),
    );
  }
}

class AccountInfo extends StatelessWidget {
  const AccountInfo({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: Colors.pinkAccent[100],
            width: double.infinity,
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Logged in as ${snapshot.data?.email}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => logout(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pinkAccent[100],
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        } else {
          return const Text('No user is logged in');
        }
      },
    );
  }
}
