-- Extracts request data from staged (converted) request data and merge data into request archive
-- Remember to disable MIM_RequestArchive SQL job while running this script!
--
-- Fredrik Melby, Crayon 2016
-----------------------------------------------------------------------------------------------

-- ###################################################################################
-- Extract Request Change information from RequestXML and show each changes as one row
-- To #RequestChanges
-- ###################################################################################
SELECT RequestChanges.* INTO #RequestChanges FROM
(
SELECT
	Request.RequestID,
	Requestor.ReferenceValue as RequestorID,
	Parent.ReferenceValue as ParentRequestID,
	Target.ReferenceValue as RequestTargetID,
	Operation.StringValue as RequestOperation,
	Status.StringValue as RequestStatus,
	CreatedTime.DateTimeValue as CreatedTime,
	CompletedTime.DateTimeValue as CompletedTime,

	-- Extract detailed information from the Request XML
	CAST(CAST(CAST(RequestParameter.TextValue as XML).query('/RequestParameter/Target/node()') as nvarchar(448)) as uniqueidentifier) as TargetID,
	NULLIF(CAST(CAST(RequestParameter.TextValue as XML).query('/RequestParameter/PropertyName/node()') as nvarchar(448)),'') as AttributeName,
	NULLIF(CAST(CAST(RequestParameter.TextValue as XML).query('/RequestParameter/Mode/node()') as nvarchar(448)),'') as AttributeChangeMode,
	NULLIF(CAST(RequestParameter.TextValue as xml).value('(/RequestParameter/Value/@xsi:type)[1]', 'nvarchar(64)'),'') as AttributeValueType,
	-- Exclude values for certain attribute types (Binary values etc.)
	CASE CAST(RequestParameter.TextValue as xml).value('(/RequestParameter/Value/@xsi:type)[1]', 'nvarchar(64)')
		WHEN 'xsd:base64Binary' THEN 'Binary value - See full request XML for more details'
		ELSE NULLIF(CAST(CAST(RequestParameter.TextValue as XML).query('/RequestParameter/Value/node()') as nvarchar(max)),'')
	END as AttributeValue

FROM (SELECT DISTINCT RequestID FROM Staging_RequestData) as Request

-- Get Requestor/Creator reference
LEFT JOIN Staging_RequestData as Requestor ON (
	Requestor.RequestID = Request.RequestID
	AND Requestor.AttributeKey = 55)

-- Get Created Time
LEFT JOIN Staging_RequestData as CreatedTime ON (
	CreatedTime.RequestID = Request.RequestID
	AND CreatedTime.AttributeKey = 53)

-- Get Completed Time
LEFT JOIN Staging_RequestData as CompletedTime ON (
	CompletedTime.RequestID = Request.RequestID
	AND CompletedTime.AttributeKey = 257)

-- Get Parent request reference
LEFT JOIN Staging_RequestData as Parent ON (
	Parent.RequestID = Request.RequestID
	AND Parent.AttributeKey = 140)

-- Get Target reference
LEFT JOIN Staging_RequestData as Target ON (
	Target.RequestID = Request.RequestID
	AND Target.AttributeKey = 227)

-- Get Request Status
LEFT JOIN Staging_RequestData as Status ON (
	Status.RequestID = Request.RequestID
	AND Status.AttributeKey = 158)

-- Get Request Operation
LEFT JOIN Staging_RequestData as Operation ON (
	Operation.RequestID = Request.RequestID
	AND Operation.AttributeKey = 136)

-- Get Request Parameter XMLs
LEFT JOIN Staging_RequestData as RequestParameter ON (
	RequestParameter.RequestID = Request.RequestID
	AND RequestParameter.AttributeKey = 156)

) as RequestChanges

-- #################################################
-- MERGE #RequestChanges INTO RequestChangesArchive
-- #################################################
MERGE MIM_RequestArchive.dbo.RequestDataExtracted as Destination
USING #RequestChanges as Source
	ON Destination.RequestID = Source.RequestID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (RequestID, RequestorID, ParentRequestID, RequestTargetID, RequestOperation, RequestStatus, CreatedTime, CompletedTime, TargetID, AttributeName, AttributeChangeMode, AttributeValueType, AttributeValue)
	VALUES (RequestID, RequestorID, ParentRequestID, RequestTargetID, RequestOperation, RequestStatus, CreatedTime, CompletedTime, TargetID, AttributeName, AttributeChangeMode, AttributeValueType, AttributeValue);

-- ##################################################
-- MERGE Staged RequestData into RequestDataArchive
-- ##################################################
MERGE MIM_RequestArchive.dbo.RequestDataArchive as Destination
USING MIM_RequestArchive.dbo.Staging_RequestData as Source
	ON Destination.RequestID = Source.RequestID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (RequestID, AttributeKey, AttributeName, DataTypeKey, DataType, Multivalued, TextValue, StringValue, IntegerValue, DateTimeValue, ReferenceValue, BoolValue)
	VALUES (RequestID, AttributeKey, AttributeName, DataTypeKey, DataType, Multivalued, TextValue, StringValue, IntegerValue, DateTimeValue, ReferenceValue, BoolValue);
