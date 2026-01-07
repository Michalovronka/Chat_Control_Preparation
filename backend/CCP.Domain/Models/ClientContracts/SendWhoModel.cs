namespace CCP.Domain.Models.ClientContracts;

public record SendWhoModel(IReadOnlyList<UserInfoDto> Users) : SendContractModel;