import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
String plantnetApiKey = dotenv.env['PLANTNET_API_KEY'] ?? 'API_KEY not found';
String trefleApiToken = dotenv.env['TREFLE_API_TOKEN'] ?? 'BASE_URL not found';
class PlantService {
  static final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 180),
    receiveTimeout: Duration(seconds: 180),
  ))
    ..httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    });

  static Future<void> getInfoPlant(
      BuildContext context, String scientificName) async {
    try {
      String formatScientificName(String name) {
        return name.toLowerCase().replaceAll(' ', '-');
      }

      String formattedName = formatScientificName(scientificName);
      String apiUrl = 'https://trefle.io/api/v1/species/$formattedName';
      String apiKey = trefleApiToken;

      Response response =
          await dio.get(apiUrl, queryParameters: {'token': apiKey});

      if (response.statusCode == 200) {
        _showResultDialog(context, response.data['data'], scientificName);
      } else {
        _showErrorDialog(context, 'Error - StatusCode: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _showErrorDialog(context, 'Exception during API call: $e');
    } on SocketException catch (e) {
      _showErrorDialog(context, 'SocketException during API call: $e');
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(fontFamily: 'Anek Bangla')),
          content: Text(message, style: TextStyle(fontFamily: 'Anek Bangla')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(fontFamily: 'Anek Bangla')),
            ),
          ],
        );
      },
    );
  }

  static void _showResultDialog(BuildContext context,
      Map<String, dynamic> speciesDetails, String scientificName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(scientificName, style: TextStyle(fontFamily: 'Anek Bangla',fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 if (speciesDetails['family'] != null)
                  Text(
                    'Family: ',
                    style: TextStyle(
                        fontFamily: 'Anek Bangla', fontWeight: FontWeight.bold),
                  ),
                  if (speciesDetails['family'] != null)
                   Text(
                      '${speciesDetails['family'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                if (speciesDetails['family'] != null)
                  Text(
                    'Genus: ',
                    style: TextStyle(
                        fontFamily: 'Anek Bangla', fontWeight: FontWeight.bold),
                  ),
                if (speciesDetails['genus'] != null)
                  Text('${speciesDetails['genus'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                if (speciesDetails['edible_part'] != null )
                  Text(
                    'Edible Part(s): ',
                    style: TextStyle(
                        fontFamily: 'Anek Bangla', fontWeight: FontWeight.bold),
                  ),
                if (speciesDetails['edible_part'] != null)
                  Text(
                    '${speciesDetails['edible_part']?.join(', ') ?? 'Unknown'}',
                    style: TextStyle(fontFamily: 'Anek Bangla'),
                  ),
                if (speciesDetails['common_names'] != null &&
                    speciesDetails['common_names']['eng'] != null)
                  Text(
                    'Common Names (English): ',
                    style: TextStyle(
                        fontFamily: 'Anek Bangla', fontWeight: FontWeight.bold),
                  ),
                if (speciesDetails['common_names'] != null &&
                    speciesDetails['common_names']['eng'] != null)
                  Text(
                    '${speciesDetails['common_names']['eng']?.join(', ') ?? 'Unknown'}',
                    style: TextStyle(fontFamily: 'Anek Bangla'),
                  ),
                if (speciesDetails['common_names'] != null &&
                    speciesDetails['common_names']['bn'] != null)
                  Text(
                    'Common Names (Bangla): ',
                    style: TextStyle(
                        fontFamily: 'Anek Bangla', fontWeight: FontWeight.bold),
                  ),
                if (speciesDetails['common_names'] != null &&
                    speciesDetails['common_names']['bn'] != null)
                  Text(
                    '${speciesDetails['common_names']['bn']?.join(', ') ?? 'Unknown'}',
                    style: TextStyle(fontFamily: 'Anek Bangla'),
                  ),
               
                Text('Edible: ',
                    style: TextStyle(
                        fontFamily: 'Anek Bangla',
                        fontWeight: FontWeight.bold)),
                Text('${speciesDetails['edible'] ?? 'Unknown'}',
                    style: TextStyle(fontFamily: 'Anek Bangla')),
                if (speciesDetails['growth'] != null) ...[
                  if (speciesDetails['growth']['description'] != null)
                    Text('Growth Information:',
                        style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['description'] != null)
                  Text('Description: ',
                      style: TextStyle(
                          fontFamily: 'Anek Bangla',
                          fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['description'] != null)
                  Text(
                      '${speciesDetails['growth']['description'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['sowing'] != null)
                    Text('Sowing: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['sowing'] != null)
                  Text('${speciesDetails['growth']['sowing'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['days_to_harvest'] != null)
                    Text('Days to Harvest: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                   if (speciesDetails['growth']['days_to_harvest'] != null)
                  Text(
                      '${speciesDetails['growth']['days_to_harvest'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['row_spacing']?['cm'] != null)
                    Text('Row Spacing (cm): ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['row_spacing']?['cm'] != null)
                  Text(
                      '${speciesDetails['growth']['row_spacing']['cm'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['spread']?['cm'] != null)
                    Text('Spread (cm): ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['row_spacing']?['cm'] != null)
                  Text(
                      '${speciesDetails['growth']['spread']['cm'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['ph_maximum'] != null)
                    Text('Maximum pH: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['ph_maximum'] != null)
                  Text('${speciesDetails['growth']['ph_maximum'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['ph_minimum'] != null)
                    Text('Minimum pH: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['ph_minimum'] != null)
                  Text('${speciesDetails['growth']['ph_minimum'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['light'] != null)
                    Text('Light Requirement: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['light'] != null)
                  Text('${speciesDetails['growth']['light'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['atmospheric_humidity'] != null)
                    Text('Atmospheric Humidity: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['atmospheric_humidity'] != null)
                  Text(
                      '${speciesDetails['growth']['atmospheric_humidity'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['growth_months'] != null)
                    Text('Growth Months: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['growth_months'] != null)
                  Text(
                      '${speciesDetails['growth']['growth_months'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['bloom_months'] != null)
                    Text('Bloom Months: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['bloom_months'] != null)
                  Text(
                      '${speciesDetails['growth']['bloom_months'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['fruit_months'] != null)
                    Text('Fruit Months: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['fruit_months'] != null)
                  Text(
                      '${speciesDetails['growth']['fruit_months'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['minimum_precipitation']
                          ?['mm'] !=
                      null)
                    Text('Minimum Precipitation (mm): ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['minimum_precipitation']
                          ?['mm'] !=
                      null)
                  Text(
                      '${speciesDetails['growth']['minimum_precipitation']['mm'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['maximum_precipitation']
                          ?['mm'] !=
                      null)
                    Text('Maximum Precipitation (mm): ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                   if (speciesDetails['growth']['maximum_precipitation']
                          ?['mm'] !=
                      null)
                  Text(
                      '${speciesDetails['growth']['maximum_precipitation']['mm'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['minimum_root_depth']?['cm'] !=
                      null)
                    Text('Minimum Root Depth (cm): ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['minimum_root_depth']?['cm'] !=
                      null)
                  Text(
                      '${speciesDetails['growth']['minimum_root_depth']['cm'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['minimum_temperature']
                          ?['deg_c'] !=
                      null)
                    Text('Minimum Temperature (°C): ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['minimum_temperature']
                          ?['deg_c'] !=
                      null)
                  Text(
                      '${speciesDetails['growth']['minimum_temperature']['deg_c'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['maximum_temperature']
                          ?['deg_c'] !=
                      null)
                    Text('Maximum Temperature (°C): ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['maximum_temperature']
                          ?['deg_c'] !=
                      null)
                  Text(
                      '${speciesDetails['growth']['maximum_temperature']['deg_c'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['soil_nutriments'] != null)
                    Text('Soil Nutriments: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['soil_nutriments'] != null)
                  Text(
                      '${speciesDetails['growth']['soil_nutriments'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['soil_salinity'] != null)
                    Text('Soil Salinity: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['soil_salinity'] != null)
                 
                  Text(
                      '${speciesDetails['growth']['soil_salinity'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                  if (speciesDetails['growth']['soil_texture'] != null)
                    Text('Soil Texture: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['soil_texture'] != null)
                  Text(
                      '${speciesDetails['growth']['soil_texture'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),

                  if (speciesDetails['growth']['soil_humidity'] != null)
                    Text('Soil Humidity: ',
                        style: TextStyle(
                            fontFamily: 'Anek Bangla',
                            fontWeight: FontWeight.bold)),
                  if (speciesDetails['growth']['soil_humidity'] != null)
                  
                  Text(
                      '${speciesDetails['growth']['soil_humidity'] ?? 'Unknown'}',
                      style: TextStyle(fontFamily: 'Anek Bangla')),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

