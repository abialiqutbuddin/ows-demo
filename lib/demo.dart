import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiScreen extends StatefulWidget {
  @override
  _ApiScreenState createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  final TextEditingController _endpointController = TextEditingController();
  String _method = 'GET'; // Default to GET
  String _responseData = "";
  bool _isLoading = false;

  Future<void> _fetchData() async {
    if (_endpointController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an API endpoint')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _responseData = "";
    });

    String baseUrl = "http://localhost:3002"; // Replace with actual base URL
    String fullUrl = "$baseUrl/${_endpointController.text}";

    try {
      http.Response response;

      if (_method == 'GET') {
        response = await http.get(Uri.parse(fullUrl));
      } else {
        response = await http.post(Uri.parse(fullUrl), body: jsonEncode({"sample": "data"}), headers: {"Content-Type": "application/json"});
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _responseData = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
        });
      } else {
        setState(() {
          _responseData = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _responseData = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text('API Tester')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _endpointController,
                decoration: InputDecoration(labelText: 'Enter API Endpoint (e.g., posts/1)'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Method: "),
                  DropdownButton<String>(
                    value: _method,
                    onChanged: (String? newValue) {
                      setState(() {
                        _method = newValue!;
                      });
                    },
                    items: <String>['GET', 'POST'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _fetchData,
                    child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Fetch Data'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _responseData.isEmpty ? "Response will appear here" : _responseData,
                    style: TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}