USE [MIM_RequestArchive]
GO

/****** Object:  StoredProcedure [dbo].[Stage-Objects]    Script Date: 09/20/2016 09:53:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Fredrik Melby
-- Create date: 25.11.2015
-- Description:	Gets all objects from FIM/MIM and saves them
--				to MIM_RequestArchive staging table
-- Updated 12.02.2016, Fredrik Melby
-- =============================================
CREATE PROCEDURE [dbo].[Stage-Objects] 

AS
BEGIN

SET NOCOUNT ON;

-- Delete old result from staging table
DELETE FROM Staging_Objects

-- Get all objects from FIM/MIM and save them to staging table
INSERT INTO Staging_Objects

SELECT
	Object.ObjectID as ObjectID,
	ObjectType.Name as ObjectType,
	AccountName.ValueString as AccountName,
	DisplayName.ValueString as DisplayName,
	CreatedTime.ValueDateTime as CreatedTime,
	Creator.ObjectID as CreatedBy
	
FROM FIMService.fim.Objects as Object

-- Get Object Type
JOIN FIMService.fim.ObjectTypeInternal as ObjectType ON(
	ObjectType.[Key] = Object.ObjectTypeKey)

-- Created Time
JOIN FIMService.FIM.ObjectValueDateTime as CreatedTime ON (
	CreatedTime.ObjectKey = Object.ObjectKey
	AND CreatedTime.AttributeKey = 53)

-- Created by reference
LEFT JOIN FIMService.FIM.ObjectValueReference as CreatorRef ON (
	CreatorRef.ObjectKey = Object.ObjectKey
	AND CreatorRef.AttributeKey = 55)
LEFT JOIN FIMService.FIM.Objects as Creator ON (
	Creator.ObjectKey = CreatorRef.ValueReference)
	
-- DisplayName
LEFT JOIN FIMService.FIM.ObjectValueString as AccountName ON (
	AccountName.ObjectKey = Object.ObjectKey
	AND AccountName.AttributeKey = 1)

-- DisplayName
LEFT JOIN FIMService.FIM.ObjectValueString as DisplayName ON (
	DisplayName.ObjectKey = Object.ObjectKey
	AND DisplayName.AttributeKey = 66
	AND DisplayName.LocaleKey = 127) -- LocaleKey 127 = Default English values

END




GO


