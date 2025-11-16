import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scholar_model.dart';
import '../models/college_model.dart';
import '../models/program_model.dart';
import '../models/engagement_model.dart';

// --- Data models for our charts ---
class CourseEnrollmentStats {
  final String courseName;
  final String type; // "Course" or "Internship"
  final int enrolled;
  final int performing;
  final int notEnrolled;
  CourseEnrollmentStats(
      {required this.courseName,
      required this.type,
      required this.enrolled,
      required this.performing,
      required this.notEnrolled});
}

class ScholarPerformance {
  final String courseName;
  final double completionRate; // 0.0 to 1.0
  ScholarPerformance({required this.courseName, required this.completionRate});
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MockDataService _mockDataService =
      MockDataService(); // Re-introducing mock data for charts

  // --- Methods to get statistical data for charts (Using Mock Data) ---
  Stream<List<CourseEnrollmentStats>> getCourseEnrollmentStats() {
    return _mockDataService.getCourseEnrollmentStatsStream();
  }

  Stream<List<ScholarPerformance>> getOverallPerformance() {
    return _mockDataService.getOverallPerformanceStream();
  }

  Stream<Map<String, int>> getScholarsByState() {
    return _mockDataService.getScholarsByStateStream();
  }

  // --- All other existing methods use live data ---

  Stream<int> getScholarsCount() {
    return _db
        .collection('scholars')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> getCollegesCount() {
    return _db
        .collection('colleges')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> getTotalProgramsCount() {
    return _db
        .collection('programs')
        .where('isGlobal', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<List<Scholar>> getScholars() {
    return _db.collection('scholars').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Scholar.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Future<List<String>> getAllScholarIds() async {
    final snapshot = await _db.collection('scholars').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getAllScholarEmails() async {
    final snapshot = await _db.collection('scholars').get();
    return snapshot.docs.map((doc) => doc.data()['email'] as String).toList();
  }

  Future<List<String>> getAllScholarPhoneNumbers() async {
    final snapshot = await _db.collection('scholars').get();
    return snapshot.docs
        .map((doc) => doc.data()['mobileNumber'] as String)
        .toList();
  }

  Future<List<String>> getScholarIdsForCollege(String collegeName) async {
    final snapshot = await _db
        .collection('scholars')
        .where('collegeName', isEqualTo: collegeName)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<Scholar>> getScholarsByIds(List<String> scholarIds) async {
    if (scholarIds.isEmpty) return [];
    final snapshot = await _db
        .collection('scholars')
        .where(FieldPath.documentId, whereIn: scholarIds)
        .get();
    return snapshot.docs
        .map((doc) => Scholar.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<List<College>> getColleges() {
    return _db.collection('colleges').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => College.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Stream<List<Program>> getProgramsForCollege(String collegeId) {
    return _db
        .collection('colleges')
        .doc(collegeId)
        .collection('programs')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Program.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Program>> getUniversalPrograms() {
    return _db
        .collection('programs')
        .where('isGlobal', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Program.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addProgram(String collegeId, Map<String, dynamic> programData) {
    return _db
        .collection('colleges')
        .doc(collegeId)
        .collection('programs')
        .add(programData);
  }

  Future<void> addUniversalProgram(Program program) {
    return _db.collection('programs').add(program.toFirestore());
  }

  Stream<List<EngagementGroup>> getEngagementGroups() {
    return _db.collection('engagementGroups').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => EngagementGroup.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}

// --- MOCK DATA SERVICE FOR CHARTS ---
class MockDataService {
  final Random _random = Random();
  final List<String> _courseNames = [
    'Data Analytics Essentials',
    'Python Essentials - 1',
    'Python Essentials - 2',
    'CSS Essentials',
    'English for IT-1',
    'English for IT-2',
    'HTML Essentials',
    'Introduction to Cyber Security',
    'Java Script Essentials -1',
    'Java Script Essentials -2',
    'Operating Systems Basics'
  ];
  final List<String> _internships = [
    'Goldman Sachs -(Internship)',
    'Oracle Cloud Infrastructure -2023',
    'CISCO- (Internship)'
  ];

  Stream<List<CourseEnrollmentStats>> getCourseEnrollmentStatsStream() {
    return Stream.fromFuture(
        Future.delayed(const Duration(milliseconds: 500), () {
      final courses = _courseNames.map((name) {
        int enrolled = 50 + _random.nextInt(150);
        int performing =
            (enrolled * (0.4 + _random.nextDouble() * 0.5)).round();
        int notEnrolled = 20 + _random.nextInt(80);
        return CourseEnrollmentStats(
            courseName: name,
            type: 'Course',
            enrolled: enrolled,
            performing: performing,
            notEnrolled: notEnrolled);
      }).toList();

      final internships = _internships.map((name) {
        int enrolled = 20 + _random.nextInt(50);
        int performing =
            (enrolled * (0.6 + _random.nextDouble() * 0.3)).round();
        int notEnrolled = 10 + _random.nextInt(40);
        return CourseEnrollmentStats(
            courseName: name,
            type: 'Internship',
            enrolled: enrolled,
            performing: performing,
            notEnrolled: notEnrolled);
      }).toList();

      return courses + internships;
    }));
  }

  Stream<List<ScholarPerformance>> getOverallPerformanceStream() {
    return Stream.fromFuture(
        Future.delayed(const Duration(milliseconds: 700), () {
      final List<String> topCourses =
          (_courseNames..shuffle()).take(5).toList();
      return topCourses.map((courseName) {
        return ScholarPerformance(
            courseName: courseName,
            completionRate: 0.6 + _random.nextDouble() * 0.35);
      }).toList();
    }));
  }

  Stream<Map<String, int>> getScholarsByStateStream() {
    return Stream.fromFuture(
        Future.delayed(const Duration(milliseconds: 600), () {
      return {
        'Telangana': 120,
        'Maharashtra': 95,
        'Karnataka': 80,
        'Tamil Nadu': 75,
        'Delhi': 60,
        'Other': 45,
      };
    }));
  }
}
