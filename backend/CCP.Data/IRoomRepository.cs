namespace CCP.Data;

public record RoomEntity(Guid Id, string Name, string Password, Guid[] ChatHistory) : BaseEntity(Id);

public interface IRoomRepository : IRepository<RoomEntity>
{
    
}