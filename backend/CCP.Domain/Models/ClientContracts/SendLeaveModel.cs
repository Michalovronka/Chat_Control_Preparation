namespace CCP.Domain.Models.ClientContracts;

public record SendLeaveModel(Guid UserId, Guid RoomId, string? Message = null, bool PermanentLeave = false) : SendContractModel;