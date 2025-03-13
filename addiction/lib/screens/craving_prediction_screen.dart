import 'package:flutter/material.dart';
import '../models/craving.dart';
import '../services/craving_service.dart';
import '../services/advanced_craving_analysis.dart';
import 'package:intl/intl.dart';

class CravingPredictionScreen extends StatefulWidget {
  @override
  _CravingPredictionScreenState createState() => _CravingPredictionScreenState();
}

class _CravingPredictionScreenState extends State<CravingPredictionScreen> {
  final CravingService _cravingService = CravingService();
  final AdvancedCravingAnalysis _analysis = AdvancedCravingAnalysis();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _circadianPredictions = [];
  List<Map<String, dynamic>> _triggerAnalysis = [];
  double _currentVulnerability = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }
  
  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);
    
    final cravings = await _cravingService.getCravings();
    
    if (cravings.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    
    final circadianPredictions = await _analysis.predictCircadianCravings(cravings);
    final triggerAnalysis = await _analysis.analyzeContextualTriggers(cravings);
    final vulnerability = await _analysis.calculateCurrentVulnerabilityScore(
      cravings, 
      DateTime.now()
    );
    
    setState(() {
      _circadianPredictions = circadianPredictions.take(5).toList();
      _triggerAnalysis = triggerAnalysis.take(5).toList();
      _currentVulnerability = vulnerability;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Predictions'),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPredictions,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVulnerabilityCard(),
                      SizedBox(height: 20),
                      _circadianPredictions.isEmpty
                          ? _buildNoDataCard('hourly predictions')
                          : _buildCircadianPredictionsCard(),
                      SizedBox(height: 20),
                      _triggerAnalysis.isEmpty
                          ? _buildNoDataCard('trigger analysis')
                          : _buildTriggerAnalysisCard(),
                      SizedBox(height: 20),
                      _buildRecommendationsCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildVulnerabilityCard() {
    final vulnerabilityPercentage = (_currentVulnerability * 100).round();
    
    Color cardColor;
    String riskLevel;
    
    if (_currentVulnerability < 0.3) {
      cardColor = Colors.green.shade50;
      riskLevel = "Low";
    } else if (_currentVulnerability < 0.6) {
      cardColor = Colors.orange.shade50;
      riskLevel = "Moderate";
    } else {
      cardColor = Colors.red.shade50;
      riskLevel = "High";
    }
    
    return Card(
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Vulnerability Index',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _currentVulnerability,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      _currentVulnerability < 0.3 ? Colors.green : 
                      _currentVulnerability < 0.6 ? Colors.orange : Colors.red
                    ),
                    minHeight: 10,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  '$vulnerabilityPercentage%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _currentVulnerability < 0.3 ? Colors.green : 
                           _currentVulnerability < 0.6 ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Risk Level: $riskLevel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getVulnerabilityMessage(_currentVulnerability),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCircadianPredictionsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hourly Craving Predictions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(
              _circadianPredictions.length,
              (index) {
                final prediction = _circadianPredictions[index];
                final hour = prediction['hour'];
                final intensity = prediction['predictedIntensity'].toStringAsFixed(1);
                final risk = prediction['risk'];
                
                Color riskColor;
                if (risk == "low") {
                  riskColor = Colors.green;
                } else if (risk == "moderate") {
                  riskColor = Colors.orange;
                } else {
                  riskColor = Colors.red;
                }
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}h00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: prediction['predictedIntensity'] / 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(riskColor),
                          minHeight: 8,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Intensity: $intensity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTriggerAnalysisCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trigger Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(
              _triggerAnalysis.length,
              (index) {
                final trigger = _triggerAnalysis[index];
                final triggerName = trigger['trigger'];
                final frequency = trigger['frequency'];
                final impact = trigger['impact'].toDouble();
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              triggerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'Impact: ${impact.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: impact > 7 ? Colors.red : 
                                    impact > 4 ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: impact / 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          impact > 7 ? Colors.red : 
                          impact > 4 ? Colors.orange : Colors.green,
                        ),
                        minHeight: 6,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Frequency: $frequency times',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard(String dataType) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Not enough data for $dataType',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Continue recording your cravings to get personalized insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildRecommendationItem(
              icon: Icons.timer,
              title: 'Plan ahead for high-risk times',
              description: 'Prepare coping strategies for your predicted high-risk periods.',
            ),
            SizedBox(height: 12),
            _buildRecommendationItem(
              icon: Icons.psychology,
              title: 'Recognize your triggers',
              description: 'Notice patterns in what situations trigger your cravings.',
            ),
            SizedBox(height: 12),
            _buildRecommendationItem(
              icon: Icons.equalizer,
              title: 'Track your progress',
              description: 'Continue recording cravings to improve prediction accuracy.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.blue.shade700,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getVulnerabilityMessage(double vulnerability) {
    if (vulnerability < 0.3) {
      return 'Your risk of experiencing cravings is currently low. This is a good time to reinforce healthy habits.';
    } else if (vulnerability < 0.6) {
      return 'Your risk level is moderate. Be mindful of potential triggers and have coping strategies ready.';
    } else {
      return 'Your risk is currently high. Consider using distraction techniques and reaching out for support.';
    }
  }
}