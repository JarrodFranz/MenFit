import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';

/// Persistence for the food diary: the user's food definitions and the
/// entries logged from them.
///
/// Split from [NutritionGoalsRepository] rather than merged into one
/// interface because the two have genuinely different shapes — a
/// many-rows-per-day log versus a single-row preference record — and
/// different lifetimes: the goals row survives clearing the whole diary.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`: nutrition
/// logs): never logged, never in analytics, and no implementation may put a
/// food name, a quantity, or a nutrition value into a thrown exception's
/// message.
abstract interface class NutritionRepository {
  /// Emits every live (non-deleted) food, name ascending, on every change.
  ///
  /// Unwindowed and unpaged: the food catalogue is the user's own
  /// hand-entered list, which stays small until S1-5 starts caching
  /// provider-sourced products — that is the change that will need paging
  /// here, and it should add it rather than this doing it speculatively.
  Stream<List<Food>> watchFoods();

  /// One-shot, case-insensitive search over live foods' name and brand,
  /// name ascending, capped at [limit].
  ///
  /// A blank or whitespace-only [query] returns the first [limit] foods
  /// rather than nothing — an empty search box should show the catalogue,
  /// not an empty state.
  Future<List<Food>> searchFoods(String query, {int limit});

  /// Live foods the user has actually logged, **most recently logged
  /// first**, capped at [limit].
  ///
  /// Recency is the time of the most recent entry that links to the food
  /// (`NutritionEntry.foodId`), not the food's own `updatedAt`: a food is
  /// "recent" because she ate it, not because she corrected its macros.
  ///
  /// The link is soft and lossy by design — an entry keeps its own snapshot
  /// and may name no food at all (quick-add) or a food since deleted (see
  /// [deleteFood]). Both simply drop out here: an unlinked entry has no
  /// food to offer, and a deleted one is not something to offer again.
  ///
  /// Alphabetical order is the wrong default for a picker that exists to
  /// re-log breakfast; this is the query that fixes it.
  Future<List<Food>> getRecentFoods({int limit});

  /// [getRecentFoods] as a stream, re-emitting whenever a food or an entry
  /// changes.
  ///
  /// Exists because the picker's "Recent" section must notice a food logged
  /// behind its back. A one-shot future would go stale the moment anything
  /// was logged and stay stale until the screen was rebuilt from scratch —
  /// a bug this codebase has already paid for once.
  Stream<List<Food>> watchRecentFoods({int limit});

  /// Live foods logged **most often** in the last [days] days, count
  /// descending, capped at [limit].
  ///
  /// The window is measured against each entry's `createdAt` — when it was
  /// logged — rather than the diary day it was filed under, so back-filling
  /// last month's meals doesn't make them look like this week's habits.
  ///
  /// Same soft-link and soft-delete rules as [getRecentFoods].
  Future<List<Food>> getFrequentFoods({int limit, int days});

  /// One-shot fetch of the live food with [id], or `null` when it doesn't
  /// exist or has been deleted.
  Future<Food?> getFood(String id);

  /// One-shot fetch of a live food carrying [barcode], or `null` when the
  /// catalogue has never seen that product.
  ///
  /// **This is the first thing every barcode lookup consults, before any
  /// network call** (`presentation/barcode_lookup_controller.dart`). Two
  /// things follow from that, and both are the point rather than a
  /// side-effect:
  ///
  /// - *Offline.* A supermarket aisle is where barcodes get scanned and
  ///   where signal is worst. A product the user has already saved is
  ///   loggable there with no connectivity at all.
  /// - *Privacy.* Re-scanning a saved product makes **zero** requests, so
  ///   the app does not tell a third party about a food it already knows.
  ///   Nothing is sent about a repeat purchase, ever
  ///   (`knowledge/engineering/security_and_privacy.md`, S2).
  ///
  /// [barcode] is matched exactly, so callers pass the canonical digits from
  /// `domain/barcode.dart` — that type exists precisely so a UPC-A and its
  /// EAN-13 spelling do not miss each other here.
  ///
  /// The `barcode` column is deliberately **non-unique**
  /// (`core/db/tables/foods.dart`), so several live rows can carry the same
  /// code — a provider-sourced row the user saved and a hand-entered one she
  /// typed first, say. When they do, the **most recently updated** live row
  /// wins: it is the definition she most recently stood behind, and it is
  /// the one an edit would have just touched.
  Future<Food?> getFoodByBarcode(String barcode);

