using db.Migrations;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AuditPricingMutations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // SQL-only: fn_audit_trigger now reads the actor/tenant GUCs and binds to
            // prices + price_rules, so every price and rule create/update/delete lands
            // in audit_logs attributed to the JWT user. CREATE OR REPLACE plus
            // DROP TRIGGER IF EXISTS make this idempotent.
            migrationBuilder.Sql(MigrationSqlLoader.Load("20_fn_audit_trigger.sql"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP TRIGGER IF EXISTS tr_audit_prices ON prices;");
            migrationBuilder.Sql("DROP TRIGGER IF EXISTS tr_audit_price_rules ON price_rules;");
        }
    }
}
