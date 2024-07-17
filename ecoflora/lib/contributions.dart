import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'organization.dart';
import 'organization_data.dart';

class ContributionsPage extends StatelessWidget {
  Future<void> launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contributions',style: TextStyle(
            fontFamily: 'Anek Bangla',
          ),),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8090FD), Color(0xFF76FFBD)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.all(20.0),
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color:
                            Color.fromARGB(255, 249, 161, 191).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.25),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Support these organizations to help protect and conserve plants and biodiversity. Tap on the expand button to view more details and visit their websites.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Anek Bangla',
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final org = organizations[index];
                  return OrganizationCard(
                    name: org.name,
                    description: org.description,
                    url: org.url,
                    imageUrl: org.imageUrl,
                  );
                },
                childCount: organizations.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrganizationCard extends StatefulWidget {
  final String name;
  final String description;
  final String url;
  final String imageUrl;

  const OrganizationCard({
    Key? key,
    required this.name,
    required this.description,
    required this.url,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _OrganizationCardState createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  bool _isDescriptionVisible = false;

  void _toggleDescriptionVisibility() {
    setState(() {
      _isDescriptionVisible = !_isDescriptionVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle tap if needed
      },
      child: Container(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0, bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(156, 255, 255, 255).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 10.0, left: 8.0),
                    child: CircleAvatar(
                      radius: 35, // Adjust the radius as needed
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Image.asset(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          width: 60, // Adjust the image width as needed
                          height: 60, // Adjust the image height as needed
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0), // Adjust the width as needed
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 30.0, left: 10.0),
                      constraints: BoxConstraints(
                          maxWidth: 200.0), // Set the maximum width as needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'Anek Bangla',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.0), // Adjust the height as needed
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 10.0),
                    child: IconButton(
                      icon: Icon(
                        _isDescriptionVisible
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      color: Colors.black.withOpacity(0.5),
                      iconSize: 25.0,
                      onPressed: _toggleDescriptionVisibility,
                    ),
                  ),
                ],
              ),
              if (_isDescriptionVisible)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 8.0),
                  child: Text(
                    widget.description,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontFamily: 'Anek Bangla',
                    ),
                  ),
                ),
              // SizedBox(height: 4.0), // Adjust the height as needed
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 2.0, bottom: 2.0)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    decoration: BoxDecoration(
                      color:
                          Color.fromARGB(255, 179, 216, 245).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(widget.url);
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch ${widget.url}');
                        }
                      },
                      child: Text(
                        'Visit Now ->',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 14.0,
                          fontFamily: 'Anek Bangla',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
