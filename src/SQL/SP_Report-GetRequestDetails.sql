USE [MIM_RequestArchive]
GO

/****** Object:  StoredProcedure [dbo].[Report-GetRequestDetails]    Script Date: 15.03.2018 15:54:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Fredrik Melby, Crayon AS
-- Create date: 15.2.2018
-- Description:	Procedure to pull detailed request data/information from the request archive
-- =============================================
CREATE PROCEDURE [dbo].[Report-GetRequestDetails]
	@RequestId uniqueidentifier,
	@DataType nvarchar(50)
AS
BEGIN
SET NOCOUNT ON;

---------------------------------------------------
-- Fetch "raw" request data from dbo.RequestData table
---------------------------------------------------
IF (@DataType = 'RAW') BEGIN
	SELECT
		id,
		inserted,
		RequestID,
		AttributeKey,
		AttributeName,
		DataTypeKey,
		DataTypeKey,
		Multivalued,
		TextValue,
		StringValue,
		DateTimeValue,
		ReferenceValue,
		IntegerValue,
		BoolValue
	FROM dbo.RequestData
	WHERE RequestID = @RequestId
END;

---------------------------------------------------
-- Fetch basic request data from dbo.RequestData table
---------------------------------------------------
IF (@DataType = 'Basic') BEGIN
	SELECT
		Request.RequestID,
		DisplayName.StringValue as RequestName,
		Operation.StringValue as Operation,
		Status.StringValue as Status,
		NULLIF(CAST(CAST(StatusDetails.TextValue as XML).query('/RequestStatusDetail/node()') as nvarchar(4000)),'') as StatusDetails,
		Partition.StringValue as Partition,
		Created.DateTimeValue as CreatedTime,
		Committed.DateTimeValue as CommittedTime,
		Completed.DateTimeValue as CompletedTime,
		dbo.resolveObject(Creator.ReferenceValue) as Creator,
		dbo.resolveObject(Target.ReferenceValue) as Target
	FROM (SELECT DISTINCT RequestId FROM dbo.RequestData WHERE RequestID = @RequestId) as Request
	LEFT JOIN dbo.RequestData as DisplayName ON (DisplayName.RequestID = Request.RequestID AND DisplayName.AttributeKey = 66) -- DisplayName
	LEFT JOIN dbo.RequestData as Operation ON (Operation.RequestID = Request.RequestID AND Operation.AttributeKey = 136) -- Operation
	LEFT JOIN dbo.RequestData as Status ON (Status.RequestID = Request.RequestID AND Status.AttributeKey = 158) -- Status
	LEFT JOIN dbo.RequestData as StatusDetails ON (StatusDetails.RequestID = Request.RequestID AND StatusDetails.AttributeKey = 159) -- StatusDetails
	LEFT JOIN dbo.RequestData as Partition ON (Partition.RequestID = Request.RequestID AND Partition.AttributeKey = 251) -- Partition
	LEFT JOIN dbo.RequestData as Created ON (Created.RequestID = Request.RequestID AND Created.AttributeKey = 53) -- Created Time
	LEFT JOIN dbo.RequestData as Committed ON (Committed.RequestID = Request.RequestID AND Committed.AttributeKey = 37) -- Committed time
	LEFT JOIN dbo.RequestData as Completed ON (Completed.RequestID = Request.RequestID AND Completed.AttributeKey = 257) -- Completed time
	LEFT JOIN dbo.RequestData as Creator ON (Creator.RequestID = Request.RequestID AND Creator.AttributeKey = 55) -- Creator
	LEFT JOIN dbo.RequestData as Target ON (Target.RequestID = Request.RequestID AND Target.AttributeKey = 227) -- Target
END;

---------------------------------------------------
-- Fetch request details from dbo.RequestData: MPRs
---------------------------------------------------
IF (@DataType = 'MPR') BEGIN
	SELECT
		ReferenceValue as Id, 
		dbo.resolveObject(ReferenceValue) as Name
	FROM dbo.RequestData
	WHERE
		RequestID = @RequestId
		AND AttributeKey = 118
END;

---------------------------------------------------
-- Fetch request details from dbo.RequestData: Workflows
---------------------------------------------------
IF (@DataType = 'Workflow') BEGIN
	SELECT
		AttributeName as WorkflowType, 
		dbo.resolveObject(ReferenceValue) as WorkflowName
	FROM dbo.RequestData
	WHERE
		RequestID = @RequestId
		AND AttributeKey IN (5,24,29) -- Action, AuthN, AuthZ Workflows
END;

---------------------------------------------------
-- Fetch request details from dbo.RequestData: Request Chain
---------------------------------------------------
IF (@DataType = 'RequestChain') BEGIN
	-- Get Current Request
	SELECT Request.* INTO #Request FROM
		(SELECT DISTINCT RequestID, ParentRequestID, 0 as Level
		FROM dbo.RequestDataExtracted
		WHERE RequestID = @RequestID) as Request
	
	-- Get Parent Requests if exist and loop until we dont have any parent reference (First request)
	DECLARE @CurrentRequest uniqueidentifier, @NextRequest uniqueidentifier, @Level as int
	SELECT @NextRequest = ParentRequestID, @Level = Level from #Request
	WHILE @NextRequest IS NOT NULL
		BEGIN
			SET @CurrentRequest = @NextRequest
			SELECT DISTINCT @NextRequest = ParentRequestID, @Level = @Level-1 FROM dbo.RequestDataExtracted WHERE RequestID = @CurrentRequest
			INSERT INTO #Request (RequestID,ParentRequestID,Level) VALUES (@CurrentRequest,@NextRequest,@Level)
		END
	
	-- Get 1. level of Child Requests related to this request
	INSERT INTO #Request
		SELECT DISTINCT RequestID, ParentRequestID, 1 as Level 
		FROM dbo.RequestDataExtracted 
		WHERE ParentRequestID = @RequestID
	
	-- Get 2. level of Child Requests related to this request
	INSERT INTO #Request
		SELECT DISTINCT RequestID, ParentRequestID, 2 as Level 
		FROM dbo.RequestDataExtracted 
		WHERE ParentRequestID IN (SELECT RequestID FROM #Request WHERE Level = 1)
	
	-- Get 3. level of Child Requests related to this request
	INSERT INTO #Request
		SELECT DISTINCT RequestID, ParentRequestID, 3 as Level 
		FROM dbo.RequestDataExtracted 
		WHERE ParentRequestID IN (SELECT RequestID FROM #Request WHERE Level = 2)
	
	-- Get 4. level of Child Requests related to this request
	INSERT INTO #Request
		SELECT DISTINCT RequestID, ParentRequestID, 4 as Level 
		FROM dbo.RequestDataExtracted 
		WHERE ParentRequestID IN (SELECT RequestID FROM #Request WHERE Level = 3)
	
	-- Get 5. level of Child Requests related to this request
	INSERT INTO #Request
		SELECT DISTINCT RequestID, ParentRequestID, 5 as Level 
		FROM dbo.RequestDataExtracted 
		WHERE ParentRequestID IN (SELECT RequestID FROM #Request WHERE Level = 4)
	
	-- Return Result
	SELECT
		RequestID,
		dbo.resolveObject(RequestID) as RequestName,
		ParentRequestID,
		Level
	FROM #Request
	ORDER BY LEVEL
END;

---------------------------------------------------
-- Fetch request details from dbo.RequestData: Request Changes
---------------------------------------------------
IF (@DataType = 'Changes') BEGIN
	SELECT
		dbo.ResolveObject(TargetID) as Target,
		AttributeName,
		CASE
			WHEN AttributeValueType = 'q1:guid' THEN dbo.resolveObject(AttributeValue)
			ELSE AttributeValue
		END AS Value,
		AttributeChangeMode as ChangeType
	FROM dbo.RequestDataExtracted
	WHERE RequestID = @RequestId
END;

END
GO


