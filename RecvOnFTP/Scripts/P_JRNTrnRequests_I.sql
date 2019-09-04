if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_JRNTrnRequests_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_JRNTrnRequests_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE dbo.P_JRNTrnRequests_I
	@IdTrns		int	,
	@ATM 		varchar (10) 	,
	@FUIB 		varchar (10) 	,
	@Date	 	datetime       ,
	@dtAmount	datetime ,
	@Amount		varchar (15) ,
	@dtRequest 	datetime 	,
	@Request 	varchar (150) 	,
	@dtReply 	datetime 	,
	@ReplyNext 	varchar (50) 	,
	@ReplyFunction 	varchar (50) 	,
	@dtCashDisp	datetime ,
	@CashDisp	varchar (16) ,
	@dtCashPres	datetime ,
	@dtCashTaken	datetime ,
	@CashA		varchar (2) ,
	@CashB		varchar (2) ,
	@CashC		varchar (2) ,
	@CashD		varchar (2) ,
	@CashE		varchar (2) ,
	@CashF		varchar (2) ,
	@CashG		varchar (2) ,
	@CashH		varchar (2) ,
	@Error		varchar (150)	,
	@ErrorCode	varchar (50)	,
	@err		int	OUTPUT, 
	@Mess 		varchar(100) OUTPUT 

 AS
declare @id int
declare @rowcount int
    insert
	JRNTrnRequests(
	IdTrns		,
	ATM 		,
	FUIB 		,
	[Date]	 	,
	dtAmount	,
	Amount		,
	dtRequest 	,
	Request 	,
	dtReply 	,
	ReplyNext 	,
	ReplyFunction 	,
	dtCashDisp	,
	CashDisp	,
	dtCashPres	,
	dtCashTaken	,
	CashA		,
	CashB		,
	CashC		,
	CashD		,
	CashE		,
	CashF		,
	CashG		,
	CashH		,
	Error		,
	ErrorCode	
		)      
	VALUES
	(
	@IdTrns		,
	@ATM 		,
	@FUIB 		,
	@Date	 	,
	@dtAmount	,
	@Amount		,
	@dtRequest 	,
	@Request 	,
	@dtReply 	,
	@ReplyNext 	,
	@ReplyFunction 	,
	@dtCashDisp	,
	@CashDisp	,
	@dtCashPres	,
	@dtCashTaken	,
	@CashA		,
	@CashB		,
	@CashC		,
	@CashD		,
	@CashE		,
	@CashF		,
	@CashG		,
	@CashH		,
	@Error		,
	@ErrorCode	
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

