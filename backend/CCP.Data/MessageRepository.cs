using System;
using System.Collections.Generic;
using System.Data.SQLite;
using CCP.Domain.Entities;

namespace CCP.Data
{
    public class MessageRepository : IMessageRepository
    {
        private IMessageRepository _messageRepositoryImplementation;
        private const string ConnectionString = "Data Source=chat.db;Version=3;";

        // ========================
        // CREATE
        // ========================
        public IEnumerable<MessageEntity> GetAll()
        {
            throw new NotImplementedException();
        }
        
        public void Update(MessageEntity entity)
        {
            throw new NotImplementedException();
        }

        public void Add(MessageEntity message)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            INSERT INTO Messages
            (Id, IsImage, Content, UserId, RoomId, SentTime)
            VALUES
            (@Id, @IsImage, @Content, @UserId, @RoomId, @SentTime);";

            using var cmd = new SQLiteCommand(sql, conn);
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
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Messages WHERE Id = @Id;";
            using var cmd = new SQLiteCommand(sql, conn);
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

            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            SELECT * FROM Messages
            WHERE RoomId = @RoomId
            ORDER BY SentTime ASC;";

            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@RoomId", roomId.ToString());

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                messages.Add(MapMessage(reader));
            }

            return messages;
        }

        // ========================
        // DELETE
        // ========================
        public void Delete(Guid id)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "DELETE FROM Messages WHERE Id = @Id;";
            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            cmd.ExecuteNonQuery();
        }

        // ========================
        // MAPPING (SQLite → class)
        // ========================
        private static MessageEntity MapMessage(SQLiteDataReader reader)
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