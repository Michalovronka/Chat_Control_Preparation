namespace CCP.Data
{
    public class MessageRepository : IMessageRepository
    {

        public MessageEntity GetById(Guid id)
        {
            throw new NotImplementedException();
        }

        public MessageEntity[] GetAll()
        {
            throw new NotImplementedException();
        }

        public MessageEntity Add(MessageEntity entity)
        {
            throw new NotImplementedException();
        }

        public MessageEntity Update(MessageEntity entity)
        {
            throw new NotImplementedException();
        }

        public MessageEntity Remove(Guid id)
        {
            throw new NotImplementedException();
        }
        
        public MessageEntity[] GetMessagesByRoom(Guid roomId)
        {
            throw new NotImplementedException();
        }
    }
}