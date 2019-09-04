if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JrnTrnRequests]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[JrnTrnRequests]
GO

CREATE TABLE [dbo].[JrnTrnRequests] (
	[id] 		[int] IDENTITY (1, 1) NOT NULL ,
	[IdTrns] 	[int] NULL ,
	[ATM] 		[varchar] 	(10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FUIB]		[varchar] 	(10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[date] 		[datetime]	 NULL ,
	[dtAmount]	[datetime] 	NULL ,
	[Amount]	[varchar] 	(15) NULL ,
	[dtRequest] 	[datetime]	NULL ,
	[Request] 	[varchar] 	(150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtReply] 	[datetime] 	NULL ,
	[ReplyNext] 	[varchar] 	(50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[ReplyFunction] [varchar] 	(50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtCashDisp]	[datetime] 	NULL ,
	[CashDisp]	[varchar] 	(16) ,
	[dtCashPres]	[datetime] 	,
	[dtCashTaken]	[datetime] 	,
	[CashA]		[varchar] 	(2) ,
	[CashB]		[varchar] 	(2) ,
	[CashC]		[varchar] 	(2) ,
	[CashD]		[varchar] 	(2) ,
	[CashE]		[varchar] 	(2) ,
	[CashF]		[varchar] 	(2) ,
	[CashG]		[varchar] 	(2) ,
	[CashH]		[varchar] 	(2) ,
	[Error] 	[varchar] 	(150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[ErrorCode] 	[varchar] 	(50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Creator] 	[varchar] 	(50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Created] 	[datetime] 	NOT NULL ,
	[Changer] 	[varchar] 	(50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Changed] 	[datetime] 	NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[JrnTrnRequests] ADD 
	CONSTRAINT [DF_JrnTrnRequests_Creator] DEFAULT (suser_sname()) FOR [Creator],
	CONSTRAINT [DF_JrnTrnRequests_Created] DEFAULT (getdate()) FOR [Created],
	CONSTRAINT [DF_JrnTrnRequests_Changer] DEFAULT (suser_sname()) FOR [Changer],
	CONSTRAINT [DF_JrnTrnRequests_Changed] DEFAULT (getdate()) FOR [Changed]
GO

