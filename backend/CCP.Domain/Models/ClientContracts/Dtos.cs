namespace CCP.Domain.Models.ClientContracts;

public record UserInfoDto(string UserName, string StatusMessage, string UserState);

public record MessageDto(Guid RoomId, Guid UserId, string Content, DateTime SentTime);

public record RoomDto(Guid RoomId, string RoomName);
