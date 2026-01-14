namespace CCP.Domain.Models.ClientContracts;

public record SendKickModel(Guid KickerUserId, Guid KickedUserId, Guid RoomId) : SendContractModel;
