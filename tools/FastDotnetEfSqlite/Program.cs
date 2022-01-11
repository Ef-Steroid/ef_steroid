// See https://aka.ms/new-console-template for more information

using FastDotnetEfSqlite.EntityFrameworkCore;

// Helper method to print the db.
Console.WriteLine(new FastDotnetEfDbContext().DbPath);
