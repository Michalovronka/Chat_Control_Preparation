using CCP.Data;
using CCP.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace CCP.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserController : ControllerBase
{
    private readonly IUserRepository _userRepository;

    public UserController(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    [HttpPost("create")]
    public IActionResult CreateUser([FromBody] CreateUserRequest request)
    {
        try
        {
            var userId = request.UserId ?? Guid.NewGuid();
            
            // Check if user already exists
            var existingUser = _userRepository.GetById(userId);
            if (existingUser != null)
            {
                return Ok(new { UserId = userId, Message = "User already exists" });
            }

            var user = new UserEntity
            {
                Id = userId,
                UserName = request.UserName ?? $"User_{userId.ToString().Substring(0, 8)}",
                LastTimeSeen = DateTime.UtcNow,
                StatusMessage = null,
                UserState = UserStatus.Online.ToString(),
                CurrentRoomId = null,
                ConnectionId = null
            };

            _userRepository.Add(user);
            return Ok(new { UserId = userId, UserName = user.UserName });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public IActionResult GetUser(string id)
    {
        if (!Guid.TryParse(id, out var userId))
        {
            return BadRequest(new { Error = "Invalid user ID format" });
        }

        var user = _userRepository.GetById(userId);
        if (user == null)
        {
            return NotFound(new { Error = "User not found" });
        }

        return Ok(new
        {
            Id = user.Id,
            UserName = user.UserName,
            LastTimeSeen = user.LastTimeSeen,
            StatusMessage = user.StatusMessage,
            UserState = user.UserState,
            CurrentRoomId = user.CurrentRoomId
        });
    }

    [HttpGet("room/{roomId}")]
    public IActionResult GetUsersByRoom(string roomId)
    {
        if (!Guid.TryParse(roomId, out var roomGuid))
        {
            return BadRequest(new { Error = "Invalid room ID format" });
        }

        var users = _userRepository.GetAll()
            .Where(u => u.CurrentRoomId.HasValue && u.CurrentRoomId.Value == roomGuid)
            .Select(u => new
            {
                Id = u.Id,
                UserName = u.UserName,
                StatusMessage = u.StatusMessage ?? "",
                UserState = u.UserState,
                LastTimeSeen = u.LastTimeSeen
            })
            .ToList();

        return Ok(users);
    }

    [HttpPut("{id}")]
    public IActionResult UpdateUser(string id, [FromBody] UpdateUserRequest request)
    {
        if (!Guid.TryParse(id, out var userId))
        {
            return BadRequest(new { Error = "Invalid user ID format" });
        }

        var user = _userRepository.GetById(userId);
        if (user == null)
        {
            return NotFound(new { Error = "User not found" });
        }

        if (!string.IsNullOrEmpty(request.UserName))
        {
            user.UserName = request.UserName;
        }

        if (request.StatusMessage != null)
        {
            user.StatusMessage = request.StatusMessage;
        }

        if (!string.IsNullOrEmpty(request.UserState))
        {
            user.UserState = request.UserState;
        }

        _userRepository.Update(user);

        return Ok(new
        {
            Id = user.Id,
            UserName = user.UserName,
            StatusMessage = user.StatusMessage,
            UserState = user.UserState
        });
    }
}

public class CreateUserRequest
{
    public Guid? UserId { get; set; }
    public string? UserName { get; set; }
}

public class UpdateUserRequest
{
    public string? UserName { get; set; }
    public string? StatusMessage { get; set; }
    public string? UserState { get; set; }
}
