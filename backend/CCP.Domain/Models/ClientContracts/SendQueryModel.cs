namespace CCP.Domain.Models.ClientContracts;

public record SendQueryModel(Guid SenderUserId, Guid ReceiverUserId, Guid RoomId) : SendContractModel;