namespace CCP.Domain.Models;

//Adds User to Room 
public record SendJoinModel(Guid UserId, Guid RoomId): SendContractModel;