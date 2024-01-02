import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class GeminiUtil {
  static Future<String> _loadCredentials() async {
    return await rootBundle.loadString('hearbat-408909-40d76f6c489d.json');
  }

  static Future<String> generateContent(String word) async {
    http.Client client = http.Client();
    try {
      String jsonString = await _loadCredentials();
      var jsonCredentials = jsonDecode(jsonString);
      String projectId = jsonCredentials['project_id'];
      print(projectId);

      final accountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
      AccessCredentials credentials = await obtainAccessCredentialsViaServiceAccount(
          accountCredentials, 
          ['https://www.googleapis.com/auth/cloud-platform'],
          client);

      String url = 
      "https://us-west1-aiplatform.googleapis.com/v1/projects/$projectId/locations/us-west1/publishers/google/models/gemini-pro:streamGenerateContent";

      var body = json.encode({
        "contents": [
          {
            "role": "USER",
            "parts": [
              {
                "text": "what are words that sound similar to $word"
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.6,
          "candidateCount": 1,
          "maxOutputTokens": 50,

        }
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${credentials.accessToken.data}"
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData[0]['candidates'][0]['content']['parts'][0]['text'];

      } else {
        throw Exception("Failed to get a valid response from the API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in GeminiUtil.generateContent: $e");
      throw Exception("Error occurred in GeminiUtil.generateContent: $e");
    } finally {
      client.close();
    }
  }


}