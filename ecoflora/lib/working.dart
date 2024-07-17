import 'dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;
  await Supabase.initialize(
    url: "https://csbskugsoqdxukfiuweb.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzYnNrdWdzb3FkeHVrZml1d2ViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAwODM3NjYsImV4cCI6MjAzNTY1OTc2Nn0.CPGq5Eg46oZNPCwp230COSgJ_lO--NiecXhtY-onZ1c",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
          ),
        );
      }
    });
  }

  Future<AuthResponse> _googleSignIn() async {
    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '844985621931-k4quo58o9e05ks22fdutbd6bagv76fjt.apps.googleusercontent.com';

    /// TODO: update the iOS client ID with your own.
    ///
    /// iOS Client ID that you registered with Google Cloud.
    const iosClientId =
        '844985621931-g0evpbr91abpighdqauaqpr3hevl8051.apps.googleusercontent.com';

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
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: _googleSignIn,
              child: Row(mainAxisSize: MainAxisSize.min, children:[CircleAvatar(foregroundImage: AssetImage('assets/images/logo_google.png'),backgroundColor: Colors.white,), SizedBox(width: 10,),Text('Google Sign In', ),]),
            ),
          ],
        ),
      ),
    );
  }
}


final supabase = Supabase.instance.client;

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
    return Scaffold(
      appBar: AppBar(
        leading: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back'),
        ),
        title: const Text('Sign Up'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: UsernameController,
            decoration: const InputDecoration(hintText: 'Username'),
          ),
          TextField(
            controller: EmailController,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          TextField(
            controller: PasswordController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () async {
              final authResponse = await supabase.auth.signUp(
                email: EmailController.text,
                password: PasswordController.text,
                data: {
                  'full_name': UsernameController.text,
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signed up ${authResponse.user!.email!}'),
                ),
              );
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final EmailController = TextEditingController();
  final PasswordController = TextEditingController();

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: EmailController,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          TextField(
            controller: PasswordController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () async {
              final authResponse = await supabase.auth.signInWithPassword(
                email: EmailController.text,
                password: PasswordController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signed in ${authResponse.user!.email!}'),
                ),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(),
                ),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}

