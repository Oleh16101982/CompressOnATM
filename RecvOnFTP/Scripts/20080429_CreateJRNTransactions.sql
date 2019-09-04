if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JRNTransactions]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[JRNTransactions]
GO

CREATE TABLE [dbo].[JRNTransactions] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[ATM] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FUIB] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FileName] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FileNameOrg] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[date] [datetime] NULL ,
	[datetime] [datetime] NULL ,
	[TypePS] [tinyint] NULL ,
	[Card] [varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[DateCard] [datetime] NULL ,
	[DateTaken] [datetime] NULL ,
	[DateEnd] [datetime] NULL ,
	[Success] [tinyint] NULL ,
	[Creator] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Created] [datetime] NOT NULL ,
	[Changer] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Changed] [datetime] NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[JRNTransactions] ADD 
	CONSTRAINT [DF_JRNTransactions_Creator] DEFAULT (suser_sname()) FOR [Creator],
	CONSTRAINT [DF_JRNTransactions_Created] DEFAULT (getdate()) FOR [Created],
	CONSTRAINT [DF_JRNTransactions_Changer] DEFAULT (suser_sname()) FOR [Changer],
	CONSTRAINT [DF_JRNTransactions_Changed] DEFAULT (getdate()) FOR [Changed],
	CONSTRAINT [PK_JRNTransactions] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

