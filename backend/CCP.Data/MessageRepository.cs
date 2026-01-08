using System;
using System.Collections.Generic;
using Microsoft.Data.Sqlite;
using CCP.Domain.Entities;

namespace CCP.Data
{
    public class MessageRepository : IMessageRepository
    {
        private const string ConnectionString = "Data Source=chat.db";

        // ========================
        // READ - ALL
        // ========================
        public IEnumerable<MessageEntity> GetAll()
        {
            var messages = new List<MessageEntity>();

            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Messages ORDER BY SentTime ASC;";
            using var cmd = new SqliteCommand(sql, conn);
            using var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                messages.Add(MapMessage(reader));
            }

            return messages;
        }
        
        // ========================
        // UPDATE
        // ========================
        public void Update(MessageEntity entity)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            UPDATE Messages SET
                IsImage = @IsImage,
                Content = @Content,
                UserId = @UserId,
                RoomId = @RoomId,
                SentTime = @SentTime
            WHERE Id = @Id;";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", entity.Id.ToString());
            cmd.Parameters.AddWithValue("@IsImage", entity.IsImage ? 1 : 0);
            cmd.Parameters.AddWithValue("@Content", entity.Content);
            cmd.Parameters.AddWithValue("@UserId", entity.UserId.ToString());
            cmd.Parameters.AddWithValue("@RoomId", entity.RoomId.ToString());
            cmd.Parameters.AddWithValue("@SentTime", entity.SentTime.ToString("o"));

            cmd.ExecuteNonQuery();
        }

        public void Add(MessageEntity message)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            INSERT INTO Messages
            (Id, IsImage, Content, UserId, RoomId, SentTime)
            VALUES
            (@Id, @IsImage, @Content, @UserId, @RoomId, @SentTime);";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", message.Id.ToString());
            cmd.Parameters.AddWithValue("@IsImage", message.IsImage ? 1 : 0);
            cmd.Parameters.AddWithValue("@Content", message.Content);
            cmd.Parameters.AddWithValue("@UserId", message.UserId.ToString());
            cmd.Parameters.AddWithValue("@RoomId", message.RoomId.ToString());
            cmd.Parameters.AddWithValue("@SentTime", message.SentTime.ToString("o"));

            cmd.ExecuteNonQuery();
        }

        


        // ========================
        // READ - BY ID
        // ========================
        public MessageEntity? GetById(Guid id)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Messages WHERE Id = @Id;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            using var reader = cmd.ExecuteReader();
            if (!reader.Read())
                return null;

            return MapMessage(reader);
        }

        // ========================
        // READ - BY ROOM
        // ========================
        public IEnumerable<MessageEntity> GetByRoomId(Guid roomId)
        {
            var messages = new List<MessageEntity>();

            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            SELECT * FROM Messages
            WHERE RoomId = @RoomId
            ORDER BY SentTime ASC;";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@RoomId", roomId.ToString());

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                messages.Add(MapMessage(reader));
            }

            return messages;
        }

        public IEnumerable<MessageEntity> GetMessagesByRoom(Guid roomId)
        {
            return GetByRoomId(roomId);
        }

        // ========================
        // READ - ROOMS BY USER
        // ========================
        public IEnumerable<Guid> GetRoomIdsByUser(Guid userId)
        {
            var roomIds = new List<Guid>();

            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            SELECT DISTINCT RoomId FROM Messages
            WHERE UserId = @UserId;";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@UserId", userId.ToString());

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                roomIds.Add(Guid.Parse(reader["RoomId"].ToString()!));
            }

            return roomIds;
        }

        // ========================
        // DELETE
        // ========================
        public void Delete(Guid id)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "DELETE FROM Messages WHERE Id = @Id;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            cmd.ExecuteNonQuery();
        }

        // ========================
        // MAPPING (SQLite → class)
        // ========================
        private static MessageEntity MapMessage(SqliteDataReader reader)
        {
            return new MessageEntity
            {
                Id = Guid.Parse(reader["Id"].ToString()!),
                IsImage = Convert.ToInt32(reader["IsImage"]) == 1,
                Content = reader["Content"].ToString()!,
                UserId = Guid.Parse(reader["UserId"].ToString()!),
                RoomId = Guid.Parse(reader["RoomId"].ToString()!),
                SentTime = DateTime.Parse(reader["SentTime"].ToString()!)
            };
        }
    }
}