import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../model/family_model.dart';
import '../model/member_model.dart';
import '../model/request_form_model.dart';

class Api {
  static const String baseUrl = "http://192.168.18.7:3002"; // Replace with your server URL

  static Future<int> addRequestForm(RequestFormModel requestData) async {
    final url = Uri.parse('$baseUrl/add-request');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print("Data inserted successfully: ${response.body}");
        return 200;
      } else {
        print("Failed to insert data: ${response.statusCode}");
        print("Error: ${response.body}");
        return 500;
      }
    } catch (e) {
      print("Error occurred: $e");
      return 500;
    }
  }

  // API call function
  static Future<UserProfile?> fetchUserProfile(String itsId) async {
    final String baseUrl1 =
        '$baseUrl/get-profile'; // Replace with your server URL
    final Uri url = Uri.parse('$baseUrl1/$itsId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return UserProfile.fromJson(jsonResponse);
      } else {
        print("Failed to load profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

  // Function to fetch family profile
  static Future<Family?> fetchFamilyProfile(String itsId) async {
    final String baseUrl1 =
        '$baseUrl/get-family-profile'; // Replace with your Node.js server URL
    final Uri url = Uri.parse('$baseUrl1/$itsId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        return Family.fromJson(jsonResponse);
      } else {
        print("Failed to load family profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

  static Future<int> fetchNextReqMasId() async {
    const apiUrl = "$baseUrl/get-last-req"; // Replace with your server URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['nextReqFormId'];
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch data. Status code: $e");
    }
  }

  static String fetchImage(String imageUrl) {
    return '$baseUrl/fetch-image?url=${Uri.encodeComponent(imageUrl)}';
  }

  static Future<Uint8List> fetchAndLoadPDF(String its) async {
    try {
      // Fetch the PDF from the backend
      final response =
          //await http.get(Uri.parse('$baseUrl/fetch-pdf$its'));
          await http.get(Uri.parse('$baseUrl/fetch-pdf1'));

      if (response.statusCode == 200) {
        final pdfData = response.bodyBytes;
        return pdfData;
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
