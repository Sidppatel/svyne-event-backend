using db.Migrations;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddEventImageType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "ix_event_images_events_id",
                table: "event_images");

            migrationBuilder.AddColumn<string>(
                name: "type",
                table: "event_images",
                type: "character varying(32)",
                maxLength: 32,
                nullable: false,
                defaultValue: "event_image");

            migrationBuilder.CreateIndex(
                name: "ix_event_images_events_id_type",
                table: "event_images",
                columns: new[] { "events_id", "type" },
                unique: true,
                filter: "is_primary = true");

            migrationBuilder.AddCheckConstraint(
                name: "CK_event_images_Type",
                table: "event_images",
                sql: "type IN ('event_image','event_thumbnail')");

            // Reinstall the view and SPs so they pick up the new type column and per-type scoping.
            MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.views");
            MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.stored_procedures");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "ix_event_images_events_id_type",
                table: "event_images");

            migrationBuilder.DropCheckConstraint(
                name: "CK_event_images_Type",
                table: "event_images");

            migrationBuilder.DropColumn(
                name: "type",
                table: "event_images");

            migrationBuilder.CreateIndex(
                name: "ix_event_images_events_id",
                table: "event_images",
                column: "events_id",
                unique: true,
                filter: "is_primary = true");
        }
    }
}
