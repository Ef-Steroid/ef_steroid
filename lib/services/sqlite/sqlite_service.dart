/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ef_steroid/services/sqlite/unit_of_work.dart';

abstract class SqliteService {
  /// The path to the database.
  String get dbPath;

  /// Setup the database.
  ///
  /// This will update the migration.
  Future<void> setupAsync();

  /// Open a database and close it after usage.
  Future<T> useDatabaseAsync<T>({
    required UnitOfWork<T> uow,
    required DefaultResultAction<T> orDefault,
  });

  /// Open a readonly database and close it after usage.
  Future<T> useReadonlyDatabaseAsync<T>({
    required UnitOfWork<T> uow,
    required DefaultResultAction<T> orDefault,
  });
}
