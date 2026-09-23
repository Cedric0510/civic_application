import 'package:civic_app/features/articles/data/models/article_model.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/commerces/data/models/commerce_model.dart';
import 'package:civic_app/features/polls/data/models/poll_model.dart';
import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:civic_app/features/reports/data/models/report_model.dart';
import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/weather/data/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArticleModel', () {
    test('fromJson maps all fields', () {
      final json = {
        'id': 'article-1',
        'title': 'Conseil municipal',
        'content': 'Compte rendu complet',
        'category': 'Info générale',
        'imageUrl': 'https://example.com/article.jpg',
        'publishedAt': '2026-06-01T10:30:00.000Z',
      };

      final model = ArticleModel.fromJson(json);

      expect(model.id, 'article-1');
      expect(model.title, 'Conseil municipal');
      expect(model.content, 'Compte rendu complet');
      expect(model.category, 'Info générale');
      expect(model.imageUrl, 'https://example.com/article.jpg');
      expect(model.publishedAt, DateTime.parse('2026-06-01T10:30:00.000Z'));
    });

    test('toJson serializes all fields', () {
      final model = ArticleModel(
        id: 'article-2',
        title: 'Travaux',
        content: 'Travaux en cours',
        category: null,
        imageUrl: null,
        publishedAt: DateTime.utc(2026, 6, 2, 8),
      );

      expect(model.toJson(), {
        'id': 'article-2',
        'title': 'Travaux',
        'content': 'Travaux en cours',
        'category': null,
        'imageUrl': null,
        'publishedAt': '2026-06-02T08:00:00.000Z',
      });
    });
  });

  group('AppointmentModel', () {
    test('fromJson maps all fields, including status', () {
      final json = {
        'id': 'appointment-1',
        'serviceId': 'service-1',
        'date': '2026-06-15',
        'message': 'Besoin d un document',
        'status': 'CONFIRME',
      };

      final model = AppointmentModel.fromJson(json);

      expect(model.id, 'appointment-1');
      expect(model.serviceId, 'service-1');
      expect(model.date, DateTime.parse('2026-06-15'));
      expect(model.message, 'Besoin d un document');
      expect(model.status, AppointmentStatus.confirme);
    });

    test('fromJson defaults status to null when absent', () {
      final model = AppointmentModel.fromJson({
        'id': 'appointment-2',
        'serviceId': 'service-1',
        'date': '2026-06-15',
        'message': null,
      });

      expect(model.status, isNull);
    });

    test('toJson formats date and omits empty message', () {
      final model = AppointmentModel(
        serviceId: 'service-1',
        date: DateTime(2026, 6, 15),
        message: '',
      );

      expect(model.toJson(), {'serviceId': 'service-1', 'date': '2026-06-15'});
    });
  });

  group('ReportModel', () {
    test('fromJson maps all fields, including category/status enums', () {
      final json = {
        'id': 'report-1',
        'address': '12 rue de la Mairie',
        'category': 'ECLAIRAGE',
        'description': 'Ampoule grillée',
        'imageUrl': 'https://example.com/report.jpg',
        'status': 'EN_COURS',
        'createdAt': '2026-06-01T10:30:00.000Z',
      };

      final model = ReportModel.fromJson(json);

      expect(model.id, 'report-1');
      expect(model.address, '12 rue de la Mairie');
      expect(model.category, ReportCategory.eclairage);
      expect(model.description, 'Ampoule grillée');
      expect(model.imageUrl, 'https://example.com/report.jpg');
      expect(model.status, ReportStatus.enCours);
      expect(model.createdAt, DateTime.parse('2026-06-01T10:30:00.000Z'));
    });

    test(
      'toJson sends only creation fields, omitting imageUrl when absent',
      () {
        final model = ReportModel(
          address: '5 place de la Mairie',
          category: ReportCategory.espacesVerts,
          description: 'Herbe trop haute',
        );

        expect(model.toJson(), {
          'address': '5 place de la Mairie',
          'category': 'ESPACES_VERTS',
          'description': 'Herbe trop haute',
        });
      },
    );
  });

  group('CommerceModel', () {
    test('toUpdateJson maps all editable fields', () {
      final model = CommerceModel(
        id: 'commerce-1',
        name: 'Boulangerie du Centre',
        category: 'Alimentation',
        description: 'Pain frais et pâtisseries',
        email: 'contact@boulangerie.fr',
        phone: '0467123456',
        address: '12 rue du Centre',
        hours: 'Lun-Sam 7h-19h',
        imageUrl: 'https://example.com/photo.jpg',
        notes: 'Congés du 12 au 25 juillet',
      );

      expect(model.toUpdateJson(), {
        'name': 'Boulangerie du Centre',
        'category': 'Alimentation',
        'description': 'Pain frais et pâtisseries',
        'email': 'contact@boulangerie.fr',
        'phone': '0467123456',
        'address': '12 rue du Centre',
        'hours': 'Lun-Sam 7h-19h',
        'imageUrl': 'https://example.com/photo.jpg',
        'notes': 'Congés du 12 au 25 juillet',
      });
    });

    test('toUpdateJson omits null fields instead of clearing them', () {
      final model = CommerceModel(
        id: 'commerce-1',
        name: 'Boulangerie du Centre',
      );

      expect(model.toUpdateJson(), {'name': 'Boulangerie du Centre'});
    });
  });

  group('PollModel', () {
    test('fromJson maps opensAt/closesAt/isVotable when present', () {
      final json = {
        'id': 'poll-1',
        'question': 'Quel projet prioriser ?',
        'isActive': true,
        'opensAt': '2026-06-01T00:00:00.000Z',
        'closesAt': '2026-06-15T00:00:00.000Z',
        'isVotable': false,
        'options': <Map<String, dynamic>>[],
      };

      final model = PollModel.fromJson(json);

      expect(model.opensAt, DateTime.parse('2026-06-01T00:00:00.000Z'));
      expect(model.closesAt, DateTime.parse('2026-06-15T00:00:00.000Z'));
      expect(model.isVotable, isFalse);
    });

    test('fromJson defaults opensAt/closesAt to null and isVotable to true', () {
      final model = PollModel.fromJson({
        'id': 'poll-2',
        'question': 'Quel projet prioriser ?',
        'isActive': true,
        'options': <Map<String, dynamic>>[],
      });

      expect(model.opensAt, isNull);
      expect(model.closesAt, isNull);
      expect(model.isVotable, isTrue);
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
