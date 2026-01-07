namespace CCP.Domain.Entities;

public record RoomEntity(
    Guid Id, 
    string RoomName, 
    string Password, 
    Guid[] RoomMembers
    ) : BaseEntity(Id);