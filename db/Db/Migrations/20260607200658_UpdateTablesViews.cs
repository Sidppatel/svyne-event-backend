using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace db.Migrations
{
    /// <inheritdoc />
    public partial class UpdateTablesViews : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP VIEW IF EXISTS v_event_table_stats CASCADE;");
            migrationBuilder.Sql("DROP VIEW IF EXISTS v_event_tables_summary CASCADE;");
            migrationBuilder.Sql("DROP VIEW IF EXISTS v_tables CASCADE;");

            migrationBuilder.Sql(MigrationSqlLoader.Load("v_tables.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("v_event_tables_summary.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("v_event_table_stats.sql"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}
