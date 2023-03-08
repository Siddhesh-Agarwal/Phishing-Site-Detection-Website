import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phishing Site Detector',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create a input bar to input a URL
  String _url = '';
  void setUrl(String url) {
    setState(() {
      _url = url;
    });
  }

  // Function to send URL to https://localhost:8080/api/predict to get the result
  void _sendUrl() async {
    // Create a new HttpClient
    HttpClient httpClient = new HttpClient();

    // Open a connection to the server
    HttpClientRequest request = await httpClient
        .postUrl(Uri.parse('https://localhost:8080/api/predict'));

    // Set the content-type header
    request.headers.set('content-type', 'application/json');

    // Add the JSON-encoded data to the request body
    request.add(utf8.encode(json.encode({'url': _url})));

    // Send the request
    HttpClientResponse response = await request.close();

    // Decode the response
    String reply = await response.transform(utf8.decoder).join();

    // Print the response
    if (kDebugMode) {
      print(reply);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            // Project Name
            const Text(
              'Phishing Detector',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 16),
            // Input bar with a width of 720 for large screen and 500 for small screen
            SizedBox(
              width: MediaQuery.of(context).size.width > 720 ? 720 : 500,
              child: TextField(
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  ),
                  hintText: 'Enter a URL',
                ),
                keyboardType: TextInputType.url,
                onChanged: setUrl,
              ),
            ),

            const SizedBox(height: 16),

            // Send button - green button with white text
            ElevatedButton(
              onPressed: _sendUrl,
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green.shade600),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                // Add a margin top to the button
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.fromLTRB(24, 16, 24, 16),
                ),
              ),
              child: const Text('Check'),
            ),
          ],
        )
      )
    );
  }
}
