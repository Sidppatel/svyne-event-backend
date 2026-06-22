using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace db.Migrations
{
    /// <inheritdoc />
    public partial class AddSponsors : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "sponsors",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Slug = table.Column<string>(type: "character varying(220)", maxLength: 220, nullable: false),
                    PrimaryImagePath = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
                    Meta = table.Column<string>(type: "jsonb", nullable: false, defaultValueSql: "'[]'::jsonb"),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()"),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sponsors", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "event_sponsors",
                columns: table => new
                {
                    EventId = table.Column<Guid>(type: "uuid", nullable: false),
                    SponsorId = table.Column<Guid>(type: "uuid", nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    EventMeta = table.Column<string>(type: "jsonb", nullable: false, defaultValueSql: "'[]'::jsonb"),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_event_sponsors", x => new { x.EventId, x.SponsorId });
                    table.ForeignKey(
                        name: "FK_event_sponsors_events_EventId",
                        column: x => x.EventId,
                        principalTable: "events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_event_sponsors_sponsors_SponsorId",
                        column: x => x.SponsorId,
                        principalTable: "sponsors",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_event_sponsors_EventId_SortOrder",
                table: "event_sponsors",
                columns: new[] { "EventId", "SortOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_event_sponsors_SponsorId",
                table: "event_sponsors",
                column: "SponsorId");

            migrationBuilder.CreateIndex(
                name: "IX_sponsors_Name",
                table: "sponsors",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_sponsors_Slug",
                table: "sponsors",
                column: "Slug",
                unique: true);

            MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.Sponsors");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_set_event_sponsors(uuid, jsonb);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_delete_sponsor(uuid);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_update_sponsor(uuid, text, text, text, jsonb);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_create_sponsor(text, text, text, jsonb);");
            migrationBuilder.Sql("DROP VIEW IF EXISTS v_sponsors;");
            migrationBuilder.Sql("DROP VIEW IF EXISTS v_events;");
            migrationBuilder.Sql(MigrationSqlLoader.Load("02_v_events_with_performers.sql"));
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS fn_merge_sponsor_meta(jsonb, jsonb);");

            migrationBuilder.DropTable(
                name: "event_sponsors");

            migrationBuilder.DropTable(
                name: "sponsors");
        }
    }
}
