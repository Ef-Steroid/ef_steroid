using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FastDotnetEfSqlite.Migrations
{
    public partial class InitialMigration : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "EfPanels",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    DirectoryUri = table.Column<string>(type: "TEXT", nullable: false),
                    ConfigFileUri = table.Column<string>(type: "TEXT", nullable: true),
                    ProjectEfType = table.Column<int>(type: "INTEGER", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EfPanels", x => x.Id);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EfPanels");
        }
    }
}
