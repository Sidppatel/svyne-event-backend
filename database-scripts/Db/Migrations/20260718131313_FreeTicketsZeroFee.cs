using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class FreeTicketsZeroFee : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Free entry (price 0) → service fee 0 (tax follows). Reload the shared fee function.
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("01_compute_fee.sql"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
