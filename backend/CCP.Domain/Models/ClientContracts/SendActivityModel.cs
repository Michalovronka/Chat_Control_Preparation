namespace CCP.Domain.Models.ClientContracts;

public record SendActivityModel(Guid UserId, string Activity) : SendContractModel;