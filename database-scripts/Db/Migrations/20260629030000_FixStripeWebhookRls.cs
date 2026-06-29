using db.Migrations;
using Db;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    [DbContext(typeof(EventPlatformDbContext))]
    [Migration("20260629030000_FixStripeWebhookRls")]
    public partial class FixStripeWebhookRls : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_confirm_purchase.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_cancel_purchase.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_refund_purchase.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_update_stripe_transaction_status.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_enrich_stripe_transaction.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_insert_stripe_transfer.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_update_stripe_payout.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_expire_holds.sql"));
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Best effort fallback
        }
    }
}
