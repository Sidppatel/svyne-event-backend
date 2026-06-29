namespace Db.Entities;

public class Tenant : BaseEntity
{
    public required string Slug { get; set; }
    public required string Name { get; set; }
    public string? LegalName { get; set; }
    public string CountryCode { get; set; } = "US";
    public string? StripeConnectedAccountId { get; set; }
    public bool StripeChargesEnabled { get; set; }
    public bool StripePayoutsEnabled { get; set; }
    public bool StripeDetailsSubmitted { get; set; }
    public DateTime? StripeOnboardedAt { get; set; }
    public string? StripeRequirementsDue { get; set; }

    public string? Phone { get; set; }
    public string? AddressLine1 { get; set; }
    public string? AddressLine2 { get; set; }
    public string? City { get; set; }
    public string? State { get; set; }
    public string? Zip { get; set; }

    public Guid? LogoImagesId { get; set; }
    public string? BrandPrimary { get; set; }
    public string? BrandSecondary { get; set; }
    public string? BrandAccent { get; set; }

    public DateTime? ArchivedAt { get; set; }

    /// <summary>
    /// Tenant-level default fee formula auto-applied to every price unless a price
    /// overrides it. Settable only by developers (role 99).
    /// </summary>
    public Guid? DefaultFeeFormulasId { get; set; }
    public FeeFormula? DefaultFeeFormula { get; set; }
}
