import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dashboard_screen.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final UsernameController = TextEditingController();
  final EmailController = TextEditingController();
  final PasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String signupRedirectEmail = dotenv.env['SIGNUP_REDIRECT_EMAIL'] ?? 'API_KEY not found';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontFamily: 'Anek Bangla',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 83, 113, 234),
              Color.fromARGB(255, 43, 230, 192),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60, // Larger CircleAvatar
              backgroundImage: AssetImage(
                  'assets/images/logo_ecoflora.png'), // Change this to your app's icon
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: UsernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  hintStyle: TextStyle(
                    fontFamily: 'Anek Bangla',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: EmailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontFamily: 'Anek Bangla',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: PasswordController,
                decoration: const InputDecoration(
                  hintText: 'Password(atleast 6 characters)',
                  hintStyle: TextStyle(
                    fontFamily: 'Anek Bangla',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final authResponse = await supabase.auth.signUp(
                  email: EmailController.text,
                  password: PasswordController.text,
                  emailRedirectTo: signupRedirectEmail,
                  data: {
                    'full_name': UsernameController.text,
                  },
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Signed up ${authResponse.user!.email!}',
                      style: TextStyle(
                        fontFamily: 'Anek Bangla',
                      ),
                    ),
                  ),
                );
               context.go('/');
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'Anek Bangla',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
