namespace Db.Entities;

// Stripe Connect onboarding business profile, kept in its own table.
// 1:1 with a tenant (PK == FK tenants_id). Developer-owned: only a developer
// may write it (enforced by RLS WITH CHECK); the tenant admin may read it.
public class TenantStripeProfile
{
    public Guid TenantsId { get; set; }
    public Tenant? Tenant { get; set; }

    public string? BusinessType { get; set; }        // "individual" | "company"
    public string? BusinessUrl { get; set; }
    public string? ProductDescription { get; set; }
    public string? Mcc { get; set; }                 // 4-digit Stripe merchant category code
    public string? SupportEmail { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
