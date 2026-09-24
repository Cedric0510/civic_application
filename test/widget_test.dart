import 'package:civic_app/features/articles/data/models/article_model.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:civic_app/features/appointments/data/models/appointment_request_model.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:civic_app/features/commerces/data/models/commerce_model.dart';
import 'package:civic_app/features/polls/data/models/poll_model.dart';
import 'package:civic_app/features/polls/domain/entities/poll.dart';
import 'package:civic_app/features/polls/domain/entities/poll_option.dart';
import 'package:civic_app/features/reports/data/models/report_model.dart';
import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/settings/data/models/city_settings_model.dart';
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
    test('fromJson maps all fields, including the service name and status', () {
      final json = {
        'id': 'appointment-1',
        'serviceId': 'service-1',
        'service': {'name': 'Urbanisme'},
        'startsAt': '2026-06-15T07:30:00.000Z',
        'endsAt': '2026-06-15T08:00:00.000Z',
        'message': 'Besoin d un document',
        'status': 'CONFIRME',
      };

      final model = AppointmentModel.fromJson(json);

      expect(model.id, 'appointment-1');
      expect(model.serviceId, 'service-1');
      expect(model.serviceName, 'Urbanisme');
      expect(model.startsAt, DateTime.parse('2026-06-15T07:30:00.000Z'));
      expect(model.endsAt, DateTime.parse('2026-06-15T08:00:00.000Z'));
      expect(model.message, 'Besoin d un document');
      expect(model.status, AppointmentStatus.confirme);
    });

    test('fromJson accepts a missing message', () {
      final model = AppointmentModel.fromJson({
        'id': 'appointment-2',
        'serviceId': 'service-1',
        'service': {'name': 'Urbanisme'},
        'startsAt': '2026-06-15T07:30:00.000Z',
        'endsAt': '2026-06-15T08:00:00.000Z',
        'message': null,
        'status': 'DEMANDE',
      });

      expect(model.message, isNull);
      expect(model.status, AppointmentStatus.demande);
    });
  });

  group('AppointmentRequestModel', () {
    test(
      'toJson sends the start as a UTC instant and omits an empty message',
      () {
        final model = AppointmentRequestModel(
          serviceId: 'service-1',
          startsAt: DateTime.utc(2026, 6, 15, 7, 30),
          message: '',
        );

        expect(model.toJson(), {
          'serviceId': 'service-1',
          'startsAt': '2026-06-15T07:30:00.000Z',
        });
      },
    );

    test('toJson keeps a non-empty message', () {
      final model = AppointmentRequestModel(
        serviceId: 'service-1',
        startsAt: DateTime.utc(2026, 6, 15, 7, 30),
        message: 'Permis',
      );

      expect(model.toJson()['message'], 'Permis');
    });
  });

  group('groupSlotsByDay', () {
    AppointmentSlot slotAt(DateTime start) => AppointmentSlot(
      startsAt: start,
      endsAt: start.add(const Duration(minutes: 30)),
    );

    test('groups slots under their local calendar day, in order', () {
      final morning = DateTime(2026, 10, 14, 9);
      final later = DateTime(2026, 10, 14, 14, 30);
      final nextDay = DateTime(2026, 10, 15, 9);

      final days = groupSlotsByDay([
        slotAt(morning),
        slotAt(later),
        slotAt(nextDay),
      ]);

      expect(days.keys.toList(), [
        DateTime(2026, 10, 14),
        DateTime(2026, 10, 15),
      ]);
      expect(days[DateTime(2026, 10, 14)], hasLength(2));
      expect(days[DateTime(2026, 10, 15)], hasLength(1));
    });

    test('returns nothing for no slot', () {
      expect(groupSlotsByDay(const []), isEmpty);
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

    test(
      'fromJson defaults opensAt/closesAt to null and isVotable to true',
      () {
        final model = PollModel.fromJson({
          'id': 'poll-2',
          'question': 'Quel projet prioriser ?',
          'isActive': true,
          'options': <Map<String, dynamic>>[],
        });

        expect(model.opensAt, isNull);
        expect(model.closesAt, isNull);
        expect(model.isVotable, isTrue);
      },
    );
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

  group('CitySettingsModel', () {
    test('fromJson maps the cached weather when present', () {
      final json = {
        'name': 'Bessan',
        'weatherTemperature': 21.4,
        'weatherDescription': 'ciel dégagé',
        'weatherIconCode': '01d',
        'weatherHumidity': 55,
        'weatherWindSpeed': 3.6,
        'weatherFeelsLike': 20.2,
        'weatherSunrise': '2026-09-24T05:35:27.000Z',
        'weatherSunset': '2026-09-24T17:41:22.000Z',
        'weatherUpdatedAt': '2026-09-24T10:00:00.000Z',
      };

      final model = CitySettingsModel.fromJson(json);

      expect(model.villageName, 'Bessan');
      expect(model.weather, isNotNull);
      expect(model.weather!.cityName, 'Bessan');
      expect(model.weather!.temperature, 21.4);
      expect(model.weather!.feelsLike, 20.2);
      expect(model.weather!.description, 'ciel dégagé');
      expect(model.weather!.iconCode, '01d');
      expect(model.weather!.humidity, 55);
      expect(model.weather!.windSpeed, 3.6);
      expect(
        model.weather!.sunrise!.isAtSameMomentAs(
          DateTime.utc(2026, 9, 24, 5, 35, 27),
        ),
        isTrue,
      );
      expect(model.weather!.sunrise!.isUtc, isFalse);
      expect(
        model.weather!.sunset!.isAtSameMomentAs(
          DateTime.utc(2026, 9, 24, 17, 41, 22),
        ),
        isTrue,
      );
      expect(
        model.weather!.updatedAt!.isAtSameMomentAs(
          DateTime.utc(2026, 9, 24, 10),
        ),
        isTrue,
      );
      expect(model.weather!.forecast, isEmpty);
    });

    test(
      'fromJson falls back to the temperature when feels-like or sun times are absent',
      () {
        final model = CitySettingsModel.fromJson({
          'name': 'Bessan',
          'weatherTemperature': 21.4,
        });

        expect(model.weather!.feelsLike, 21.4);
        expect(model.weather!.sunrise, isNull);
        expect(model.weather!.sunset, isNull);
        expect(model.weather!.updatedAt, isNull);
      },
    );

    test('fromJson maps the cached forecast entries when present', () {
      final json = {
        'name': 'Bessan',
        'weatherTemperature': 21.4,
        'weatherDescription': 'ciel dégagé',
        'weatherIconCode': '01d',
        'weatherHumidity': 55,
        'weatherWindSpeed': 3.6,
        'forecastEntries': [
          {
            'forecastAt': '2026-09-24T12:00:00.000Z',
            'temperature': 22.1,
            'feelsLike': 21.3,
            'description': 'nuageux',
            'iconCode': '04d',
            'humidity': 48,
            'windSpeed': 2.5,
            'precipitationProbability': 35,
          },
        ],
      };

      final model = CitySettingsModel.fromJson(json);

      expect(model.weather!.forecast, hasLength(1));
      final entry = model.weather!.forecast.single;
      expect(
        entry.time.isAtSameMomentAs(DateTime.utc(2026, 9, 24, 12)),
        isTrue,
      );
      expect(entry.time.isUtc, isFalse);
      expect(entry.temperature, 22.1);
      expect(entry.feelsLike, 21.3);
      expect(entry.description, 'nuageux');
      expect(entry.iconCode, '04d');
      expect(entry.humidity, 48);
      expect(entry.windSpeed, 2.5);
      expect(entry.precipitationProbability, 35);
    });

    test(
      'fromJson leaves weather null when civic_api has not cached it yet',
      () {
        final model = CitySettingsModel.fromJson({'name': 'Bessan'});

        expect(model.weather, isNull);
      },
    );
  });
}
