USE [MIM_RequestArchive]
GO

/****** Object:  StoredProcedure [dbo].[Report-GetAttributeNames]    Script Date: 09/20/2016 09:52:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Fredrik Melby, Crayon AS
-- Create date: 13.7.2016
-- Description:	Procedure for listing out all available attributes in request archive
-- =============================================
CREATE PROCEDURE [dbo].[Report-GetAttributeNames]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT '*' as AttributeName
	UNION
	SELECT DISTINCT AttributeName FROM RequestDataExtracted WHERE AttributeName IS NOT NULL ORDER BY AttributeName
END

GO


