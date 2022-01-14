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
