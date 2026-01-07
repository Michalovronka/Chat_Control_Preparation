using CCP.Domain.Models.ClientContracts;

namespace CCP.Contracts.Interfaces;

public interface IChatContracts
{
    void RegisterSendMessage(Action<SendContractModel> func);
    
    void RegisterSendJoin(Action<SendContractModel> func);
}