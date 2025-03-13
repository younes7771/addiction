import 'package:flutter/material.dart';
import '../services/craving_service.dart';

class EmergencyScreen extends StatelessWidget {
  final CravingService _cravingService = CravingService();

  EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide d\'urgence'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.red.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Respirez profondément',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Inspirez pendant 4 secondes, retenez pendant 4 secondes, expirez pendant 6 secondes. Répétez 5 fois.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Techniques rapides',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildEmergencyTechnique(
                context,
                'Buvez un grand verre d\'eau',
                'L\'hydratation aide à réduire les envies et à éclaircir l\'esprit.',
                Icons.water_drop,
              ),
              _buildEmergencyTechnique(
                context,
                'Changez d\'environnement',
                'Déplacez-vous dans une autre pièce ou sortez prendre l\'air.',
                Icons.shuffle,
              ),
              _buildEmergencyTechnique(
                context,
                'Appelez un ami de confiance',
                'Parler à quelqu\'un peut vous aider à surmonter ce moment difficile.',
                Icons.phone,
              ),
              const SizedBox(height: 20),
              const Text(
                'Rappel important',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Les cravings ne durent généralement que 15 à 20 minutes. Tenez bon, ça va passer.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Obtenir des recommandations d'urgence
                  final recommendations = await _cravingService.getRecommendations(
                    'urgence',
                    9, // Haute intensité pour les situations d'urgence
                  );
                  
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Stratégies personnalisées'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: recommendations
                            .map((rec) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(child: Text(rec)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Voir plus de stratégies'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Enregistrer ce craving'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/record-craving');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyTechnique(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}