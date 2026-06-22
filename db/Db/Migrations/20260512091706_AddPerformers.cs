using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace db.Migrations
{
    public partial class AddPerformers : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "performers",
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
                    table.PrimaryKey("PK_performers", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "event_performers",
                columns: table => new
                {
                    EventId = table.Column<Guid>(type: "uuid", nullable: false),
                    PerformerId = table.Column<Guid>(type: "uuid", nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    EventMeta = table.Column<string>(type: "jsonb", nullable: false, defaultValueSql: "'[]'::jsonb"),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_event_performers", x => new { x.EventId, x.PerformerId });
                    table.ForeignKey(
                        name: "FK_event_performers_events_EventId",
                        column: x => x.EventId,
                        principalTable: "events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_event_performers_performers_PerformerId",
                        column: x => x.PerformerId,
                        principalTable: "performers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_event_performers_EventId_SortOrder",
                table: "event_performers",
                columns: new[] { "EventId", "SortOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_event_performers_PerformerId",
                table: "event_performers",
                column: "PerformerId");

            migrationBuilder.CreateIndex(
                name: "IX_performers_Name",
                table: "performers",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_performers_Slug",
                table: "performers",
                column: "Slug",
                unique: true);

            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_events_by_performer(uuid, text, int, int);");
            MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.Performers");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_events_by_performer(uuid, text, int, int);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_count_performers(text);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_search_performers(text, int, int);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_set_event_performers(uuid, jsonb);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_delete_performer(uuid);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_update_performer(uuid, text, text, text, jsonb);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_create_performer(text, text, text, jsonb);");
            migrationBuilder.Sql("DROP VIEW IF EXISTS v_performers;");
            migrationBuilder.Sql(MigrationSqlLoader.Load("v_events.sql"));
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS fn_merge_performer_meta(jsonb, jsonb);");

            migrationBuilder.DropTable(name: "event_performers");
            migrationBuilder.DropTable(name: "performers");
        }
    }
}
