-- =============================================
-- Script: Create BATTLEGAME Database for MySQL
-- Description: Database for Studio Game
-- Author: SET01 Exam
-- =============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS BATTLEGAME;

USE BATTLEGAME;

-- =============================================
-- Table: Asset
-- Description: Store all assets (Hero, equipment, etc.)
-- =============================================
CREATE TABLE IF NOT EXISTS Asset (
    AssetId VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    AssetName VARCHAR(64) NOT NULL,
    LevelRequire INT NOT NULL,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CK_Asset_LevelRequire CHECK (LevelRequire >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: Player
-- Description: Store all player information
-- =============================================
CREATE TABLE IF NOT EXISTS Player (
    PlayerId VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    PlayerName VARCHAR(64) NOT NULL UNIQUE,
    FullName VARCHAR(128) NOT NULL,
    Age VARCHAR(10) NOT NULL,
    `Level` INT NOT NULL DEFAULT 1,
    Email VARCHAR(64) NOT NULL,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CK_Player_Level CHECK (`Level` >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: PlayerAsset
-- Description: Store all assets of any player
-- =============================================
CREATE TABLE IF NOT EXISTS PlayerAsset (
    PlayerId VARCHAR(36) NOT NULL,
    AssetId VARCHAR(36) NOT NULL,
    AcquiredDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (PlayerId, AssetId),
    CONSTRAINT FK_PlayerAsset_Player FOREIGN KEY (PlayerId) 
        REFERENCES Player(PlayerId) ON DELETE CASCADE,
    CONSTRAINT FK_PlayerAsset_Asset FOREIGN KEY (AssetId) 
        REFERENCES Asset(AssetId) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Create Indexes for Performance
-- =============================================
CREATE INDEX IF NOT EXISTS IX_PlayerAsset_PlayerId ON PlayerAsset(PlayerId);
CREATE INDEX IF NOT EXISTS IX_PlayerAsset_AssetId ON PlayerAsset(AssetId);
CREATE INDEX IF NOT EXISTS IX_Player_PlayerName ON Player(PlayerName);

-- =============================================
-- Insert Sample Data
-- =============================================

-- Sample Assets
INSERT INTO Asset (AssetId, AssetName, LevelRequire) VALUES
(UUID(), 'Hero 1', 1),
(UUID(), 'Hero 2', 5),
(UUID(), 'Sword of Light', 10),
(UUID(), 'Shield of Defense', 8),
(UUID(), 'Magic Staff', 15);

SELECT 'Database BATTLEGAME created successfully!' AS Message;
