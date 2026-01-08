using CCP.Domain.Entities;

namespace CCP.Data;

public interface IMessageRepository : IRepository<MessageEntity>
{
    IEnumerable<MessageEntity> GetByRoomId(Guid roomId);
    IEnumerable<MessageEntity> GetMessagesByRoom(Guid roomId);
    IEnumerable<Guid> GetRoomIdsByUser(Guid userId);
}