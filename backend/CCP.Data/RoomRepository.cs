using System;
using System.Collections.Generic;
using System.Data.SQLite;
using CCP.Domain.Entities;

namespace CCP.Data
{
    public class RoomRepository : IRoomRepository
    {
        private const string ConnectionString = "Data Source=chat.db;Version=3;";

        // ========================
        // CREATE
        // ========================


        public void Add(RoomEntity room)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            INSERT INTO Rooms
            (Id, Name, PasswordHash)
            VALUES
            (@Id, @Name, @PasswordHash);";

            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", room.Id.ToString());
            cmd.Parameters.AddWithValue("@Name", room.RoomName);
            cmd.Parameters.AddWithValue("@PasswordHash",
                (object?)room.Password ?? DBNull.Value);

            cmd.ExecuteNonQuery();
        }

        // ========================
        // READ - BY ID
        // ========================
        public RoomEntity? GetById(Guid id)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Rooms WHERE Id = @Id;";
            using var cmd = new SQLiteCommand(sql, conn);
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
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Rooms WHERE Name = @Name;";
            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Name", name);

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

            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "SELECT * FROM Rooms;";
            using var cmd = new SQLiteCommand(sql, conn);
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
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = @"
            UPDATE Rooms SET
                Name = @Name,
                PasswordHash = @PasswordHash
            WHERE Id = @Id;";

            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", room.Id.ToString());
            cmd.Parameters.AddWithValue("@Name", room.RoomName);
            cmd.Parameters.AddWithValue("@PasswordHash",
                (object?)room.Password ?? DBNull.Value);

            cmd.ExecuteNonQuery();
        }
        

        // ========================
        // DELETE
        // ========================
        public void Delete(Guid id)
        {
            using var conn = new SQLiteConnection(ConnectionString);
            conn.Open();

            const string sql = "DELETE FROM Rooms WHERE Id = @Id;";
            using var cmd = new SQLiteCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Id", id.ToString());

            cmd.ExecuteNonQuery();
        }

        // ========================
        // MAPPING (SQLite → class)
        // ========================
        private static RoomEntity MapRoom(SQLiteDataReader reader)
        {
            return new RoomEntity
            {
                Id = Guid.Parse(reader["Id"].ToString()!),
                RoomName = reader["Name"].ToString()!,
                Password = reader["PasswordHash"] == DBNull.Value
                    ? null
                    : reader["PasswordHash"].ToString()
            };
        }
    }
}