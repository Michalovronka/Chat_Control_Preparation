namespace CCP.Domain.Entities;

public record MessageEntity(
    Guid Id, 
    Guid UserId, 
    Guid RoomId, 
    string Content, 
    bool IsImage, 
    DateTime SentTime
    ) : BaseEntity(Id);