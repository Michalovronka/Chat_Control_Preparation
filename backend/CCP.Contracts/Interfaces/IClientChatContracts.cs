using CCP.Domain.Models;

namespace CCP.Contracts.Interfaces;

public interface IClientChatContracts
{
    void SendMessage(SendMessageModel model);
    
    void SendJoin(SendJoinModel model);
}