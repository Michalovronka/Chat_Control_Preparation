using CCP.Domain.Entities;

namespace CCP.Data;


public interface IMessageRepository : IRepository<MessageEntity>
{
    public interface IMessageRepository
    {
        void Add(MessageEntity message);

        MessageEntity? GetById(Guid id);
        IEnumerable<MessageEntity> GetByRoomId(Guid roomId);

        void Delete(Guid id);
    }
}