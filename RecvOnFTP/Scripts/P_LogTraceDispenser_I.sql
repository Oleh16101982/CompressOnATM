if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_LogTraceDispenser_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_LogTraceDispenser_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE dbo.P_LogTraceDispenser_I
	@ATM 		varchar (10),
	@FUIB 		varchar (10),
	@Date 		datetime,
	@Time 		datetime,
	@DateTime 	datetime,
	@FileName 	varchar (150),
	@Len 		varchar (10) ,
	@S_SW 		varchar (10) ,
	@DLOC 		varchar (10) ,
	@CAS 		varchar (10) ,
	@SHERR 		varchar (10) ,
	@SHUT 		varchar (10) ,
	@MON 		varchar (10) ,
	@TER 		varchar (10) ,
	@TS 		varchar (10) ,
	@TF 		varchar (10) ,
	@SR 		varchar (10) ,
	@DIS 		varchar (10) ,
	@CEX 		varchar (10) ,
	@DOOR 		varchar (10) ,
	@DO_S 		varchar (10) ,
	@TYPE 		varchar (10) ,
	@N_VM 		varchar (10) ,
	@SEDM 		varchar (10) ,
	@LCMD 		varchar (10) ,
	@LSTA 		varchar (10) ,
	@SCLE 		varchar (10) ,
	@SRES 		varchar (10) ,
	@TST 		varchar (10) ,
	@SCOD 		varchar (10) ,
	@OR 		varchar (10) ,
	@err		int	OUTPUT, 
	@Mess 		varchar(100) OUTPUT 

 AS
    insert
	LogTraceDispenser(
	ATM 		,
	FUIB 		,
	[Date] 		,
	[Time] 		,
	[DateTime] 	,
	[FileName] 	,
	[Len] 		,
	S_SW 		,
	DLOC 		,
	CAS 		,
	SHERR 		,
	SHUT 		,
	MON 		,
	TER 		,
	TS 		,
	TF 		,
	SR 		,
	DIS 		,
	CEX 		,
	DOOR 		,
	DO_S 		,
	TYPE 		,
	N_VM 		,
	SEDM 		,
	LCMD 		,
	LSTA 		,
	SCLE 		,
	SRES 		,
	TST 		,
	SCOD 		,
	[OR] 		
		)
	VALUES
	(
	@ATM 		,
	@FUIB 		,
	@Date 		,
	@Time 		,
	@DateTime 	,
	@FileName 	,
	@Len 		,
	@S_SW 		,
	@DLOC 		,
	@CAS 		,
	@SHERR 		,
	@SHUT 		,
	@MON 		,
	@TER 		,
	@TS 		,
	@TF 		,
	@SR 		,
	@DIS 		,
	@CEX 		,
	@DOOR 		,
	@DO_S 		,
	@TYPE 		,
	@N_VM 		,
	@SEDM 		,
	@LCMD 		,
	@LSTA 		,
	@SCLE 		,
	@SRES 		,
	@TST 		,
	@SCOD 		,
	@OR 		
	)               
	                


	if @@rowcount<>1 begin
		select @Mess='Не могу добавить в БД' ,@err=1
		RaisError(@Mess,16,1)
		return 1
	end		
	select @Mess='Успешно!!!'
	select @err=0
	return 0
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

