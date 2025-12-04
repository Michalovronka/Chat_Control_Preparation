namespace CCP.Data;

public interface IRepository<T> where T : class
{
    T GetById(Guid id);
    T[] GetAll();
    T Add(T entity);
    T Update(T entity);
    T Remove(Guid id);
}