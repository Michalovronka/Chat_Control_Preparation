namespace CCP.Domain.Models.ClientContracts;

public record SendBlockModel(Guid UserId, Guid BlockedUserId, bool IsBlock) : SendContractModel;
