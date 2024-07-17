import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'native_plant_finder.dart';
import 'saved_plant.dart';
import 'saved_plants_provider.dart';
import 'package:go_router/go_router.dart';

class SavedPlantsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPlants = ref.watch(savedPlantsProvider);

    // Use a Set to filter out duplicates
    final uniquePlants = savedPlants.toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Plants List',
          style: TextStyle(
            fontFamily: 'Anek Bangla',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NativePlantsFinder()),
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
        padding: EdgeInsets.all(10.0), // Add padding around the container
        child: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.75, // Adjust to fit the card's content
          ),
          itemCount: uniquePlants.length,
          itemBuilder: (context, index) {
            SavedPlant plant = uniquePlants[index];
            return Card(
              elevation: 3,
              color: Colors.white.withOpacity(0.7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                      child: plant.imageUrl.isNotEmpty
                          ? Image.network(
                              plant.imageUrl,
                              fit: BoxFit.cover,
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.commonName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Anek Bangla',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          plant.scientificName,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            fontFamily: 'Anek Bangla',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Area: ${plant.areas.join(', ')}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12.0,
                            fontFamily:
                                'Anek Bangla', // Set the font size to be smaller
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: Colors.purple.withOpacity(0.5)),
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, ref, plant),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, SavedPlant plant) {
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
                ref.read(savedPlantsProvider.notifier).removePlant(plant);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
