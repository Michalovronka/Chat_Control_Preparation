using System;
using System.Collections.Generic;
using Microsoft.Data.Sqlite;
using CCP.Domain.Entities;

namespace CCP.Data
{
    public class UserRepository : IUserRepository
    {
        private const string ConnectionString = "Data Source=chat.db";

        public UserEntity? GetById(Guid id)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            var sql = "SELECT * FROM Users WHERE Id = @Id;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            using var reader = cmd.ExecuteReader();
            return reader.Read() ? MapUser(reader) : null;
        }

        public UserEntity? GetByUsername(string username)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            var sql = "SELECT * FROM Users WHERE UserName = @UserName;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@UserName", username);

            using var reader = cmd.ExecuteReader();
            return reader.Read() ? MapUser(reader) : null;
        }

        public IEnumerable<UserEntity> GetAll()
        {
            var users = new List<UserEntity>();

            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            using var cmd = new SqliteCommand("SELECT * FROM Users;", conn);
            using var reader = cmd.ExecuteReader();

            while (reader.Read())
                users.Add(MapUser(reader));

            return users;
        }

        public void Add(UserEntity entity)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            var sql = @"
            INSERT INTO Users
            (Id, UserName, PasswordHash, LastTimeSeen, StatusMessage, UserState, CurrentRoomId, ConnectionId)
            VALUES
            (@Id, @UserName, @PasswordHash, @LastTimeSeen, @StatusMessage, @UserState, @CurrentRoomId, @ConnectionId);";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", entity.Id.ToString());
            cmd.Parameters.AddWithValue("@UserName", entity.UserName);
            cmd.Parameters.AddWithValue("@PasswordHash", (object?)entity.PasswordHash ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@LastTimeSeen", entity.LastTimeSeen.ToString("o"));
            cmd.Parameters.AddWithValue("@StatusMessage", (object?)entity.StatusMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@UserState", entity.UserState);
            cmd.Parameters.AddWithValue("@CurrentRoomId", (object?)entity.CurrentRoomId?.ToString() ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ConnectionId", (object?)entity.ConnectionId ?? DBNull.Value);

            cmd.ExecuteNonQuery();
        }

        public void Update(UserEntity entity)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            var sql = @"
            UPDATE Users SET
                UserName = @UserName,
                PasswordHash = @PasswordHash,
                LastTimeSeen = @LastTimeSeen,
                StatusMessage = @StatusMessage,
                UserState = @UserState,
                CurrentRoomId = @CurrentRoomId,
                ConnectionId = @ConnectionId
            WHERE Id = @Id;";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", entity.Id.ToString());
            cmd.Parameters.AddWithValue("@UserName", entity.UserName);
            cmd.Parameters.AddWithValue("@PasswordHash", (object?)entity.PasswordHash ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@LastTimeSeen", entity.LastTimeSeen.ToString("o"));
            cmd.Parameters.AddWithValue("@StatusMessage", (object?)entity.StatusMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@UserState", entity.UserState);
            cmd.Parameters.AddWithValue("@CurrentRoomId", (object?)entity.CurrentRoomId?.ToString() ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ConnectionId", (object?)entity.ConnectionId ?? DBNull.Value);

            cmd.ExecuteNonQuery();
        }

        public void Delete(Guid id)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            using var cmd = new SqliteCommand("DELETE FROM Users WHERE Id = @Id;", conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            cmd.ExecuteNonQuery();
        }

        private static UserEntity MapUser(SqliteDataReader reader)
        {
            return new UserEntity
            {
                Id = Guid.Parse(reader["Id"].ToString()!),
                UserName = reader["UserName"].ToString()!,
                PasswordHash = reader["PasswordHash"] == DBNull.Value ? null : reader["PasswordHash"].ToString(),
                LastTimeSeen = DateTime.Parse(reader["LastTimeSeen"].ToString()!),
                StatusMessage = reader["StatusMessage"] == DBNull.Value ? null : reader["StatusMessage"].ToString(),
                UserState = reader["UserState"].ToString()!,
                CurrentRoomId = reader["CurrentRoomId"] == DBNull.Value ? null : Guid.Parse(reader["CurrentRoomId"].ToString()!),
                ConnectionId = reader["ConnectionId"] == DBNull.Value ? null : reader["ConnectionId"].ToString()
            };
        }
    }
    
}