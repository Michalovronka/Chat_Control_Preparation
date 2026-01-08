using CCP.Data;
using CCP.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace CCP.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RoomController : ControllerBase
{
    private readonly IRoomRepository _roomRepository;

    public RoomController(IRoomRepository roomRepository)
    {
        _roomRepository = roomRepository;
    }

    [HttpPost("create")]
    public IActionResult CreateRoom([FromBody] CreateRoomRequest request)
    {
        try
        {
            var roomId = request.RoomId ?? Guid.NewGuid();
            
            // Check if room already exists
            var existingRoom = _roomRepository.GetById(roomId);
            if (existingRoom != null)
            {
                return Ok(new { RoomId = roomId, RoomName = existingRoom.RoomName, InviteCode = existingRoom.InviteCode, Message = "Room already exists" });
            }

            // Generate invite code from room ID (last 8 characters without dashes)
            // Normalize to uppercase for consistency
            var roomIdWithoutDashes = roomId.ToString().Replace("-", "").ToUpperInvariant();
            var inviteCode = roomIdWithoutDashes.Length >= 8
                ? roomIdWithoutDashes.Substring(roomIdWithoutDashes.Length - 8)
                : roomIdWithoutDashes;

            var room = new RoomEntity
            {
                Id = roomId,
                RoomName = request.RoomName ?? $"Room_{roomId.ToString().Substring(0, 8)}",
                Password = request.Password ?? string.Empty,
                InviteCode = inviteCode,
                RoomMembers = Array.Empty<Guid>()
            };

            _roomRepository.Add(room);
            return Ok(new { RoomId = roomId, RoomName = room.RoomName, InviteCode = inviteCode });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public IActionResult GetRoom(string id)
    {
        if (!Guid.TryParse(id, out var roomId))
        {
            return BadRequest(new { Error = "Invalid room ID format" });
        }

        var room = _roomRepository.GetById(roomId);
        if (room == null)
        {
            return NotFound(new { Error = "Room not found" });
        }

        return Ok(new
        {
            Id = room.Id,
            RoomName = room.RoomName,
            HasPassword = !string.IsNullOrEmpty(room.Password)
        });
    }

    [HttpGet("by-code/{code}")]
    public IActionResult GetRoomByCode(string code)
    {
        // Normalize code to uppercase for consistent lookup
        var normalizedCode = code?.ToUpperInvariant() ?? string.Empty;
        var room = _roomRepository.GetByInviteCode(normalizedCode);
        if (room == null)
        {
            return NotFound(new { Error = "Room not found" });
        }

        return Ok(new
        {
            Id = room.Id,
            RoomName = room.RoomName,
            HasPassword = !string.IsNullOrEmpty(room.Password),
            InviteCode = room.InviteCode
        });
    }

    [HttpGet]
    public IActionResult GetAllRooms()
    {
        var rooms = _roomRepository.GetAll()
            .Where(r => r.Id.HasValue)
            .Select(r => new
            {
                Id = r.Id,
                RoomName = r.RoomName,
                HasPassword = !string.IsNullOrEmpty(r.Password)
            })
            .ToList();

        return Ok(rooms);
    }
}

public class CreateRoomRequest
{
    public Guid? RoomId { get; set; }
    public string? RoomName { get; set; }
    public string? Password { get; set; }
}
