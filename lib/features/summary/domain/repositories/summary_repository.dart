import '../entities/daily_summary_entity.dart';
import '../entities/weekly_summary_entity.dart';

/// Interface domain untuk agregasi ringkasan. Sama seperti
/// home_repository.dart — implementasi konkret hanya memanggil
/// repository fitur lain yang sudah ada, TIDAK membuat akses
/// database baru sendiri.
abstract class ISummaryRepository {
  Future<DailySummaryEntity> getDailySummary(DateTime date);
  Future<WeeklySummaryEntity> getWeeklySummary({DateTime? reference});
}
