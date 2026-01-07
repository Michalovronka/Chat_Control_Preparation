namespace CCP.Domain.Models.ClientContracts;

public record SendUserInfoModel(Guid UserId, string UserName, string StatusMessage, string UserState) : SendContractModel;