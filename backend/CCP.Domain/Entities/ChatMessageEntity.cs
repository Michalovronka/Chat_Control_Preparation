namespace CCP.Domain.Entities;

public record ChatMessageEntity(Guid Id, Guid UserId, Guid ChannelId, string Content, bool IsImage, DateTime SentTime)
    : BaseEntity(Id);