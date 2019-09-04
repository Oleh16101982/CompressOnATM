if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_JRNCassetteState_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_JRNCassetteState_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE dbo.P_JRNCassetteState_I
	@ATM 		varchar (10) 	,
	@FUIB 		varchar (10) 	,
	@FileName	varchar (15)	,
	@FileNameOrg	varchar(150)	,
	@Date	 	datetime       ,
	@DateTime 	datetime       ,
	@TypePS 	tinyint ,
	@CassRejAll 	varchar (3),
	@CassRejCurr 	varchar (3),
	@Cass1Nominal 	varchar (6),
	@Cass1Curr 	varchar (3),
	@Cass1Fill 	varchar (6),
	@Cass1RejCurr 	varchar (6),
	@Cass1RejAll 	varchar (6),
	@Cass1Sign 	varchar (3),
	@Cass2Nominal 	varchar (6),
	@Cass2Curr 	varchar (3),
	@Cass2Fill 	varchar (6),
	@Cass2RejCurr 	varchar (6),
	@Cass2RejAll 	varchar (6),
	@Cass2Sign 	varchar (3),
	@Cass3Nominal 	varchar (6),
	@Cass3Curr 	varchar (3),
	@Cass3Fill 	varchar (6),
	@Cass3RejCurr 	varchar (6),
	@Cass3RejAll 	varchar (6),
	@Cass3Sign 	varchar (3),
	@Cass4Nominal 	varchar (6),
	@Cass4Curr 	varchar (3),
	@Cass4Fill 	varchar (6),
	@Cass4RejCurr 	varchar (6),
	@Cass4RejAll 	varchar (6),
	@Cass4Sign 	varchar (3),
	@err		int	OUTPUT, 
	@Mess 		varchar(100) OUTPUT 

 AS
declare @id int
declare @rowcount int
    insert
	JRNCassetteState(
	ATM 		,
	FUIB 		,
	[FileName]	,
	FileNameOrg	,
	[Date]	 	,
	[DateTime] 	,
	TypePS 	,
	CassRejAll 	,
	CassRejCurr 	,
	Cass1Nominal 	,
	Cass1Curr 	,
	Cass1Fill 	,
	Cass1RejCurr 	,
	Cass1RejAll 	,
	Cass1Sign 	,
	Cass2Nominal 	,
	Cass2Curr 	,
	Cass2Fill 	,
	Cass2RejCurr 	,
	Cass2RejAll 	,
	Cass2Sign 	,
	Cass3Nominal 	,
	Cass3Curr 	,
	Cass3Fill 	,
	Cass3RejCurr 	,
	Cass3RejAll 	,
	Cass3Sign 	,
	Cass4Nominal 	,
	Cass4Curr 	,
	Cass4Fill 	,
	Cass4RejCurr 	,
	Cass4RejAll 	,
	Cass4Sign 	

		)      
	VALUES
	(
	@ATM 		,
	@FUIB 		,
	@FileName	,
	@FileNameOrg	,
	@Date		,
	@DateTime       ,
	@TypePS		,
	@CassRejAll 	,
	@CassRejCurr 	,
	@Cass1Nominal 	,
	@Cass1Curr 	,
	@Cass1Fill 	,
	@Cass1RejCurr 	,
	@Cass1RejAll 	,
	@Cass1Sign 	,
	@Cass2Nominal 	,
	@Cass2Curr 	,
	@Cass2Fill 	,
	@Cass2RejCurr 	,
	@Cass2RejAll 	,
	@Cass2Sign 	,
	@Cass3Nominal 	,
	@Cass3Curr 	,
	@Cass3Fill 	,
	@Cass3RejCurr 	,
	@Cass3RejAll 	,
	@Cass3Sign 	,
	@Cass4Nominal 	,
	@Cass4Curr 	,
	@Cass4Fill 	,
	@Cass4RejCurr 	,
	@Cass4RejAll 	,
	@Cass4Sign 	

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

