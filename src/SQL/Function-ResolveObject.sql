USE [MIM_RequestArchive]
GO

/****** Object:  UserDefinedFunction [dbo].[resolveObject]    Script Date: 01.08.2018 08:45:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Fredrik Melby, Crayon AS
-- Create date: 7.2.2018
-- Description:	Resolves object GUID to friendly names
-- =============================================
CREATE FUNCTION [dbo].[resolveObject]
(
	@ObjectID uniqueidentifier
)
RETURNS nvarchar(448)
AS
BEGIN
	DECLARE 
		@ReturnName nvarchar(448),
		@ObjectDisplayName nvarchar(448),
		@ObjectAccountName nvarchar(448),
		@ObjectType nvarchar(448)
	
	-- Resolve ObjectID to Friendly Names
	SELECT 
		@ObjectDisplayName = DisplayName,
		@ObjectAccountName = AccountName,
		@ObjectType = ObjectType
	FROM dbo.Objects
	WHERE ObjectID = @ObjectID

	-- Return Firendly Name
	IF (@ObjectAccountName IS NULL and @ObjectDisplayName is null)
		set @ReturnName = @ObjectID
	ELSE IF (@ObjectAccountName IS NOT NULL AND @ObjectDisplayName IS NOT NULL)
		SET @ReturnName = @ObjectDisplayName + ' (' + @ObjectAccountName + ')'
	ELSE
		SET @ReturnName = @ObjectDisplayName

	RETURN @ReturnName;

END

GO


