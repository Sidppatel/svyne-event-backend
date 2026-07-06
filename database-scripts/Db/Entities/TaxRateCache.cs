namespace Db.Entities;

public class TaxRateCache
{
    public required string ZipCode { get; set; }
    public string? State { get; set; }
    public string? County { get; set; }
    public string? City { get; set; }
    public decimal StateRate { get; set; }
    public decimal CountyRate { get; set; }
    public decimal CityRate { get; set; }
    public decimal LocalRate { get; set; }
    public decimal CombinedRate { get; set; }
    public string? ApiResponseId { get; set; }
    public DateTime FetchedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
