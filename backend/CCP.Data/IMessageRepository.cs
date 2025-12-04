namespace CCP.Data;

public record MessageEntity(Guid Id, string Content, bool isImage, Guid SenderId, Guid RoomId, DateTime SentAt) : BaseEntity(Id);

public interface IMessageRepository : IRepository<MessageEntity>
{
    MessageEntity[] GetMessagesByRoom(Guid roomId);
}