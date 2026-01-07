using CCP.Domain.Entities;

namespace CCP.Domain.Models.ServerContracts;

public record ReceiveStatusModel(Guid UserId, UserStatus Status) : ReceiveContractModel;