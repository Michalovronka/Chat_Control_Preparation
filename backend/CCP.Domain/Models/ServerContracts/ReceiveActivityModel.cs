namespace CCP.Domain.Models.ServerContracts;

public record ReceiveActivityModel(Guid UserId, string Activity) : ReceiveContractModel;