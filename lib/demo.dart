import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'controller/state_management/state_manager.dart';

class ProfileService {
  static const String proxyUrl = "https://mode.imadiinnovations.com:3002/get-url"; // Updated URL
  static final GlobalStateController permissionsController = Get.find<GlobalStateController>();
  /// Updates user profile by sending data to the Node.js proxy
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
      // Construct the target API URL
      final Map<String, String> params = {
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

      // Encode parameters as a query string
      String queryString = Uri(queryParameters: params).query;
      String targetUrl = "https://paktalim.com/admin/ws_app/UpdateProfile?$queryString";

      // Send a POST request to the proxy with the target URL in the body
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {
          "Authorization": "Bearer ${permissionsController.token.value}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"url": targetUrl}),
      );

      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        return jsonDecode(response.body); // Parse JSON response
      } else {
        throw Exception("Failed to update profile: ${response.body}");
      }
    } catch (error) {
      print("Error updating profile: $error");
      return {"error": error.toString()};
    }
  }
}