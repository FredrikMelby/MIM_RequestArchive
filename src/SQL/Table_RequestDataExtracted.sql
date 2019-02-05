USE [MIM_RequestArchive]
GO

/****** Object:  Table [dbo].[RequestDataExtracted]    Script Date: 09/20/2016 09:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestDataExtracted](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[inserted] [datetime] NOT NULL,
	[RequestID] [uniqueidentifier] NOT NULL,
	[RequestorID] [uniqueidentifier] NULL,
	[ParentRequestID] [uniqueidentifier] NULL,
	[RequestTargetID] [uniqueidentifier] NULL,
	[RequestOperation] [nvarchar](448) NULL,
	[RequestStatus] [nvarchar](448) NULL,
	[CreatedTime] [datetime] NULL,
	[CompletedTime] [datetime] NULL,
	[TargetID] [uniqueidentifier] NULL,
	[AttributeName] [nvarchar](448) NULL,
	[AttributeChangeMode] [nvarchar](448) NULL,
	[AttributeValueType] [nvarchar](64) NULL,
	[AttributeValue] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RequestDataExtracted] ADD  CONSTRAINT [DF_RequestChangesArchive_inserted]  DEFAULT (getdate()) FOR [inserted]
GO


