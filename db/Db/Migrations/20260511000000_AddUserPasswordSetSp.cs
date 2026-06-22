using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace db.Migrations
{
    public partial class AddUserPasswordSetSp : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_set_user_password.sql"));
            migrationBuilder.Sql(MigrationSqlLoader.Load("sp_consume_magic_link.sql"));
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP FUNCTION IF EXISTS sp_set_user_password(uuid, text, boolean, text);");
            migrationBuilder.Sql(@"CREATE OR REPLACE FUNCTION sp_consume_magic_link(p_token_hash text)
RETURNS TABLE (
    ""Id"" uuid, ""Email"" text, ""ExpiresAt"" timestamptz
) LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    RETURN QUERY
    UPDATE magic_link_tokens AS t
    SET ""IsUsed"" = true, ""UsedAt"" = now(), ""UpdatedAt"" = now()
    WHERE t.""TokenHash"" = p_token_hash AND t.""IsUsed"" = false AND t.""ExpiresAt"" > now()
    RETURNING t.""Id"", t.""Email""::text, t.""ExpiresAt"";
END; $$;");
        }
    }
}
