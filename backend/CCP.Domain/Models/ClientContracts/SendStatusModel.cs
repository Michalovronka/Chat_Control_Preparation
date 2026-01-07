namespace CCP.Domain.Models.ClientContracts;

public record SendStatusModel(Guid UserId, string Status) : SendContractModel;