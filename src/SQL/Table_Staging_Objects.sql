USE [MIM_RequestArchive]
GO

/****** Object:  Table [dbo].[Staging_Objects]    Script Date: 09/20/2016 09:50:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Staging_Objects](
	[ObjectID] [uniqueidentifier] NOT NULL,
	[ObjectType] [nvarchar](448) NOT NULL,
	[AccountName] [nvarchar](448) NULL,
	[DisplayName] [nvarchar](448) NULL,
	[CreatedTime] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL
) ON [PRIMARY]

GO


