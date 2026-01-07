namespace CCP.Domain.Entities;


public abstract class BaseEntity
{
    public Guid Id { get; set; }
}
// public record BaseEntity(Guid Id);