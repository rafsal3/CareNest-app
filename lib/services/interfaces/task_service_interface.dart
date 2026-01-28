import '../../models/patient_task.dart';

abstract class TaskServiceInterface {
  /// Fetch tasks assigned to a specific patient
  Future<List<PatientTask>> fetchTasks(int patientId);

  /// Update the status of a specific task (e.g. mark as done)
  Future<void> updateTaskStatus(int taskId, TaskStatus status);

  /// Get adherence statistics for a patient
  /// Returns a map of stats (e.g. {'completionRate': 0.85})
  Future<Map<String, dynamic>> getTaskStatistics(int patientId);
}
