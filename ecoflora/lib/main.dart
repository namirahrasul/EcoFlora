// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, prefer_const_constructors

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dashboard_screen.dart';
import 'home_page.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import 'forget_password.dart';
import 'native_plant_finder.dart';
import 'saved_plants_list.dart';
import 'plant_identifer.dart';
import 'garden_index.dart';
import 'care_log.dart';
import 'contributions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'API_KEY not found';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'BASE_URL not found';
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey:
        supabaseAnonKey,
  );
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ecoflora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return HomePage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'sign_up',
            builder: (context, state) {
              return SignUp();
            },
          ),
          GoRoute(
              path: 'sign_in',
              builder: (context, state) {
                return SignIn();
              },
              routes: <RouteBase>[
                GoRoute(
                    path: 'dashboard',
                    builder: (context, state) {
                      return DashboardScreen();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'native_plant_finder',
                        builder: (context, state) {
                          return NativePlantsFinder();
                        },
                      ),
                       GoRoute(
                        path: 'garden_index',
                        builder: (context, state) {
                          return GardenIndex();
                        },
                      ),
                      GoRoute(
                        path: 'saved_plants',
                        builder: (context, state) {
                          return SavedPlantsList();
                        },
                      ),
                      GoRoute(
                        path: 'plant_identifier',
                        builder: (context, state) {
                          return PlantIdentificationPage();
                        },
                      ),
                      GoRoute(
                        path: 'care_log',
                        builder: (context, state) {
                          return CheckList();
                        },
                      ),
                      GoRoute(
                        path: 'contribute',
                        builder: (context, state) {
                          return ContributionsPage();
                        },
                      ),
                    ]),
                GoRoute(
                  path: 'forget_password',
                  builder: (context, state) {
                    return ForgetPassword();
                  },
                ),
              ]),
        ]),
  ],
);
