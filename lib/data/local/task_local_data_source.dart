import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getSavedTasks();
  Future<void> saveTasks(List<TaskModel> tasks);
  Future<void> clearTasks();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences? _prefsInstance;

  TaskLocalDataSourceImpl({SharedPreferences? prefs}) : _prefsInstance = prefs;

  Future<SharedPreferences> get _prefs async {
    if (_prefsInstance != null) return _prefsInstance;
    return await SharedPreferences.getInstance();
  }

  @override
  Future<List<TaskModel>> getSavedTasks() async {
    try {
      final prefs = await _prefs;
      final rawJson = prefs.getString(AppConstants.tasksStorageKey);
      if (rawJson == null || rawJson.trim().isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      final tasks = decoded
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .where((task) => !task.id.startsWith('seed-'))
          .toList();

      // If previously seeded static tasks were removed, persist the cleaned list
      if (tasks.length != decoded.length) {
        await saveTasks(tasks);
      }

      return tasks;
    } catch (e) {
      debugPrint('Error loading tasks from SharedPreferences: $e');
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final prefs = await _prefs;
      final jsonList = tasks.map((t) => t.toJson()).toList();
      final rawJson = jsonEncode(jsonList);
      await prefs.setString(AppConstants.tasksStorageKey, rawJson);
    } catch (e) {
      debugPrint('Error saving tasks to SharedPreferences: $e');
    }
  }

  @override
  Future<void> clearTasks() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(AppConstants.tasksStorageKey);
    } catch (e) {
      debugPrint('Error clearing tasks from SharedPreferences: $e');
    }
  }
}
