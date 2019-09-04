-- if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FTPUnzipLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
-- drop table [dbo].[FTPUnzipLog]
-- GO

CREATE TABLE [dbo].[LogTraceDispenser] (
	[id] 		[int] IDENTITY (1, 1) NOT NULL ,
	[ATM] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FUIB] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Date] 		[datetime] NULL ,
	[Time] 		[datetime] NULL ,
	[DateTime] 	[datetime] NULL ,
	[FileName] 	[varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Len] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[S_SW] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[DLOC] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CAS] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SHERR] 	[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SHUT] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[MON] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TER] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TS] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TF] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SR] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[DIS] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CEX] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[DOOR] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[DO_S] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TYPE] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[N_VM] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SEDM] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[LCMD] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[LSTA] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SCLE] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SRES] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[TST] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SCOD] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[OR] 		[varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Creator] 	[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Created] 	[datetime] NULL ,
	[Changer] 	[varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Changed] 	[datetime] NULL 
) ON [PRIMARY]
GO



