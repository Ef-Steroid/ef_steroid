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

const initializationScript = [
  '''
  CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" TEXT NOT NULL CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY,
    "ProductVersion" TEXT NOT NULL
  );
  ''',
  '''
  CREATE TABLE "EfPanels" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_EfPanels" PRIMARY KEY AUTOINCREMENT,
    "DirectoryUri" TEXT NOT NULL,
    "ConfigFileUri" TEXT NULL,
    "ProjectEfType" INTEGER NULL
  );
  ''',
  '''
  INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
  VALUES ('20220116110454_InitialMigration', '6.0.0');
  ''',
];
