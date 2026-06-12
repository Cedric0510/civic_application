import 'package:civic_app/features/articles/data/models/article_model.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:civic_app/features/weather/data/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArticleModel', () {
    test('fromJson maps all fields', () {
      final json = {
        'id': 'article-1',
        'title': 'Conseil municipal',
        'content': 'Compte rendu complet',
        'image_url': 'https://example.com/article.jpg',
        'published_at': '2026-06-01T10:30:00.000Z',
      };

      final model = ArticleModel.fromJson(json);

      expect(model.id, 'article-1');
      expect(model.title, 'Conseil municipal');
      expect(model.content, 'Compte rendu complet');
      expect(model.imageUrl, 'https://example.com/article.jpg');
      expect(model.publishedAt, DateTime.parse('2026-06-01T10:30:00.000Z'));
    });

    test('toJson serializes all fields', () {
      final model = ArticleModel(
        id: 'article-2',
        title: 'Travaux',
        content: 'Travaux en cours',
        imageUrl: null,
        publishedAt: DateTime.utc(2026, 6, 2, 8),
      );

      expect(model.toJson(), {
        'id': 'article-2',
        'title': 'Travaux',
        'content': 'Travaux en cours',
        'image_url': null,
        'published_at': '2026-06-02T08:00:00.000Z',
      });
    });
  });

  group('AppointmentModel', () {
    test('fromJson maps all fields', () {
      final json = {
        'id': 'appointment-1',
        'name': 'Jean Dupont',
        'email': 'jean@example.com',
        'service': 'Urbanisme',
        'date': '2026-06-15',
        'message': 'Besoin d un document',
      };

      final model = AppointmentModel.fromJson(json);

      expect(model.id, 'appointment-1');
      expect(model.name, 'Jean Dupont');
      expect(model.email, 'jean@example.com');
      expect(model.service, 'Urbanisme');
      expect(model.date, DateTime.parse('2026-06-15'));
      expect(model.message, 'Besoin d un document');
    });

    test('toJson formats date and omits empty message', () {
      final model = AppointmentModel(
        name: 'Jean Dupont',
        email: 'jean@example.com',
        service: 'Urbanisme',
        date: DateTime(2026, 6, 15),
        message: '',
      );

      expect(model.toJson(), {
        'name': 'Jean Dupont',
        'email': 'jean@example.com',
        'service': 'Urbanisme',
        'date': '2026-06-15',
      });
    });
  });

  group('Poll', () {
    test('totalVotes sums voteCount of all options', () {
      final poll = Poll(
        id: 'poll-1',
        question: 'Quel projet prioriser ?',
        isActive: true,
        options: const [
          PollOption(
            id: 'option-1',
            pollId: 'poll-1',
            optionText: 'Parc',
            voteCount: 12,
          ),
          PollOption(
            id: 'option-2',
            pollId: 'poll-1',
            optionText: 'Voirie',
            voteCount: 8,
          ),
        ],
      );

      expect(poll.totalVotes, 20);
    });
  });

  group('WeatherModel', () {
    test('fromJson maps nested API payload', () {
      final json = {
        'name': 'Lyon',
        'weather': [
          {'description': 'ciel degage', 'icon': '01d'},
        ],
        'main': {'temp': 21.4, 'humidity': 55},
        'wind': {'speed': 3.6},
      };

      final model = WeatherModel.fromJson(json);

      expect(model.cityName, 'Lyon');
      expect(model.temperature, 21.4);
      expect(model.description, 'ciel degage');
      expect(model.iconCode, '01d');
      expect(model.humidity, 55);
      expect(model.windSpeed, 3.6);
    });
  });
}
