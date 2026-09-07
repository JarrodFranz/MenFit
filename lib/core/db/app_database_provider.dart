import 'package:menfit_app/core/db/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database_provider.g.dart';

/// The app-wide [AppDatabase] instance.
///
/// `keepAlive` because it's an app-scoped service, not screen-scoped state
/// — repositories across every feature depend on it for the lifetime of
/// the app.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
