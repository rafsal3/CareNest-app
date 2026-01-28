import '../../models/patient_task.dart';
import '../../network/api_client.dart';
import '../interfaces/task_service_interface.dart';

class TaskService implements TaskServiceInterface {
  final ApiClient _apiClient;

  TaskService({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<PatientTask>> fetchTasks(int patientId) async {
    // Endpoint likely /tasks or /tasks?patientId=... or /tasks/patient/:id
    // Based on analysis: /tasks (filtered by user context automatically?)
    // Or explicit param.
    // Let's assume /tasks with query param for now, or /tasks/user/:id if admin.
    // If we are logged in as patient, /tasks usually returns *my* tasks.
    // But interface asks for patientId.

    final response = await _apiClient.get(
      '/tasks',
      queryParameters: {'patientId': patientId},
    );

    if (response is Map<String, dynamic> && response['success'] == true) {
      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => PatientTask.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch tasks');
  }

  @override
  Future<void> updateTaskStatus(int taskId, TaskStatus status) async {
    await _apiClient.patch(
      '/tasks/$taskId',
      data: {'status': status.toString().split('.').last.toUpperCase()},
    );
    // Or specific endpoint /tasks/$taskId/status
  }

  @override
  Future<Map<String, dynamic>> getTaskStatistics(int patientId) async {
    final response = await _apiClient.get(
      '/tasks/stats',
      queryParameters: {'patientId': patientId},
    );

    if (response is Map<String, dynamic> && response['success'] == true) {
      return response['data'] as Map<String, dynamic>;
    }
    // Fallback Mock if endpoint missing
    return {'completionRate': 0.0, 'totalTasks': 0, 'completedTasks': 0};
  }
}
