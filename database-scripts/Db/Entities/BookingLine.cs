using Db.Enums;

namespace Db.Entities;

/// <summary>
/// One line of a booking: a ticket tier (with seats) or a table.
/// Each line carries an IMMUTABLE pricing snapshot captured at reserve time.
/// Also stores ticket code, QR token, and guest assignments directly for unified booking items.
/// </summary>
public class BookingLine : BaseEntity
{
    public Guid TenantsId { get; set; }
    public Tenant Tenant { get; set; } = null!;

    public Guid BookingsId { get; set; }
    public Booking Booking { get; set; } = null!;

    public Guid? EventsId { get; set; }
    public Event? Event { get; set; }

    /// <summary>"Ticket" | "Table".</summary>
    public required string Kind { get; set; }

    public Guid? EventTicketTypesId { get; set; }
    public EventTicketType? EventTicketType { get; set; }

    public Guid? TablesId { get; set; }
    public Table? Table { get; set; }

    /// <summary>Linked Pricing Module price snapshot used at reserve time.</summary>
    public Guid? PricesId { get; set; }
    public Price? Price { get; set; }

    /// <summary>Seats this line reserves. Typically 1 in the new redesign.</summary>
    public int Seats { get; set; } = 1;

    // ── Ticket / Table specific properties (merged from Ticket entity) ──────────
    public string? TicketCode { get; set; }
    public string? QrToken { get; set; }
    public int? SeatNumber { get; set; }
    public TicketStatus Status { get; set; } = TicketStatus.Unassigned;

    public Guid? GuestUsersId { get; set; }
    public User? GuestUser { get; set; }

    public string? InviteTokenHash { get; set; }
    public DateTime? InviteExpiresAt { get; set; }
    public string? InvitedEmail { get; set; }
    public DateTime? InviteSentAt { get; set; }
    public DateTime? ClaimedAt { get; set; }

    // ── Immutable pricing snapshot (captured at reserve time) ──────────────────

    /// <summary>Original configured price for this line before any rule.</summary>
    public int BasePriceCents { get; set; }

    /// <summary>Price after the applied rule. The amount the organizer earns.</summary>
    public int SellingPriceCents { get; set; }

    /// <summary>BasePriceCents - SellingPriceCents (>= 0).</summary>
    public int DiscountCents { get; set; }

    /// <summary>The price rule applied at reserve time; null when none was active.</summary>
    public Guid? AppliedPriceRulesId { get; set; }

    /// <summary>Snapshot of the applied rule's name (rule may change/delete later).</summary>
    public string? AppliedRuleName { get; set; }

    public int PlatformFeeCents { get; set; }
    public int GatewayFeeCents { get; set; }

    /// <summary>What the customer pays for this line: selling + platform + gateway.</summary>
    public int FinalPriceCents { get; set; }

    /// <summary>ISO currency snapshot (e.g. "usd").</summary>
    public string Currency { get; set; } = "usd";

    // ── Aggregate mirrors kept for the total = subtotal + fee invariant ─────────
    // subtotal = selling, fee = platform + gateway, total = final.
    public int SubtotalCents { get; set; }
    public int FeeCents { get; set; }
    public int TotalCents { get; set; }
}
