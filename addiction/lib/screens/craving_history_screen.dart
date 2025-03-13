import 'package:flutter/material.dart';
import '../models/craving.dart';
import '../services/craving_service.dart';
import 'package:intl/intl.dart';

class CravingHistoryScreen extends StatefulWidget {
  const CravingHistoryScreen({super.key});

  @override
  CravingHistoryScreenState createState() => CravingHistoryScreenState();
}

class CravingHistoryScreenState extends State<CravingHistoryScreen> {
  final CravingService _cravingService = CravingService();
  List<Craving> _cravings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCravings();
  }

  Future<void> _loadCravings() async {
    setState(() => _isLoading = true);
    
    final cravings = await _cravingService.getCravings();
    cravings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() {
      _cravings = cravings;
      _isLoading = false;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des cravings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cravings.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun craving enregistré pour le moment',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _cravings.length,
                  itemBuilder: (context, index) {
                    final craving = _cravings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDateTime(craving.timestamp),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getIntensityColor(craving.intensity),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Intensité: ${craving.intensity}/10',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Déclencheur: ${craving.trigger}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (craving.notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Notes: ${craving.notes}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) {
      return Colors.green;
    } else if (intensity <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}