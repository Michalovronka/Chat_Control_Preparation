using Microsoft.Data.Sqlite;

namespace CCP.Data
{
    public static class DatabaseSetUp
    {
        private const string ConnectionString = "Data Source=chat.db";

        public static void Initialize()
        {
            using var connection = new SqliteConnection(ConnectionString);
            connection.Open();

            CreateUsersTable(connection);
            CreateRoomsTable(connection);
            CreateMessagesTable(connection);
            CreateInvitesTable(connection);
        }

        private static void CreateUsersTable(SqliteConnection connection)
        {
            var sql = @"
            CREATE TABLE IF NOT EXISTS Users (
                Id TEXT PRIMARY KEY,
                UserName TEXT NOT NULL UNIQUE,
                PasswordHash TEXT,
                LastTimeSeen TEXT,
                StatusMessage TEXT,
                UserState TEXT,
                CurrentRoomId TEXT,
                ConnectionId TEXT,
                JoinedRooms TEXT,
                BlockedUsers TEXT
            );";

            using var cmd = new SqliteCommand(sql, connection);
            cmd.ExecuteNonQuery();

            // Add columns if they don't exist (for existing databases)
            try
            {
                var alterSql = "ALTER TABLE Users ADD COLUMN PasswordHash TEXT;";
                using var alterCmd = new SqliteCommand(alterSql, connection);
                alterCmd.ExecuteNonQuery();
            }
            catch { /* Column already exists */ }

            try
            {
                var alterSql = "ALTER TABLE Users ADD COLUMN JoinedRooms TEXT;";
                using var alterCmd = new SqliteCommand(alterSql, connection);
                alterCmd.ExecuteNonQuery();
            }
            catch { /* Column already exists */ }

            try
            {
                var alterSql = "ALTER TABLE Users ADD COLUMN BlockedUsers TEXT;";
                using var alterCmd = new SqliteCommand(alterSql, connection);
                alterCmd.ExecuteNonQuery();
            }
            catch { /* Column already exists */ }
        }

        private static void CreateRoomsTable(SqliteConnection connection)
        {
            var sql = @"
            CREATE TABLE IF NOT EXISTS Rooms (
                Id TEXT PRIMARY KEY,
                Name TEXT NOT NULL,
                PasswordHash TEXT,
                InviteCode TEXT,
                JoinedUsers TEXT
            );";

            using var cmd = new SqliteCommand(sql, connection);
            cmd.ExecuteNonQuery();

            // Add columns if they don't exist (for existing databases)
            try
            {
                var alterSql = "ALTER TABLE Rooms ADD COLUMN InviteCode TEXT;";
                using var alterCmd = new SqliteCommand(alterSql, connection);
                alterCmd.ExecuteNonQuery();
            }
            catch { /* Column already exists */ }

            try
            {
                var alterSql = "ALTER TABLE Rooms ADD COLUMN JoinedUsers TEXT;";
                using var alterCmd = new SqliteCommand(alterSql, connection);
                alterCmd.ExecuteNonQuery();
            }
            catch { /* Column already exists */ }
        }

        private static void CreateMessagesTable(SqliteConnection connection)
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

            using var cmd = new SqliteCommand(sql, connection);
            cmd.ExecuteNonQuery();
        }

        private static void CreateInvitesTable(SqliteConnection connection)
        {
            var sql = @"
            CREATE TABLE IF NOT EXISTS Invites (
                Id TEXT PRIMARY KEY,
                SenderUserId TEXT NOT NULL,
                ReceiverUserId TEXT NOT NULL,
                RoomId TEXT NOT NULL,
                SentTime TEXT NOT NULL,
                IsDelivered INTEGER NOT NULL DEFAULT 0,
                FOREIGN KEY (SenderUserId) REFERENCES Users(Id),
                FOREIGN KEY (ReceiverUserId) REFERENCES Users(Id),
                FOREIGN KEY (RoomId) REFERENCES Rooms(Id)
            );";

            using var cmd = new SqliteCommand(sql, connection);
            cmd.ExecuteNonQuery();
        }
    }
}