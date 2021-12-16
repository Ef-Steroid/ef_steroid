﻿// <auto-generated />
using FastDotnetEfSqlite.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

#nullable disable

namespace FastDotnetEfSqlite.Migrations
{
    [DbContext(typeof(FastDotnetEfDbContext))]
    [Migration("20211215113530_ChangeIsUpdateDatabaseSectionExpandedToSelectedEfOperation")]
    partial class ChangeIsUpdateDatabaseSectionExpandedToSelectedEfOperation
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder.HasAnnotation("ProductVersion", "6.0.0");

            modelBuilder.Entity("FastDotnetEfSqlite.Entity.EfPanel", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("INTEGER");

                    b.Property<string>("DirectoryUrl")
                        .IsRequired()
                        .HasColumnType("TEXT");

                    b.Property<int>("SelectedEfOperation")
                        .HasColumnType("INTEGER");

                    b.HasKey("Id");

                    b.ToTable("EfPanels");
                });
#pragma warning restore 612, 618
        }
    }
}
