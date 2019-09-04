if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LogTraceInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LogTraceInfo]
GO

CREATE TABLE [dbo].[LogTraceInfo] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[ATM] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FUIB] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Date] [datetime] NULL ,
	[Time] [datetime] NULL ,
	[DateTime] [datetime] NULL ,
	[FileName] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CmdText] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CmdInfo] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Creator] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Created] [datetime] NULL ,
	[Changer] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Changed] [datetime] NULL 
) ON [PRIMARY]
GO

