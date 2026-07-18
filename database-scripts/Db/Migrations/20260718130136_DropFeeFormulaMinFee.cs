using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class DropFeeFormulaMinFee : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Reload functions + views that referenced min_fee_cents. Views must be
            // recreated (they DROP + CREATE without the column) before the column can
            // be dropped, since a view column depends on it.
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("01_compute_fee.sql"));
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("03_tier_pricing.sql"));
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("sp_fee_formulas.sql"));
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("sp_billing.sql"));
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("sp_set_tenant_tier.sql"));
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("0106_v_developer_billing.sql"));
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("0145_v_fee_formulas.sql"));
            migrationBuilder.Sql(db.Migrations.MigrationSqlLoader.Load("0200_fix_security_invoker.sql"));

            migrationBuilder.DropColumn(
                name: "min_fee_cents",
                table: "fee_formulas");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "min_fee_cents",
                table: "fee_formulas",
                type: "integer",
                nullable: true);
        }
    }
}
