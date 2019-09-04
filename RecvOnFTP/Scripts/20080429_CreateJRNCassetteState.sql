if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JRNCassetteState]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[JRNCassetteState]
GO

CREATE TABLE [dbo].[JRNCassetteState] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[ATM] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FUIB] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FileName] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FileNameOrg] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[date] [datetime] NULL ,
	[datetime] 	[datetime] NULL ,
	[TypePS] 	[tinyint] NULL  ,
	[CassRejAll] 	[varchar] (3) NULL ,
	[CassRejCurr] 	[varchar] (3) NULL ,
	[Cass1Nominal] 	[varchar] (6) NULL ,
	[Cass1Curr] 	[varchar] (3) NULL ,
	[Cass1Fill] 	[varchar] (6) NULL ,
	[Cass1RejCurr] 	[varchar] (6) NULL ,
	[Cass1RejAll] 	[varchar] (6) NULL ,
	[Cass1Sign] 	[varchar] (3) NULL ,
	[Cass2Nominal] 	[varchar] (6) NULL ,
	[Cass2Curr] 	[varchar] (3) NULL ,
	[Cass2Fill] 	[varchar] (6) NULL ,
	[Cass2RejCurr] 	[varchar] (6) NULL ,
	[Cass2RejAll] 	[varchar] (6) NULL ,
	[Cass2Sign] 	[varchar] (3) NULL ,
	[Cass3Nominal] 	[varchar] (6) NULL ,
	[Cass3Curr] 	[varchar] (3) NULL ,
	[Cass3Fill] 	[varchar] (6) NULL ,
	[Cass3RejCurr] 	[varchar] (6) NULL ,
	[Cass3RejAll] 	[varchar] (6) NULL ,
	[Cass3Sign] 	[varchar] (3) NULL ,
	[Cass4Nominal] 	[varchar] (6) NULL ,
	[Cass4Curr] 	[varchar] (3) NULL ,
	[Cass4Fill] 	[varchar] (6) NULL ,
	[Cass4RejCurr] 	[varchar] (6) NULL ,
	[Cass4RejAll] 	[varchar] (6) NULL ,
	[Cass4Sign] 	[varchar] (3) NULL ,
	[Creator] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Created] [datetime] NOT NULL ,
	[Changer] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Changed] [datetime] NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[JRNCassetteState] ADD 
	CONSTRAINT [DF_JRNCassetteState_Creator] DEFAULT (suser_sname()) FOR [Creator],
	CONSTRAINT [DF_JRNCassetteState_Created] DEFAULT (getdate()) FOR [Created],
	CONSTRAINT [DF_JRNCassetteState_Changer] DEFAULT (suser_sname()) FOR [Changer],
	CONSTRAINT [DF_JRNCassetteState_Changed] DEFAULT (getdate()) FOR [Changed],
	CONSTRAINT [PK_JRNCassetteState] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

