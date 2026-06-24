using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddTenantStripeProfileTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
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

            migrationBuilder.CreateTable(
                name: "tenant_stripe_profiles",
                columns: table => new
                {
                    tenants_id = table.Column<Guid>(type: "uuid", nullable: false),
                    business_type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    business_url = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
                    product_description = table.Column<string>(type: "character varying(2048)", maxLength: 2048, nullable: true),
                    mcc = table.Column<string>(type: "character varying(4)", maxLength: 4, nullable: true),
                    support_email = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_tenant_stripe_profiles", x => x.tenants_id);
                    table.ForeignKey(
                        name: "fk_tenant_stripe_profiles_tenants_tenants_id",
                        column: x => x.tenants_id,
                        principalTable: "tenants",
                        principalColumn: "tenants_id",
                        onDelete: ReferentialAction.Cascade);
                });

            // RLS: developer (any tenant) or the tenant's own members may read;
            // only a developer may write. Inlined here rather than as a policies/
            // file because InstallSqlArtifacts runs before this table exists.
            migrationBuilder.Sql(@"
ALTER TABLE tenant_stripe_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_tenant_isolation ON tenant_stripe_profiles;
CREATE POLICY p_tenant_isolation ON tenant_stripe_profiles
    USING (app.is_developer() OR tenants_id = app.current_tenant())
    WITH CHECK (app.is_developer());");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "tenant_stripe_profiles");

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
    }
}
