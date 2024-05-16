import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatelessWidget {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    String name = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    try {
      var url = Uri.parse('https://api.voilacode.com/api/register');
      var response = await http.post(url, body: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Registration successful, navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Handle unsuccessful registration
        String errorMessage = 'Registration failed';

        // Check if the response body contains an HTML error message
        if (response.body != null && response.body.isNotEmpty) {
          errorMessage = _extractErrorMessage(response.body);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(errorMessage),
              actions: [
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
    } catch (e) {
      print('Error: $e');
      // Handle network or other errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while registering.'),
            actions: [
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
  }

// Helper function to extract error message from HTML response
  String _extractErrorMessage(String htmlResponse) {
    // Find the start of the error message within the HTML response
    int startIndex = htmlResponse.indexOf('<!--');
    if (startIndex != -1) {
      int endIndex = htmlResponse.indexOf('-->', startIndex);
      if (endIndex != -1) {
        // Extract the error message from the HTML comment
        String errorMessage = htmlResponse.substring(startIndex + 4, endIndex).trim();
        return errorMessage;
      }
    }

    return 'Unknown error occurred';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}