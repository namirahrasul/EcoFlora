// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, prefer_const_constructors

import 'package:go_router/go_router.dart';

import 'dashboard_screen.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  @override
  
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
       context.go('/sign_in/dashboard');
      }
    });
  }

  Future<AuthResponse> _googleSignIn() async {
    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    String webClientId =
        dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? 'API_KEY not found';
    String iosClientId =
        dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? 'BASE_URL not found';

    /// TODO: update the iOS client ID with your own.
    ///
    /// iOS Client ID that you registered with Google Cloud.
    

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                  radius: 60, // Larger CircleAvatar
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                      'assets/images/logo_ecoflora.png') // Change this to your app's icon
                  ),
              const SizedBox(height: 10),
              Text(
                'ecoflora',
                style: TextStyle(
                    fontFamily: 'Anek Bangla',
                    fontWeight: FontWeight.w500,
                    fontSize: 40,
                    color: Colors.white),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/sign_up');
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'Anek Bangla',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                   context.go('/sign_in');
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'Anek Bangla',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: _googleSignIn,
                  label: const Text(
                    'Google Sign In',
                    style: TextStyle(
                      fontFamily: 'Anek Bangla',
                    ),
                  ),
                  icon: Image.asset(
                    'assets/images/logo_google.png',
                    height: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final supabase = Supabase.instance.client;


