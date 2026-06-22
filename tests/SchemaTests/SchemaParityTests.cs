using Db;
using Microsoft.EntityFrameworkCore;
using Testcontainers.PostgreSql;

namespace EventPlatform.SchemaTests;

public class SchemaParityTests : IAsyncLifetime
{
    private PostgreSqlContainer _pg = null!;

    public async ValueTask InitializeAsync()
    {
        _pg = new PostgreSqlBuilder("postgres:16")
            .WithDatabase("ep")
            .WithUsername("ep")
            .WithPassword("ep")
            .Build();

        await _pg.StartAsync(TestContext.Current.CancellationToken);
    }

    public async ValueTask DisposeAsync()
    {
        await _pg.DisposeAsync();
    }

    [Fact]
    public async Task Migrations_apply_cleanly_against_ephemeral_postgres()
    {
        var ct = TestContext.Current.CancellationToken;
        var opts = new DbContextOptionsBuilder<EventPlatformDbContext>()
            .UseNpgsql(_pg.GetConnectionString())
            .Options;

        await using var ctx = new EventPlatformDbContext(opts);

        // Create the authenticated role and auth schema/functions required by Supabase RLS policies
        await ctx.Database.ExecuteSqlRawAsync(@"
            CREATE SCHEMA IF NOT EXISTS auth;
            CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS 'SELECT null::uuid';
            
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
                    CREATE ROLE authenticated;
                END IF;
            END
            $$;
        ", ct);

        await ctx.Database.MigrateAsync(ct);

        var pending = await ctx.Database.GetPendingMigrationsAsync(ct);
        Assert.Empty(pending);

        var applied = await ctx.Database.GetAppliedMigrationsAsync(ct);
        Assert.NotEmpty(applied);
    }
}
