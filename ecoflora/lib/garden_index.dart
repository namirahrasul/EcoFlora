// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'garden_plant.dart';
import 'add_edit_garden_plant_page.dart';



class GardenIndex extends StatefulWidget {
  @override
  _GardenIndexState createState() => _GardenIndexState();
}

class _GardenIndexState extends State<GardenIndex> {
  List<GardenPlant> plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> plantJsonList = prefs.getStringList('plants') ?? [];
    setState(() {
      plants = plantJsonList
          .map((plantJson) => GardenPlant.fromJson(json.decode(plantJson)))
          .toList();
    });
  }

  Future<void> _savePlants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> plantJsonList =
        plants.map((plant) => json.encode(plant.toJson())).toList();
    prefs.setStringList('plants', plantJsonList);
  }

  void _deletePlant(int index) {
    setState(() {
      plants.removeAt(index);
      _savePlants();
    });
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Plant',
            style: TextStyle(
              fontFamily: 'Anek Bangla',
            ),
          ),
          content: Text('Are you sure you want to delete this plant?',
            style: TextStyle(
              fontFamily: 'Anek Bangla',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                style: TextStyle(
                  fontFamily: 'Anek Bangla',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',
                style: TextStyle(
                  fontFamily: 'Anek Bangla',
                ),
              ),
              onPressed: () {
                _deletePlant(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Garden Index',
          style: TextStyle(
            fontFamily: 'Anek Bangla',
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 83, 113, 234),
              Color.fromARGB(255, 43, 230, 192)
            ],
          ),
        ),
        child: plants.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No plants added yet',
                      style: TextStyle(
                        fontFamily: 'Anek Bangla',
                      ),
                    ),
                    SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditGardenPlantPage(
                              onSave: (newPlant) {
                                setState(() {
                                  plants.add(newPlant);
                                  _savePlants();
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.add),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75,
                    ),
                    padding: EdgeInsets.all(8.0),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditGardenPlantPage(
                                plant: plants[index],
                                onSave: (editedPlant) {
                                  setState(() {
                                    plants[index] = editedPlant;
                                    _savePlants();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white.withOpacity(0.7),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      FileImage(File(plants[index].imagePath)),
                                ),
                              ),
                              Spacer(),
                              FractionallySizedBox(
                                widthFactor: 0.8,
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 200, 230, 201)
                                        .withOpacity(0.7),
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(15),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                            66, 88, 87, 87),
                                        blurRadius: 4.0,
                                        spreadRadius: 1.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                       
                                        children: [
                                          Text(
                                            plants[index].name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Anek Bangla',
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                DateFormat('yyyy-MM-dd').format(
                                                    plants[index].dateBought),
                                                    style: TextStyle(
                                                  fontFamily: 'Anek Bangla',
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                iconSize: 20,
                                                onPressed: () {
                                                  _showDeleteConfirmationDialog(
                                                      index);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height:5),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditGardenPlantPage(
                                onSave: (newPlant) {
                                  setState(() {
                                    plants.add(newPlant);
                                    _savePlants();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white
                              .withOpacity(0.7), // Set the background color
                          padding: EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 20.0),
                        ),
                        child: Text(
                          'Add Plant',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Anek Bangla',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
