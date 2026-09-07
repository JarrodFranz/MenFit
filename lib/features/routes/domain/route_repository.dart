import 'package:menfit_app/features/routes/domain/saved_route.dart';

/// Persistence for saved routes.
abstract interface class RouteRepository {
  /// Emits every non-deleted route, newest [SavedRoute.createdAt] first,
  /// on every change.
  Stream<List<SavedRoute>> watchRoutes();

  /// Emits the non-deleted route with [id], or `null` if it doesn't exist
  /// (or has been deleted), on every change.
  Stream<SavedRoute?> watchRoute(String id);

  /// One-shot fetch of the non-deleted route with [id], or `null`.
  Future<SavedRoute?> getRoute(String id);

  /// Upserts [route] by id. Always stamps the persisted `updatedAt` to
  /// UTC-now; the persisted `createdAt` is always the value of the
  /// first-ever save for that id (same transactional read-then-write
  /// convention as `ActivityRepository.saveActivity`).
  Future<void> saveRoute(SavedRoute route);

  /// Soft-deletes the route with [id]: sets `deletedAt`, keeps the row
  /// (ADR 004 default — routes are shareable-later artifacts).
  Future<void> deleteRoute(String id);

  /// Permanently (hard-)deletes every saved route on this device — part of
  /// the "Delete my data" flow. Routes carry start points that are
  /// typically home-adjacent (S2-tier location data,
  /// `knowledge/engineering/security_and_privacy.md`); the full-wipe flow
  /// must leave nothing recoverable, same reasoning as
  /// `ActivityRepository.deleteAllData`.
  Future<void> deleteAllData();
}
