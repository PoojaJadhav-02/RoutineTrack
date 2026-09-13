import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
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
        final initialTasks = _createInitialSeedTasks();
        await saveTasks(initialTasks);
        return initialTasks;
      }
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks from SharedPreferences: $e');
      return [];
    }
  }

  List<TaskModel> _createInitialSeedTasks() {
    final now = DateTime.now();
    final today = AppDateUtils.normalize(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    return [
      // Today's Routine
      TaskModel(
        id: 'seed-today-1',
        title: 'Wake up at 6:30 AM',
        description: 'Start the day early and hydrated',
        date: today,
        time: const TimeOfDay(hour: 6, minute: 30),
        isCompleted: true,
        createdAt: today.add(const Duration(hours: 6)),
        completedAt: today.add(const Duration(hours: 6, minutes: 35)),
      ),
      TaskModel(
        id: 'seed-today-2',
        title: 'Exercise for 30 minutes',
        description: 'Morning stretching and cardio workout',
        date: today,
        time: const TimeOfDay(hour: 7, minute: 0),
        isCompleted: true,
        createdAt: today.add(const Duration(hours: 7)),
        completedAt: today.add(const Duration(hours: 7, minutes: 35)),
      ),
      TaskModel(
        id: 'seed-today-3',
        title: 'Read a book',
        description: '20 pages of current reading',
        date: today,
        time: const TimeOfDay(hour: 8, minute: 0),
        isCompleted: false,
        createdAt: today.add(const Duration(hours: 8)),
      ),
      TaskModel(
        id: 'seed-today-4',
        title: 'Drink 2L water',
        description: 'Stay hydrated throughout the workday',
        date: today,
        time: null,
        isCompleted: true,
        createdAt: today.add(const Duration(hours: 9)),
        completedAt: today.add(const Duration(hours: 14)),
      ),
      TaskModel(
        id: 'seed-today-5',
        title: 'Practice Flutter',
        description: 'Build Clean Architecture Habit Tracker',
        date: today,
        time: const TimeOfDay(hour: 16, minute: 0),
        isCompleted: false,
        createdAt: today.add(const Duration(hours: 10)),
      ),
      TaskModel(
        id: 'seed-today-6',
        title: 'Meditation',
        description: '10 minutes mindfulness before bed',
        date: today,
        time: const TimeOfDay(hour: 21, minute: 30),
        isCompleted: false,
        createdAt: today.add(const Duration(hours: 11)),
      ),

      // Yesterday's Routine (History)
      TaskModel(
        id: 'seed-yesterday-1',
        title: 'Wake up at 6:30 AM',
        description: 'Early morning start',
        date: yesterday,
        time: const TimeOfDay(hour: 6, minute: 30),
        isCompleted: true,
        createdAt: yesterday.add(const Duration(hours: 6)),
        completedAt: yesterday.add(const Duration(hours: 6, minutes: 32)),
      ),
      TaskModel(
        id: 'seed-yesterday-2',
        title: 'Exercise for 30 minutes',
        description: 'Cardio & core workout',
        date: yesterday,
        time: const TimeOfDay(hour: 7, minute: 0),
        isCompleted: true,
        createdAt: yesterday.add(const Duration(hours: 7)),
        completedAt: yesterday.add(const Duration(hours: 7, minutes: 40)),
      ),
      TaskModel(
        id: 'seed-yesterday-3',
        title: 'Flutter practice',
        description: 'State management and clean UI',
        date: yesterday,
        time: const TimeOfDay(hour: 15, minute: 0),
        isCompleted: true,
        createdAt: yesterday.add(const Duration(hours: 8)),
        completedAt: yesterday.add(const Duration(hours: 16)),
      ),
      TaskModel(
        id: 'seed-yesterday-4',
        title: 'Reading',
        description: 'Atomic Habits chapter 4',
        date: yesterday,
        time: const TimeOfDay(hour: 19, minute: 0),
        isCompleted: true,
        createdAt: yesterday.add(const Duration(hours: 9)),
        completedAt: yesterday.add(const Duration(hours: 19, minutes: 30)),
      ),
      TaskModel(
        id: 'seed-yesterday-5',
        title: 'Meditation',
        description: 'Evening relaxation',
        date: yesterday,
        time: const TimeOfDay(hour: 21, minute: 30),
        isCompleted: true,
        createdAt: yesterday.add(const Duration(hours: 10)),
        completedAt: yesterday.add(const Duration(hours: 21, minutes: 45)),
      ),

      // Two Days Ago Routine (History)
      TaskModel(
        id: 'seed-2days-1',
        title: 'Morning Exercise',
        description: 'Jogging in the park',
        date: twoDaysAgo,
        time: const TimeOfDay(hour: 7, minute: 0),
        isCompleted: true,
        createdAt: twoDaysAgo.add(const Duration(hours: 6)),
        completedAt: twoDaysAgo.add(const Duration(hours: 7, minutes: 45)),
      ),
      TaskModel(
        id: 'seed-2days-2',
        title: 'Reading',
        description: 'Productivity literature',
        date: twoDaysAgo,
        time: const TimeOfDay(hour: 8, minute: 30),
        isCompleted: true,
        createdAt: twoDaysAgo.add(const Duration(hours: 8)),
        completedAt: twoDaysAgo.add(const Duration(hours: 9)),
      ),
      TaskModel(
        id: 'seed-2days-3',
        title: 'Meditation',
        description: 'Breathing exercises',
        date: twoDaysAgo,
        time: const TimeOfDay(hour: 12, minute: 30),
        isCompleted: true,
        createdAt: twoDaysAgo.add(const Duration(hours: 9)),
        completedAt: twoDaysAgo.add(const Duration(hours: 12, minutes: 45)),
      ),
      TaskModel(
        id: 'seed-2days-4',
        title: 'Flutter practice',
        description: 'Widget tree optimization',
        date: twoDaysAgo,
        time: const TimeOfDay(hour: 16, minute: 0),
        isCompleted: false,
        createdAt: twoDaysAgo.add(const Duration(hours: 10)),
      ),
      TaskModel(
        id: 'seed-2days-5',
        title: 'Walking',
        description: 'Evening 5,000 steps stroll',
        date: twoDaysAgo,
        time: const TimeOfDay(hour: 18, minute: 30),
        isCompleted: false,
        createdAt: twoDaysAgo.add(const Duration(hours: 11)),
      ),
    ];
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
