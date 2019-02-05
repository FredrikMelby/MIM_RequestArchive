USE [MIM_RequestArchive]
GO

/****** Object:  StoredProcedure [dbo].[Stage-RequestData]    Script Date: 15.03.2018 15:53:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Fredrik Melby
-- Create date: 17.3.2016
-- Description:	Get Request data from FIM/MIM and save them to 
--				MIM_RequestArchive staging table for further processing
--
-- Last updated: 7.2.2018, Fredrik Melby
--
-- Update 13.11.2017: Stage only new requests that we havent processed before - removed the @DaysBackToFetch parameter
-- Update 7.2.2018: Code cleanup
-- =============================================
CREATE PROCEDURE [dbo].[Stage-RequestData]

AS

BEGIN

SET NOCOUNT ON;

-- Get all RequestIDs we have in RequestArchive - Filter out these ID's when we search for new requests from FIM/MIM
SELECT Requests.* INTO #Requests FROM
(SELECT DISTINCT RequestID from RequestData) as Requests

-- Delete all content from Staging_RequestData
DELETE FROM Staging_RequestData

-- Fetch new MIM/FIM RequestData and insert them to Staging_RequestData
INSERT INTO Staging_RequestData

-- #########################################
-- Get "ValueText" values for Request objects
-- #########################################
SELECT
	Request.ObjectID as RequestID,
	reqValue.AttributeKey as AttributeKey,
	AttributeType.Name as AttributeName,
	AttributeType.DataTypeKey as DataTypeKey,
	AttributeType.DataType as DataType,
	AttributeType.Multivalued as Multivalued,
	reqValue.ValueText as TextValue,
	NULL as StringValue,
	NULL as IntegerValue,
	NULL as DateTimeValue,
	NULL as ReferenceValue,
	NULL as BoolValue
	
FROM FIMService.FIM.Objects as Request

-- Completed Time - JOIN - Get only finished requests
JOIN FIMService.FIM.ObjectValueDateTime as CompletedTime ON (
	CompletedTime.ObjectKey = Request.ObjectKey
	AND CompletedTime.AttributeKey = 257)

-- Request valuetexts
JOIN FIMService.FIM.ObjectValueText as reqValue ON (
	reqValue.ObjectKey = Request.ObjectKey)

-- Attribute types
LEFT JOIN FIMService.FIM.AttributeInternal as AttributeType ON (
	AttributeType.[Key] = reqValue.AttributeKey)

WHERE 
	Request.ObjectTypeKey = 26
	AND Request.ObjectID NOT IN (SELECT RequestID FROM #Requests)

-- #########################################
-- Get string values for Request objects
-- #########################################
UNION ALL

SELECT
	Request.ObjectID as RequestID,
	reqValue.AttributeKey as AttributeKey,
	AttributeType.Name as AttributeName,
	AttributeType.DataTypeKey as DataTypeKey,
	AttributeType.DataType as DataType,
	AttributeType.Multivalued as Multivalued,
	NULL as TextValue,
	reqValue.ValueString as StringValue,
	NULL as IntegerValue,
	NULL as DateTimeValue,
	NULL as ReferenceValue,
	NULL as BoolValue
	
FROM FIMService.FIM.Objects as Request

-- Completed Time - JOIN - Get only finished requests
JOIN FIMService.FIM.ObjectValueDateTime as CompletedTime ON (
	CompletedTime.ObjectKey = Request.ObjectKey
	AND CompletedTime.AttributeKey = 257)

-- Request string values
JOIN FIMService.FIM.ObjectValueString as reqValue ON (
	reqValue.ObjectKey = Request.ObjectKey)

-- Attribute types
LEFT JOIN FIMService.FIM.AttributeInternal as AttributeType ON (
	AttributeType.[Key] = reqValue.AttributeKey)

WHERE 
	Request.ObjectTypeKey = 26
	AND Request.ObjectID NOT IN (SELECT RequestID FROM #Requests)

-- #########################################
-- Get integer values for Request objects
-- #########################################
UNION ALL

SELECT
	Request.ObjectID as RequestID,
	reqValue.AttributeKey as AttributeKey,
	AttributeType.Name as AttributeName,
	AttributeType.DataTypeKey as DataTypeKey,
	AttributeType.DataType as DataType,
	AttributeType.Multivalued as Multivalued,
	NULL as TextValue,
	NULL as StringValue,
	reqValue.ValueInteger as IntegerValue,
	NULL as DateTimeValue,
	NULL as ReferenceValue,
	NULL as BoolValue
	
FROM FIMService.FIM.Objects as Request

-- Completed Time - JOIN - Get only finished requests
JOIN FIMService.FIM.ObjectValueDateTime as CompletedTime ON (
	CompletedTime.ObjectKey = Request.ObjectKey
	AND CompletedTime.AttributeKey = 257)

-- Request integer values
JOIN FIMService.FIM.ObjectValueInteger as reqValue ON (
	reqValue.ObjectKey = Request.ObjectKey)

-- Attribute types
LEFT JOIN FIMService.FIM.AttributeInternal as AttributeType ON (
	AttributeType.[Key] = reqValue.AttributeKey)

WHERE 
	Request.ObjectTypeKey = 26
	AND Request.ObjectID NOT IN (SELECT RequestID FROM #Requests)

-- #########################################
-- Get datetime values for Request objects
-- #########################################
UNION ALL

SELECT
	Request.ObjectID as RequestID,
	reqValue.AttributeKey as AttributeKey,
	AttributeType.Name as AttributeName,
	AttributeType.DataTypeKey as DataTypeKey,
	AttributeType.DataType as DataType,
	AttributeType.Multivalued as Multivalued,
	NULL as TextValue,
	NULL as StringValue,
	NULL as IntegerValue,
	reqValue.ValueDateTime as DateTimeValue,
	NULL as ReferenceValue,
	NULL as BoolValue
	
FROM FIMService.FIM.Objects as Request

-- Completed Time - JOIN - Get only finished requests
JOIN FIMService.FIM.ObjectValueDateTime as CompletedTime ON (
	CompletedTime.ObjectKey = Request.ObjectKey
	AND CompletedTime.AttributeKey = 257)

-- Request integer values
JOIN FIMService.FIM.ObjectValueDateTime as reqValue ON (
	reqValue.ObjectKey = Request.ObjectKey)

-- Attribute types
LEFT JOIN FIMService.FIM.AttributeInternal as AttributeType ON (
	AttributeType.[Key] = reqValue.AttributeKey)

WHERE 
	Request.ObjectTypeKey = 26
	AND Request.ObjectID NOT IN (SELECT RequestID FROM #Requests)

-- #########################################
-- Get reference values for Request objects
-- #########################################
UNION ALL

SELECT
	Request.ObjectID as RequestID,
	reqValue.AttributeKey as AttributeKey,
	AttributeType.Name as AttributeName,
	AttributeType.DataTypeKey as DataTypeKey,
	AttributeType.DataType as DataType,
	AttributeType.Multivalued as Multivalued,
	NULL as TextValue,
	NULL as StringValue,
	NULL as IntegerValue,
	NULL as DateTimeValue,
	ObjectRef.ObjectID as ReferenceValue,
	NULL as BoolValue
	
FROM FIMService.FIM.Objects as Request

-- Completed Time - JOIN - Get only finished requests
JOIN FIMService.FIM.ObjectValueDateTime as CompletedTime ON (
	CompletedTime.ObjectKey = Request.ObjectKey
	AND CompletedTime.AttributeKey = 257)

-- Request Reference values
JOIN FIMService.FIM.ObjectValueReference as reqValue ON (
	reqValue.ObjectKey = Request.ObjectKey)

-- Resolve reference value to objectID
LEFT JOIN FIMService.FIM.Objects as ObjectRef ON (
	ObjectRef.ObjectKey = reqValue.ValueReference)

-- Attribute types
LEFT JOIN FIMService.FIM.AttributeInternal as AttributeType ON (
	AttributeType.[Key] = reqValue.AttributeKey)

WHERE 
	Request.ObjectTypeKey = 26
	AND Request.ObjectID NOT IN (SELECT RequestID FROM #Requests)

-- #########################################
-- Get bool values for Request objects
-- #########################################
UNION ALL

SELECT
	Request.ObjectID as RequestID,
	reqValue.AttributeKey as AttributeKey,
	AttributeType.Name as AttributeName,
	AttributeType.DataTypeKey as DataTypeKey,
	AttributeType.DataType as DataType,
	AttributeType.Multivalued as Multivalued,
	NULL as TextValue,
	NULL as StringValue,
	NULL as IntegerValue,
	NULL as DateTimeValue,
	NULL as ReferenceValue,
	reqValue.ValueBoolean as BoolValue
	
FROM FIMService.FIM.Objects as Request

-- Completed Time - JOIN - Get only finished requests
JOIN FIMService.FIM.ObjectValueDateTime as CompletedTime ON (
	CompletedTime.ObjectKey = Request.ObjectKey
	AND CompletedTime.AttributeKey = 257)

-- Request bool values
JOIN FIMService.FIM.ObjectValueBoolean as reqValue ON (
	reqValue.ObjectKey = Request.ObjectKey)

-- Attribute types
LEFT JOIN FIMService.FIM.AttributeInternal as AttributeType ON (
	AttributeType.[Key] = reqValue.AttributeKey)

WHERE 
	Request.ObjectTypeKey = 26
	AND Request.ObjectID NOT IN (SELECT RequestID FROM #Requests)

END




GO


