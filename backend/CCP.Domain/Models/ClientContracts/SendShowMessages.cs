namespace CCP.Domain.Models.ClientContracts;

public record SendShowMessagesModel(IReadOnlyList<MessageDto> Message) : SendContractModel;