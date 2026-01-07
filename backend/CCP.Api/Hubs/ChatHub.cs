using CCP.Contracts.Interfaces;
using CCP.Data;
using CCP.Domain.Entities;
using CCP.Domain.Models;
using Microsoft.AspNetCore.SignalR;

namespace CCP.Api.Hubs;

public class ChatHub : Hub, IClientChatContracts
{
    private readonly IMessageRepository _messageRepository;
    private readonly IRoomRepository _roomRepository;
    private readonly IUserRepository _userRepository;

    public ChatHub(
        IMessageRepository messageRepository,
        IRoomRepository roomRepository,
        IUserRepository userRepository)
    {
        _messageRepository = messageRepository;
        _roomRepository = roomRepository;
        _userRepository = userRepository;
    }

    public override async Task OnConnectedAsync()
    {
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        // Update user's connection status when they disconnect
        // You can implement logic here to update the user's ConnectionId to null
        await base.OnDisconnectedAsync(exception);
    }

    // Client calls this method to send a message
    public async Task SendMessage(SendMessageModel model)
    {
        // Validate user and room exist
        var user = _userRepository.GetById(model.UserId);
        if (user == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        var room = _roomRepository.GetById(model.RoomId);
        if (room == null)
        {
            await Clients.Caller.SendAsync("Error", "Room not found");
            return;
        }

        // Create and save message entity
        var messageEntity = new MessageEntity
        {
            Id = Guid.NewGuid(),
            UserId = model.UserId,
            RoomId = model.RoomId,
            Content = model.Content,
            IsImage = model.IsImage == "true" || model.IsImage == "1",
            SentTime = DateTime.UtcNow
        };

        _messageRepository.Add(messageEntity);

        // Broadcast message to all clients in the room
        await Clients.Group(room.Id.ToString()!).SendAsync("ReceiveMessage", new
        {
            messageEntity.Id,
            messageEntity.UserId,
            messageEntity.RoomId,
            messageEntity.Content,
            messageEntity.IsImage,
            messageEntity.SentTime,
            UserName = user.UserName
        });
    }

    // Client calls this method to join a room
    public async Task SendJoin(SendJoinModel model)
    {
        // Validate user and room exist
        var user = _userRepository.GetById(model.UserId);
        if (user == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        var room = _roomRepository.GetById(model.RoomId);
        if (room == null)
        {
            await Clients.Caller.SendAsync("Error", "Room not found");
            return;
        }

        // Update user's current room and connection ID
        user.CurrentRoomId = model.RoomId;
        user.ConnectionId = Context.ConnectionId;
        _userRepository.Update(user);

        // Add connection to SignalR group for the room
        await Groups.AddToGroupAsync(Context.ConnectionId, model.RoomId.ToString());

        // Notify others in the room that user joined
        await Clients.Group(model.RoomId.ToString()).SendAsync("UserJoined", new
        {
            UserId = user.Id,
            UserName = user.UserName,
            RoomId = model.RoomId
        });

        // Send current room messages to the joining user
        var messages = _messageRepository.GetMessagesByRoom(model.RoomId);
        await Clients.Caller.SendAsync("LoadMessages", messages.Select(m => new
        {
            m.Id,
            m.UserId,
            m.RoomId,
            m.Content,
            m.IsImage,
            m.SentTime
        }));
    }

    // Client can call this to leave a room
    public async Task LeaveRoom(Guid userId, Guid roomId)
    {
        var user = _userRepository.GetById(userId);
        if (user != null)
        {
            user.CurrentRoomId = null;
            _userRepository.Update(user);
        }

        await Groups.RemoveFromGroupAsync(Context.ConnectionId, roomId.ToString());

        await Clients.Group(roomId.ToString()).SendAsync("UserLeft", new
        {
            UserId = userId,
            RoomId = roomId
        });
    }
}
