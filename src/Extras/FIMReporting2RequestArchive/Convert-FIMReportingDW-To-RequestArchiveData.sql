-- SQL Script for converting FIM Reporting DW to MIM RequestArchive Data
--
-- Fredrik Melby, Crayon 2016
-------------------------------------------------------------------------------------

-- Drop temp table if it exist
Drop table tempdb.dbo.Staging_RequestData

-- Save results to a temp table
SELECT Requests.* INTO tempdb.dbo.Staging_RequestData FROM
(
-- Get RequestID reference
SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	0 as AttributeKey,
	'ObjectID' as AttributeName,
	4 as DataTypeKey,
	'Reference' as DataType,
	0 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	CAST(R.FIMObjectID as uniqueidentifier) as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 -- Get Target id reference - Not used. We get TargetID (GUID) from the RequestParameter XML later.
 /*
 UNION ALL
 SELECT DISTINCT
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	227 as AttributeKey,
	'Target' as AttributeName,
	4 as DataTypeKey,
	'Reference' as DataType,
	0 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	CAST(Rel1.FIMRequestTargetDetailTarget as uniqueidentifier) as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestTargetDetailFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 */
 
 -- Get Creator id reference
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	55 as AttributeKey,
	'Creator' as AttributeName,
	4 as DataTypeKey,
	'Reference' as DataType,
	0 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	CAST(Rel1.FIMCreator as uniqueidentifier) as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 -- Get MPR references
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	118 as AttributeKey,
	'ManagementPolicy' as AttributeName,
	4 as DataTypeKey,
	'Reference' as DataType,
	1 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	CAST(Rel1.MPRObjectID as uniqueidentifier) as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestMPRvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)

