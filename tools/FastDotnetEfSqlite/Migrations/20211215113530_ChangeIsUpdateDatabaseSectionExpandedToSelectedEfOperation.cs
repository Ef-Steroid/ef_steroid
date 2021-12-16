using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FastDotnetEfSqlite.Migrations
{
    public partial class ChangeIsUpdateDatabaseSectionExpandedToSelectedEfOperation : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "IsUpdateDatabaseSectionExpanded",
                table: "EfPanels",
                newName: "SelectedEfOperation");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "SelectedEfOperation",
                table: "EfPanels",
                newName: "IsUpdateDatabaseSectionExpanded");
        }
    }
}
