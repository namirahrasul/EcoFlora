import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'saved_plant.dart';

final savedPlantsProvider =
    StateNotifierProvider<SavedPlantsNotifier, List<SavedPlant>>((ref) {
  return SavedPlantsNotifier();
});

class SavedPlantsNotifier extends StateNotifier<List<SavedPlant>> {
  SavedPlantsNotifier() : super([]) {
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> plantJsonList = prefs.getStringList('plants') ?? [];
    state = plantJsonList
        .map((plantJson) => SavedPlant.fromJson(json.decode(plantJson)))
        .toList();
  }

  Future<void> _savePlants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> plantJsonList =
        state.map((plant) => json.encode(plant.toJson())).toList();
    prefs.setStringList('plants', plantJsonList);
  }

  void addPlant(SavedPlant plant) {
    state = [...state, plant];
    _savePlants();
  }

  void removePlant(SavedPlant plant) {
    state = state.where((p) => p != plant).toList();
    _savePlants();
  }
}
