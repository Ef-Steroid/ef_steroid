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
        "DirectoryUrl" TEXT NOT NULL
      );
  ''',
  '''
      INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
      VALUES ('20211229052819_InitialMigration', '6.0.0');
  ''',
];
