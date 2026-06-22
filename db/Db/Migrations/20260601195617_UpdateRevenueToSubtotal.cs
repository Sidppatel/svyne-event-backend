using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace db.Migrations
{
    /// <inheritdoc />
    public partial class UpdateRevenueToSubtotal : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(MigrationSqlLoader.Load("v_admin_dashboard_stats.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("v_top_events_revenue.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("v_organizations.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_get_next_event_dashboard.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_get_purchase_stats.sql"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
