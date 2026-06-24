using System;
using Microsoft.EntityFrameworkCore.Migrations;
using db.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddBookingHoldExpiry : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "hold_expires_at",
                table: "bookings",
                type: "timestamp with time zone",
                nullable: true);

            // Column exists now — (re)install the stored procedures that read/write
            // hold_expires_at plus the new payment/hold procs (all CREATE OR REPLACE,
            // so re-running the whole set is idempotent).
            MigrationSqlLoader.LoadAll(migrationBuilder, "Sql.stored_procedures");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "hold_expires_at",
                table: "bookings");
        }
    }
}
