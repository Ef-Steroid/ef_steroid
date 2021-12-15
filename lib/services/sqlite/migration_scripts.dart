const migrationScripts = <String>[
  '''
  ALTER TABLE "EfPanels" ADD "IsUpdateDatabaseSectionExpanded" INTEGER NOT NULL DEFAULT 0;

  INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
  VALUES ('20211212001859_AddIsUpdateDatabaseSectionExpanded', '6.0.0');
  ''',
];
