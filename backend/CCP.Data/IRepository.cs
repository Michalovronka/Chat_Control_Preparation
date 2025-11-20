namespace CCP.Data;

public interface IRepository<T>
{
    T GetById(Guid id);
    T[] GetAll();
    void Add(T entity);
    void Update(T entity);
    void Remove(Guid id);

    public class User
    {
        public string Username { get; set; }
    }
    public class Iuser
    {
        public string Username { get; set; }
    }
}