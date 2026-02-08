import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/errors/exceptions.dart';

/// Gemini data source interface
abstract class GeminiDataSource {
  /// Analyze document and return health brief
  Future<Map<String, dynamic>> analyzeDocument({
    required File document,
    required bool isPdf,
  });
}

/// Gemini data source implementation
class GeminiDataSourceImpl implements GeminiDataSource {
  final GenerativeModel generativeModel;

  GeminiDataSourceImpl({required this.generativeModel});

  static const String _prompt = '''
You are a medical document assistant helping patients understand their health reports.
Analyze this medical document and return ONLY a valid JSON response (no markdown, no code blocks).

Return this exact JSON structure:
{
  "title": "Report title (e.g., Complete Blood Count (CBC))",
  "labSource": "Lab name if visible, or null",
  "reportDate": "Date in YYYY-MM-DD format, or null if not found",
  "summary": "2-3 sentence plain-language summary of the overall results",
  "findings": [
    {
      "name": "Test name (e.g., Hemoglobin)",
      "value": numeric_value_only,
      "unit": "unit string (e.g., g/dL)",
      "status": "low|normal|borderline|high",
      "minRange": minimum_normal_value,
      "maxRange": maximum_normal_value,
      "clinicalSignificance": "What this test measures and why it matters in simple terms",
      "doctorQuestions": ["Specific question 1 about this finding", "Specific question 2"]
    }
  ],
  "appointmentQuestions": [
    "Overall question 1 based on all findings",
    "Overall question 2 based on patterns",
    "Overall question 3 about next steps"
  ]
}

IMPORTANT RULES:
- Return ONLY valid JSON, no other text
- Do NOT diagnose or suggest treatments
- Only explain what values mean in simple, patient-friendly language
- Generate helpful questions the patient can ask their doctor
- Be empathetic and reassuring while being factually accurate
- If a value is borderline (near the edge of normal range), mark it as "borderline"
- Include at least 3-5 key findings if available
- Include 3-5 appointment questions based on all findings
''';

  @override
  Future<Map<String, dynamic>> analyzeDocument({
    required File document,
    required bool isPdf,
  }) async {
    try {
      final bytes = await document.readAsBytes();
      final mimeType = isPdf ? 'application/pdf' : 'image/jpeg';

      final content = [
        Content.multi([
          TextPart(_prompt),
          DataPart(mimeType, bytes),
        ])
      ];

      final response = await generativeModel.generateContent(content);
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw const GeminiException(
          message: 'Empty response from Gemini',
          code: 'empty-response',
        );
      }

      // Clean up the response - remove markdown code blocks if present
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      try {
        final json = jsonDecode(cleanedText) as Map<String, dynamic>;
        return json;
      } catch (e) {
        throw GeminiException(
          message: 'Failed to parse Gemini response: $e',
          code: 'parse-error',
        );
      }
    } on GenerativeAIException catch (e) {
      throw GeminiException(
        message: e.message,
        code: 'api-error',
      );
    } on SocketException catch (_) {
      throw const GeminiException(
        message: 'Unable to connect. Please check your internet connection and try again.',
        code: 'network',
      );
    } on TimeoutException catch (_) {
      throw const GeminiException(
        message: 'The request took too long. Please check your connection and try again.',
        code: 'timeout',
      );
    } on HandshakeException catch (_) {
      throw const GeminiException(
        message: 'Unable to connect securely. Please check your internet connection and try again.',
        code: 'network',
      );
    } on OSError catch (e) {
      // Covers "Failed host lookup", "nodename nor servname provided", etc.
      if (e.message.contains('lookup') ||
          e.message.contains('nodename') ||
          e.message.contains('servname') ||
          e.message.contains('Network is unreachable')) {
        throw const GeminiException(
          message: 'No internet connection. Please check your network and try again.',
          code: 'network',
        );
      }
      rethrow;
    } catch (e) {
      if (e is GeminiException) rethrow;
      final msg = e.toString();
      if (msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('ClientException') ||
          msg.contains('nodename nor servname')) {
        throw const GeminiException(
          message: 'No internet connection. Please check your network and try again.',
          code: 'network',
        );
      }
      throw GeminiException(
        message: 'Something went wrong while analyzing the document. Please try again.',
        code: 'unknown',
      );
    }
  }
}
