using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using Microsoft.Data.Sqlite;
using CCP.Domain.Entities;

namespace CCP.Data
{
    public class RoomRepository : IRoomRepository
    {
        private const string ConnectionString = "Data Source=chat.db";

        // ========================
        // CREATE
        // ========================


        public void Add(RoomEntity room)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            INSERT INTO Rooms
            (Id, Name, PasswordHash, InviteCode, JoinedUsers)
            VALUES
            (@Id, @Name, @PasswordHash, @InviteCode, @JoinedUsers);";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", room.Id.ToString());
            cmd.Parameters.AddWithValue("@Name", room.RoomName);
            cmd.Parameters.AddWithValue("@PasswordHash",
                (object?)room.Password ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@InviteCode",
                (object?)room.InviteCode ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@JoinedUsers", room.JoinedUsers != null && room.JoinedUsers.Any() 
                ? JsonSerializer.Serialize(room.JoinedUsers) 
                : (object?)DBNull.Value);

            cmd.ExecuteNonQuery();
        }

        // ========================
        // READ - BY ID
        // ========================
        public RoomEntity? GetById(Guid id)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Rooms WHERE Id = @Id;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            using var reader = cmd.ExecuteReader();
            if (!reader.Read())
                return null;

            return MapRoom(reader);
        }

        // ========================
        // READ - BY NAME
        // ========================
        public RoomEntity? GetByName(string name)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Rooms WHERE Name = @Name;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Name", name);

            using var reader = cmd.ExecuteReader();
            if (!reader.Read())
                return null;

            return MapRoom(reader);
        }

        // ========================
        // READ - BY INVITE CODE
        // ========================
        public RoomEntity? GetByInviteCode(string inviteCode)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            // Normalize invite code to uppercase for case-insensitive lookup
            var normalizedCode = inviteCode?.ToUpperInvariant() ?? string.Empty;
            
            const string sql = "SELECT * FROM Rooms WHERE UPPER(InviteCode) = UPPER(@InviteCode);";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@InviteCode", normalizedCode);

            using var reader = cmd.ExecuteReader();
            if (!reader.Read())
                return null;

            return MapRoom(reader);
        }

        // ========================
        // READ - ALL
        // ========================
        public IEnumerable<RoomEntity> GetAll()
        {
            var rooms = new List<RoomEntity>();

            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Rooms;";
            using var cmd = new SqliteCommand(sql, conn);
            using var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                rooms.Add(MapRoom(reader));
            }

            return rooms;
        }

        // ========================
        // UPDATE
        // ========================
        public void Update(RoomEntity room)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            UPDATE Rooms SET
                Name = @Name,
                PasswordHash = @PasswordHash,
                InviteCode = @InviteCode,
                JoinedUsers = @JoinedUsers
            WHERE Id = @Id;";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", room.Id.ToString());
            cmd.Parameters.AddWithValue("@Name", room.RoomName);
            cmd.Parameters.AddWithValue("@PasswordHash",
                (object?)room.Password ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@InviteCode",
                (object?)room.InviteCode ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@JoinedUsers", room.JoinedUsers != null && room.JoinedUsers.Any() 
                ? JsonSerializer.Serialize(room.JoinedUsers) 
                : (object?)DBNull.Value);

            cmd.ExecuteNonQuery();
        }
        

        // ========================
        // DELETE
        // ========================
        public void Delete(Guid id)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "DELETE FROM Rooms WHERE Id = @Id;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            cmd.ExecuteNonQuery();
        }

        // ========================
        // MAPPING (SQLite → class)
        // ========================
        private static RoomEntity MapRoom(SqliteDataReader reader)
        {
            var joinedUsersJson = reader["JoinedUsers"] == DBNull.Value ? null : reader["JoinedUsers"].ToString();
            List<Guid> joinedUsers = new List<Guid>();
            if (!string.IsNullOrEmpty(joinedUsersJson))
            {
                try
                {
                    joinedUsers = JsonSerializer.Deserialize<List<Guid>>(joinedUsersJson) ?? new List<Guid>();
                }
                catch
                {
                    joinedUsers = new List<Guid>();
                }
            }

            return new RoomEntity
            {
                Id = Guid.Parse(reader["Id"].ToString()!),
                RoomName = reader["Name"].ToString()!,
                Password = reader["PasswordHash"] == DBNull.Value
                    ? null
                    : reader["PasswordHash"].ToString(),
                InviteCode = reader["InviteCode"] == DBNull.Value
                    ? null
                    : reader["InviteCode"].ToString(),
                JoinedUsers = joinedUsers
            };
        }
    }
}