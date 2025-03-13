import 'package:flutter/material.dart';
import '../models/craving.dart';
import '../services/craving_service.dart';
import 'package:uuid/uuid.dart';

class RecordCravingScreen extends StatefulWidget {
  const RecordCravingScreen({super.key});

  @override
  _RecordCravingScreenState createState() => _RecordCravingScreenState();
}

class _RecordCravingScreenState extends State<RecordCravingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _triggerController = TextEditingController();
  final _notesController = TextEditingController();
  final CravingService _cravingService = CravingService();
  int _intensity = 5;
  List<String> _recommendations = [];
  bool _showRecommendations = false;

  Future<void> _getRecommendations() async {
    if (_triggerController.text.isNotEmpty) {
      final recommendations = await _cravingService.getRecommendations(
        _triggerController.text,
        _intensity,
      );
      
      setState(() {
        _recommendations = recommendations;
        _showRecommendations = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez indiquer ce qui a déclenché votre envie')),
      );
    }
  }

  Future<void> _saveCraving() async {
    if (_formKey.currentState!.validate()) {
      final craving = Craving(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        intensity: _intensity,
        trigger: _triggerController.text,
        notes: _notesController.text,
      );
      
      await _cravingService.addCraving(craving);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer un craving'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quelle est l\'intensité de votre envie ?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _intensity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_intensity',
                  onChanged: (value) {
                    setState(() {
                      _intensity = value.round();
                    });
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Faible'),
                    Text('Modéré'),
                    Text('Intense'),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _triggerController,
                  decoration: const InputDecoration(
                    labelText: 'Qu\'est-ce qui a déclenché cette envie ?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez indiquer le déclencheur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes supplémentaires',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _getRecommendations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Obtenir des recommandations'),
                ),
                if (_showRecommendations) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Recommandations personnalisées :',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _recommendations.length,
                    (index) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(_recommendations[index]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: _saveCraving,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Enregistrer ce craving'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
