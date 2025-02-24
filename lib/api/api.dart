import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/family_data2.dart';
import '../model/family_model.dart';
import '../model/member_model.dart';
import '../model/permission_model.dart';
import '../model/request_form_model.dart';
import 'package:get_storage/get_storage.dart';

class Api {
  static const String baseUrl =
      //"http://36.50.12.171:3002";
        // "http://localhost:3002";
     "https://mode.imadiinnovations.com:3002";

  static final GlobalStateController permissionsController = Get.find<GlobalStateController>();

  static Future<List<dynamic>> loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    return json.decode(response);
  }

  static Future<List<FamilyMember>?> fetchFamilyData2(String itsId) async {
    final url = Uri.parse("$baseUrl/get-family-profile");
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${permissionsController.token.value}'
    };

    final body = jsonEncode({"its_id": itsId});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['family_members'] != null) {
          return (jsonResponse['family_members'] as List)
              .map((member) => FamilyMember.fromJson(member))
              .toList();
        } else {
          print("⚠️ No family members found.");
          return [];
        }
      } else {
        print("❌ Failed to fetch family data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🚨 Error fetching family data: $e");
      return null;
    }
  }

  static Future<dynamic> fetchProxiedData(String targetUrl) async {
    final encodedUrl = Uri.encodeComponent(targetUrl); // Proper encoding
    final Uri uri = Uri.parse('$baseUrl/get-url');

    try {
      final response = await http.post(uri,
          headers: {
            'Authorization':
                'Bearer ${permissionsController.token.value}', // Add authentication if needed
            'Content-Type': 'application/json',
          },
          body: json.encode({'url': encodedUrl}));

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
        //return Family.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<int> addRequestForm(RequestFormModel requestData) async {
    final url = Uri.parse('$baseUrl/submit-request-form');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization':
              'Bearer ${permissionsController.token.value}', // Add authentication if needed
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        return 201;
      } else {
        return 500;
      }
    } catch (e) {
      print("Error occurred: $e");
      return 500;
    }
  }

  static Future<UserProfile?> fetchUserProfile(String itsId) async {
    final String url = '$baseUrl/get-profile';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${permissionsController.token.value}',
        },
        body: json.encode({
          'its_id': itsId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // ✅ Check for valid user profile data
        if (jsonResponse['error'] == null) {
          print(jsonResponse);
          return UserProfile.fromJson(jsonResponse);
        } else {
          print("Error: ${jsonResponse['error']}");
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error occurred while fetching profile: $e");
      return null;
    }
  }

  static Future<Family?> fetchFamilyProfileOld(String itsId) async {
    //final String url = '$baseUrl/get-family-profile/$itsId';
    final String url = '$baseUrl/get-family-profile-old';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${permissionsController.token.value}',
        },
        body: json.encode({'itsId': itsId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Family.fromJson(jsonResponse);
        } else {
          return null;
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized: Check your authentication token.");
        return null;
      } else {
        print("Failed to load family profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error occurred while fetching family profile: $e");
      return null;
    }
  }

  // Function to fetch family profile
  static Future<Family?> fetchFamilyProfile(String itsId) async {
    final String url = '$baseUrl/get-family-profile';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${permissionsController.token.value}",
        },
        body: json.encode({
          'its_id': itsId,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // ✅ Check for errors in the response
        if (jsonResponse['error'] == null) {
          print(jsonResponse);
          return Family.fromJson(jsonResponse);
        } else {
          print("Error: ${jsonResponse['error']}");
          return null;
        }
      } else {
        print("Failed to load family profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> runQuery() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run-query'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": "SELECT * FROM owsReqForm"}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          print(List<Map<String, dynamic>>.from(data['data']));
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception("Failed to fetch data: ${data['message']}");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<int> fetchNextReqMasId() async {
    const apiUrl = "$baseUrl/get-last-req"; // Replace with your server URL

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${permissionsController.token.value}",
        },
      );

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
    final String url = '$baseUrl/fetch-pdf';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${permissionsController.token.value}', // ✅ Include Authorization header
        },
        body: json.encode({
          'its': its, // ✅ Pass ITS ID in the request body
        }),
      );

      if (response.statusCode == 200) {
        final pdfData = response.bodyBytes;
        return pdfData;
      } else {
        print("Failed to load PDF: ${response.statusCode}");
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      print("Error occurred while fetching the PDF: $e");
      throw Exception(e);
    }
  }

  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    final Uri url = Uri.parse("$baseUrl/send-email");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "to": to,
          "subject": subject,
          "text": text,
          "html": html,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Email sent successfully!");
        return true;
      } else {
        print("❌ Failed to send email: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error sending email: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchRequests({String? id}) async {
    final Uri url =
        Uri.parse("$baseUrl/get-requests${id != null ? "?id=$id" : ""}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("❌ Failed to fetch data: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching requests: $e");
      return [];
    }
  }

  // Login API Call
  static Future<Map<String, dynamic>> getToken(String itsId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"its_id": itsId, "password": itsId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      await GetStorage().write("token", data["token"]); // Store token
      permissionsController.token.value = GetStorage().read("token");
      List<dynamic> permissionsData = data['user']['permissions'];
      List<Permission> permissions = permissionsData.map((perm) {
        return Permission.fromJson(perm as Map<String, dynamic>);
      }).toList();

      permissionsController.setPermissions(permissions);

      //print(data);
      return data;
    } else {
      throw Exception("Login Failed");
    }
  }

  // ✅ Fetch User Permissions API
  static Future<void> getUserPermissions(String itsId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/permissions"),
      headers: {
        "Authorization": "Bearer ${permissionsController.token.value}",
        "its": itsId,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);

      // Convert to Permission model list
      List<Permission> permissions = responseData.map((data) {
        return Permission.fromJson(data as Map<String, dynamic>);
      }).toList();

      // Set permissions in the GetX controller
      permissionsController.setPermissions(permissions);
    } else {
      throw Exception("Failed to fetch permissions");
    }
  }

  // ✅ Fetch Requests by Mohalla
  static Future<List<RequestFormModel>> fetchRequestsByMohalla(
      String mohalla,String org) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users-by-mohalla"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mohalla": mohalla,"org":org}),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((json) => RequestFormModel.fromJson(json)).toList();
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  // ✅ Update Request Status
  static Future<bool> updateRequestStatus(int reqId, String newStatus) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update-request-status"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${permissionsController.token.value}",
      },
      body: jsonEncode({"reqId": reqId, "newStatus": newStatus}),
    );
    return response.statusCode == 200;
  }

  // Function to log out (delete token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }
}
