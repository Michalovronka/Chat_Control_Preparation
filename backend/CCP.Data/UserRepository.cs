using System.Data.SQLite;
using CCP.Domain.Entities;

namespace CCP.Data
{
   public class UserRepository : IUserRepository
    {
        private const string ConnectionString = "Data Source=chat.db;Version=3;";

        // ========================
        // CREATE
        // ========================
        public void Add(UserEntity user)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            INSERT INTO Users
            (Id, UserName, LastTimeSeen, StatusMessage, UserState, CurrentRoomId, ConnectionId)
            VALUES
            (@Id, @UserName, @LastTimeSeen, @StatusMessage, @UserState, @CurrentRoomId, @ConnectionId);";

            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", user.Id.ToString());
            cmd.Parameters.AddWithValue("@UserName", user.UserName);
            cmd.Parameters.AddWithValue("@LastTimeSeen", user.LastTimeSeen.ToString("o"));
            cmd.Parameters.AddWithValue("@StatusMessage", (object?)user.StatusMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@UserState", user.UserState);
            cmd.Parameters.AddWithValue("@CurrentRoomId", (object?)user.CurrentRoomId?.ToString() ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ConnectionId", (object?)user.ConnectionId ?? DBNull.Value);

            cmd.ExecuteNonQuery();
        }

        // ========================
        // READ - BY ID
        // ========================
        public UserEntity? GetById(Guid id)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Users WHERE Id = @Id;";
            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            using var reader = cmd.ExecuteReader();
            if (!reader.Read())
                return null;

            return MapUser(reader);
        }

        

        // ========================
        // READ - ALL
        // ========================
        public IEnumerable<UserEntity> GetAll()
        {
            var users = new List<UserEntity>();

            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Users;";
            using var cmd = new SQLiteCommand(sql, conn);
            using var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                users.Add(MapUser(reader));
            }

            return users;
        }

        // ========================
        // UPDATE
        // ========================
        public void Update(UserEntity user)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            UPDATE Users SET
                UserName = @UserName,
                LastTimeSeen = @LastTimeSeen,
                StatusMessage = @StatusMessage,
                UserState = @UserState,
                CurrentRoomId = @CurrentRoomId,
                ConnectionId = @ConnectionId
            WHERE Id = @Id;";

            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", user.Id.ToString());
            cmd.Parameters.AddWithValue("@UserName", user.UserName);
            cmd.Parameters.AddWithValue("@LastTimeSeen", user.LastTimeSeen.ToString("o"));
            cmd.Parameters.AddWithValue("@StatusMessage", (object?)user.StatusMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@UserState", user.UserState);
            cmd.Parameters.AddWithValue("@CurrentRoomId", (object?)user.CurrentRoomId?.ToString() ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ConnectionId", (object?)user.ConnectionId ?? DBNull.Value);

            cmd.ExecuteNonQuery();
        }

        // ========================
        // DELETE
        // ========================
        public void Delete(Guid id)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "DELETE FROM Users WHERE Id = @Id;";
            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            cmd.ExecuteNonQuery();
        }

        // ========================
        // MAPPING (SQLite → class)
        // ========================
        private static UserEntity MapUser(SQLiteDataReader reader)
        {
            return new UserEntity
            {
                Id = Guid.Parse(reader["Id"].ToString()!),
                UserName = reader["UserName"].ToString()!,
                LastTimeSeen = DateTime.Parse(reader["LastTimeSeen"].ToString()!),
                StatusMessage = reader["StatusMessage"] == DBNull.Value
                    ? null
                    : reader["StatusMessage"].ToString(),
                UserState = reader["UserState"].ToString()!,
                CurrentRoomId = reader["CurrentRoomId"] == DBNull.Value
                    ? null
                    : Guid.Parse(reader["CurrentRoomId"].ToString()!),
                ConnectionId = reader["ConnectionId"] == DBNull.Value
                    ? null
                    : reader["ConnectionId"].ToString()
            };
        }
        
        public UserEntity[] GetUsersInRoom(Guid roomIdd)
        {
            throw new NotImplementedException();
        }
    }
    
}