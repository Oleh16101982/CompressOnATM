if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JrnTrnDUET]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[JrnTrnDUET]
GO

CREATE TABLE [dbo].[JrnTrnDUET] (
	[id] 			[int] IDENTITY (1, 1) NOT NULL ,
	[IdTrns] 		[int] NULL ,
	[PAN] 			[varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtOperation] 		[datetime] NULL ,
	[Operation] 		[int] NULL ,
	[dtTrnBegin] 		[datetime] NULL ,
	[dtCollected] 		[datetime] NULL ,
	[Amount] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtTaken] 		[datetime] NULL ,
	[Taken] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Cass1] 		[varchar] (3) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Cass2] 		[varchar] (3) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Cass3] 		[varchar] (3) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Cass4] 		[varchar] (3) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtTrn] 		[datetime] NULL ,
	[TrnPan] 		[varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnBank] 		[varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnAccount] 		[varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnAmount] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnFee] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnTSN] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnRSN] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnSK] 		[varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TrnSM] 		[varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtCashTaken] 		[datetime] NULL ,
	[dtEndOperation] 	[datetime] NULL ,
	[OperationSymbol] 	[varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtError] 		[datetime] NULL ,
	[Error] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtErrorDUET] 		[datetime] NULL ,
	[ErrorDuet] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtErrorUEPS] 		[datetime] NULL ,
	[ErrorUEPS] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtReject] 		[datetime] NULL ,
	[dtRetract] 		[datetime] NULL ,
	[dtErrorCollect] 	[datetime] NULL ,
	[ErrorCollect] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[dtErrorTrn] 		[datetime] NULL ,
	[ErrorTrn] 		[char] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Creator] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Created] 		[datetime] NOT NULL ,
	[Changer] 		[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Changed] 		[datetime] NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[JrnTrnDUET] ADD 
	CONSTRAINT [DF_JrnTrnDUET_Creator] DEFAULT (suser_sname()) FOR [Creator],
	CONSTRAINT [DF_JrnTrnDUET_Created] DEFAULT (getdate()) FOR [Created],
	CONSTRAINT [DF_JrnTrnDUET_Changer] DEFAULT (suser_sname()) FOR [Changer],
	CONSTRAINT [DF_JrnTrnDUET_Changed] DEFAULT (getdate()) FOR [Changed]
GO

