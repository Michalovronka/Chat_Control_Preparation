namespace CCP.Domain.Models.ServerContracts;

public record ReceiveLeaveModel(Guid UserId, Guid RoomId) : ReceiveContractModel;