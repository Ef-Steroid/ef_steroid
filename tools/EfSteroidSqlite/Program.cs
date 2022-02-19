// See https://aka.ms/new-console-template for more information

using EfSteroidSqlite.EntityFrameworkCore;

// Helper method to print the db.
Console.WriteLine(new EfSteroidDbContext().DbPath);
