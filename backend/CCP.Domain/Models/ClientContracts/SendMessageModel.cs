namespace CCP.Domain.Models.ClientContracts;

public record SendMessageModel(Guid RoomId, Guid UserId, string Content, DateTime SentTime) : SendContractModel;