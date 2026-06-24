using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddTenantStripePrefill : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "stripe_business_type",
                table: "tenants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "stripe_business_url",
                table: "tenants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "stripe_mcc",
                table: "tenants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "stripe_product_description",
                table: "tenants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "stripe_support_email",
                table: "tenants",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "stripe_business_type",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "stripe_business_url",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "stripe_mcc",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "stripe_product_description",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "stripe_support_email",
                table: "tenants");
        }
    }
}
