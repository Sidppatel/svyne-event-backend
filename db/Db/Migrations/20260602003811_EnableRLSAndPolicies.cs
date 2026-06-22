using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace db.Migrations
{
    /// <inheritdoc />
    public partial class EnableRLSAndPolicies : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
-- 1. ENABLE ROW LEVEL SECURITY ON ALL TABLES
ALTER TABLE public.""__EFMigrationsHistory"" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_password_reset_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_user_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_performers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_ticket_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magic_link_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.table_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_email_verification_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_password_reset_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venue_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;

-- 2. DROP EXISTING POLICIES TO AVOID DUPLICATES (to make migration idempotent)
DROP POLICY IF EXISTS ""Allow public read events"" ON public.events;
DROP POLICY IF EXISTS ""Allow public read event ticket types"" ON public.event_ticket_types;
DROP POLICY IF EXISTS ""Allow public read sponsors"" ON public.sponsors;
DROP POLICY IF EXISTS ""Allow public read performers"" ON public.performers;
DROP POLICY IF EXISTS ""Allow public read event sponsors"" ON public.event_sponsors;
DROP POLICY IF EXISTS ""Allow public read event performers"" ON public.event_performers;
DROP POLICY IF EXISTS ""Allow public read event images"" ON public.event_images;
DROP POLICY IF EXISTS ""Allow public read venues"" ON public.venues;
DROP POLICY IF EXISTS ""Allow public read venue images"" ON public.venue_images;
DROP POLICY IF EXISTS ""Allow public read images"" ON public.images;

DROP POLICY IF EXISTS ""Allow users select own row"" ON public.users;
DROP POLICY IF EXISTS ""Allow users update own row"" ON public.users;
DROP POLICY IF EXISTS ""Allow users select own purchases"" ON public.purchases;
DROP POLICY IF EXISTS ""Allow users select own tickets"" ON public.purchase_tickets;
DROP POLICY IF EXISTS ""Allow users select own stripe transactions"" ON public.stripe_transactions;
DROP POLICY IF EXISTS ""Allow users select own address"" ON public.addresses;
DROP POLICY IF EXISTS ""Allow users update own address"" ON public.addresses;
DROP POLICY IF EXISTS ""Allow users select own device sessions"" ON public.device_sessions;

-- 3. CREATE PUBLIC READ POLICIES
CREATE POLICY ""Allow public read events"" ON public.events FOR SELECT USING (true);
CREATE POLICY ""Allow public read event ticket types"" ON public.event_ticket_types FOR SELECT USING (true);
CREATE POLICY ""Allow public read sponsors"" ON public.sponsors FOR SELECT USING (true);
CREATE POLICY ""Allow public read performers"" ON public.performers FOR SELECT USING (true);
CREATE POLICY ""Allow public read event sponsors"" ON public.event_sponsors FOR SELECT USING (true);
CREATE POLICY ""Allow public read event performers"" ON public.event_performers FOR SELECT USING (true);
CREATE POLICY ""Allow public read event images"" ON public.event_images FOR SELECT USING (true);
CREATE POLICY ""Allow public read venues"" ON public.venues FOR SELECT USING (true);
CREATE POLICY ""Allow public read venue images"" ON public.venue_images FOR SELECT USING (true);
CREATE POLICY ""Allow public read images"" ON public.images FOR SELECT USING (true);

-- 3. CREATE USER DATA ISOLATION POLICIES
CREATE POLICY ""Allow users select own row"" ON public.users
    FOR SELECT TO authenticated USING (""Id"" = auth.uid());

CREATE POLICY ""Allow users update own row"" ON public.users
    FOR UPDATE TO authenticated USING (""Id"" = auth.uid()) WITH CHECK (""Id"" = auth.uid());

CREATE POLICY ""Allow users select own purchases"" ON public.purchases
    FOR SELECT TO authenticated USING (""UserId"" = auth.uid());

CREATE POLICY ""Allow users select own tickets"" ON public.purchase_tickets
    FOR SELECT TO authenticated USING (
        ""PurchaseId"" IN (SELECT ""Id"" FROM public.purchases WHERE ""UserId"" = auth.uid())
    );

CREATE POLICY ""Allow users select own stripe transactions"" ON public.stripe_transactions
    FOR SELECT TO authenticated USING (
        ""PurchaseId"" IN (SELECT ""Id"" FROM public.purchases WHERE ""UserId"" = auth.uid())
    );

CREATE POLICY ""Allow users select own address"" ON public.addresses
    FOR SELECT TO authenticated USING (
        ""Id"" IN (SELECT ""AddressId"" FROM public.users WHERE ""Id"" = auth.uid())
    );

CREATE POLICY ""Allow users update own address"" ON public.addresses
    FOR UPDATE TO authenticated USING (
        ""Id"" IN (SELECT ""AddressId"" FROM public.users WHERE ""Id"" = auth.uid())
    ) WITH CHECK (
        ""Id"" IN (SELECT ""AddressId"" FROM public.users WHERE ""Id"" = auth.uid())
    );

CREATE POLICY ""Allow users select own device sessions"" ON public.device_sessions
    FOR SELECT TO authenticated USING (""UserId"" = auth.uid());
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
-- 1. DROP POLICIES
DROP POLICY IF EXISTS ""Allow public read events"" ON public.events;
DROP POLICY IF EXISTS ""Allow public read event ticket types"" ON public.event_ticket_types;
DROP POLICY IF EXISTS ""Allow public read sponsors"" ON public.sponsors;
DROP POLICY IF EXISTS ""Allow public read performers"" ON public.performers;
DROP POLICY IF EXISTS ""Allow public read event sponsors"" ON public.event_sponsors;
DROP POLICY IF EXISTS ""Allow public read event performers"" ON public.event_performers;
DROP POLICY IF EXISTS ""Allow public read event images"" ON public.event_images;
DROP POLICY IF EXISTS ""Allow public read venues"" ON public.venues;
DROP POLICY IF EXISTS ""Allow public read venue images"" ON public.venue_images;
DROP POLICY IF EXISTS ""Allow public read images"" ON public.images;

DROP POLICY IF EXISTS ""Allow users select own row"" ON public.users;
DROP POLICY IF EXISTS ""Allow users update own row"" ON public.users;
DROP POLICY IF EXISTS ""Allow users select own purchases"" ON public.purchases;
DROP POLICY IF EXISTS ""Allow users select own tickets"" ON public.purchase_tickets;
DROP POLICY IF EXISTS ""Allow users select own stripe transactions"" ON public.stripe_transactions;
DROP POLICY IF EXISTS ""Allow users select own address"" ON public.addresses;
DROP POLICY IF EXISTS ""Allow users update own address"" ON public.addresses;
DROP POLICY IF EXISTS ""Allow users select own device sessions"" ON public.device_sessions;

-- 2. DISABLE RLS ON ALL TABLES
ALTER TABLE public.""__EFMigrationsHistory"" DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_password_reset_tokens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_user_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_performers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_sponsors DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_tables DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_ticket_types DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.events DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.images DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.magic_link_tokens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.performers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_tables DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_tickets DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchases DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.sponsors DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_payouts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_transfers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.table_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tables DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_email_verification_tokens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_password_reset_tokens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.venue_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.venues DISABLE ROW LEVEL SECURITY;
");
        }
    }
}
