using db.Migrations;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class RemoveVenueCapacityAndType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Drop the view (binds the columns) and the stale capacity/venue_type SP
            // overloads before dropping the columns. The SQL reinstall at the end
            // recreates the view/procs against the slimmed schema.
            migrationBuilder.Sql("DROP VIEW IF EXISTS vw_venues CASCADE;");
            migrationBuilder.Sql(
                "DROP FUNCTION IF EXISTS sp_create_venue(uuid,text,text,text,text,text,text,text,text,text,text,text,int,text);");
            migrationBuilder.Sql(
                "DROP FUNCTION IF EXISTS sp_update_venue(uuid,text,text,text,text,text,text,bool,text,text,text,text,text,int,text);");

            migrationBuilder.DropColumn(
                name: "capacity",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "venue_type",
                table: "venues");

            MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.views");
            MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.stored_procedures");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "capacity",
                table: "venues",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "venue_type",
                table: "venues",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);
        }
    }
}
