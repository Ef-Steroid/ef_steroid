using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EfSteroidSqlite.Migrations
{
    public partial class AddEfPanel : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DbContextName",
                table: "EfPanels",
                type: "TEXT",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DbContextName",
                table: "EfPanels");
        }
    }
}
