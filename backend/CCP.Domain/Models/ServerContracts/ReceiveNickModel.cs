namespace CCP.Domain.Models.ServerContracts;

public record ReceiveNickModel(Guid UserId, string Nick) : ReceiveContractModel;