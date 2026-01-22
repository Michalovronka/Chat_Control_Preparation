using CCP.Domain.Entities;

namespace CCP.Data;

public interface IInviteRepository
{
    void Add(InviteEntity invite);
    IEnumerable<InviteEntity> GetPendingInvitesForUser(Guid receiverUserId);
    void MarkAsDelivered(Guid inviteId);
    void Delete(Guid inviteId);
    void DeleteInvitesForRoom(Guid roomId);
}
