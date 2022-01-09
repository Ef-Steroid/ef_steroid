const migrationScripts = <String>[
  '''
    ALTER TABLE "EfPanels" ADD "ConfigFileUrl" TEXT NOT NULL DEFAULT '';

    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20220111112728_AddConfigFileUrl', '6.0.0');
  ''',
];
