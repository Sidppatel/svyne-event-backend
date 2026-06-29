using db.Migrations;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class InstallTenantSettingsSql : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_link_google.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_unlink_google.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_get_my_tenant.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_update_tenant_contact.sql"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_link_google(uuid, text);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_unlink_google(uuid);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_get_my_tenant(uuid);");
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_update_tenant_contact(uuid, text, text, text, text, text, text);");
        }
    }
}
