// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'garden_plant.dart';

class AddEditGardenPlantPage extends StatefulWidget {
  final GardenPlant? plant;
  final Function(GardenPlant) onSave;

  AddEditGardenPlantPage({this.plant, required this.onSave});

  @override
  _AddEditGardenPlantPageState createState() => _AddEditGardenPlantPageState();
}

class _AddEditGardenPlantPageState extends State<AddEditGardenPlantPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late DateTime _dateBought;
  late String _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _name = widget.plant!.name;
      _dateBought = widget.plant!.dateBought;
      _imagePath = widget.plant!.imagePath;
    } else {
      _name = '';
      _dateBought = DateTime.now();
      _imagePath = '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateBought,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateBought) {
      setState(() {
        _dateBought = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSave(
          GardenPlant(name: _name, imagePath: _imagePath, dateBought: _dateBought));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant == null ? 'Add Plant' : 'Edit Plant',style: TextStyle(fontFamily: 'Anek Bangla'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 83, 113, 234),
              Color.fromARGB(255, 43, 230, 192)
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imagePath.isNotEmpty
                      ? FileImage(File(_imagePath))
                      : null,
                  child: _imagePath.isEmpty
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Plant Name',
                  labelStyle: TextStyle(fontFamily:  'Anek Bangla'),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plant name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  'Date Bought: ${DateFormat.yMd().format(_dateBought)}',
                  style: const TextStyle(color: Colors.white,fontFamily:  'Anek Bangla'),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.white),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _save,
                child:
                    Text(widget.plant == null ? 'Add Plant' : 'Save Changes',
                  style:TextStyle(fontFamily:  'Anek Bangla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
