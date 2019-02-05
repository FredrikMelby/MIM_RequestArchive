USE [MIM_RequestArchive]
GO

/****** Object:  StoredProcedure [dbo].[Merge-StagedRequestData]    Script Date: 09/20/2016 09:52:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Fredrik Melby
-- Create date: 18.03.2015
-- Description:	Merges Staging_RequestData into RequestArchive
--
-- Last updated: 18.03.2016, Fredrik Melby
-- =============================================
CREATE PROCEDURE [dbo].[Merge-StagedRequestData] 

AS
BEGIN

SET NOCOUNT ON;

MERGE MIM_RequestArchive.dbo.RequestData as Destination
USING MIM_RequestArchive.dbo.Staging_RequestData as Source
	ON Destination.RequestID = Source.RequestID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (RequestID, AttributeKey, AttributeName, DataTypeKey, DataType, Multivalued, TextValue, StringValue, IntegerValue, DateTimeValue, ReferenceValue, BoolValue)
	VALUES (RequestID, AttributeKey, AttributeName, DataTypeKey, DataType, Multivalued, TextValue, StringValue, IntegerValue, DateTimeValue, ReferenceValue, BoolValue);

END




GO


