/*
import 'package:faker/faker.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/services/activity_service.dart';

class FakerService {
  final ActivityService _courseServices = ActivityService();
  final Faker _faker = Faker();

  Future<void> generateActivities() async {
    for (int i = 0; i < 15; i++) {
      ActivityModel course = ActivityModel(
        title: _faker.lorem.sentence(),
        description: _faker.person.name(),
        location: _faker.internet.httpsUrl(), // Assume this is a URL to the content
        type: _faker.randomGenerator.element(['text', 'pdf', 'word']),
      );

      await _courseServices.addActivity(course);
    }
  }
}
*/