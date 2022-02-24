import 'package:ef_steroid/services/dotnet_ef/model/db_context.dart';
import 'package:flutter/foundation.dart';

mixin DbContextSelectorViewModelMixin {
  List<DbContext> _dbContexts = [];

  @nonVirtual
  List<DbContext> get dbContexts => _dbContexts;

  @protected
  @nonVirtual
  set dbContexts(List<DbContext> dbContexts) => _dbContexts = dbContexts;

  /// Fetch the DbContexts.
  Future<void> fetchDbContextsAsync();

  /// Store the DbContext.
  Future<void> configureDbContextAsync({
    DbContext? dbContext,
  });
}
