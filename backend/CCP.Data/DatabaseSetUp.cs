using System.Data.SQLite;

namespace CCP.Data
{
    public static class DatabaseSetUp
    {
        private const string ConnectionString = "Data Source=chat.db;Version=3;";

        public static void Initialize()
        {
            using var connection = new SQLiteConnection(ConnectionString);
            connection.Open();

            CreateUsersTable(connection);
            CreateRoomsTable(connection);
            CreateMessagesTable(connection);
        }

        private static void CreateUsersTable(SQLiteConnection connection)
        {
            var sql = @"
            CREATE TABLE IF NOT EXISTS Users (
                Id TEXT PRIMARY KEY,
                UserName TEXT NOT NULL,
                LastTimeSeen TEXT,
                StatusMessage TEXT,
                UserState TEXT,
                CurrentRoomId TEXT,
                ConnectionId TEXT
            );";

            using var cmd = new SQLiteCommand(sql, connection);
            cmd.ExecuteNonQuery();
        }

        private static void CreateRoomsTable(SQLiteConnection connection)
        {
            var sql = @"
            CREATE TABLE IF NOT EXISTS Rooms (
                Id TEXT PRIMARY KEY,
                Name TEXT NOT NULL,
                PasswordHash TEXT
            );";

            using var cmd = new SQLiteCommand(sql, connection);
            cmd.ExecuteNonQuery();
        }

        private static void CreateMessagesTable(SQLiteConnection connection)
        {
            var sql = @"
            CREATE TABLE IF NOT EXISTS Messages (
                Id TEXT PRIMARY KEY,
                IsImage INTEGER,
                Content TEXT,
                UserId TEXT NOT NULL,
                RoomId TEXT NOT NULL,
                SentTime TEXT,

                FOREIGN KEY (UserId) REFERENCES Users(Id),
                FOREIGN KEY (RoomId) REFERENCES Rooms(Id)
            );";

            using var cmd = new SQLiteCommand(sql, connection);
            cmd.ExecuteNonQuery();
        }
    }
}