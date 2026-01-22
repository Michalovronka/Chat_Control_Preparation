using Microsoft.AspNetCore.Mvc;

namespace CCP.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ImageController : ControllerBase
{
    private const string ImagesDirectory = "uploads/images";

    public ImageController()
    {
        // Ensure images directory exists
        if (!Directory.Exists(ImagesDirectory))
        {
            Directory.CreateDirectory(ImagesDirectory);
        }
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadImage(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(new { Error = "No file uploaded" });
        }

        // Validate file type
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
        var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!allowedExtensions.Contains(fileExtension))
        {
            return BadRequest(new { Error = "Invalid file type. Allowed: jpg, jpeg, png, gif, webp" });
        }

        // Validate file size (max 10MB)
        const long maxFileSize = 10 * 1024 * 1024; // 10MB
        if (file.Length > maxFileSize)
        {
            return BadRequest(new { Error = "File size exceeds 10MB limit" });
        }

        try
        {
            // Generate unique filename
            var fileName = $"{Guid.NewGuid()}{fileExtension}";
            var filePath = Path.Combine(ImagesDirectory, fileName);

            // Save file
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Return relative path - client will construct full URL based on platform
            var imagePath = $"/api/image/{fileName}";
            return Ok(new { ImagePath = imagePath, FileName = fileName });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error uploading image: {ex.Message}");
            return StatusCode(500, new { Error = "Failed to upload image" });
        }
    }

    [HttpGet("{fileName}")]
    public IActionResult GetImage(string fileName)
    {
        try
        {
            var filePath = Path.Combine(ImagesDirectory, fileName);
            
            if (!System.IO.File.Exists(filePath))
            {
                return NotFound(new { Error = "Image not found" });
            }

            var fileBytes = System.IO.File.ReadAllBytes(filePath);
            var contentType = GetContentType(fileName);
            
            return File(fileBytes, contentType);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error retrieving image: {ex.Message}");
            return StatusCode(500, new { Error = "Failed to retrieve image" });
        }
    }

    private string GetContentType(string fileName)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return extension switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".webp" => "image/webp",
            _ => "application/octet-stream"
        };
    }
}
