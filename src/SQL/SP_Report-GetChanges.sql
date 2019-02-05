USE [MIM_RequestArchive]
GO

/****** Object:  StoredProcedure [dbo].[Report-GetChanges]    Script Date: 07.07.2017 09:21:49 ******/
DROP PROCEDURE [dbo].[Report-GetChanges]
GO

/****** Object:  StoredProcedure [dbo].[Report-GetChanges]    Script Date: 07.07.2017 09:21:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Fredrik Melby, Crayon AS
-- Create date: 13.7.2016
-- Description:	Procedure for querying request changes from the archive
-- =============================================
CREATE PROCEDURE [dbo].[Report-GetChanges]
	@CompletedTimeFrom datetime = NULL,
	@CompletedTimeTo datetime = NULL,
	@RequestID nvarchar(448) = NULL,
	@IncludeChildRequests bit = NULL,
	@RequestorID nvarchar(448) = NULL,
	@RequestorName nvarchar(448) = NULL,
	@TargetID nvarchar(448) = NULL,
	@TargetName nvarchar(448) = NULL,
	@AttributeName nvarchar(448) = NULL
AS

BEGIN

SET NOCOUNT ON;

------------------------------------------
-- Set default values for parameters/handle NULL or blank values
------------------------------------------
IF(@AttributeName = '*' or @AttributeName = N'*' or @AttributeName = '' or @AttributeName = N'')
	BEGIN SELECT @AttributeName = NULL END;

IF (@CompletedTimeFrom = '' or @CompletedTimeFrom = N'' or @CompletedTimeFrom IS NULL)
	BEGIN SELECT @CompletedTimeFrom = GETDATE() -7 END;

IF (@CompletedTimeTo = '' or @CompletedTimeTo = N'' or @CompletedTimeTo IS NULL)
	BEGIN SELECT @CompletedTimeTo = GETDATE() END;

IF(@RequestID = '' or @RequestID = N'')
	BEGIN SELECT @RequestID = NULL END;
	
IF(@RequestorID = '' or @RequestorID = N'')
	BEGIN SELECT @RequestorID = NULL END;

IF(@RequestorName = '' or @RequestorName = N'')
	BEGIN SELECT @RequestorName = NULL END;
	
IF(@TargetID = '' or @TargetID = N'')
	BEGIN SELECT @TargetID = NULL END;

IF(@TargetName = '' or @TargetName = N'')
	BEGIN SELECT @TargetName = NULL END;

IF (@IncludeChildRequests = 0)
	BEGIN SELECT @IncludeChildRequests = NULL END;
		
------------------------------------------			
-- Begin querying request archive
------------------------------------------
SELECT
   RequestChanges.RequestID
  ,Coalesce (Requestor.AccountName, Requestor.DisplayName, CAST (RequestChanges.RequestorID as nvarchar(448))) as Requestor
  ,RequestChanges.RequestorID as RequestorID
  ,Coalesce (Target.AccountName, Target.DisplayName, CAST (RequestChanges.TargetID as nvarchar(448))) as Target
  ,RequestChanges.TargetID as TargetID
  ,Target.ObjectType as TargetObjectType
  ,Parent.DisplayName as ParentRequest
  ,RequestChanges.ParentRequestID
  ,RequestChanges.CreatedTime
  ,RequestChanges.CompletedTime
  ,RequestChanges.RequestOperation
  ,RequestChanges.RequestStatus
  ,Coalesce(RequestChanges.AttributeName, '') as AttributeName
  ,RequestChanges.AttributeChangeMode
  ,Coalesce (ValueReference.AccountName, ValueReference.DisplayName, LEFT(RequestChanges.AttributeValue, 100)) as AttributeValue

FROM
  RequestDataExtracted as RequestChanges

-- Requestor
LEFT JOIN Objects as Requestor ON
(
	RequestChanges.RequestorID = Requestor.ObjectID
)

-- Target
LEFT JOIN Objects as Target ON
(
	RequestChanges.TargetID = Target.ObjectID
)

-- Parent request
LEFT JOIN Objects as Parent ON
(
	RequestChanges.ParentRequestID = Parent.ObjectID
)

-- Resolve attributeValue references to object names
LEFT JOIN Objects as ValueReference ON
(
	ValueReference.ObjectID = (SELECT CAST(AttributeValue as uniqueidentifier) FROM RequestDataExtracted WHERE id = RequestChanges.id AND AttributeValueType = 'q1:guid')
)

WHERE
	-- Always search with date to/from parameters
	RequestChanges.CompletedTime >= @CompletedTimeFrom
	AND RequestChanges.CompletedTime <= @CompletedTimeTo
	-- Optional parameters
	AND 
	(
		@RequestID IS NULL AND @IncludeChildRequests IS NULL
		OR @RequestID IS NULL AND @IncludeChildRequests IS NOT NULL
		OR @RequestID IS NOT NULL AND @IncludeChildRequests IS NULL AND RequestChanges.RequestID = @RequestID
		OR @RequestID IS NOT NULL AND @IncludeChildRequests IS NOT NULL AND (RequestChanges.RequestID = @RequestID OR RequestChanges.ParentRequestID = @RequestID)
	)
	AND
	(
		@RequestorID IS NULL
		OR @RequestorID IS NOT NULL AND RequestChanges.RequestorID = @RequestorID
	)
	AND 
	(
		@RequestorName IS NULL
		-- Full-text catalog search
		-- OR @RequestorName IS NOT NULL AND CONTAINS((Requestor.AccountName, Requestor.DisplayName), @RequestorName)
		OR (@RequestorName IS NOT NULL AND (Requestor.AccountName = @RequestorName or Requestor.DisplayName like @RequestorName))
	)
	AND
	(
		@TargetID IS NULL
		OR @TargetID IS NOT NULL AND RequestChanges.TargetID = @TargetID
	)
	AND
	(
		@TargetName IS NULL
		-- Full-text catalog search
		-- OR @TargetName IS NOT NULL AND CONTAINS((Target.AccountName, Target.DisplayName), @TargetName)
		OR (@TargetName IS NOT NULL AND (Target.AccountName = @TargetName OR Target.DisplayName like @TargetName))
	)
	AND
	(
		@AttributeName IS NULL
		OR @AttributeName IS NOT NULL AND RequestChanges.AttributeName = @AttributeName
	)

ORDER BY
	RequestChanges.CompletedTime DESC

END

GO


