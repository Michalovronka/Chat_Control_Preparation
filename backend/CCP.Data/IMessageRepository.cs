using CCP.Domain.Entities;

namespace CCP.Data;


public interface IMessageRepository : IRepository<MessageEntity>
{
    MessageEntity[] GetMessagesByRoom(Guid roomId);
}