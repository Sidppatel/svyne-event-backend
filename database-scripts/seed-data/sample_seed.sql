-- Tenant
INSERT INTO tenants (tenants_id, slug, name, created_at, updated_at)
VALUES (
    '11111111-1111-1111-1111-111111111111', 
    'acme-events', 
    'Acme Events',
    now(),
    now()
) ON CONFLICT (tenants_id) DO NOTHING;

-- Users (1 Developer, 1 Admin, 1 Customer)
-- Role 0 Attendee, 1 Admin, 2 Staff, 3 Sub-Tenant, 99 Developer
INSERT INTO users (users_id, tenants_id, email, email_hash, first_name, last_name, role, is_active, created_at, updated_at)
VALUES 
(
    '22222222-2222-2222-2222-222222222220',
    NULL,
    'developer@svyne.test',
    'fc992d397d78fddc23fb8280688c0e40ce91181d5d36479c39be7e8b00fdfaa1',
    'Dev',
    'Eloper',
    99,
    true,
    now(),
    now()
),
(
    '22222222-2222-2222-2222-222222222221',
    '11111111-1111-1111-1111-111111111111',
    'admin@acme.test',
    '0dd364e23ccba164dfd2c07a013d61e0b42af553e1ef10f682a5186fa3717e30',
    'Admin',
    'User',
    1,
    true,
    now(),
    now()
),
(
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'customer@acme.test',
    '77ab746f1fa822949115fec397c6b3b03f26781574b6955163aec19926771659',
    'Customer',
    'User',
    0,
    true,
    now(),
    now()
) ON CONFLICT (users_id) DO NOTHING;

-- Passwords for all seeded users: "Password123!"
-- Hash = BCrypt.EnhancedHashPassword(HMACSHA256(pepper_v1, password), 12), pepper_version=1
UPDATE users SET password_hash = '$2a$12$u.Lwn6CQuSH.fwm/dS4H8u0n.Qgzn4Uu3x3kuOKvXEV43Fw31tQ6e', pepper_version = 1
WHERE users_id IN (
    '22222222-2222-2222-2222-222222222220',
    '22222222-2222-2222-2222-222222222221',
    '22222222-2222-2222-2222-222222222222'
);

-- Venue
INSERT INTO venues (venues_id, tenants_id, name, description, is_active, created_at, updated_at)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    '11111111-1111-1111-1111-111111111111',
    'Grand Arena',
    'The best place for events.',
    true,
    now(),
    now()
) ON CONFLICT (venues_id) DO NOTHING;

-- Performers
INSERT INTO performers (performers_id, tenants_id, name, slug, created_at, updated_at)
VALUES 
(
    '55555555-5555-5555-5555-555555555551',
    '11111111-1111-1111-1111-111111111111',
    'The Rockers',
    'the-rockers',
    now(),
    now()
),
(
    '55555555-5555-5555-5555-555555555552',
    '11111111-1111-1111-1111-111111111111',
    'DJ Svyne',
    'dj-svyne',
    now(),
    now()
) ON CONFLICT (performers_id) DO NOTHING;

-- Sponsors
INSERT INTO sponsors (sponsors_id, tenants_id, name, slug, created_at, updated_at)
VALUES 
(
    '66666666-6666-6666-6666-666666666661',
    '11111111-1111-1111-1111-111111111111',
    'RedBull',
    'redbull',
    now(),
    now()
) ON CONFLICT (sponsors_id) DO NOTHING;

-- Event
INSERT INTO events (events_id, tenants_id, venues_id, title, slug, description, status, category, layout_mode, start_date, end_date, created_by_users_id, is_featured, published_at, created_at, updated_at)
VALUES (
    '44444444-4444-4444-4444-444444444444',
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    'Summer Music Festival 2026',
    'summer-music-festival-2026',
    'A fantastic music festival to test the svyne platform.',
    'Published',
    'Music',
    'Open',
    now() + interval '10 days',
    now() + interval '12 days',
    '22222222-2222-2222-2222-222222222221',
    false,
    now(),
    now(),
    now()
) ON CONFLICT (events_id) DO NOTHING;

-- Event Performers
INSERT INTO event_performers (events_id, performers_id, tenants_id, sort_order)
VALUES 
('44444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555551', '11111111-1111-1111-1111-111111111111', 1),
('44444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555552', '11111111-1111-1111-1111-111111111111', 2)
ON CONFLICT (events_id, performers_id) DO NOTHING;

-- Event Sponsors
INSERT INTO event_sponsors (events_id, sponsors_id, tenants_id, sort_order)
VALUES 
('44444444-4444-4444-4444-444444444444', '66666666-6666-6666-6666-666666666661', '11111111-1111-1111-1111-111111111111', 1)
ON CONFLICT (events_id, sponsors_id) DO NOTHING;

-- Event Ticket Types
INSERT INTO event_ticket_types (event_ticket_types_id, tenants_id, events_id, label, price_cents, max_quantity, sort_order, is_active, created_at, updated_at)
VALUES 
(
    '77777777-7777-7777-7777-777777777771',
    '11111111-1111-1111-1111-111111111111',
    '44444444-4444-4444-4444-444444444444',
    'General Admission',
    5000,
    500,
    1,
    true,
    now(),
    now()
),
(
    '77777777-7777-7777-7777-777777777772',
    '11111111-1111-1111-1111-111111111111',
    '44444444-4444-4444-4444-444444444444',
    'VIP Pass',
    15000,
    100,
    2,
    true,
    now(),
    now()
) ON CONFLICT (event_ticket_types_id) DO NOTHING;

-- Event Tables
INSERT INTO event_tables (event_tables_id, tenants_id, events_id, label, shape, capacity, price_cents, is_active, created_at, updated_at)
VALUES 
(
    '88888888-8888-8888-8888-888888888881',
    '11111111-1111-1111-1111-111111111111',
    '44444444-4444-4444-4444-444444444444',
    'Table 1',
    'Round',
    8,
    20000,
    true,
    now(),
    now()
) ON CONFLICT (event_tables_id) DO NOTHING;

-- Tables (Physical tables instances)
INSERT INTO tables (tables_id, tenants_id, event_tables_id, events_id, label, status, grid_row, grid_col, row_span, col_span, is_active, sort_order, created_at, updated_at)
VALUES
(
    '99999999-9999-9999-9999-999999999991',
    '11111111-1111-1111-1111-111111111111',
    '88888888-8888-8888-8888-888888888881',
    '44444444-4444-4444-4444-444444444444',
    'T1',
    'Available',
    1,
    1,
    1,
    1,
    true,
    0,
    now(),
    now()
) ON CONFLICT (tables_id) DO NOTHING;

-- Purchase
INSERT INTO purchases (purchases_id, tenants_id, users_id, events_id, event_ticket_types_id, purchase_number, status, subtotal_cents, fee_cents, total_cents, created_at, updated_at)
VALUES 
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444',
    '77777777-7777-7777-7777-777777777771',
    'PUR-0001',
    'Paid',
    5000,
    500,
    5500,
    now(),
    now()
) ON CONFLICT (purchases_id) DO NOTHING;

-- Purchase Ticket
INSERT INTO purchase_tickets (purchase_tickets_id, tenants_id, purchases_id, ticket_code, qr_token, status, seat_number, created_at, updated_at)
VALUES 
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'TKT-0001',
    'qr-0001',
    'Claimed',
    1,
    now(),
    now()
) ON CONFLICT (purchase_tickets_id) DO NOTHING;
