namespace CCP.Domain.Models.ClientContracts;

public record SendListModel(IReadOnlyList<RoomDto> Rooms) : SendContractModel;