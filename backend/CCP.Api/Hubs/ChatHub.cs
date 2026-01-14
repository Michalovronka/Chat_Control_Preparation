using CCP.Contracts.Interfaces;
using CCP.Data;
using CCP.Domain.Entities;
using CCP.Domain.Models.ClientContracts;
using CCP.Domain.Models.ServerContracts;
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
        // User will be created/updated when they send their first message or join
    }

    // Helper method to get or create user
    private UserEntity GetOrCreateUser(Guid userId, string? userName = null)
    {
        var user = _userRepository.GetById(userId);
        if (user == null)
        {
            user = new UserEntity
            {
                Id = userId,
                UserName = userName ?? $"User_{userId.ToString().Substring(0, 8)}",
                LastTimeSeen = DateTime.UtcNow,
                StatusMessage = null,
                UserState = UserStatus.Online.ToString(),
                CurrentRoomId = null,
                ConnectionId = Context.ConnectionId
            };
            _userRepository.Add(user);
        }
        else
        {
            // Update connection ID and last seen
            user.ConnectionId = Context.ConnectionId;
            user.LastTimeSeen = DateTime.UtcNow;
            if (!string.IsNullOrEmpty(userName))
            {
                user.UserName = userName;
            }
            _userRepository.Update(user);
        }
        return user;
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        // Update user's connection status when they disconnect
        var user = _userRepository.GetAll().FirstOrDefault(u => u.ConnectionId == Context.ConnectionId);
        if (user != null)
        {
            user.ConnectionId = null;
            _userRepository.Update(user);
        }
        await base.OnDisconnectedAsync(exception);
    }

    public async Task SendMessage(SendMessageModel model)
    {
        var user = GetOrCreateUser(model.UserId);

        var room = _roomRepository.GetById(model.RoomId);
        if (room == null)
        {
            await Clients.Caller.SendAsync("Error", "Room not found");
            return;
        }

        var messageEntity = new MessageEntity
        {
            Id = Guid.NewGuid(),
            UserId = model.UserId,
            RoomId = model.RoomId,
            Content = model.Content,
            IsImage = false,
            SentTime = model.SentTime
        };

        _messageRepository.Add(messageEntity);

        // Send message as an object to ensure proper JSON serialization
        await Clients.Group(room.Id.ToString()!).SendAsync("ReceiveMessage", new
        {
            UserId = model.UserId.ToString(),
            UserName = user.UserName,
            Content = model.Content,
            IsImage = "false",
            RoomId = model.RoomId.ToString()
        });
    }

    public async Task SendJoin(SendJoinModel model)
    {
        // Get or create user
        var user = GetOrCreateUser(model.UserId);
        
        // Get the room
        var room = _roomRepository.GetById(model.RoomId);
        if (room == null)
        {
            await Clients.Caller.SendAsync("Error", "Room not found");
            return;
        }

        if (!room.Id.HasValue)
        {
            await Clients.Caller.SendAsync("Error", "Invalid room");
            return;
        }

        // Leave previous room if in one
        if (user.CurrentRoomId.HasValue && user.CurrentRoomId.Value != model.RoomId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, user.CurrentRoomId.Value.ToString());
        }

        // Initialize JoinedRooms if null
        if (user.JoinedRooms == null)
        {
            user.JoinedRooms = new List<Guid>();
        }

        // Add room to user's JoinedRooms list if not already there
        if (!user.JoinedRooms.Contains(model.RoomId))
        {
            user.JoinedRooms.Add(model.RoomId);
        }

        // Initialize JoinedUsers if null
        if (room.JoinedUsers == null)
        {
            room.JoinedUsers = new List<Guid>();
        }

        // Add user to room's JoinedUsers list if not already there
        if (!room.JoinedUsers.Contains(model.UserId))
        {
            room.JoinedUsers.Add(model.UserId);
            _roomRepository.Update(room);
        }

        // Update user's current room
        user.CurrentRoomId = model.RoomId;
        user.ConnectionId = Context.ConnectionId;
        _userRepository.Update(user);

        // Add to SignalR group
        var roomId = room.Id.Value;
        await Groups.AddToGroupAsync(Context.ConnectionId, roomId.ToString());

        // Notify others in the room
        var receiveModel = new ReceiveJoinModel(user.Id, roomId, room.Password ?? "");
        await Clients.Group(roomId.ToString()).SendAsync("ReceiveJoin", receiveModel);
    }

    public async Task SendLeave(SendLeaveModel model)
    {
        try
        {
            var user = GetOrCreateUser(model.UserId);
            
            // For permanent leave, allow even if CurrentRoomId doesn't match (user might be in a different state)
            // For temporary leave, check CurrentRoomId
            if (!model.PermanentLeave && user.CurrentRoomId != model.RoomId)
            {
                await Clients.Caller.SendAsync("Error", "User not in the specified room");
                return;
            }

            // Get the room
            var room = _roomRepository.GetById(model.RoomId);
            if (room == null)
            {
                await Clients.Caller.SendAsync("Error", "Room not found");
                return;
            }

            // Remove from SignalR group first (before any potential room deletion)
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, model.RoomId.ToString());

            // Send leave notification before potentially deleting the room
            var receiveModel = new ReceiveLeaveModel(user.Id, model.RoomId);
            await Clients.Group(model.RoomId.ToString()).SendAsync("ReceiveLeave", receiveModel);

            // Clear current room (user navigates away)
            user.CurrentRoomId = null;
            user.ConnectionId = Context.ConnectionId;

            // If permanent leave (leave button), remove from both lists
            if (model.PermanentLeave)
            {
                // Initialize lists if null (shouldn't happen, but safety check)
                if (user.JoinedRooms == null)
                {
                    user.JoinedRooms = new List<Guid>();
                }
                if (room.JoinedUsers == null)
                {
                    room.JoinedUsers = new List<Guid>();
                }

                // Remove room from user's JoinedRooms list
                if (user.JoinedRooms.Contains(model.RoomId))
                {
                    user.JoinedRooms.Remove(model.RoomId);
                }

                // Remove user from room's JoinedUsers list
                if (room.JoinedUsers.Contains(model.UserId))
                {
                    room.JoinedUsers.Remove(model.UserId);
                    _roomRepository.Update(room);
                }

                // If room's JoinedUsers list is empty, delete the room
                // Note: We already sent the ReceiveLeave message, so deletion is safe
                if (room.JoinedUsers == null || !room.JoinedUsers.Any())
                {
                    // Delete all messages for this room first (to avoid foreign key constraint)
                    _messageRepository.DeleteByRoomId(model.RoomId);
                    // Then delete the room
                    _roomRepository.Delete(model.RoomId);
                    // Notify remaining clients (if any) that room was deleted
                    try
                    {
                        await Clients.Group(model.RoomId.ToString()).SendAsync("RoomDeleted", new { RoomId = model.RoomId });
                    }
                    catch
                    {
                        // Ignore if group doesn't exist (room already deleted)
                    }
                }
            }
            // If temporary leave (back arrow), user stays in both lists, just CurrentRoomId is cleared

            _userRepository.Update(user);
        }
        catch (Exception ex)
        {
            // Log the error and send a generic error message
            await Clients.Caller.SendAsync("Error", $"An error occurred while leaving the room: {ex.Message}");
        }
    }

    public async Task SendWho(SendWhoModel model)
    {
        var user = _userRepository.GetAll().FirstOrDefault(u => u.ConnectionId == Context.ConnectionId);
        if (user == null || !user.CurrentRoomId.HasValue)
        {
            await Clients.Caller.SendAsync("Error", "User not in a room");
            return;
        }

        // Get all users in the current room
        var roomUsers = _userRepository.GetAll()
            .Where(u => u.CurrentRoomId == user.CurrentRoomId.Value)
            .Select(u => new UserInfoDto(
                u.UserName,
                u.StatusMessage ?? "",
                u.UserState
            ))
            .ToList();

        var receiveModel = new ReceiveWhoModel(user.CurrentRoomId.Value);
        await Clients.Caller.SendAsync("ReceiveWho", receiveModel);
    }

    public async Task SendNames(SendNamesModel model)
    {
        // Get room ID from current user's room
        var user = _userRepository.GetAll().FirstOrDefault(u => u.ConnectionId == Context.ConnectionId);
        if (user == null || !user.CurrentRoomId.HasValue)
        {
            await Clients.Caller.SendAsync("Error", "User not in a room");
            return;
        }

        var receiveModel = new ReceiveNamesModel(user.CurrentRoomId.Value);
        await Clients.Caller.SendAsync("ReceiveNames", receiveModel);
    }

    public async Task SendQuery(SendQueryModel model)
    {
        var sender = _userRepository.GetById(model.SenderUserId);
        var receiver = _userRepository.GetById(model.ReceiverUserId);

        if (sender == null || receiver == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        var receiveModel = new ReceiveQueryModel(model.SenderUserId, model.ReceiverUserId);
        
        // Send to the receiver
        if (!string.IsNullOrEmpty(receiver.ConnectionId))
        {
            await Clients.Client(receiver.ConnectionId).SendAsync("ReceiveQuery", receiveModel);
        }
    }

    public async Task SendUserInfo(SendUserInfoModel model)
    {
        var user = _userRepository.GetById(model.UserId);
        if (user == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        // Update user info
        user.UserName = model.UserName;
        user.StatusMessage = model.StatusMessage;
        user.UserState = model.UserState;
        _userRepository.Update(user);

        var receiveModel = new ReceiveUserInfoModel(model.UserId);
        await Clients.Caller.SendAsync("ReceiveUserInfo", receiveModel);
    }

    public async Task SendNick(SendNickModel model)
    {
        var user = _userRepository.GetById(model.UserId);
        if (user == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        user.UserName = model.Nick;
        _userRepository.Update(user);

        var receiveModel = new ReceiveNickModel(model.UserId, model.Nick);
        
        // Notify users in the same room
        if (user.CurrentRoomId.HasValue)
        {
            await Clients.Group(user.CurrentRoomId.Value.ToString()!).SendAsync("ReceiveNick", receiveModel);
        }
    }

    public async Task SendStatus(SendStatusModel model)
    {
        var user = _userRepository.GetById(model.UserId);
        if (user == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        user.StatusMessage = model.Status;
        _userRepository.Update(user);

        // Parse status string to UserStatus enum
        var statusEnum = Enum.TryParse<UserStatus>(model.Status, true, out var parsedStatus) 
            ? parsedStatus 
            : UserStatus.Online;

        var receiveModel = new ReceiveStatusModel(model.UserId, statusEnum);
        
        // Notify users in the same room
        if (user.CurrentRoomId.HasValue)
        {
            await Clients.Group(user.CurrentRoomId.Value.ToString()!).SendAsync("ReceiveStatus", receiveModel);
        }
    }

    public async Task SendInvite(SendInviteModel model)
    {
        var sender = _userRepository.GetAll().FirstOrDefault(u => u.ConnectionId == Context.ConnectionId);
        if (sender == null || !sender.CurrentRoomId.HasValue)
        {
            await Clients.Caller.SendAsync("Error", "Sender not in a room");
            return;
        }

        // For invite, we need to identify the receiver - this is simplified
        // In a real implementation, you'd parse the message or have receiver info
        var receiveModel = new ReceiveInviteModel(
            sender.Id,
            Guid.Empty, // Receiver ID would come from model.Message parsing
            sender.CurrentRoomId.Value
        );

        await Clients.Caller.SendAsync("ReceiveInvite", receiveModel);
    }

    public async Task SendIgnore(SendIgnoreModel model)
    {
        var sender = _userRepository.GetAll().FirstOrDefault(u => u.ConnectionId == Context.ConnectionId);
        if (sender == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        // For ignore, we need to identify the user to ignore - this is simplified
        // In a real implementation, you'd parse the message
        var receiveModel = new ReceiveIgnoreModel(
            sender.Id,
            Guid.Empty // Muted user ID would come from model.Message parsing
        );

        await Clients.Caller.SendAsync("ReceiveIgnore", receiveModel);
    }

    public async Task SendList(SendListModel model)
    {
        var user = _userRepository.GetAll().FirstOrDefault(u => u.ConnectionId == Context.ConnectionId);
        if (user == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        // Get all available rooms
        var rooms = _roomRepository.GetAll()
            .Where(r => r.Id.HasValue)
            .Select(r => new RoomDto(r.Id!.Value, r.RoomName))
            .ToList();

        var receiveModel = new ReceiveListModel(user.Id);
        await Clients.Caller.SendAsync("ReceiveList", receiveModel);
    }

    public async Task SendActivity(SendActivityModel model)
    {
        var user = _userRepository.GetById(model.UserId);
        if (user == null)
        {
            await Clients.Caller.SendAsync("Error", "User not found");
            return;
        }

        var receiveModel = new ReceiveActivityModel(model.UserId, model.Activity);
        
        // Broadcast activity to users in the same room
        if (user.CurrentRoomId.HasValue)
        {
            await Clients.Group(user.CurrentRoomId.Value.ToString()!).SendAsync("ReceiveActivity", receiveModel);
        }
    }

    public async Task SendShowMessages(SendShowMessagesModel model)
    {
        var user = _userRepository.GetAll().FirstOrDefault(u => u.ConnectionId == Context.ConnectionId);
        if (user == null || !user.CurrentRoomId.HasValue)
        {
            await Clients.Caller.SendAsync("Error", "User not in a room");
            return;
        }

        var messages = _messageRepository.GetMessagesByRoom(user.CurrentRoomId.Value);
        // Send messages as objects to ensure proper JSON serialization
        // Include username for each message by looking up the user
        var messageObjects = messages.Select(m =>
        {
            var messageUser = _userRepository.GetById(m.UserId);
            return new
            {
                UserId = m.UserId.ToString(),
                UserName = messageUser?.UserName ?? $"User_{m.UserId.ToString().Substring(0, 8)}",
                Content = m.Content,
                RoomId = m.RoomId.ToString(),
                SentTime = m.SentTime.ToString("o") // ISO 8601 format
            };
        }).ToList();

        // Send messages via LoadMessages event
        await Clients.Caller.SendAsync("LoadMessages", messageObjects);
        
        var receiveModel = new ReceiveShowMessagesModel(user.CurrentRoomId.Value);
        await Clients.Caller.SendAsync("ReceiveShowMessages", receiveModel);
    }
}
