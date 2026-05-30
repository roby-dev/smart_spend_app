/// Outcome of importing a backup JSON payload.
///
/// The import is resilient: a malformed record is skipped and reported here
/// instead of aborting the whole restore. Callers can surface [failures] to
/// the user (e.g. which compra could not be imported and why).
class ImportResult {
  /// Number of compras successfully imported (inserted or updated).
  final int imported;

  /// Records that could not be imported, with the reason.
  final List<ImportFailure> failures;

  const ImportResult({
    required this.imported,
    this.failures = const [],
  });

  bool get hasFailures => failures.isNotEmpty;

  /// Names of the compras that failed to import.
  List<String> get failedTitulos => failures.map((f) => f.titulo).toList();
}

/// A single record that failed to import.
class ImportFailure {
  /// The compra's `titulo`, used to tell the user which record failed.
  final String titulo;

  /// Human-readable reason (e.g. missing date).
  final String reason;

  const ImportFailure({
    required this.titulo,
    required this.reason,
  });
}
