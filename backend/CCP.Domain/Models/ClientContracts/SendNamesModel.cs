namespace CCP.Domain.Models.ClientContracts;

public record SendNamesModel(IReadOnlyList<string> UserNames) : SendContractModel;