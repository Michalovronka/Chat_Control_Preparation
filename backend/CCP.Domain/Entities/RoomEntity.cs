namespace CCP.Domain.Entities;

public class RoomEntity : BaseEntity
{
    public Guid? Id  { get; set; }
    public string RoomName { get; set; }
    public string Password { get; set; }
    public string? InviteCode { get; set; }
    public Guid[] RoomMembers { get; set; }
}

// public record RoomEntity(
//     Guid Id, 
//     string RoomName, 
//     string Password, 
//     Guid[] RoomMembers
//     ) : BaseEntity(Id);
