import '../entities/home_summary_entity.dart';

/// Interface domain untuk agregasi ringkasan home. Implementasi
/// konkret memanggil repository fitur lain (calendar, todo, expense)
/// yang sudah ada — TIDAK membuat query database baru, dan TIDAK
/// duplikasi definisi tabel (sesuai aturan folder di guide).
abstract class IHomeRepository {
  Future<HomeSummaryEntity> getTodaySummary();
}
