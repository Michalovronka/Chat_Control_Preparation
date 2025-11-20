namespace CCP.Contracts;

public interface IChatRMessages
{
    void SendChatMessage(Message message);
    void RegisterChatMessage(Action callBackFc);
    void SendEditMessage(Message message);
    void RegisterEditMessage(Action callBackFc);
    void SendDeleteMessage(Message message);
    void RegisterDeleteMessage(Action callBackFc);
 
    public class Message()
    {
        private Guid _user;
        private string _message;
        private Guid _messageid;
        private DateTime _dateCreated;
    }


}