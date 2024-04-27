import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmotionalDetectorScreen extends StatefulWidget {
  const EmotionalDetectorScreen({super.key});

  @override
  State<EmotionalDetectorScreen> createState() => _EmotionalDetectorScreenState();
}

class _EmotionalDetectorScreenState extends State<EmotionalDetectorScreen> {
  Future<List<Question>>? _data;
  Map<String, String?> _selectedAnswers = {}; // Map to store question ID and selected answer

  @override
  void initState() {
    super.initState();
    _data = _fetchData();
  }

  Future<List<Question>> _fetchData() async {
    // Replace 'YOUR_API_ENDPOINT' with your actual endpoint
    final response = await http.get(Uri.parse('http://<localhost-ip>:5000/questionnaire'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      // for (var item in jsonData) {
      //   if (item['id'] is String) { // Check if "id" exists and is a String
      //     _selectedAnswers[item['id']] = null; // Add entry with id and null value
      //   }
      // }
      print(_selectedAnswers);
      return jsonData.map((data) => Question.fromJson(data)).toList();
      
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  void _handleOptionSelection(String question, String option) {
    setState(() {
      _selectedAnswers[question] = option;
    });
  }


  String _getEncodedAnswers() {
    return jsonEncode(_selectedAnswers); // Convert selected answers map to JSON string
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotional Detector'),
      ),
      body: FutureBuilder<List<Question>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final questions = snapshot.data!;
            return ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return QuestionCard(
                  question: question,
                  onOptionSelected: (option) => _handleOptionSelection(question.id, option), // Pass callback to handle selection
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Display a loading indicator while fetching data
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final encodedAnswers = _getEncodedAnswers();
          // Use encodedAnswers (JSON string) for further processing or storage
          print(encodedAnswers); // Example usage
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class Question {
  final String id;
  final String question;
  final String? imageUrl;
  final Map<String, bool> options;

  Question({required this.id, required this.question, this.imageUrl, required this.options});

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        question: json['question'] as String,
        imageUrl: json['image_url'] as String?,
        options: (json['options'] as Map<dynamic, dynamic>).cast<String, bool>(),
      );
}

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(String) onOptionSelected; // Callback to handle option selection

  const QuestionCard({required this.question, required this.onOptionSelected});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedOption; // Use String to store selected option

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.question), // Access question using widget.question
            if (widget.question.imageUrl != null)
              Image.network(widget.question.imageUrl!),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: widget.question.options.entries.map((entry) {
                final option = entry.key;
                return ChoiceChip(
                  label: Text(option),
                  selected: option == _selectedOption,
                  onSelected: (value) {
                    setState(() {
                      _selectedOption = option;
                      widget.onOptionSelected(option);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}