WHERE Rel1.MPRObjectID IS NOT NULL
 
 -- Get parent request id reference
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	140 as AttributeKey,
	'ParentRequest' as AttributeName,
	4 as DataTypeKey,
	'Reference' as DataType,
	0 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	CAST(Rel1.FIMRequestParentRequest as uniqueidentifier) as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 WHERE Rel1.FIMRequestParentRequest IS NOT NULL
 
 -- Get completed time (use committed time as completed time for now..)
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	257 as AttributeKey,
	'msidmCompletedTime' as AttributeName,
	2 as DataTypeKey,
	'DateTime' as DataType,
	0 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Rel1.FIMRequestCommittedTime as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 -- Get created time
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	53 as AttributeKey,
	'CreatedTime' as AttributeName,
	2 as DataTypeKey,
	'DateTime' as DataType,
	0 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Rel1.FIMCreatedDate as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 -- Get committed time
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	37 as AttributeKey,
	'CommittedTime' as AttributeName,
	2 as DataTypeKey,
	'DateTime' as DataType,
	0 as Multivalued,
	Null as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Rel1.FIMRequestCommittedTime as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 -- get service partition name
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	251 as AttributeKey,
	'ServicePartitionName' as AttributeName,
	5 as DataTypeKey,
	'String' as DataType,
	0 as Multivalued,
	Null as TextValue,
	CAST(Rel1.FIMRequestServicePartitionName as nvarchar(448)) as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
  -- get target object type - We dont need this information. Get it from RequestParameter XML. It's lost in the DW anyway?
 /*
 UNION ALL
 SELECT DISTINCT
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	228 as AttributeKey,
	'TargetObjectType' as AttributeName,
	5 as DataTypeKey,
	'String' as DataType,
	0 as Multivalued,
	Null as TextValue,
	CAST(Rel2.FIMObjectTypeName as nvarchar(448)) as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
LEFT JOIN [DWDataMart].[dbo].[FIMRequestTargetDetailFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
LEFT JOIN [DWDataMart].[dbo].[FIMObjectTypeDimvw] as Rel2 ON
	(Rel2.FIMObjectTypeDimKey = Rel1.FIMObjectTypeDimKey)
 */
 
 -- get RequestStatus
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	158 as AttributeKey,
	'RequestStatus' as AttributeName,
	5 as DataTypeKey,
	'String' as DataType,
	0 as Multivalued,
	Null as TextValue,
	CASE
		WHEN Rel1.FIMRequestRequestStatus = 'Committed' THEN CAST('Completed' as nvarchar(448))
		Else CAST(Rel1.FIMRequestRequestStatus as nvarchar(448))
	End as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 -- get Operation
 UNION ALL
 SELECT DISTINCT
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	136 as AttributeKey,
	'Operation' as AttributeName,
	5 as DataTypeKey,
	'String' as DataType,
	0 as Multivalued,
	Null as TextValue,
	CASE
		WHEN Rel1.FIMRequestRequestStatusMode IN ('Add','Modify','Remove') THEN CAST('Put' as nvarchar(448))
		Else CAST(Rel1.FIMRequestRequestStatusMode as nvarchar(448))
	End as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestTargetDetailFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
 -- Set object type (static)
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	132 as AttributeKey,
	'ObjectType' as AttributeName,
	5 as DataTypeKey,
	'String' as DataType,
	0 as Multivalued,
	Null as TextValue,
	CAST('Request' as nvarchar(448)) as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R

  -- Set migrated from FIM Reporting DW notification (static)
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	9999 as AttributeKey,
	'MigratedFromDW' as AttributeName,
	5 as DataTypeKey,
	'String' as DataType,
	0 as Multivalued,
	Null as TextValue,
	CAST('Request migrated from FIM Reporting DW' as nvarchar(448)) as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R

 -- get DisplayName
 UNION ALL
 SELECT 
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	66 as AttributeKey,
	'DisplayName' as AttributeName,
	5 as DataTypeKey,
	'String' as DataType,
	0 as Multivalued,
	Null as TextValue,
	CAST(Rel1.FIMDisplayName as nvarchar(448)) as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
 LEFT JOIN [DWDataMart].[dbo].[FIMRequestFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
	
  -- Get/generate request XML data - full XML is lost in the DW... :(
 UNION ALL
 SELECT
	CAST(R.FIMObjectID as uniqueidentifier) as RequestID,
	156 as AttributeKey,
	'RequestParameter' as AttributeName,
	1 as DataTypeKey,
	'Text' as DataType,
	1 as Multivalued,
	-- Generate RequestParameter XML
	CASE
		-- Modify XML
		WHEN Rel1.FIMRequestRequestStatusMode IN ('Add','Modify','Remove') THEN
			CAST('<RequestParameter xmlns:q1="http://microsoft.com/wsdl/types/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="UpdateRequestParameter"><Target>' + 
				Rel1.FIMRequestTargetDetailTarget + 
				'</Target><Calculated>false</Calculated><PropertyName>' + 
				Rel2.FIMAttributeTypeName + 
				'</PropertyName><Value xsi:type="' + 
				CASE Rel2.FIMAttributeTypeDataType
					WHEN 'Binary' THEN 'xsd:base64Binary'
					WHEN 'Boolean' THEN 'xsd:boolean'
					WHEN 'DateTime' THEN 'xsd:dateTime'
					WHEN 'Integer' THEN 'xsd:int'
					WHEN 'Reference' THEN 'q1:guid'
					ELSE 'xsd:string'
				END +
				'">' +
				Replace(Replace(Replace(Replace(Replace(CAST(Rel1.FIMRequestTargetDetailAttributeValue as nvarchar(MAX)),'<','&lt;'),'>','&gt;'),'&','&amp;'),'"','&quot;'),'''','&apos;') +
				'</Value><Operation>Create</Operation><Mode>' +
				Rel1.FIMRequestRequestStatusMode +
				'</Mode></RequestParameter>'					  
			 as nvarchar(MAX))
		-- Create XML
		WHEN Rel1.FIMRequestRequestStatusMode = 'Create' THEN
			CAST('<RequestParameter xmlns:q1="http://microsoft.com/wsdl/types/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CreateRequestParameter"><Target>' + 
				Rel1.FIMRequestTargetDetailTarget + 
				'</Target><Calculated>false</Calculated><PropertyName>' + 
				Rel2.FIMAttributeTypeName + 
				'</PropertyName><Value xsi:type="' + 
				CASE Rel2.FIMAttributeTypeDataType
					WHEN 'Binary' THEN 'xsd:base64Binary'
					WHEN 'Boolean' THEN 'xsd:boolean'
					WHEN 'DateTime' THEN 'xsd:dateTime'
					WHEN 'Integer' THEN 'xsd:int'
					WHEN 'Reference' THEN 'q1:guid'
					ELSE 'xsd:string'
				END +
				'">' +
				Replace(Replace(Replace(Replace(Replace(CAST(Rel1.FIMRequestTargetDetailAttributeValue as nvarchar(MAX)),'<','&lt;'),'>','&gt;'),'&','&amp;'),'"','&quot;'),'''','&apos;') +
				'</Value><Operation>Create</Operation></RequestParameter>'					  
			 as nvarchar(MAX))
		-- Delete XML
		ELSE
			CAST('<RequestParameter xmlns:q1="http://microsoft.com/wsdl/types/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="DeleteRequestParameter"><Target>' + 
				Rel1.FIMRequestTargetDetailTarget + 
				'</Target><Calculated>false</Calculated><Operation>Delete</Operation></RequestParameter>'					  
			 as nvarchar(MAX))
		END as TextValue,
	Null as StringValue,
	Null as IntegerValue,
	Null as DateTimeValue,
	Null as ReferenceValue,
	Null as BoolValue
 FROM [DWDataMart].[dbo].[FIMRequestDimvw] as R
  
LEFT JOIN [DWDataMart].[dbo].[FIMRequestTargetDetailFactvw] as Rel1 ON
	(Rel1.FIMRequestDimKey = R.FIMRequestDimKey)
LEFT JOIN [DWDataMart].[dbo].[FIMAttributeTypeDimvw] as Rel2 ON
	(Rel2.FIMAttributeTypeDimKey = Rel1.FIMAttributeTypeDimKey)

) as Requests


-- Clean up tasks
Delete from tempdb.dbo.Staging_RequestData where RequestID IS NULL -- Some default crap?
Delete from tempdb.dbo.Staging_RequestData where AttributeKey = 156 AND TextValue IS NULL
Delete from tempdb.dbo.Staging_RequestData where AttributeKey = 136 AND StringValue IS NULL
