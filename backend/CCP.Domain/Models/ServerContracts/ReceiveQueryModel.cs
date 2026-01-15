namespace CCP.Domain.Models.ServerContracts;

public record ReceiveQueryModel(Guid SenderUserId, Guid ReceiverUserId, Guid RoomId) : ReceiveContractModel;