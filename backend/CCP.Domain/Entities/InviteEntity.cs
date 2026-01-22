namespace CCP.Domain.Entities;

public class InviteEntity : BaseEntity
{
    public Guid SenderUserId { get; set; }
    public Guid ReceiverUserId { get; set; }
    public Guid RoomId { get; set; }
    public DateTime SentTime { get; set; }
    public bool IsDelivered { get; set; }
}
