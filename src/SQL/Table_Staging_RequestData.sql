USE [MIM_RequestArchive]
GO

/****** Object:  Table [dbo].[Staging_RequestData]    Script Date: 09/20/2016 09:51:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Staging_RequestData](
	[RequestID] [uniqueidentifier] NOT NULL,
	[AttributeKey] [smallint] NOT NULL,
	[AttributeName] [nvarchar](448) NOT NULL,
	[DataTypeKey] [smallint] NOT NULL,
	[DataType] [nvarchar](100) NOT NULL,
	[Multivalued] [bit] NULL,
	[TextValue] [nvarchar](max) NULL,
	[StringValue] [nvarchar](448) NULL,
	[IntegerValue] [bigint] NULL,
	[DateTimeValue] [datetime] NULL,
	[ReferenceValue] [uniqueidentifier] NULL,
	[BoolValue] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


