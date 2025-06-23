import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/db/firestore_service.dart';
import 'package:flutter_chat_app/models/user.dart';
import 'package:flutter_chat_app/widgets/image_picker.dart';

final _fireBase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogging = true;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String enteredUsername = '';
    String enteredEmail = '';
    String enteredPassword = '';
    String error = '';
    File? takenImage;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    void toggleIsLogging() {
      setState(() {
        isLogging = !isLogging;
      });
    }

    void handleLogin() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        try {
          final userCredentials = await _fireBase.signInWithEmailAndPassword(
            email: enteredEmail,
            password: enteredPassword,
          );
        } on FirebaseAuthException catch (e) {
          if (e.message != null) {
            error = e.message!;
          } else {
            error = 'Authentication Error';
          }
        }
        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(error)));
      }
    }

    void handleSignUp() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        try {
          final userCredentials = await _fireBase
              .createUserWithEmailAndPassword(
                email: enteredEmail,
                password: enteredPassword,
              );

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('favorite-places')
              .child('/${userCredentials.user!.uid}.png');

          final uploadTask = storageRef.putFile(takenImage!);
          final snapshot = await uploadTask.whenComplete(() {});
          final downloadUrl = await snapshot.ref.getDownloadURL();

          final userInfoToSave = UserModel(
            username: enteredUsername,
            email: enteredEmail,
            imgDownloadUrl: downloadUrl,
          );

          await FirestoreService().saveUserInfo(
            userCredentials.user!.uid,
            userInfoToSave,
          );
        } on FirebaseAuthException catch (e) {
          if (!mounted) return;

          if (e.message != null) {
            error = e.message!;
          } else {
            error = 'Sign up error';
          }

          scaffoldMessenger.clearSnackBars();
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(error)));
        }
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10),
          child: Column(
            children: [
              Image.asset('assets/images/chat.png', width: 200),
              SizedBox(height: 24),
              if (!isLogging)
                ImagePickerWidget(
                  onImageTake: (File file) {
                    takenImage = file;
                  },
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      spacing: 10,
                      children: [
                        if (!isLogging)
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Username'),
                            validator: usernameValidator,
                            autocorrect: false,
                            keyboardType: TextInputType.none,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (newValue) => enteredUsername = newValue!,
                          ),

                        TextFormField(
                          decoration: InputDecoration(labelText: "Email"),
                          validator: emailValidator,
                          autofocus: true,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (newValue) => enteredEmail = newValue!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          validator: passwordValidator,
                          autocorrect: false,
                          keyboardType: TextInputType.none,
                          obscureText: true,
                          onSaved: (newValue) => enteredPassword = newValue!,
                        ),
                        ElevatedButton(
                          onPressed: isLogging ? handleLogin : handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Text(
                            (isLogging ? 'Login' : 'Sign up'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: toggleIsLogging,
                          child: Text(
                            (isLogging
                                ? 'Create an account'
                                : 'Already have an account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter username';
    }

    if (value.length < 4) {
      return 'Usernamed must be at least 4 characters long';
    }

    return null;
  }

  String? emailValidator(String? value) {
    const pattern =
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Must include at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Must include at least one number';
    }
    if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
      return 'Must include at least one special character (@, \$, !, %, *, ?, &)';
    }
    return null;
  }
}
