using System;

namespace Db.Entities;

public class CheckInLog : BaseEntity
{
    public Guid EventId { get; set; }
    public Event Event { get; set; } = null!;

    public Guid StaffUserId { get; set; }
    public User StaffUser { get; set; } = null!;

    public Guid? BookingId { get; set; }
    public Booking? Booking { get; set; }

    public Guid? TicketId { get; set; }
    public BookingLine? Ticket { get; set; }

    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    public string Method { get; set; } = "qr_scan";

    public string Status { get; set; } = "success";

    public string? FailureReason { get; set; }
}
