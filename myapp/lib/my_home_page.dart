import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MyHomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String? res;
  final TextEditingController _textController = TextEditingController();
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(widget.cameras[0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      setState(() {
        res = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sehastrajit')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: res != null
                  ? SingleChildScrollView(
                      child: res!.startsWith('invalid comment')
                          ? Text(res!, style: const TextStyle(fontSize: 18.0, height: 1.5))
                          : Table(
                              border: TableBorder.all(),
                              children: _buildTableRows(res!),
                            ),
                    )
                  : const Center(child: Text('Waiting for input...')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter your prompt...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _generateContent(_textController.text),
              child: const Text('Generate'),
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildTableRows(String content) {
    final rows = content.split('\n');
    final maxCells = rows.map((row) => row.split('-').length).reduce((a, b) => a > b ? a : b);
    return rows.map((row) {
      final cells = row.split('-');
      return TableRow(
        children: List.generate(maxCells, (index) {
          final cellContent = index < cells.length ? cells[index].trim() : '';
          return TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cellContent.replaceAll('*', ''),
                style: TextStyle(
                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      );
    }).toList();
  }

  void _generateContent(String prompt) async {
    prompt = prompt + " say invalid comment if it's not related to schedule else then give it in format of time-taskname-duration-priority and no other words before or after it.";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'Ur API Key Here',
    );
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      setState(() {
        res = response.text;
      });
    } catch (e) {
      setState(() {
        if (e is GenerativeAIException) {
          res = 'Content generation blocked: ${e.message}';
        } else if (e is SocketException) {
          res = 'Network error: Please check your internet connection.';
        } else {
          res = 'Error: ${e.toString()}';
        }
      });
    }
  }
}