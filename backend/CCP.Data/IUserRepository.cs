namespace CCP.Data;

public record UserEntity (Guid Id, string Name, DateTime LastTimeSeen, string[] HistoryOfUsernames, string Activity,
    Guid[] IgnoreList ) : BaseEntity(Id);
public interface IUserRepository
{
    UserEntity GetByUsername(string username);
    UserEntity[] GetUsersInRoom(Guid roomId);
}