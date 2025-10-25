using System;

namespace BattleGameFunctions.Models
{
    /// <summary>
    /// Player model representing a game player
    /// </summary>
    public class Player
    {
        public Guid PlayerId { get; set; }
        public string PlayerName { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Age { get; set; } = string.Empty;
        public int Level { get; set; }
        public string Email { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; }
    }

    /// <summary>
    /// Request model for registering a new player
    /// </summary>
    public class RegisterPlayerRequest
    {
        public string PlayerName { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Age { get; set; } = string.Empty;
        public int Level { get; set; } = 1;
        public string Email { get; set; } = string.Empty;
    }
}

