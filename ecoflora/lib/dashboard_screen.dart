import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'main.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];
    final email = user?.email;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: CircleAvatar(
            foregroundImage: AssetImage('assets/images/logo_ecoflora.png'),
          ),
        ),
        title: Text(
          'ecoflora',
          style: TextStyle(
              fontFamily: 'Anek Bangla',
              fontWeight: FontWeight.w500,
              fontSize: 30,
              color: Colors.deepPurple),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.person),
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white.withOpacity(0.75),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 40,
                  fontFamily: 'Anek Bangla',
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.075),
            if (profileImageUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl),
                radius: 80,
              ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      fullName!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Anek Bangla',
                          fontWeight: FontWeight.normal),
                    ),
                    Text(
                      email!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Anek Bangla',
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
                    ElevatedButton(
                      onPressed: () async {
                        await supabase.auth.signOut();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: const Text(
                          'Sign out',
                          style: TextStyle(
                              fontFamily: 'Anek Bangla',
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8090FD), Color(0xFF76FFBD)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.25),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.all(2.0),
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.25),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome to ',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: 'Anek Bangla'),
                              ),
                              TextSpan(
                                text: 'ecoflora',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.deepPurple,
                                    fontFamily: 'Anek Bangla'),
                              ),
                              TextSpan(
                                text: ',\n${fullName!}',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: 'Anek Bangla'),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      children: [
                        MenuTile(
                          icon: Icons.location_on,
                          label: 'Find Native Plants',
                          onPressed: () {
                            context
                                .go('/sign_in/dashboard/native_plant_finder');
                          },
                        ),
                        MenuTile(
                          icon: Icons.local_florist,
                          label: 'My Garden',
                          onPressed: () {
                            context.go('/sign_in/dashboard/garden_index');
                          },
                        ),
                        MenuTile(
                          icon: Icons.bookmark,
                          label: 'Saved Plants',
                          onPressed: () {
                            context.go('/sign_in/dashboard/saved_plants');
                          },
                        ),
                        MenuTile(
                          icon: Icons.remove_red_eye,
                          label: 'Identify Plant',
                          onPressed: () {
                            context.go('/sign_in/dashboard/plant_identifier');
                          },
                        ),
                        MenuTile(
                          icon: Icons.water_drop,
                          label: 'Care Log',
                          onPressed: () {
                            context.go('/sign_in/dashboard/care_log');
                          },
                        ),
                        MenuTile(
                          icon: Icons.handshake,
                          label: 'Contribute',
                          onPressed: () {
                            context
                                .go('/sign_in/dashboard/contribute');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  MenuTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          margin: EdgeInsets.all(6.0),
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.25),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20.0,
                color: Colors.deepPurple.withOpacity(0.8),
              ),
              SizedBox(height: 5.0),
              Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.deepPurple.withOpacity(0.8),
                    fontFamily: 'Anek Bangla'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
