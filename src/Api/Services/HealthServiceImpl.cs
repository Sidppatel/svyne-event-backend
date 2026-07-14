using Grpc.Core;
using Npgsql;
using EntryVine.Api.Data;
using EntryVine.Protos.Admin;
using EntryVine.Protos.Common;

namespace EntryVine.Api.Services;

public sealed class HealthServiceImpl : HealthService.HealthServiceBase
{
    private readonly Db db;

    public HealthServiceImpl(Db db)
    {
        this.db = db;
    }

    public override async Task<HealthStatus> Check(Empty request, ServerCallContext context)
    {
        var ct = context.CancellationToken;
        var dbOk = false;
        try
        {
            await using var connection = await db.OpenAsync(null, null, ct);
            await using var cmd = new NpgsqlCommand("SELECT 1", connection);
            await cmd.ExecuteScalarAsync(ct);
            dbOk = true;
        }
        catch (NpgsqlException)
        {
            dbOk = false;
        }
        return new HealthStatus { Status = dbOk ? "healthy" : "degraded", Database = dbOk, Redis = false };
    }
}
