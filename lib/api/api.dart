import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mobile_ui/forms/documents_upload.dart';
import '../model/document.dart';
import '../model/funding_record_model.dart';
import '../model/family_data2.dart';
import '../model/family_model.dart';
import '../model/member_model.dart';
import '../model/permission_model.dart';
import '../model/request_form_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';

import '../model/submit_application_form.dart';

class Api {
  static const String baseUrl =
      //"http://36.50.12.171:3002";
      // "http://172.16.109.94:3002";
      //  "https://mode.imadiinnovations.com:3002";
      "https://dev.imadiinnovations.com:3003";
  // "http://localhost:3003";

  static final GlobalStateController permissionsController =
      Get.find<GlobalStateController>();

  static Future<List<dynamic>> loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    return json.decode(response);
  }

  static Future<String> fetchVersion() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api-version'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['version'] ?? "Unknown Version";
      } else {
        throw Exception("Failed to fetch version");
      }
    } catch (e) {
      print("Error fetching version: $e");
      return "Unknown Version";
    }
  }

  static Future<List<FundingRecords>> fetchRecords(String its) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/fetch-records"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"its": its}),
      );

      if (response.statusCode == 200) {
        return FundingRecords.fromJsonList(response.body);
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to fetch records");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
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
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['family_members'] != null) {
          List<FamilyMember> familyList =
              (jsonResponse['family_members'] as List)
                  .map((member) => FamilyMember.fromJson(member))
                  .toList();

          FamilyMember? matchingMember = familyList.firstWhereOrNull(
              (member) => member.itsNumber.toString() == itsId);

          permissionsController.appliedByITS.value = itsId;
          permissionsController.appliedByName.value = matchingMember!.fullName;

          return familyList;
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
            'Authorization': 'Bearer ${permissionsController.token.value}',
            'Content-Type': 'application/json',
          },
          body: json.encode({'url': targetUrl}));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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
          'Authorization': 'Bearer ${permissionsController.token.value}',
          // Add authentication if needed
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // ✅ Check for errors in the response
        if (jsonResponse['error'] == null) {
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
          'Authorization': 'Bearer ${permissionsController.token.value}',
          // ✅ Include Authorization header
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
      String mohalla, String org, String its, String role) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users-by-mohalla"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"mohalla": mohalla, "org": org, "userRole": role, "ITS": its}),
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

  //get goods
  static Future<List<Map<String, dynamic>>> fetchGoods() async {
    final response = await http.get(Uri.parse("$baseUrl/fetch-goods"));
    if (response.statusCode == 200) {
      print(List<Map<String, dynamic>>.from(json.decode(response.body)));
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to load goods");
    }
  }

  static Future<void> uploadDocument(
      String docType, String ITS, String reqId) async {
    final String studentId = ITS;
    final String reqid = reqId;
    final uri = Uri.parse('http://172.16.109.94:3002/upload');
    var request = http.MultipartRequest('POST', uri)
      ..fields['studentId'] = studentId;

    // Get the specific document (File object) for the given docType
    final document = permissionsController.documents[docType];
    if (document?.file != null) {
      try {
        // Read the file bytes
        var fileBytes = await document!.file!.readAsBytes();
        var fileName = '${studentId}_$docType';
        var mimeType =
            lookupMimeType(document.file!.path) ?? 'application/octet-stream';

        // Add the file to the request using the correct field name
        request.files.add(http.MultipartFile.fromBytes(
          docType, // Use the document type as the field name dynamically
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ));

        try {
          // Send the request
          var response = await request.send();

          if (response.statusCode == 200) {
            final responseData = await http.Response.fromStream(response);

            // Decode the JSON response
            Map<String, dynamic> responseJson = json.decode(responseData.body);

            // Access the full file path returned by the backend
            String uploadedFilePath = responseJson['file']['filePath'];

            // Store the file path in the documents map for the current docType
            permissionsController.documents[docType] = Document(
              file: permissionsController.documents[docType]?.file,
              // Keep the file object as is
              filePath:
                  uploadedFilePath, // Store the file path returned by the backend
            );

            print("File uploaded successfully for $docType!");
          } else {
            print("Failed to upload file: ${response.statusCode}");
          }
        } catch (e) {
          print("Error during upload: $e");
        }
      } catch (e) {
        print("Error reading file for $docType: $e");
      }
    } else {
      print("No file selected for $docType");
    }
  }

  static Future<void> removeDocument(String docType) async {
    final document = permissionsController.documents[docType];
    if (document == null || document.filePath == null) {
      return; // No file to remove
    }

    final studentId = '30445124';

    // Build the URI with query parameters for file deletion
    final uri =
        Uri.parse('http://172.16.109.94:3002/delete').replace(queryParameters: {
      'studentId': studentId,
      'docType': docType,
      'filePath': document.filePath!, // Send the full file path for deletion
    });

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      permissionsController.documents[docType] =
          null; // Remove the file object locally
      // Optionally, show a success message or handle deletion
      print("File removed successfully for $docType.");
    } else {
      print("Error removing file: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String accessKey,
    required String username,
    required String mId,
    String? pId, // Optional
    required String jId,
    required String itsId,
    required String cId,
    required String cityId,
    required String imani,
    required String iId,
    required String scholarshipTaken,
    required String qardan,
    required String scholar,
    required String classId,
    required String sId,
    String? yearCountDir, // Optional
    required String edate,
    required String duration,
    required String sdate,
  }) async {
    try {
      // Construct request body as JSON
      final Map<String, dynamic> requestBody = {
        "access_key": accessKey,
        "username": username,
        "m_id": mId,
        if (pId != null) "p_id": pId,
        "j_id": jId,
        "its_id": itsId,
        "c_id": cId,
        "city_id": cityId,
        "imani": imani,
        "i_id": iId,
        "scholarship_taken": scholarshipTaken,
        "qardan": qardan,
        "scholar": scholar,
        "class_id": classId,
        "s_id": sId,
        if (yearCountDir != null) "year_count_dir": yearCountDir,
        "edate": edate,
        "duration": duration,
        "sdate": sdate,
      };

      // Send a POST request to the Node.js server
      final response = await http.post(
        Uri.parse('$baseUrl/update-paktalim-profile'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to update profile: ${response.body}");
      }
    } catch (error) {
      print("Error updating profile: $error");
      return {"error": error.toString()};
    }
  }

  static Future<dynamic> postProxiedData({
    required int pId,
    required int mId,
    required int jId,
    required int itsId,
    required int cId,
    required int cityId,
    required String imani,
    required int iId,
    required List<String> subId,
    required int scholarshipTaken,
    required String qardan,
    required String scholar,
    required String className,
    required String sId,
    required String edate,
    required String duration,
    required String sdate,
  }) async {
    //final encodedUrl = Uri.encodeComponent(targetUrl); // Proper encoding
    final Uri uri = Uri.parse('$baseUrl/post-url-v2');

    try {
      final response = await http.post(uri,
          headers: {
            'Authorization': 'Bearer ${permissionsController.token.value}',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'url':
                'https://paktalim.com/admin/ws_app/UpdateProfile?access_key=bbb1d493d3c4969f55045326d6e2f4a662b85374&username=40459629',
            'data': {
              "its_id": itsId,
              "p_id": pId,
              "m_id": mId,
              "j_id": jId,
              "c_id": cId,
              "city_id": cityId,
              "imani": imani,
              "i_id": iId,
              "sub_id": subId,
              "scholarship_taken": scholarshipTaken,
              "class_id": className,
              "s_id": sId,
              "edate": edate,
              "sdate": sdate,
              "duration": duration
            }
          }));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> submitForm(SubmissionFormModel model) async {
    final url = '$baseUrl/submit-draft-form';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(model.toJson()),
      );

      if (response.statusCode == 200) {
        // Successful submission.
        print('Form submitted successfully!');
        final responseData = jsonDecode(response.body);
        print('Inserted ID: ${responseData['id']}');
      } else {
        print('Error submitting form: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchApplicationData(String its, String reqId) async {
    final String url = '$baseUrl/get-draft-application?its=$its&reqId=$reqId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Application Data: $data");
      } else {
        print("Error: ${jsonDecode(response.body)['error']}");
      }
    } catch (e) {
      print("Network Error: $e");
    }
  }

  static Future<void> updateGuardian({
    required String its, // Guardian ITS
    required String name,
    required String contact,
    required String relation,
    required String studentIts, // Optional student ITS
  }) async {
    final String apiUrl = "$baseUrl/add-guardian";

    final Map<String, dynamic> requestBody = {
      "name": name,
      "ITS": its,
      "contact": contact,
      "relation": relation,
      "student_ITS": studentIts,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("Guardian updated successfully: ${response.body}");
      } else {
        print("Failed to update guardian: ${response.body}");
      }
    } catch (error) {
      print("Error updating guardian: $error");
    }
  }
}
