USE [MIM_RequestArchive]
GO

/****** Object:  Table [dbo].[Objects]    Script Date: 09/20/2016 09:49:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Objects](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inserted] [datetime] NOT NULL,
	[ObjectID] [uniqueidentifier] NOT NULL,
	[ObjectType] [nvarchar](448) NOT NULL,
	[AccountName] [nvarchar](448) NULL,
	[DisplayName] [nvarchar](448) NULL,
	[CreatedTime] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NULL,
	[MarkedAsDeleted] [datetime] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Objects] ADD  CONSTRAINT [DF_Objects_Inserted]  DEFAULT (getdate()) FOR [Inserted]
GO


