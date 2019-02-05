-- Stage converted RequestData from FIM Reporting DW server to RequestArchive (Via linked server)
-- Remember to disable MIM_RequestArchive SQL job while running this script!
--
-- Fredrik Melby, Crayon 2016
-------------------------------------------------------------------------------
USE MIM_RequestArchive

-- Delete all content from Staging_RequestData
DELETE FROM Staging_RequestData

-- Fetch RequestData and insert them to Staging_RequestData
INSERT INTO Staging_RequestData

SELECT [RequestID]
      ,[AttributeKey]
      ,[AttributeName]
      ,[DataTypeKey]
      ,[DataType]
      ,[Multivalued]
      ,[TextValue]
      ,[StringValue]
      ,[IntegerValue]
      ,[DateTimeValue]
      ,[ReferenceValue]
      ,[BoolValue]
FROM [OSE-SCSM02.NBSEMP.NO].[tempdb].[dbo].[Staging_RequestData]
-- Get only requests we dont have!
WHERE RequestID NOT IN (SELECT DISTINCT RequestID from RequestDataArchive)



