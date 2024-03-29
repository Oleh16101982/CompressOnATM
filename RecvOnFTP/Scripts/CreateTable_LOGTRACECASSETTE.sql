if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LogTraceCassette]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LogTraceCassette]
GO

CREATE TABLE [dbo].[LogTraceCassette] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[ATM] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FUIB] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Date] [datetime] NULL ,
	[Time] [datetime] NULL ,
	[DateTime] [datetime] NULL ,
	[FileName] [varchar] (150) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Len] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[RSTA] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[RACT] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[RRET] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1STA] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1NUM] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1CUR] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1REL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1VAL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1LEN] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1TOL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1ACT] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1LOW] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1L_D] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[1REJ] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2STA] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2NUM] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2CUR] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2REL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2VAL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2LEN] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2TOL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2ACT] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2LOW] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2L_D] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[2REJ] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3STA] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3NUM] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3CUR] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3REL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3VAL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3LEN] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3TOL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3ACT] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3LOW] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3L_D] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[3REJ] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4STA] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4NUM] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4CUR] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4REL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4VAL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4LEN] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4TOL] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4ACT] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4LOW] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4L_D] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[4REJ] [varchar] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Creator] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Created] [datetime] NULL ,
	[Changer] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Changed] [datetime] NULL 
) ON [PRIMARY]
GO

