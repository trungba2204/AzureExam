-- =============================================
-- Stored Procedures for BATTLEGAME Database
-- =============================================

USE BATTLEGAME;
GO

-- =============================================
-- Procedure: sp_RegisterPlayer
-- Description: Register a new player
-- =============================================
CREATE OR ALTER PROCEDURE sp_RegisterPlayer
    @PlayerName NVARCHAR(64),
    @FullName NVARCHAR(128),
    @Age NVARCHAR(10),
    @Level INT = 1,
    @Email NVARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if player name already exists
        IF EXISTS (SELECT 1 FROM Player WHERE PlayerName = @PlayerName)
        BEGIN
            RAISERROR('Player name already exists', 16, 1);
            RETURN;
        END
        
        -- Insert new player
        DECLARE @PlayerId UNIQUEIDENTIFIER = NEWID();
        
        INSERT INTO Player (PlayerId, PlayerName, FullName, Age, [Level], Email)
        VALUES (@PlayerId, @PlayerName, @FullName, @Age, @Level, @Email);
        
        -- Return the new player
        SELECT PlayerId, PlayerName, FullName, Age, [Level], Email, CreatedDate
        FROM Player
        WHERE PlayerId = @PlayerId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_CreateAsset
-- Description: Create a new asset
-- =============================================
CREATE OR ALTER PROCEDURE sp_CreateAsset
    @AssetName NVARCHAR(64),
    @LevelRequire INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if asset name already exists
        IF EXISTS (SELECT 1 FROM Asset WHERE AssetName = @AssetName)
        BEGIN
            RAISERROR('Asset name already exists', 16, 1);
            RETURN;
        END
        
        -- Insert new asset
        DECLARE @AssetId UNIQUEIDENTIFIER = NEWID();
        
        INSERT INTO Asset (AssetId, AssetName, LevelRequire)
        VALUES (@AssetId, @AssetName, @LevelRequire);
        
        -- Return the new asset
        SELECT AssetId, AssetName, LevelRequire, CreatedDate
        FROM Asset
        WHERE AssetId = @AssetId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_GetAssetsByPlayer
-- Description: Get report of all players with their assets
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetAssetsByPlayer
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ROW_NUMBER() OVER (ORDER BY p.PlayerName, a.AssetName) AS No,
        p.PlayerName AS [Player name],
        p.[Level] AS [Level],
        p.Age AS [Age],
        a.AssetName AS [Asset name]
    FROM Player p
    INNER JOIN PlayerAsset pa ON p.PlayerId = pa.PlayerId
    INNER JOIN Asset a ON pa.AssetId = a.AssetId
    ORDER BY p.PlayerName, a.AssetName;
END
GO

-- =============================================
-- Procedure: sp_AssignAssetToPlayer
-- Description: Assign an asset to a player
-- =============================================
CREATE OR ALTER PROCEDURE sp_AssignAssetToPlayer
    @PlayerName NVARCHAR(64),
    @AssetName NVARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @PlayerId UNIQUEIDENTIFIER;
        DECLARE @AssetId UNIQUEIDENTIFIER;
        
        -- Get Player ID
        SELECT @PlayerId = PlayerId FROM Player WHERE PlayerName = @PlayerName;
        IF @PlayerId IS NULL
        BEGIN
            RAISERROR('Player not found', 16, 1);
            RETURN;
        END
        
        -- Get Asset ID
        SELECT @AssetId = AssetId FROM Asset WHERE AssetName = @AssetName;
        IF @AssetId IS NULL
        BEGIN
            RAISERROR('Asset not found', 16, 1);
            RETURN;
        END
        
        -- Check if player already has this asset
        IF EXISTS (SELECT 1 FROM PlayerAsset WHERE PlayerId = @PlayerId AND AssetId = @AssetId)
        BEGIN
            RAISERROR('Player already has this asset', 16, 1);
            RETURN;
        END
        
        -- Assign asset to player
        INSERT INTO PlayerAsset (PlayerId, AssetId)
        VALUES (@PlayerId, @AssetId);
        
        SELECT 'Asset assigned successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

PRINT 'Stored procedures created successfully!';
GO

