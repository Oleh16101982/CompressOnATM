if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_JRNTrnDUET_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_JRNTrnDUET_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE dbo.P_JRNTrnDUET_I
	@IdTrns 		[int] 		,
	@ATM 			varchar (10) 	,
	@FUIB 			varchar (10) 	,
--	@PAN 			[varchar] (20) 	,
	@dtOperation 		[datetime] 	,
	@Operation 		[int] 	 	,
	@dtTrnBegin 		[datetime] 	,
	@dtCollected 		[datetime] 	,
	@Amount 		[varchar] (50) 	,
	@dtTaken 		[datetime] 	,
	@Taken 			[varchar] (50) 	,
	@Cass1 			[varchar] (3) 	,
	@Cass2 			[varchar] (3) 	,
	@Cass3 			[varchar] (3) 	,
	@Cass4 			[varchar] (3) 	,
	@dtTrn 			[datetime] 	,
	@TrnPan 		[varchar] (30) 	,
	@TrnBank 		[varchar] (20) 	,
	@TrnAccount 		[varchar] (20) 	,
	@TrnAmount 		[varchar] (50) 	,
	@TrnFee 		[varchar] (50) 	,
	@TrnTSN 		[varchar] (10) 	,
	@TrnRSN 		[varchar] (10) 	,
	@TrnSK 			[varchar] (20) 	,
	@TrnSM 			[varchar] (20) 	,
	@dtCashTaken 		[datetime] 	,
	@dtEndOperation 	[datetime] 	,
	@OperationSymbol 	[varchar] (20) 	,
	@dtError 		[datetime] 	,
	@Error 			[varchar] (50) 	,
	@dtErrorDUET 		[datetime] 	,
	@ErrorDuet 		[varchar] (50) 	,
	@dtErrorUEPS 		[datetime] 	,
	@ErrorUEPS 		[varchar] (50) 	,
	@dtReject 		[datetime] 	,
	@dtRetract 		[datetime] 	,
	@dtErrorCollect 	[datetime] 	,
	@ErrorCollect 		[varchar] (50) 	,
	@dtErrorTrn 		[datetime] ,	
	@ErrorTrn 		[varchar] (50) 	,
	@err		int	OUTPUT, 
	@Mess 		varchar(100) OUTPUT 

 AS
declare @id int
declare @rowcount int
    insert
	JRNTrnDUET(
	IdTrns 		,
	ATM 		,	
	FUIB 			,
--	PAN 			,
	dtOperation 		,
	Operation 		,
	dtTrnBegin 		,
	dtCollected 		,
	Amount 		,
	dtTaken 		,
	Taken 			,
	Cass1 			,
	Cass2 			,
	Cass3 			,
	Cass4 			,
	dtTrn 			,
	TrnPan 		,
	TrnBank 		,
	TrnAccount 		,
	TrnAmount 		,
	TrnFee 		,
	TrnTSN 		,
	TrnRSN 		,
	TrnSK 			,
	TrnSM 			,
	dtCashTaken 		,
	dtEndOperation 	,
	OperationSymbol 	,
	dtError 		,
	Error 			,
	dtErrorDUET 		,
	ErrorDuet 		,
	dtErrorUEPS 		,
	ErrorUEPS 		,
	dtReject 		,
	dtRetract 		,
	dtErrorCollect 	,
	ErrorCollect 		,
	dtErrorTrn 		,
	ErrorTrn 		
		)      
	VALUES
	(
	@IdTrns 		,
	@ATM 			,
	@FUIB 			,
--	@PAN 			,
	@dtOperation 		,
	@Operation 		,
	@dtTrnBegin 		,
	@dtCollected 		,
	@Amount 		,
	@dtTaken 		,
	@Taken 			,
	@Cass1 			,
	@Cass2 			,
	@Cass3 			,
	@Cass4 			,
	@dtTrn 			,
	@TrnPan 		,
	@TrnBank 		,
	@TrnAccount 		,
	@TrnAmount 		,
	@TrnFee 		,
	@TrnTSN 		,
	@TrnRSN 		,
	@TrnSK 			,
	@TrnSM 			,
	@dtCashTaken 		,
	@dtEndOperation 	,
	@OperationSymbol 	,
	@dtError 		,
	@Error 			,
	@dtErrorDUET 		,
	@ErrorDuet 		,
	@dtErrorUEPS 		,
	@ErrorUEPS 		,
	@dtReject 		,
	@dtRetract 		,
	@dtErrorCollect 	,
	@ErrorCollect 		,
	@dtErrorTrn 		,
	@ErrorTrn 		
	)               
	select @id = @@identity , @rowcount = @@rowcount
	if @rowcount<>1 begin
		select @Mess='Не могу добавить в БД' ,@err=1
		RaisError(@Mess,16,1)
		return 0
	end		
	select @Mess='Успешно!!!'
	select @err=0
	return @id
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

