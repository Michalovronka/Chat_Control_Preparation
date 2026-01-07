using CCP.Domain.Entities;

namespace CCP.Data;

public interface IUserRepository
{
    UserEntity GetById(Guid id);
    UserEntity[] GetUsersInRoom(Guid roomIdd);
    
}