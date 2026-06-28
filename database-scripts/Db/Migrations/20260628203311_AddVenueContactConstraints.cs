using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Db.Migrations
{
    /// <inheritdoc />
    public partial class AddVenueContactConstraints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // NOT VALID: enforce on new/updated rows only; legacy rows are left untouched.
            migrationBuilder.Sql(
                "ALTER TABLE venues ADD CONSTRAINT ck_venues_email " +
                "CHECK (email IS NULL OR email = '' OR email ~* '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$') NOT VALID;");
            migrationBuilder.Sql(
                "ALTER TABLE venues ADD CONSTRAINT ck_venues_phone " +
                "CHECK (phone IS NULL OR phone = '' OR phone ~ '^\\+1[0-9]{10}$') NOT VALID;");
            migrationBuilder.Sql(
                "ALTER TABLE addresses ADD CONSTRAINT ck_addresses_state " +
                "CHECK (state IS NULL OR state = '' OR state ~ '^[A-Z]{2}$') NOT VALID;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("ALTER TABLE venues DROP CONSTRAINT IF EXISTS ck_venues_email;");
            migrationBuilder.Sql("ALTER TABLE venues DROP CONSTRAINT IF EXISTS ck_venues_phone;");
            migrationBuilder.Sql("ALTER TABLE addresses DROP CONSTRAINT IF EXISTS ck_addresses_state;");
        }
    }
}
