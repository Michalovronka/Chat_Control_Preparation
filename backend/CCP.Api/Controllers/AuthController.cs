using System.Security.Cryptography;
using System.Text;
using CCP.Data;
using CCP.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace CCP.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IUserRepository _userRepository;

    public AuthController(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    [HttpPost("register")]
    public IActionResult Register([FromBody] RegisterRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { Error = "Username and password are required" });
            }

            // Check if username already exists
            var existingUser = _userRepository.GetByUsername(request.Username);
            if (existingUser != null)
            {
                return BadRequest(new { Error = "Username already exists" });
            }

            // Hash password
            var passwordHash = HashPassword(request.Password);

            // Create new user
            var userId = Guid.NewGuid();
            var user = new UserEntity
            {
                Id = userId,
                UserName = request.Username,
                PasswordHash = passwordHash,
                LastTimeSeen = DateTime.UtcNow,
                StatusMessage = null,
                UserState = UserStatus.Online.ToString(),
                CurrentRoomId = null,
                ConnectionId = null
            };

            _userRepository.Add(user);

            return Ok(new
            {
                UserId = userId.ToString(),
                UserName = user.UserName,
                Message = "User registered successfully"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { Error = "Username and password are required" });
            }

            // Find user by username
            var user = _userRepository.GetByUsername(request.Username);
            if (user == null)
            {
                return Unauthorized(new { Error = "Invalid username or password" });
            }

            // Check if user has a password hash (for users created before authentication was added)
            if (string.IsNullOrEmpty(user.PasswordHash))
            {
                return Unauthorized(new { Error = "This account was created before authentication was added. Please register a new account." });
            }

            // Verify password
            if (!VerifyPassword(request.Password, user.PasswordHash))
            {
                return Unauthorized(new { Error = "Invalid username or password" });
            }

            // Update last seen
            user.LastTimeSeen = DateTime.UtcNow;
            user.UserState = UserStatus.Online.ToString();
            _userRepository.Update(user);

            return Ok(new
            {
                UserId = user.Id.ToString(),
                UserName = user.UserName,
                Message = "Login successful"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    private static string HashPassword(string password)
    {
        using var sha256 = SHA256.Create();
        var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
        return Convert.ToBase64String(hashedBytes);
    }

    private static bool VerifyPassword(string password, string? passwordHash)
    {
        if (string.IsNullOrEmpty(passwordHash))
            return false;

        var hashOfInput = HashPassword(password);
        return hashOfInput == passwordHash;
    }
}

public class RegisterRequest
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class LoginRequest
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
