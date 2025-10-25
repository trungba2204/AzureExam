-- =============================================
-- Script: Create BATTLEGAME Database
-- Description: Database for Studio Game
-- Author: SET01 Exam
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BATTLEGAME')
BEGIN
    CREATE DATABASE BATTLEGAME;
END
GO

USE BATTLEGAME;
GO

-- =============================================
-- Table: Asset
-- Description: Store all assets (Hero, equipment, etc.)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Asset')
BEGIN
    CREATE TABLE Asset (
        AssetId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        AssetName NVARCHAR(64) NOT NULL,
        LevelRequire INT NOT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        CONSTRAINT CK_Asset_LevelRequire CHECK (LevelRequire >= 0)
    );
END
GO

-- =============================================
-- Table: Player
-- Description: Store all player information
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Player')
BEGIN
    CREATE TABLE Player (
        PlayerId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        PlayerName NVARCHAR(64) NOT NULL UNIQUE,
        FullName NVARCHAR(128) NOT NULL,
        Age NVARCHAR(10) NOT NULL,
        [Level] INT NOT NULL DEFAULT 1,
        Email NVARCHAR(64) NOT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        CONSTRAINT CK_Player_Level CHECK ([Level] >= 1)
    );
END
GO

-- =============================================
-- Table: PlayerAsset
-- Description: Store all assets of any player
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PlayerAsset')
BEGIN
    CREATE TABLE PlayerAsset (
        PlayerId UNIQUEIDENTIFIER NOT NULL,
        AssetId UNIQUEIDENTIFIER NOT NULL,
        AcquiredDate DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (PlayerId, AssetId),
        CONSTRAINT FK_PlayerAsset_Player FOREIGN KEY (PlayerId) 
            REFERENCES Player(PlayerId) ON DELETE CASCADE,
        CONSTRAINT FK_PlayerAsset_Asset FOREIGN KEY (AssetId) 
            REFERENCES Asset(AssetId) ON DELETE CASCADE
    );
END
GO

-- =============================================
-- Create Indexes for Performance
-- =============================================
CREATE NONCLUSTERED INDEX IX_PlayerAsset_PlayerId ON PlayerAsset(PlayerId);
CREATE NONCLUSTERED INDEX IX_PlayerAsset_AssetId ON PlayerAsset(AssetId);
CREATE NONCLUSTERED INDEX IX_Player_PlayerName ON Player(PlayerName);
GO

-- =============================================
-- Insert Sample Data
-- =============================================

-- Sample Assets
INSERT INTO Asset (AssetId, AssetName, LevelRequire) VALUES
(NEWID(), 'Hero 1', 1),
(NEWID(), 'Hero 2', 5),
(NEWID(), 'Sword of Light', 10),
(NEWID(), 'Shield of Defense', 8),
(NEWID(), 'Magic Staff', 15);
GO

PRINT 'Database BATTLEGAME created successfully!';
GO

