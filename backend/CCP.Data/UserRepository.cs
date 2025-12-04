namespace CCP.Data;

public class UserRepository : IUserRepository
{
    public UserEntity GetById(Guid id) 
    { 
        throw new NotImplementedException();
    }

    public UserEntity[] GetAll() 
    { 
        throw new NotImplementedException();
    }

    public UserEntity Add(UserEntity entity) 
    { 
        throw new NotImplementedException();
    }

    public UserEntity Update(UserEntity entity) 
    { 
        throw new NotImplementedException();
    }

    public UserEntity Remove(Guid id) 
    { 
        throw new NotImplementedException();
    }

    public UserEntity GetByUsername(string username)
    {
        throw new NotImplementedException();
    }

    public UserEntity[] GetUsersInRoom(Guid roomId)
    {
        throw new NotImplementedException();
    }
}