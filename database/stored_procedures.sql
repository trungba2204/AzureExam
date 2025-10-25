-- =============================================
-- Stored Procedures for BATTLEGAME Database (MySQL)
-- =============================================

USE BATTLEGAME;

-- =============================================
-- Procedure: sp_RegisterPlayer
-- Description: Register a new player
-- =============================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_RegisterPlayer //

CREATE PROCEDURE sp_RegisterPlayer(
    IN p_PlayerName VARCHAR(64),
    IN p_FullName VARCHAR(128),
    IN p_Age VARCHAR(10),
    IN p_Level INT,
    IN p_Email VARCHAR(64)
)
BEGIN
    DECLARE v_PlayerId VARCHAR(36);
    DECLARE v_Count INT;
    
    -- Check if player name already exists
    SELECT COUNT(*) INTO v_Count FROM Player WHERE PlayerName = p_PlayerName;
    
    IF v_Count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Player name already exists';
    ELSE
        -- Insert new player
        SET v_PlayerId = UUID();
        
        INSERT INTO Player (PlayerId, PlayerName, FullName, Age, `Level`, Email)
        VALUES (v_PlayerId, p_PlayerName, p_FullName, p_Age, p_Level, p_Email);
        
        -- Return the new player
        SELECT PlayerId, PlayerName, FullName, Age, `Level`, Email, CreatedDate
        FROM Player
        WHERE PlayerId = v_PlayerId;
    END IF;
END //

DELIMITER ;

-- =============================================
-- Procedure: sp_CreateAsset
-- Description: Create a new asset
-- =============================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_CreateAsset //

CREATE PROCEDURE sp_CreateAsset(
    IN p_AssetName VARCHAR(64),
    IN p_LevelRequire INT
)
BEGIN
    DECLARE v_AssetId VARCHAR(36);
    DECLARE v_Count INT;
    
    -- Check if asset name already exists
    SELECT COUNT(*) INTO v_Count FROM Asset WHERE AssetName = p_AssetName;
    
    IF v_Count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Asset name already exists';
    ELSE
        -- Insert new asset
        SET v_AssetId = UUID();
        
        INSERT INTO Asset (AssetId, AssetName, LevelRequire)
        VALUES (v_AssetId, p_AssetName, p_LevelRequire);
        
        -- Return the new asset
        SELECT AssetId, AssetName, LevelRequire, CreatedDate
        FROM Asset
        WHERE AssetId = v_AssetId;
    END IF;
END //

DELIMITER ;

-- =============================================
-- Procedure: sp_GetAssetsByPlayer
-- Description: Get report of all players with their assets
-- =============================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_GetAssetsByPlayer //

CREATE PROCEDURE sp_GetAssetsByPlayer()
BEGIN
    SELECT 
        ROW_NUMBER() OVER (ORDER BY p.PlayerName, a.AssetName) AS `No`,
        p.PlayerName AS `Player name`,
        p.`Level` AS `Level`,
        p.Age AS `Age`,
        a.AssetName AS `Asset name`
    FROM Player p
    INNER JOIN PlayerAsset pa ON p.PlayerId = pa.PlayerId
    INNER JOIN Asset a ON pa.AssetId = a.AssetId
    ORDER BY p.PlayerName, a.AssetName;
END //

DELIMITER ;

-- =============================================
-- Procedure: sp_AssignAssetToPlayer
-- Description: Assign an asset to a player
-- =============================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_AssignAssetToPlayer //

CREATE PROCEDURE sp_AssignAssetToPlayer(
    IN p_PlayerName VARCHAR(64),
    IN p_AssetName VARCHAR(64)
)
BEGIN
    DECLARE v_PlayerId VARCHAR(36);
    DECLARE v_AssetId VARCHAR(36);
    DECLARE v_Count INT;
    
    -- Get Player ID
    SELECT PlayerId INTO v_PlayerId FROM Player WHERE PlayerName = p_PlayerName;
    
    IF v_PlayerId IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Player not found';
    END IF;
    
    -- Get Asset ID
    SELECT AssetId INTO v_AssetId FROM Asset WHERE AssetName = p_AssetName;
    
    IF v_AssetId IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Asset not found';
    END IF;
    
    -- Check if player already has this asset
    SELECT COUNT(*) INTO v_Count 
    FROM PlayerAsset 
    WHERE PlayerId = v_PlayerId AND AssetId = v_AssetId;
    
    IF v_Count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Player already has this asset';
    ELSE
        -- Assign asset to player
        INSERT INTO PlayerAsset (PlayerId, AssetId)
        VALUES (v_PlayerId, v_AssetId);
        
        SELECT 'Asset assigned successfully' AS Message;
    END IF;
END //

DELIMITER ;

SELECT 'Stored procedures created successfully!' AS Message;
