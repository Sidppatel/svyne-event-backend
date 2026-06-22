using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace db.Migrations
{
    /// <inheritdoc />
    public partial class AddDenyAllRLSPolicies : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
DROP POLICY IF EXISTS ""Allow no access"" ON public.""__EFMigrationsHistory"";
CREATE POLICY ""Allow no access"" ON public.""__EFMigrationsHistory"" FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.app_settings;
CREATE POLICY ""Allow no access"" ON public.app_settings FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.audit_logs;
CREATE POLICY ""Allow no access"" ON public.audit_logs FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.business_password_reset_tokens;
CREATE POLICY ""Allow no access"" ON public.business_password_reset_tokens FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.business_user_events;
CREATE POLICY ""Allow no access"" ON public.business_user_events FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.business_users;
CREATE POLICY ""Allow no access"" ON public.business_users FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.email_logs;
CREATE POLICY ""Allow no access"" ON public.email_logs FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.event_tables;
CREATE POLICY ""Allow no access"" ON public.event_tables FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.feedbacks;
CREATE POLICY ""Allow no access"" ON public.feedbacks FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.invitations;
CREATE POLICY ""Allow no access"" ON public.invitations FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.magic_link_tokens;
CREATE POLICY ""Allow no access"" ON public.magic_link_tokens FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.organizations;
CREATE POLICY ""Allow no access"" ON public.organizations FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.platform_images;
CREATE POLICY ""Allow no access"" ON public.platform_images FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.purchase_tables;
CREATE POLICY ""Allow no access"" ON public.purchase_tables FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.stripe_payouts;
CREATE POLICY ""Allow no access"" ON public.stripe_payouts FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.stripe_transfers;
CREATE POLICY ""Allow no access"" ON public.stripe_transfers FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.table_templates;
CREATE POLICY ""Allow no access"" ON public.table_templates FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.tables;
CREATE POLICY ""Allow no access"" ON public.tables FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.user_email_verification_tokens;
CREATE POLICY ""Allow no access"" ON public.user_email_verification_tokens FOR ALL USING (false);

DROP POLICY IF EXISTS ""Allow no access"" ON public.user_password_reset_tokens;
CREATE POLICY ""Allow no access"" ON public.user_password_reset_tokens FOR ALL USING (false);
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
DROP POLICY IF EXISTS ""Allow no access"" ON public.""__EFMigrationsHistory"";
DROP POLICY IF EXISTS ""Allow no access"" ON public.app_settings;
DROP POLICY IF EXISTS ""Allow no access"" ON public.audit_logs;
DROP POLICY IF EXISTS ""Allow no access"" ON public.business_password_reset_tokens;
DROP POLICY IF EXISTS ""Allow no access"" ON public.business_user_events;
DROP POLICY IF EXISTS ""Allow no access"" ON public.business_users;
DROP POLICY IF EXISTS ""Allow no access"" ON public.email_logs;
DROP POLICY IF EXISTS ""Allow no access"" ON public.event_tables;
DROP POLICY IF EXISTS ""Allow no access"" ON public.feedbacks;
DROP POLICY IF EXISTS ""Allow no access"" ON public.invitations;
DROP POLICY IF EXISTS ""Allow no access"" ON public.magic_link_tokens;
DROP POLICY IF EXISTS ""Allow no access"" ON public.organizations;
DROP POLICY IF EXISTS ""Allow no access"" ON public.platform_images;
DROP POLICY IF EXISTS ""Allow no access"" ON public.purchase_tables;
DROP POLICY IF EXISTS ""Allow no access"" ON public.stripe_payouts;
DROP POLICY IF EXISTS ""Allow no access"" ON public.stripe_transfers;
DROP POLICY IF EXISTS ""Allow no access"" ON public.table_templates;
DROP POLICY IF EXISTS ""Allow no access"" ON public.tables;
DROP POLICY IF EXISTS ""Allow no access"" ON public.user_email_verification_tokens;
DROP POLICY IF EXISTS ""Allow no access"" ON public.user_password_reset_tokens;
");
        }
    }
}
