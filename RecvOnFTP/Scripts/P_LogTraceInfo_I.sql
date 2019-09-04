if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_JRNTransactions_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_JRNTransactions_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE dbo.P_JRNTransactions_I
	@ATM 		varchar (10) 	,
	@FUIB 		varchar (10) 	,
	@DateTime 	datetime       ,
	@TypePS 	tinyint  ,
	@Card	 	varchar (20)  ,
	@Taken	 	tinyint ,
	@EndTrn 	tinyint  ,
	@err		int	OUTPUT, 
	@Mess 		varchar(100) OUTPUT 

 AS
declare @id int
declare @rowcount int
    insert
	JRNTransactions(
	ATM 		 ,
	FUIB 		 ,
	[DateTime]       ,
	TypePS 		,
	Card	 	,
	Taken	 	,
	EndTrn 	
		)      
	VALUES
	(
	@ATM 		,
	@FUIB 		,
	@DateTime       ,
	@TypePS
	@Card
	@Taken
	@EndTrn
	)               
	set @id = @@identity, @rowcount = @@rowcount
	if @@rowcount<>1 begin
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

