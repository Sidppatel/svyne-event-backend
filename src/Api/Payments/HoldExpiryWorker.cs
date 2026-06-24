using Svyne.Api.Data;

namespace Svyne.Api.Payments;

/// <summary>
/// Sweeps expired seat/table holds back to availability on a fixed interval by
/// calling sp_expire_holds(). Keeps the 10-minute (configurable) hard hold
/// honest even when buyers abandon the payment screen.
/// </summary>
public sealed class HoldExpiryWorker : BackgroundService
{
    private static readonly TimeSpan Interval = TimeSpan.FromSeconds(60);
    private readonly Db db;
    private readonly ILogger<HoldExpiryWorker> logger;

    public HoldExpiryWorker(Db db, ILogger<HoldExpiryWorker> logger)
    {
        this.db = db;
        this.logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(Interval);
        try
        {
            do
            {
                try
                {
                    await using var connection = await db.OpenAsync(null, null, stoppingToken);
                    await using var cmd = new Npgsql.NpgsqlCommand("SELECT sp_expire_holds()", connection);
                    var expired = (int)(await cmd.ExecuteScalarAsync(stoppingToken) ?? 0);
                    if (expired > 0)
                    {
                        logger.LogInformation("Expired {Count} stale booking hold(s)", expired);
                    }
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    logger.LogError(ex, "Hold expiry sweep failed");
                }
            }
            while (await timer.WaitForNextTickAsync(stoppingToken));
        }
        catch (OperationCanceledException)
        {
            // Host shutting down — expected.
        }
    }
}
