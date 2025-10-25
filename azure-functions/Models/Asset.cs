using System;

namespace BattleGameFunctions.Models
{
    /// <summary>
    /// Asset model representing a game asset (Hero, equipment, etc.)
    /// </summary>
    public class Asset
    {
        public Guid AssetId { get; set; }
        public string AssetName { get; set; } = string.Empty;
        public int LevelRequire { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    /// <summary>
    /// Request model for creating a new asset
    /// </summary>
    public class CreateAssetRequest
    {
        public string AssetName { get; set; } = string.Empty;
        public int LevelRequire { get; set; }
    }
}

