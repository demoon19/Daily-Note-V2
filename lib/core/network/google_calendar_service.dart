import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../../features/calendar/domain/entities/event_entity.dart';

class GoogleCalendarService {
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarEventsScope,
      'https://www.googleapis.com/auth/gmail.readonly',
      'email',
    ],
  );

  Future<calendar.CalendarApi?> _getApi({bool interactive = false}) async {
    var isLogged = await _googleSignIn.isSignedIn();
    if (!isLogged) {
      try {
        await _googleSignIn.signInSilently();
        isLogged = await _googleSignIn.isSignedIn();
        if (!isLogged && interactive) {
          final account = await _googleSignIn.signIn();
          if (account == null) throw Exception("Dibatalkan oleh pengguna.");
          isLogged = true;
        } else if (!isLogged) {
          return null;
        }
      } catch (e) {
        if (interactive) throw Exception("Gagal otentikasi Google: $e");
        return null;
      }
    }
    
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      if (interactive) {
        // Jika client null (mungkin karena scope kurang), paksa login ulang
        await _googleSignIn.disconnect();
        final account = await _googleSignIn.signIn();
        if (account == null) throw Exception("Dibatalkan oleh pengguna.");
        final newClient = await _googleSignIn.authenticatedClient();
        if (newClient == null) throw Exception("Gagal mendapatkan client OAuth.");
        return calendar.CalendarApi(newClient);
      }
      return null;
    }
    return calendar.CalendarApi(client);
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<void> disconnect() async {
    await _googleSignIn.disconnect();
  }

  Future<bool> login() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (e) {
      print("Google Calendar login error: $e");
      throw Exception("Gagal login Google Calendar: $e");
    }
  }

  Future<void> syncEventToGoogle(EventEntity event) async {
    try {
      final api = await _getApi();
      if (api == null) return;
      
      final endDatetime = event.datetime.add(const Duration(hours: 1));
      final newEvent = calendar.Event(
        summary: event.title,
        description: event.notes,
        location: event.location,
        start: calendar.EventDateTime(
          dateTime: event.datetime.toUtc(),
        ),
        end: calendar.EventDateTime(
          dateTime: endDatetime.toUtc(),
        ),
      );
      
      await api.events.insert(newEvent, 'primary');
      print("Berhasil mensinkronkan ${event.title} ke Google Calendar");
    } catch (e) {
      print("Error adding to google calendar: $e");
    }
  }
  Future<void> deleteEventFromGoogle(EventEntity event) async {
    try {
      final api = await _getApi();
      if (api == null) return;
      
      // Cari event berdasarkan waktu dan judul
      final searchStart = event.datetime.subtract(const Duration(minutes: 5));
      final searchEnd = event.datetime.add(const Duration(hours: 24));
      
      final results = await api.events.list(
        'primary',
        timeMin: searchStart.toUtc(),
        timeMax: searchEnd.toUtc(),
        q: event.title,
      );
      
      final items = results.items;
      if (items != null && items.isNotEmpty) {
        // Hapus event pertama yang cocok (atau bisa juga dilooping jika lebih aman)
        final eventId = items.first.id;
        if (eventId != null) {
          await api.events.delete('primary', eventId);
          print("Berhasil menghapus ${event.title} dari Google Calendar");
        }
      }
    } catch (e) {
      print("Error deleting from google calendar: $e");
    }
  }

  Future<List<EventEntity>> fetchEventsFromGoogle({DateTime? start, DateTime? end, bool interactive = false}) async {
    try {
      final api = await _getApi(interactive: interactive);
      if (api == null) {
        if (interactive) throw Exception("Tidak terhubung dengan Google API");
        return [];
      }
      
      final timeMin = start ?? DateTime.now().subtract(const Duration(days: 30));
      final timeMax = end ?? DateTime.now().add(const Duration(days: 30));
      
      final results = await api.events.list(
        'primary',
        timeMin: timeMin.toUtc(),
        timeMax: timeMax.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      
      final items = results.items;
      if (items == null || items.isEmpty) return [];
      
      List<EventEntity> fetchedEvents = [];
      for (var item in items) {
        bool isAllDay = item.start?.dateTime == null && item.start?.date != null;
        DateTime? eventDate = item.start?.dateTime?.toLocal() ?? item.start?.date;
        if (eventDate != null) {
          String? notes = item.description;
          if (isAllDay) {
            notes = '__ALL_DAY__' + (notes ?? '');
          }
          fetchedEvents.add(
            EventEntity(
              title: item.summary ?? 'Acara Google Calendar',
              datetime: eventDate,
              location: item.location,
              notes: notes,
            )
          );
        }
      }
      return fetchedEvents;
    } catch (e) {
      if (interactive) throw Exception("Gagal sinkronisasi data: $e");
      print("Error fetching from google calendar: $e");
      return [];
    }
  }
}
