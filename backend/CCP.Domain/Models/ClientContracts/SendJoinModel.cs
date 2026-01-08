namespace CCP.Domain.Models.ClientContracts;

public record SendJoinModel(Guid UserId, Guid RoomId, string? Message = null) : SendContractModel;