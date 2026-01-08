using CCP.Domain.Entities;

namespace CCP.Data;


public interface IRoomRepository : IRepository<RoomEntity>
{
        void Add(RoomEntity room);

        RoomEntity? GetById(Guid id);
        RoomEntity? GetByName(string name);
        RoomEntity? GetByInviteCode(string inviteCode);
        IEnumerable<RoomEntity> GetAll();

        void Update(RoomEntity room);
        void Delete(Guid id);
}