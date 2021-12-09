const initializationScript = [
  '''
      CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
          "MigrationId" TEXT NOT NULL CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY,
          "ProductVersion" TEXT NOT NULL
      );
      ''',
  '''
      CREATE TABLE "EfPanels" (
          "Id" TEXT NOT NULL CONSTRAINT "PK_EfPanels" PRIMARY KEY,
          "DirectoryUrl" TEXT NOT NULL
      );
      ''',
];
