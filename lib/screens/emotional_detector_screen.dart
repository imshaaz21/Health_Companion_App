import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:health_companion_app/providers/emotional_detector_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class EmotionalDetectorScreen extends StatefulWidget {
  const EmotionalDetectorScreen({super.key});

  @override
  State<EmotionalDetectorScreen> createState() =>
      _EmotionalDetectorScreenState();
}

class _EmotionalDetectorScreenState extends State<EmotionalDetectorScreen> {
  Future<List<Question>>? _data;
  Map<String, String?> _selectedAnswers =
      {}; // Map to store question ID and selected answer
  bool _isQuizStarted = false; // Flag to track quiz start
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _data = _fetchData();
  }

  Future<List<Question>> _fetchData() async {
    // Replace 'YOUR_API_ENDPOINT' with your actual endpoint
    final response = await http.get(Uri.parse(
        'https://c637-2402-4000-b138-4190-8d10-a07-fd79-3d1.ngrok-free.app/questionnaire'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      debugPrint(jsonData.toString());
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
    return jsonEncode(
        _selectedAnswers); // Convert selected answers map to JSON string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Emotional Detector'),
        ),
        body: _isQuizStarted
            ? FutureBuilder<List<Question>>(
                future: _data,
                builder: (context, snapshot) {
                  if (snapshot.hasData && !_isSubmitted) {
                    final questions = snapshot.data!;
                    return ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return QuestionCard(
                          question: question,
                          onOptionSelected: (option) => _handleOptionSelection(
                              question.id,
                              option), // Pass callback to handle selection
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
              )
            : Stack(
                children: [
                  // Background image
                  // Image.asset(
                  //   "/home/akshilmy/MobileApps/health_companion_app/lib/assets/questionnaire.jpg", // Replace with your image path
                  //   fit: BoxFit.cover, // Adjust fit as needed
                  //   width: double.infinity,
                  //   height: double.infinity,
                  // ),
                  // Text widget with desired styling
                  const Center(
                    child: Text(
                      "Start Quiz ?",
                      style: TextStyle(
                        fontSize: 50.0, // Adjust font size as desired
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Adjust text color as desired
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Align buttons horizontally
            children: [
              _isQuizStarted && !_isSubmitted
                  ? FloatingActionButton(
                      onPressed: () async {
                        final encodedAnswers = _getEncodedAnswers();

                        try {
                          final response = await http.post(
                            Uri.parse(
                                'https://c637-2402-4000-b138-4190-8d10-a07-fd79-3d1.ngrok-free.app/questionnaire'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(encodedAnswers),
                          );

                          if (response.statusCode == 200) {
                            final jsonResponse = jsonDecode(response.body);

                            final result = jsonResponse['result'];

                            debugPrint("Result: $result");
                            // ignore: use_build_context_synchronously
                            Provider.of<EmotionalDetectorProvider>(context,
                                    listen: false)
                                .addTestResult(result.toString());
                          } else {
                            // Handle other status codes if needed
                            debugPrint(
                                "Request failed with status: ${response.statusCode}");
                          }
                          // Handle the response here, if needed
                        } catch (e) {
                          debugPrint("Error: $e");
                          // Handle any errors that occurred during the HTTP request
                        }

                        setState(() {
                          _isQuizStarted = false;
                          _isSubmitted = true;
                        });
                      },
                      child: const Icon(Icons.check))
                  : const Text(""),
              !_isQuizStarted
                  ? FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _isQuizStarted =
                              true; // Set flag to true when Start is pressed
                        });
                      },
                      backgroundColor:
                          _isQuizStarted ? Colors.grey : Colors.blue,
                      child: const Icon(Icons.start),
                    )
                  : const Text(""),
            ]));
  }
}

class Question {
  final String id;
  final String question;
  final String? imageUrl;
  final Map<String, bool> options;

  Question(
      {required this.id,
      required this.question,
      this.imageUrl,
      required this.options});

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        question: json['question'] as String,
        imageUrl: json['image_url'] as String?,
        options:
            (json['options'] as Map<dynamic, dynamic>).cast<String, bool>(),
      );
}

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(String)
      onOptionSelected; // Callback to handle option selection

  const QuestionCard(
      {super.key, required this.question, required this.onOptionSelected});

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
            Text(widget
                .question.question), // Access question using widget.question
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
