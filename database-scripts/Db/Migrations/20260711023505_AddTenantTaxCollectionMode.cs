using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddTenantTaxCollectionMode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "tax_collection_mode",
                table: "tenants",
                type: "character varying(16)",
                maxLength: 16,
                nullable: false,
                defaultValue: "platform");

            migrationBuilder.Sql("ALTER TABLE stripe_transactions ADD COLUMN IF NOT EXISTS payment_method_last4 text");

            migrationBuilder.Sql("ALTER TABLE stripe_transactions ADD COLUMN IF NOT EXISTS payment_method_type text");

            migrationBuilder.AddColumn<string>(
                name: "collected_by",
                table: "booking_taxes",
                type: "character varying(16)",
                maxLength: 16,
                nullable: false,
                defaultValue: "platform");

            migrationBuilder.AddCheckConstraint(
                name: "CK_tenants_TaxCollectionMode",
                table: "tenants",
                sql: "tax_collection_mode IN ('platform','self')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_booking_taxes_CollectedBy",
                table: "booking_taxes",
                sql: "collected_by IN ('platform','self')");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_tenants_TaxCollectionMode",
                table: "tenants");

            migrationBuilder.DropCheckConstraint(
                name: "CK_booking_taxes_CollectedBy",
                table: "booking_taxes");

            migrationBuilder.DropColumn(
                name: "tax_collection_mode",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "payment_method_last4",
                table: "stripe_transactions");

            migrationBuilder.DropColumn(
                name: "payment_method_type",
                table: "stripe_transactions");

            migrationBuilder.DropColumn(
                name: "collected_by",
                table: "booking_taxes");
        }
    }
}