  /// Upserts [food] by id, preserving the existing row's `createdAt` across
  /// an update (the persisted `updatedAt` is always stamped to UTC-now).
  ///
  /// **Editing a food never rewrites history.** Entries already logged from
  /// it keep the nutrition they were logged with, because each entry holds
  /// its own snapshot — see `core/db/tables/nutrition_entries.dart`. Saving
  /// an edit here changes what future entries will copy, nothing more.
  Future<void> saveFood(Food food);

  /// Soft-deletes the food with [id] — it stops appearing in [watchFoods]
  /// and [searchFoods], and stays out of [getFood].
  ///
  /// Soft rather than hard (unlike [deleteEntry]) because a food is a
  /// reusable catalogue definition, not a record of anything the user did:
  /// ADR 004's soft-delete convention applies cleanly, and there is nothing
  /// sensitive in "this food exists" that a hard delete would be protecting.
  /// Entries logged from it are untouched and remain fully readable.
  Future<void> deleteFood(String id);

  /// Emits every entry logged on [day], meal order then logging order, on
  /// every change. Emits an empty list for a day with nothing logged.
  Stream<List<NutritionEntry>> watchEntriesFor(LocalDate day);

  /// One-shot fetch of every entry logged on [day] (same ordering as
  /// [watchEntriesFor]).
  Future<List<NutritionEntry>> getEntriesFor(LocalDate day);

  /// Emits every entry logged between [start] and [end] inclusive, day
  /// ascending, meal order, then logging order, on every change.
  Stream<List<NutritionEntry>> watchEntriesForRange(
    LocalDate start,
    LocalDate end,
  );

  /// One-shot fetch of every entry logged between [start] and [end] inclusive.
  Future<List<NutritionEntry>> getEntriesForRange(
    LocalDate start,
    LocalDate end,
  );

  /// Upserts [entry] by id, preserving the existing row's `createdAt` across
  /// an update.
  ///
  /// The entry's `perServing` snapshot is persisted **exactly as given** —
  /// this method never re-reads the referenced food to "refresh" it. That
  /// is the whole point of the snapshot; see
  /// `domain/nutrition_entry.dart`. Callers building an entry from a food
  /// should use `NutritionEntry.fromFood`, and callers should have run
  /// `domain/nutrition_validation.dart#validateNutritionEntry` first.
  Future<void> saveEntry(NutritionEntry entry);

  /// Permanently (hard-)deletes the entry with [id] — not a soft delete.
  ///
  /// Removing something from a food diary has to actually remove it: a
  /// "deleted" meal that is still forensically present on the device
  /// contradicts what the delete button promises. Same reasoning as
  /// `features/streaks/domain/recovery_repository.dart#unmarkRecoveryDay`.
  Future<void> deleteEntry(String id);

  /// Permanently deletes every diary entry and every food on this device
  /// (part of the "Delete my data" flow —
  /// `features/settings/presentation/settings_screen.dart`). Hard deletes,
  /// including foods that were only soft-deleted before. Transactional
  /// across both tables.
  Future<void> deleteAllData();
}

/// Persistence for the single-row nutrition targets and display
/// preferences.
///
/// S2-tier, same handling rules as [NutritionRepository].
abstract interface class NutritionGoalsRepository {
  /// Emits the user's nutrition goals, or `null` when none have ever been
  /// saved, on every change.
  ///
  /// `null` is a real, expected state — not an error and not a reason to
  /// substitute defaults at this layer. Callers treat it as "every field at
  /// its documented default" (see `domain/nutrition_goals.dart`), which
  /// keeps "never set a target" distinguishable from "set one and cleared
  /// it".
  Stream<NutritionGoals?> watchGoals();

  /// One-shot fetch of the user's nutrition goals, or `null` when none have
  /// ever been saved.
  Future<NutritionGoals?> getGoals();

  /// Upserts [goals] by id, preserving the existing row's `createdAt` across
  /// an update. Every nullable target is written explicitly, so clearing a
  /// target back to "not set" actually persists.
  Future<void> saveGoals(NutritionGoals goals);

  /// Permanently deletes the goals row (part of the "Delete my data"
  /// flow).
  Future<void> deleteAllData();
}
