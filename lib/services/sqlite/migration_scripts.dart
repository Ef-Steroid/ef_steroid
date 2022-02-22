const migrationScripts = <String>[
  'ALTER TABLE "EfPanels" ADD "DbContextName" TEXT NULL;',
  '''
  INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
  VALUES ('20220222133346_AddEfPanel', '6.0.0');
  ''',
];
