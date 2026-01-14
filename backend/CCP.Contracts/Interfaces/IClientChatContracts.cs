using CCP.Domain.Models.ClientContracts;

namespace CCP.Contracts.Interfaces;

public interface IClientChatContracts
{
    Task SendMessage(SendMessageModel model);
    Task SendJoin(SendJoinModel model);
    Task SendLeave(SendLeaveModel model);
    Task SendWho(SendWhoModel model);
    Task SendNames(SendNamesModel model);
    Task SendQuery(SendQueryModel model);
    Task SendUserInfo(SendUserInfoModel model);
    Task SendNick(SendNickModel model);
    Task SendStatus(SendStatusModel model);
    Task SendInvite(SendInviteModel model);
    Task SendIgnore(SendIgnoreModel model);
    Task SendList(SendListModel model);
    Task SendActivity(SendActivityModel model);
    Task SendShowMessages(SendShowMessagesModel model);
    Task SendKick(SendKickModel model);
    Task RegisterConnection(RegisterConnectionModel model);
}