if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LogTraceCmdDispense]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LogTraceCmdDispense]
GO

CREATE TABLE [dbo].[LogTraceCmdDispense] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[ATM] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FUIB] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Date] [datetime] NULL ,
	[Time] [datetime] NULL ,
	[DateTime] [datetime] NULL ,
	[FileName] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[NumCass1] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CountCass1] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[KolCass1] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[StatusCass1] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[NumCass2] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CountCass2] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[KolCass2] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[StatusCass2] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[NumCass3] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CountCass3] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[KolCass3] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[StatusCass3] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[NumCass4] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CountCass4] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[KolCass4] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[StatusCass4] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Creator] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Created] [datetime] NULL ,
	[Changer] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Changed] [datetime] NULL 
) ON [PRIMARY]
GO

