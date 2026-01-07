namespace CCP.Domain.Models.ServerContracts;

public record ReceiveJoinModel(Guid UserId, Guid RoomId, string Password) : ReceiveContractModel;