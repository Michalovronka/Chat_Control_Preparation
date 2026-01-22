using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Data.Sqlite;
using CCP.Domain.Entities;

namespace CCP.Data
{
    public class InviteRepository : IInviteRepository
    {
        private const string ConnectionString = "Data Source=chat.db";

        public void Add(InviteEntity invite)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            INSERT INTO Invites
            (Id, SenderUserId, ReceiverUserId, RoomId, SentTime, IsDelivered)
            VALUES
            (@Id, @SenderUserId, @ReceiverUserId, @RoomId, @SentTime, @IsDelivered);";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", invite.Id.ToString());
            cmd.Parameters.AddWithValue("@SenderUserId", invite.SenderUserId.ToString());
            cmd.Parameters.AddWithValue("@ReceiverUserId", invite.ReceiverUserId.ToString());
            cmd.Parameters.AddWithValue("@RoomId", invite.RoomId.ToString());
            cmd.Parameters.AddWithValue("@SentTime", invite.SentTime.ToString("O"));
            cmd.Parameters.AddWithValue("@IsDelivered", invite.IsDelivered ? 1 : 0);

            cmd.ExecuteNonQuery();
        }

        public IEnumerable<InviteEntity> GetPendingInvitesForUser(Guid receiverUserId)
        {
            var invites = new List<InviteEntity>();

            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            SELECT * FROM Invites 
            WHERE ReceiverUserId = @ReceiverUserId 
            AND IsDelivered = 0
            ORDER BY SentTime ASC;";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@ReceiverUserId", receiverUserId.ToString());

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                invites.Add(new InviteEntity
                {
                    Id = Guid.Parse(reader["Id"].ToString()!),
                    SenderUserId = Guid.Parse(reader["SenderUserId"].ToString()!),
                    ReceiverUserId = Guid.Parse(reader["ReceiverUserId"].ToString()!),
                    RoomId = Guid.Parse(reader["RoomId"].ToString()!),
                    SentTime = DateTime.Parse(reader["SentTime"].ToString()!),
                    IsDelivered = reader["IsDelivered"].ToString() == "1"
                });
            }

            return invites;
        }

        public void MarkAsDelivered(Guid inviteId)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            UPDATE Invites 
            SET IsDelivered = 1 
            WHERE Id = @Id;";

            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", inviteId.ToString());
            cmd.ExecuteNonQuery();
        }

        public void Delete(Guid inviteId)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "DELETE FROM Invites WHERE Id = @Id;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", inviteId.ToString());
            cmd.ExecuteNonQuery();
        }

        public void DeleteInvitesForRoom(Guid roomId)
        {
            using var conn = new SqliteConnection(ConnectionString);
            conn.Open();

            const string sql = "DELETE FROM Invites WHERE RoomId = @RoomId;";
            using var cmd = new SqliteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@RoomId", roomId.ToString());
            cmd.ExecuteNonQuery();
        }
    }
}
