USE [MIM_RequestArchive]
GO

/****** Object:  StoredProcedure [dbo].[Merge-StagedObjects]    Script Date: 09/20/2016 09:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Fredrik Melby
-- Create date: 20.11.2015
-- Description:	Merges Staging_Objecs to Objects
-- Updated: 18.3.2016
-- =============================================
CREATE PROCEDURE [dbo].[Merge-StagedObjects] 

AS
BEGIN

SET NOCOUNT ON;

MERGE MIM_RequestArchive.dbo.Objects as Destination
USING MIM_RequestArchive.dbo.Staging_Objects as Source
	ON Destination.ObjectID = Source.ObjectID

-- Insert new objects to ObjectArchive
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ObjectID, ObjectType, AccountName, DisplayName, CreatedTime, CreatedBy)
	VALUES (ObjectID, ObjectType, AccountName, DisplayName, CreatedTime, CreatedBy)

-- Mark objects no longer seen as deleted
WHEN NOT MATCHED BY SOURCE AND Destination.Deleted IS NULL THEN UPDATE
	SET Destination.Deleted = 1,
		Destination.MarkedAsDeleted = Getdate()
	
-- Update existing object with new DisplayName or AccountName
WHEN MATCHED AND Destination.DisplayName != Source.DisplayName OR Destination.AccountName != Source.AccountName THEN UPDATE
	SET Destination.DisplayName = Source.DisplayName,
		Destination.AccountName = Source.AccountName;
		
END




GO


