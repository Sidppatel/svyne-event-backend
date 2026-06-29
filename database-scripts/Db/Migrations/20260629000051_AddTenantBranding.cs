using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddTenantBranding : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "brand_accent",
                table: "tenants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "brand_primary",
                table: "tenants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "brand_secondary",
                table: "tenants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "logo_images_id",
                table: "tenants",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "brand_accent",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "brand_primary",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "brand_secondary",
                table: "tenants");

            migrationBuilder.DropColumn(
                name: "logo_images_id",
                table: "tenants");
        }
    }
}
