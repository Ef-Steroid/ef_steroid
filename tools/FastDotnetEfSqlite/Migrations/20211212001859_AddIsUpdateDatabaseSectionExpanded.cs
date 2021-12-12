using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FastDotnetEfSqlite.Migrations
{
    public partial class AddIsUpdateDatabaseSectionExpanded : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsUpdateDatabaseSectionExpanded",
                table: "EfPanels",
                type: "INTEGER",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsUpdateDatabaseSectionExpanded",
                table: "EfPanels");
        }
    }
}
