namespace CCP.Domain.Entities;

public class MessageEntity : BaseEntity
{
    public Guid Id { get; set; }
    public bool IsImage { get; set; }
    public string Content { get; set; }
    public Guid UserId { get; set; }
    public Guid RoomId { get; set; }
    public DateTime SentTime { get; set; }
}




// public record MessageEntity(
//     Guid Id, 
//     Guid UserId, 
//     Guid RoomId, 
//     string Content, 
//     bool IsImage, 
//     DateTime SentTime
//     ) : BaseEntity(Id);