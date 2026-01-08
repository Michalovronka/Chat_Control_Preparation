using CCP.Domain.Entities;

namespace CCP.Data;

public interface IUserRepository
{
    void Add(UserEntity user);
    
    UserEntity? GetById(Guid id);
    UserEntity? GetByUsername(string username);
    IEnumerable<UserEntity> GetAll();
    
    void Update(UserEntity user);
    void Delete(Guid id);
    
}