namespace CCP.Domain.Entities;

public class UserEntity : BaseEntity
{
    public Guid Id { get; set; }

    public string UserName { get; set; } = null!;
    public string? PasswordHash { get; set; }
    public DateTime LastTimeSeen { get; set; }
    public string? StatusMessage { get; set; }

    private Guid[] IgnoreList { get; set; }
    public string UserState { get; set; } = null!;
    public Guid? CurrentRoomId { get; set; }
    public string? ConnectionId { get; set; }
    public List<Guid> JoinedRooms { get; set; } = new List<Guid>(); // List of room IDs user has joined
    public List<Guid> BlockedUsers { get; set; } = new List<Guid>(); // List of user IDs that this user has blocked
}

// public record UserEntity(
//     Guid Id, 
//     string UserName, 
//     DateTime LastTimeSeen, 
//     string StatusMessage, 
//     Guid[] IgnoreList, 
//     UserStatus UserState, 
//     Guid? CurrentRoomId, 
//     string ConnectionId
//     ) : BaseEntity(Id)
