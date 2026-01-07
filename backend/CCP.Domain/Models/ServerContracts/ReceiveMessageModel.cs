namespace CCP.Domain.Models.ServerContracts;

public record ReceiveMessageModel(Guid UserId, string Content, string IsImage, Guid RoomId) : ReceiveContractModel;