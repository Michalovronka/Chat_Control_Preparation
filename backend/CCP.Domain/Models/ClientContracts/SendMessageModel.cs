namespace CCP.Domain.Models.ClientContracts;

public record SendMessageModel(Guid RoomId, Guid UserId, string Content, string IsImage, DateTime SentTime) : SendContractModel;