
using CCP.Domain.Models.ClientContracts;

namespace CCP.Contracts.Interfaces;

public interface IClientChatContracts
{
    void SendMessage(SendMessageModel model);
    
    void SendJoin(SendJoinModel model);
}