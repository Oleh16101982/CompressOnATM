if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_LogTraceCmdDispense_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_LogTraceCmdDispense_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE dbo.P_LogTraceCmdDispense_I
	@ATM 		varchar (10) ,	
	@FUIB 		varchar (10), 	
	@Date 		datetime, 	
	@Time 		datetime ,	
	@DateTime 	datetime ,	
	@FileName 	varchar (150) ,
	@NumCass1 	varchar (10)  ,
	@CountCass1 	varchar (10)  ,
	@KolCass1 	varchar (10)  ,
	@StatusCass1 	varchar (10)  ,
	@NumCass2 	varchar (10)  ,
	@CountCass2 	varchar (10)  ,
	@KolCass2 	varchar (10)  ,
	@StatusCass2 	varchar (10)  ,
	@NumCass3 	varchar (10)  ,
	@CountCass3 	varchar (10)  ,
	@KolCass3 	varchar (10)  ,
	@StatusCass3 	varchar (10)  ,
	@NumCass4 	varchar (10)  ,
	@CountCass4 	varchar (10)  ,
	@KolCass4 	varchar (10)  ,
	@StatusCass4 	varchar (10)  ,
	@err		int	OUTPUT, 
	@Mess 		varchar(100) OUTPUT 

 AS
    insert
	LogTraceCmdDispense(
	[ATM] 		,
	[FUIB] 		,
	[Date] 		,
	[Time] 		,
	[DateTime] 	,
	[FileName] 	,
	[NumCass1] 	,
	[CountCass1] 	,
	[KolCass1] 	,
	[StatusCass1] 	,
	[NumCass2] 	,
	[CountCass2] 	,
	[KolCass2] 	,
	[StatusCass2] 	,
	[NumCass3] 	,
	[CountCass3] 	,
	[KolCass3] 	,
	[StatusCass3] 	,
	[NumCass4] 	,
	[CountCass4] 	,
	[KolCass4] 	,
	[StatusCass4] 	
		)      
	VALUES
	(
	@ATM 		,
	@FUIB 		,
	@Date 		,
	@Time 		,
	@DateTime 	,
	@FileName 	,
	@NumCass1 	,
	@CountCass1 	,
	@KolCass1 	,
	@StatusCass1 	,
	@NumCass2 	,
	@CountCass2 	,
	@KolCass2 	,
	@StatusCass2 	,
	@NumCass3 	,
	@CountCass3 	,
	@KolCass3 	,
	@StatusCass3 	,
	@NumCass4 	,
	@CountCass4 	,
	@KolCass4 	,
	@StatusCass4 	
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

