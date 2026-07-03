using Svyne.Api.Data;
using Svyne.Api.ErrorHandling;

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
    private readonly ErrorLogger errorLogger;

    public HoldExpiryWorker(Db db, ILogger<HoldExpiryWorker> logger, ErrorLogger errorLogger)
    {
        this.db = db;
        this.logger = logger;
        this.errorLogger = errorLogger;
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
                    await errorLogger.LogErrorAsync(
                        ErrorSeverity.Medium,
                        "HoldExpirySweepFailure",
                        "Hold expiry sweep failed",
                        ex,
                        new ErrorContext { RequestPath = "background:HoldExpiryWorker" },
                        CancellationToken.None);
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
