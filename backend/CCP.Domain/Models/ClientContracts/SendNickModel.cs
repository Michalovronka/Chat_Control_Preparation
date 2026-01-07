namespace CCP.Domain.Models.ClientContracts;

public record SendNickModel(Guid UserId, string Nick) : SendContractModel;