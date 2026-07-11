namespace Db.Entities;

public class BookingTax : BaseEntity
{
    public Guid TenantsId { get; set; }
    public Tenant Tenant { get; set; } = null!;

    public Guid BookingsId { get; set; }
    public Booking Booking { get; set; } = null!;

    public string ZipCode { get; set; } = string.Empty;
    public string? State { get; set; }
    public string? County { get; set; }
    public string? City { get; set; }

    public decimal CombinedRate { get; set; }
    public decimal StateRate { get; set; }
    public decimal CountyRate { get; set; }
    public decimal CityRate { get; set; }
    public decimal LocalRate { get; set; }

    public int TaxableAmountCents { get; set; }
    public int TaxAmountCents { get; set; }

    public string CollectedBy { get; set; } = "platform";

    public string? ApiResponseId { get; set; }
    public DateTime CalculatedAt { get; set; } = DateTime.UtcNow;
}
