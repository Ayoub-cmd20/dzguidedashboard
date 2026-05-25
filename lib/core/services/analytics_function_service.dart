import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';

/// Service to interact with the Appwrite analytics calculation function
class AnalyticsFunctionService {
  final AppwriteService _appwrite = AppwriteService();
  late final Functions _functions;

  AnalyticsFunctionService() {
    _functions = Functions(_appwrite.client);
  }

  /// Trigger the analytics calculation function manually
  /// Useful for immediate updates or testing
  Future<Map<String, dynamic>> triggerAnalyticsCalculation() async {
    try {
      final execution = await _functions.createExecution(
        functionId: 'calculate-analytics',
      );

      if (execution.status == 'completed') {
        // Parse the response body
        final response = execution.response;
        if (response.isNotEmpty) {
          return {
            'success': true,
            'message': 'Analytics calculation completed successfully',
            'data': response,
          };
        }
      }

      return {
        'success': false,
        'message': 'Analytics calculation failed or is still running',
        'status': execution.status,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to trigger analytics calculation: $e',
      };
    }
  }

  /// Get the status of the last function execution
  Future<Map<String, dynamic>> getLastExecutionStatus() async {
    try {
      final executions = await _functions.listExecutions(
        functionId: 'calculate-analytics',
        queries: [Query.orderDesc('\$createdAt'), Query.limit(1)],
      );

      if (executions.total > 0) {
        final lastExecution = executions.documents.first;
        return {
          'success': true,
          'status': lastExecution.status,
          'createdAt': lastExecution.createdAt,
          'response': lastExecution.response,
          'error': lastExecution.error,
        };
      }

      return {'success': false, 'message': 'No executions found'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get execution status: $e',
      };
    }
  }

  /// Get execution history
  Future<List<Map<String, dynamic>>> getExecutionHistory({
    int limit = 10,
  }) async {
    try {
      final executions = await _functions.listExecutions(
        functionId: 'calculate-analytics',
        queries: [Query.orderDesc('\$createdAt'), Query.limit(limit)],
      );

      return executions.documents
          .map(
            (execution) => {
              'id': execution.$id,
              'status': execution.status,
              'createdAt': execution.createdAt,
              'response': execution.response,
              'error': execution.error,
              'duration': execution.duration,
            },
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get execution history: $e');
    }
  }
}
