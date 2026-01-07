using CCP.Api.Hubs;
using CCP.Data;

var builder = WebApplication.CreateBuilder(args);
DatabaseSetUp.Initialize();

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// Add SignalR
builder.Services.AddSignalR();

// Configure CORS for SignalR (adjust origins as needed for your frontend)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "http://localhost:5173", "http://localhost:8080")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Register repositories
builder.Services.AddSingleton<IMessageRepository, MessageRepository>();
builder.Services.AddSingleton<IRoomRepository, RoomRepository>();
builder.Services.AddSingleton<IUserRepository, UserRepository>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// Use CORS (must be before UseHttpsRedirection and MapHub)
app.UseCors("AllowFrontend");

app.UseHttpsRedirection();

// Map SignalR Hub
app.MapHub<ChatHub>("/chathub");

app.Run();