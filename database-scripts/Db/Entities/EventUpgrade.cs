namespace Db.Entities;

public class EventUpgrade : BaseEntity
{
    public Guid EventsId { get; set; }
    public Event Event { get; set; } = null!;

    public Guid TenantsId { get; set; }
    public Tenant Tenant { get; set; } = null!;

    public required string Tier { get; set; }

    public string Status { get; set; } = "active";

    public int PriceCents { get; set; }
    public int SmsCredits { get; set; }
    public int CustomDomainLimit { get; set; }

    public DateTime? CanceledAt { get; set; }
    public int RefundedCents { get; set; }

    public string? StripePaymentIntentId { get; set; }
}
