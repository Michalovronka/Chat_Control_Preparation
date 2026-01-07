namespace CCP.Domain.Models.ServerContracts;

public record ReceiveInviteModel(Guid SenderUserId, Guid ReceiverUserId, Guid CurrentRoomId) : ReceiveContractModel;
