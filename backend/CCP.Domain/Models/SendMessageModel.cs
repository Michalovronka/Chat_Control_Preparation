namespace CCP.Domain.Models;

public record SendMessageModel(Guid UserId, string Content, string IsImage, Guid RoomId) : SendContractModel;