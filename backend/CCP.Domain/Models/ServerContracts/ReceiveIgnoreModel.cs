namespace CCP.Domain.Models.ServerContracts;

public record ReceiveIgnoreModel(Guid SenderUserId, Guid MutedUserId) : ReceiveContractModel;