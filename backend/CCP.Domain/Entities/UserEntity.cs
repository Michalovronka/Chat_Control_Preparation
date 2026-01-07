namespace CCP.Domain.Entities;

public record UserEntity(
    Guid Id, 
    string UserName, 
    DateTime LastTimeSeen, 
    string StatusMessage, 
    string[] HistoryOfUsernames, 
    Guid[] IgnoreList, 
    UserStatus UserState, 
    Guid? CurrentRoomId, 
    string ConnectionId
    ) : BaseEntity(Id);