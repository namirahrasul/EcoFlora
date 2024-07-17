import 'dart:ffi';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'saved_plants_provider.dart';
import 'native_plant_info.dart';
import 'saved_plant.dart';
import 'saved_plants_list.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String plantnetApiKey = dotenv.env['PLANTNET_API_KEY'] ?? 'API_KEY not found';
String trefleApiToken = dotenv.env['TREFLE_API_TOKEN'] ?? 'BASE_URL not found';

class NativePlantsFinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Native Plants Finder',
          style: TextStyle(
            fontFamily: 'Anek Bangla',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedPlantsList()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8090FD), Color(0xFF76FFBD)],
          ),
        ),
        child: DistributionList(),
      ),
    );
  }
}

class DistributionList extends StatefulWidget {
  @override
  _DistributionListState createState() => _DistributionListState();
}

class _DistributionListState extends State<DistributionList> {
  List<dynamic> _allDistributions = [];
  List<dynamic> _filteredDistributions = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllDistributions();
    _searchController.addListener(_searchDistributions);
  }

  void fetchAllDistributions() async {
    setState(() {
      _isLoading = true;
    });

    int page = 1;
    bool hasMorePages = true;
    Dio dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    String url = 'https://trefle.io/api/v1/distributions';
    String token = trefleApiToken;

    while (hasMorePages) {
      try {
        var response = await dio.get(
          url,
          queryParameters: {
            'token': token,
            'page': page,
          },
        );

        if (response.statusCode == 200) {
          List<dynamic> data = response.data['data'];
          setState(() {
            _allDistributions.addAll(data);
          });

          if (data.isEmpty) {
            hasMorePages = false;
          } else {
            page++;
          }
        } else {
          print(
              'Failed to load distributions. Status code: ${response.statusCode}');
          hasMorePages = false;
        }
      } catch (e) {
        print('Error fetching distributions: $e');
        hasMorePages = false;
      }
    }

    setState(() {
      _filteredDistributions = _allDistributions;
      _isLoading = false;
    });
  }

  void _searchDistributions() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDistributions = _allDistributions
          .where((distribution) =>
              distribution['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  void navigateToPlantListScreen(BuildContext context, dynamic distribution) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantListScreen(
          distribution: distribution,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for areas',
              hintStyle: TextStyle(
                fontFamily: 'Anek Bangla',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _filteredDistributions.length,
                  itemBuilder: (context, index) {
                    var distribution = _filteredDistributions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.white.withOpacity(
                              0.6), // Adjust the color and opacity here
                        ),
                        onPressed: () {
                          navigateToPlantListScreen(context, distribution);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            distribution['name'],
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Anek Bangla',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchDistributions);
    _searchController.dispose();
    super.dispose();
  }
}

class PlantListScreen extends StatefulWidget {
  final dynamic distribution;

  PlantListScreen({required this.distribution});

  @override
  _PlantListScreenState createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  List<dynamic> _allNativePlantData = [];
  int _currentPage = 1;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPlantsNativeToDistribution(widget.distribution['tdwg_code']);
    _scrollController.addListener(_scrollListener);
  }

  void _fetchPlantsNativeToDistribution(String distributionCode,
      {int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
      String url = 'https://trefle.io/api/v1/species';
      String token = trefleApiToken;
      var response = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'zone_id': distributionCode,
          'filter[establishment]': 'native',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        setState(() {
          _allNativePlantData.addAll(data);
          _isLoading = false;
        });
      } else {
        print(
            'Failed to load native plants. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching native plant data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the bottom of the list, load more data
      _fetchPlantsNativeToDistribution(widget.distribution['tdwg_code'],
          page: ++_currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Native Plants in ${widget.distribution['name']}',
          style: TextStyle(
            fontFamily: 'Anek Bangla',
          ),
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
        padding: EdgeInsets.all(10.0), // Add padding around the container
        child: Consumer(
          builder: (context, ref, child) {
            final savedPlantsNotifier = ref.read(savedPlantsProvider.notifier);

            return _isLoading
                ? Center(child: CircularProgressIndicator())
                : _allNativePlantData.isEmpty
                    ? Center(
                        child: Text(
                          'Sorry, no native species are found.',
                          style: TextStyle(
                            fontFamily: 'Anek Bangla',
                          ),
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _allNativePlantData.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _allNativePlantData.length) {
                            var plant = _allNativePlantData[index];
                            var commonName = plant['common_name'] ??
                                plant['scientific_name'];
                            var imageUrl = plant['image_url'] ?? '';
                            var scientificName =
                                plant['scientific_name'] ?? '-';

                            return GestureDetector(
                              onTap: () {
                                print(
                                    'Tapped on plant: ${plant['scientific_name']}');
                              },
                              child: Card(
                                elevation: 3,
                                color: Colors.white.withOpacity(0.7),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              )
                                            : Center(
                                                child: Text(
                                                  'No Image',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0,
                                                    fontFamily: 'Anek Bangla',
                                                  ),
                                                ),
                                              ),
                                        //  ],
                                        // ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        commonName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          
                                            fontFamily: 'Anek Bangla',
                                         
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        'Scientific Name: ${scientificName}',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[600],
                                           fontFamily: 'Anek Bangla',
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.info),
                                          onPressed: () async {
                                            PlantService.getInfoPlant(
                                                context, scientificName);
                                          },
                                        ),

                                        IconButton(
                                          icon: Icon(Icons.favorite),
                                          onPressed: () {
                                            // Create a Plant object
                                            SavedPlant plantToSave = SavedPlant(
                                              id: plant['id']
                                                  .toString(), // Convert ID to string
                                              commonName:
                                                  plant['common_name'] ??
                                                      plant['scientific_name'],
                                              scientificName:
                                                  plant['scientific_name'] ??
                                                      '-',
                                              imageUrl:
                                                  plant['image_url'] ?? '',
                                              areas: [
                                                widget.distribution['name']
                                              ], // Save the area name
                                            );
                                            print(
                                                'Saving plant: ${plantToSave.commonName}, Areas: ${plantToSave.areas}');

                                            // Save plant details using Riverpod state management
                                            savedPlantsNotifier
                                                .addPlant(plantToSave);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Saved successfully in your list',
                                                  style: TextStyle(
                                                    fontFamily: 'Anek Bangla',
                                                  ),
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
