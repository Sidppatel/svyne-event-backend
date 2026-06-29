using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddStaffAccessAndCheckinLogs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP VIEW IF EXISTS vw_user_events CASCADE;");

            migrationBuilder.DropTable(
                name: "user_events");

            migrationBuilder.AddColumn<Guid>(
                name: "event_id",
                table: "invitations",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "checkin_logs",
                columns: table => new
                {
                    checkin_logs_id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    event_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: true),
                    ticket_id = table.Column<Guid>(type: "uuid", nullable: true),
                    timestamp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_checkin_logs", x => x.checkin_logs_id);
                    table.ForeignKey(
                        name: "fk_checkin_logs_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "bookings_id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_checkin_logs_events_event_id",
                        column: x => x.event_id,
                        principalTable: "events",
                        principalColumn: "events_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_checkin_logs_tickets_ticket_id",
                        column: x => x.ticket_id,
                        principalTable: "tickets",
                        principalColumn: "tickets_id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_checkin_logs_users_staff_user_id",
                        column: x => x.staff_user_id,
                        principalTable: "users",
                        principalColumn: "users_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "staff_event_access",
                columns: table => new
                {
                    staff_event_access_id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    staff_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    event_id = table.Column<Guid>(type: "uuid", nullable: false),
                    assigned_by_admin_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_staff_event_access", x => x.staff_event_access_id);
                    table.ForeignKey(
                        name: "fk_staff_event_access_events_event_id",
                        column: x => x.event_id,
                        principalTable: "events",
                        principalColumn: "events_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_staff_event_access_users_assigned_by_admin_id",
                        column: x => x.assigned_by_admin_id,
                        principalTable: "users",
                        principalColumn: "users_id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_staff_event_access_users_staff_user_id",
                        column: x => x.staff_user_id,
                        principalTable: "users",
                        principalColumn: "users_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "ix_invitations_event_id",
                table: "invitations",
                column: "event_id");

            migrationBuilder.CreateIndex(
                name: "ix_checkin_logs_booking_id",
                table: "checkin_logs",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "ix_checkin_logs_event_id",
                table: "checkin_logs",
                column: "event_id");

            migrationBuilder.CreateIndex(
                name: "ix_checkin_logs_staff_user_id",
                table: "checkin_logs",
                column: "staff_user_id");

            migrationBuilder.CreateIndex(
                name: "ix_checkin_logs_ticket_id",
                table: "checkin_logs",
                column: "ticket_id");

            migrationBuilder.CreateIndex(
                name: "ix_staff_event_access_assigned_by_admin_id",
                table: "staff_event_access",
                column: "assigned_by_admin_id");

            migrationBuilder.CreateIndex(
                name: "ix_staff_event_access_event_id",
                table: "staff_event_access",
                column: "event_id");

            migrationBuilder.CreateIndex(
                name: "ix_staff_event_access_staff_user_id_event_id",
                table: "staff_event_access",
                columns: new[] { "staff_user_id", "event_id" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "fk_invitations_events_event_id",
                table: "invitations",
                column: "event_id",
                principalTable: "events",
                principalColumn: "events_id",
                onDelete: ReferentialAction.Cascade);

            db.Migrations.MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.views");
            db.Migrations.MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.stored_procedures");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_invitations_events_event_id",
                table: "invitations");

            migrationBuilder.DropTable(
                name: "checkin_logs");

            migrationBuilder.DropTable(
                name: "staff_event_access");

            migrationBuilder.DropIndex(
                name: "ix_invitations_event_id",
                table: "invitations");

            migrationBuilder.DropColumn(
                name: "event_id",
                table: "invitations");

            migrationBuilder.CreateTable(
                name: "user_events",
                columns: table => new
                {
                    user_events_id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    assigned_by_users_id = table.Column<Guid>(type: "uuid", nullable: true),
                    events_id = table.Column<Guid>(type: "uuid", nullable: false),
                    users_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_user_events", x => x.user_events_id);
                    table.ForeignKey(
                        name: "fk_user_events_events_events_id",
                        column: x => x.events_id,
                        principalTable: "events",
                        principalColumn: "events_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_user_events_users_assigned_by_users_id",
                        column: x => x.assigned_by_users_id,
                        principalTable: "users",
                        principalColumn: "users_id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_user_events_users_users_id",
                        column: x => x.users_id,
                        principalTable: "users",
                        principalColumn: "users_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "ix_user_events_assigned_by_users_id",
                table: "user_events",
                column: "assigned_by_users_id");

            migrationBuilder.CreateIndex(
                name: "ix_user_events_events_id",
                table: "user_events",
                column: "events_id");

            migrationBuilder.CreateIndex(
                name: "ix_user_events_users_id_events_id",
                table: "user_events",
                columns: new[] { "users_id", "events_id" },
                unique: true);
        }
    }
}
