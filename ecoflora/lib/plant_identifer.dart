import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class PlantIdentificationPage extends StatefulWidget {
  @override
  _PlantIdentificationPageState createState() =>
      _PlantIdentificationPageState();
}

class _PlantIdentificationPageState extends State<PlantIdentificationPage> {
  File? _imageFile;
  String _identificationResult = '';
  String plantnetApiKey = dotenv.env['PLANTNET_API_KEY'] ?? 'API_KEY not found';
  String trefleApiToken =dotenv.env['TREFLE_API_TOKEN'] ?? 'BASE_URL not found';
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final convertedFile = await _convertToPng(File(pickedFile.path));
      setState(() {
        _imageFile = convertedFile;
        _identificationResult = ''; // Reset result when new image is selected
      });
    }
  }

  Future<File> _convertToPng(File file) async {
    final fileExtension = file.path.split('.').last.toLowerCase();
    if (fileExtension != 'jpeg') {
      final bytes = await file.readAsBytes();
      final image = img.decodeNamedImage(file.path, bytes);
      if (image != null) {
        final pngBytes = img.encodePng(image);
        final newPath = file.path.replaceAll(RegExp(r'\.\w+$'), '.png');
        final newFile = await File(newPath).writeAsBytes(pngBytes);
        return newFile;
      } else {
        throw Exception('Unsupported image format: $fileExtension');
      }
    }
    return file;
  }

  Future<void> identifyPlant(File imageFile) async {
    try {
      String apiUrl = 'https://my-api.plantnet.org/v2/identify/all';

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'images': [
          await MultipartFile.fromFile(imageFile.path,
              filename: fileName, contentType: MediaType('image', 'png')),
        ],
        'organs': ['auto'],
      });

      Dio dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 120),
          receiveTimeout: Duration(seconds: 120),
        ),
      );

      Response response = await dio.post(
        apiUrl,
        queryParameters: {
          'include-related-images': false,
          'no-reject': true,
          'lang': 'en',
          'type': 'kt',
          'api-key': plantnetApiKey,
        },
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            return status! < 500; // Allow 400 errors to be handled
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Identification successful');
        print('Response data: ${response.data}');
        setState(() {
          _identificationResult = response.data.toString();
        });

        if (response.data != null) {
          _showResultDialog(response.data);
        } else {
          print('Error: Response data is null');
          _showErrorDialog('Unexpected error: Response data is null');
        }
      } else {
        print('Error - StatusCode: ${response.statusCode}');
        print(response.data);
        _showErrorDialog('Error - StatusCode: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Exception during API call: $e');
      _showErrorDialog('Exception during API call: $e');
    } on SocketException catch (e) {
      print('SocketException during API call: $e');
      _showErrorDialog('SocketException during API call: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(fontFamily: 'Anek Bangla'),
          ),
          content: Text(
            message,
            style: TextStyle(fontFamily: 'Anek Bangla'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(fontFamily: 'Anek Bangla'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(Map<String, dynamic> data) {
    // Helper function to format the scientific name for API request
    String formatScientificName(String scientificName) {
      return scientificName.toLowerCase().replaceAll(' ', '-');
    }

    // Configure Dio with a custom HttpClientAdapter to ignore SSL certificates
    Dio dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    });

    showDialog(
      context: context,
      builder: (context) {
        final List<dynamic> results = data['results'];
        final species = results.isNotEmpty ? results.first['species'] : null;

        if (species == null) {
          return AlertDialog(
            title: Text(
              'Identification Result',
              style: TextStyle(fontFamily: 'Anek Bangla'),
            ),
            content: Text(
              'No species information available.',
              style: TextStyle(fontFamily: 'Anek Bangla'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(fontFamily: 'Anek Bangla'),
                ),
              ),
            ],
          );
        }

        // Prepare API URL for fetching species details
        String apiUrl =
            'https://trefle.io/api/v1/species/${formatScientificName(species['scientificNameWithoutAuthor'])}';
        String apiKey = trefleApiToken;

        return FutureBuilder(
          future: dio.get(apiUrl, queryParameters: {'token': apiKey}),
          builder: (context, AsyncSnapshot<Response> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(fontFamily: 'Anek Bangla'),
                ),
                content: Text(
                  'Failed to fetch species details: ${snapshot.error}',
                  style: TextStyle(fontFamily: 'Anek Bangla'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(fontFamily: 'Anek Bangla'),
                    ),
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data?.statusCode != 200) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(fontFamily: 'Anek Bangla'),
                ),
                content: Text(
                  'Failed to fetch species details.',
                  style: TextStyle(fontFamily: 'Anek Bangla'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(fontFamily: 'Anek Bangla'),
                    ),
                  ),
                ],
              );
            }

            // Parse the species details from the response
            final Map<String, dynamic>? speciesDetails =
                snapshot.data?.data['data'];

            // Build the dialog with fetched species details
            return AlertDialog(
              title: Text(
                'Identification Result',
                style: TextStyle(fontFamily: 'Anek Bangla'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best Match: ${data['bestMatch'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla'),
                    ),
                    Text(
                      'Probability: ${results.first['score']}',
                      style: TextStyle(fontFamily: 'Anek Bangla'),
                    ),
                    Text(
                      'Scientific Name: ${species['scientificName'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla'),
                    ),
                    Text(
                      'Genus: ${species['genus']['scientificName'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla'),
                    ),
                    Text(
                      'Family: ${species['family']['scientificName'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla'),
                    ),
                    //SizedBox(height: 20),
                    if (speciesDetails != null) ...[
                      //Text('Species Details:'),
                      if (speciesDetails['common_names'] != null &&
                          speciesDetails['common_names']['eng'] != null)
                        Text(
                          'Common Names (English): ${speciesDetails['common_names']['eng']?.join(', ') ?? 'Unknown'}',
                          style: TextStyle(fontFamily: 'Anek Bangla'),
                        ),
                      if (speciesDetails['common_names'] != null &&
                          speciesDetails['common_names']['bn'] != null)
                        Text(
                          'Common Names (Bangla): ${speciesDetails['common_names']['bn']?.join(', ') ?? 'Unknown'}',
                          style: TextStyle(fontFamily: 'Anek Bangla'),
                        ),
                      if (speciesDetails['distribution'] != null &&
                          speciesDetails['distribution']['native'] != null &&
                          speciesDetails['distribution']['native']
                              .contains('Bangladesh')) ...[
                        Container(
                          child: Row(children: [
                            Text(
                              'Distribution: ',
                              style: TextStyle(fontFamily: 'Anek Bangla'),
                            ),
                            Text('Native',
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Anek Bangla',
                                )),
                          ]),
                        )
                      ] else if (speciesDetails['distribution'] == null ||
                          speciesDetails['distribution']['native'] == null ||
                          !speciesDetails['distribution']['native']
                              .contains('Bangladesh')) ...[
                        Container(
                          child: Row(children: [
                            Text(
                              'Distribution: ',
                              style: TextStyle(fontFamily: 'Anek Bangla'),
                            ),
                            Text(
                              'Introduced',
                              style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Anek Bangla'),
                            ),
                          ]),
                        )
                      ],
                      Text('Edible: ${speciesDetails['edible'] ?? 'Unknown'}'),
                      if (speciesDetails['growth'] != null) ...[
                        if (speciesDetails['growth']['description'] != null)
                          Text(
                            'Growth Information:',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        Text(
                          'Description: ${speciesDetails['growth']['description'] ?? 'Unknown'}',
                          style: TextStyle(fontFamily: 'Anek Bangla'),
                        ),
                        if (speciesDetails['growth']['sowing'] != null)
                          Text(
                            'Sowing: ${speciesDetails['growth']['sowing'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['days_to_harvest'] != null)
                          Text(
                            'Days to Harvest: ${speciesDetails['growth']['days_to_harvest'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['row_spacing']['cm'] !=
                            null)
                          Text(
                            'Row Spacing (cm): ${speciesDetails['growth']['row_spacing']['cm'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['spread']['cm'] != null)
                          Text(
                            'Spread (cm): ${speciesDetails['growth']['spread']['cm'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['ph_maximum'] != null)
                          Text(
                            'Maximum pH: ${speciesDetails['growth']['ph_maximum'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['ph_minimum'] != null)
                          Text(
                            'Minimum pH: ${speciesDetails['growth']['ph_minimum'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['light'] != null)
                          Text(
                            'Light Requirement: ${speciesDetails['growth']['light'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['atmospheric_humidity'] !=
                            null)
                          Text(
                            'Atmospheric Humidity: ${speciesDetails['growth']['atmospheric_humidity'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['growth_months'] != null)
                          Text(
                            'Growth Months: ${speciesDetails['growth']['growth_months']?.join(', ') ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['bloom_months'] != null)
                          Text(
                            'Bloom Months: ${speciesDetails['growth']['bloom_months']?.join(', ') ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['fruit_months'] != null)
                          Text(
                            'Fruit Months: ${speciesDetails['growth']['fruit_months']?.join(', ') ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['minimum_precipitation']
                                ['mm'] !=
                            null)
                          Text(
                            'Minimum Precipitation (mm): ${speciesDetails['growth']['minimum_precipitation']['mm'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['maximum_precipitation']
                                ['mm'] !=
                            null)
                          Text(
                            'Maximum Precipitation (mm): ${speciesDetails['growth']['maximum_precipitation']['mm'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['minimum_root_depth']
                                ['cm'] !=
                            null)
                          Text(
                            'Minimum Root Depth (cm): ${speciesDetails['growth']['minimum_root_depth']['cm'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['minimum_temperature']
                                ['deg_c'] !=
                            null)
                          Text(
                            'Minimum Temperature (°C): ${speciesDetails['growth']['minimum_temperature']['deg_c'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['maximum_temperature']
                                ['deg_c'] !=
                            null)
                          Text(
                            'Maximum Temperature (°C): ${speciesDetails['growth']['maximum_temperature']['deg_c'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['soil_nutriments'] != null)
                          Text(
                            'Soil Nutriments: ${speciesDetails['growth']['soil_nutriments'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['soil_salinity'] != null)
                          Text(
                            'Soil Salinity: ${speciesDetails['growth']['soil_salinity'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['soil_texture'] != null)
                          Text(
                            'Soil Texture: ${speciesDetails['growth']['soil_texture'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                        if (speciesDetails['growth']['soil_humidity'] != null)
                          Text(
                            'Soil Humidity: ${speciesDetails['growth']['soil_humidity'] ?? 'Unknown'}',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontFamily: 'Anek Bangla'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Identification',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Anek Bangla'),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8090FD), Color(0xFF76FFBD)],
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _imageFile == null
                        ? const Text(
                            'No image selected.',
                            style: TextStyle(fontFamily: 'Anek Bangla'),
                          )
                        : Container(
                            width: 300, // Adjust the width as needed
                            height: 300, // Adjust the height as needed
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit
                                  .contain, // Adjust the fit property as needed
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                    color: Colors.white.withOpacity(0.36),
                  ),
                  child: TextButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    child: const Text(
                      'Choose Image',
                      style: TextStyle(
                          fontFamily: 'Anek Bangla', color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                    color: Colors.white.withOpacity(0.36),
                  ),
                  child: TextButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    child: const Text(
                      'Take Photo',
                      style: TextStyle(
                          fontFamily: 'Anek Bangla', color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                    color: Colors.white.withOpacity(0.36),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (_imageFile != null) {
                        identifyPlant(_imageFile!);
                      } else {
                        print('No image selected.');
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    child: const Text(
                      'Identify Plant',
                      style: TextStyle(
                          fontFamily: 'Anek Bangla', color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Add some space at the bottom
          ],
        ),
      ),
    );
  }
}
