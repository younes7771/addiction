import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/craving.dart';
import 'package:uuid/uuid.dart';

class CravingService {
  static const String _storageKey = 'cravings_data';
  final Uuid _uuid = const Uuid();

  Future<List<Craving>> getCravings() async {
    final prefs = await SharedPreferences.getInstance();
    final cravingsJson = prefs.getStringList(_storageKey) ?? [];
    
    return cravingsJson
        .map((json) => Craving.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> addCraving(Craving craving) async {
    final prefs = await SharedPreferences.getInstance();
    final cravingsJson = prefs.getStringList(_storageKey) ?? [];
    
    final newCraving = Craving(
      id: _uuid.v4(),
      timestamp: craving.timestamp,
      intensity: craving.intensity,
      trigger: craving.trigger,
      notes: craving.notes,
    );
    
    cravingsJson.add(jsonEncode(newCraving.toJson()));
    await prefs.setStringList(_storageKey, cravingsJson);
  }

  Future<void> updateCraving(Craving craving) async {
    final prefs = await SharedPreferences.getInstance();
    final cravingsJson = prefs.getStringList(_storageKey) ?? [];
    
    final cravings = cravingsJson
        .map((json) => Craving.fromJson(jsonDecode(json)))
        .toList();
    
    final index = cravings.indexWhere((c) => c.id == craving.id);
    if (index != -1) {
      cravingsJson[index] = jsonEncode(craving.toJson());
      await prefs.setStringList(_storageKey, cravingsJson);
    }
  }

  Future<List<String>> getPredictedCravingTimes() async {
    // Simulation d'une analyse de données pour prédire les moments de craving
    // Dans une application réelle, cela utiliserait un algorithme d'IA plus complexe
    final cravings = await getCravings();
    
    if (cravings.isEmpty) {
      return [];
    }
    
    // Analyse basique des heures de cravings
    Map<int, int> hourFrequency = {};
    for (var craving in cravings) {
      final hour = craving.timestamp.hour;
      hourFrequency[hour] = (hourFrequency[hour] ?? 0) + 1;
    }
    
    // Trier les heures par fréquence
    List<MapEntry<int, int>> sortedHours = hourFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Retourner les 3 heures les plus fréquentes
    return sortedHours.take(3).map((entry) {
      final hour = entry.key;
      return '${hour}h00';
    }).toList();
  }

  Future<List<String>> getRecommendations(String trigger, int intensity) async {
    // Simulation de recommandations basées sur l'IA
    // Dans une app réelle, cela utiliserait un modèle ML plus sophistiqué
    
    List<String> recommendations = [];
    
    if (intensity >= 7) {
      recommendations.add("Appeler un ami de confiance immédiatement");
      recommendations.add("Pratiquer une respiration profonde pendant 2 minutes");
      recommendations.add("Changer d'environnement rapidement");
    } else if (intensity >= 4) {
      recommendations.add("Boire un grand verre d'eau");
      recommendations.add("Faire une activité physique de 10 minutes");
      recommendations.add("Méditer pendant 5 minutes");
    } else {
      recommendations.add("Noter vos sentiments dans un journal");
      recommendations.add("Faire une courte promenade");
      recommendations.add("Pratiquer une activité qui vous occupe l'esprit");
    }
    
    // Ajouter des recommandations spécifiques au déclencheur
    if (trigger.toLowerCase().contains("stress")) {
      recommendations.add("Technique de relaxation musculaire progressive");
    } else if (trigger.toLowerCase().contains("social")) {
      recommendations.add("Préparer à l'avance des réponses de refus");
    } else if (trigger.toLowerCase().contains("ennui")) {
      recommendations.add("Avoir une liste d'activités plaisantes à portée de main");
    }
    
    return recommendations;
  }
}
