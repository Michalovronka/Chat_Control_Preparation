namespace CCP.Domain.Entities;

public record UserEntity(Guid Id, string UserName, DateTime LastTimeOnline, string Activity, string[] HistoryOfUsernames, Guid[] IgnoreList, UserStatus UserState) : BaseEntity(Id);