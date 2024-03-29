if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_RouteList_U]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_RouteList_U]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE P_RouteList_U
	@RouteListId 		int	, 	--Номер маршрутного листа
	@count1Out 		int =NULL,	--Кол-во выгруженных купюр в первой кассете
	@count2Out 		int =NULL,	--Кол-во выгруженных купюр во второй кассете
	@count3Out 		int =NULL,	--Кол-во выгруженных купюр в третей кассете
	@count4Out 		int =NULL,	--Кол-во выгруженных купюр в четвертой кассете
	@count5Out 		int =NULL,	--Кол-во выгруженных купюр диверт-кассете
	@nominal1Out 		int =NULL,	--Кол-во выгруженных купюр в первой кассете
	@nominal2Out 		int =NULL,	--Кол-во выгруженных купюр во второй кассете
	@nominal3Out 		int =NULL,	--Кол-во выгруженных купюр в третей кассете
	@nominal4Out 		int =NULL,	--Кол-во выгруженных купюр в четвертой кассете
	@IncassatorOut 	varchar(100) =NULL, 	--Инкассатор
	@IncassatorOutId 	varchar(100) =NULL, 	--Инкассатор
	@datetime1		datetime=NULL,
	@datetime2		datetime=NULL,
	@err			int	OUTPUT,
       	@Mess 			varchar(100) OUTPUT

 AS
	declare
		@CashierOutId int,
		@dateOut	datetime,
		@cassete1out	varchar(5),
		@cassete2out	varchar(5),
		@cassete3out	varchar(5),
		@cassete4out	varchar(5)
	

	select  @dateOut=getdate()

	select  @cashierOutId=id from Cashiers where LoginName=suser_sname() and enabled=1

	if @cashierOutId is null begin
		select @Mess='Кассир '+suser_sname()+' не найден!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end

	if exists(select 1 from RouteLists	where	id=@RouteListId and state>1)  begin
		select @Mess='Состояние маршрутного листа не позволяет его редактирование!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end

/*	if exists(select 1 from RouteLists	where	(@count1Out>count1In) or (@count2Out>count2In) or (@count3Out>count3In) or (@count4Out>count4In))  begin
		select @Mess='Невозможно выгрузить больше чем загрузить!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end*/

   select
		@cassete1out=cassete1Out,
		@cassete1out=cassete1Out,
		@cassete1out=cassete1Out,
		@cassete1out=cassete1Out
    from 
	RouteLists
   where
 	id=@RouteListId

    if ((@cassete1out = '-') or (@cassete1Out is null)) select nominal1Out=0,count1Out=0
    if ((@cassete2out = '-') or (@cassete2Out is null)) select nominal2Out=0,count2Out=0
    if ((@cassete3out = '-') or (@cassete3Out is null)) select nominal3Out=0,count3Out=0
    if ((@cassete4out = '-') or (@cassete4Out is null)) select nominal4Out=0,count4Out=0



    update
	Routelists
    set
	count1Out=@count1Out,
	count2Out=@count2Out,
	count3Out=@count3Out,
	count4Out=@count4Out,
	count5Out=@count5Out,
	IncassatorOut  =	@IncassatorOut,
	IncassatorOutId  =	@IncassatorOutId,
	nominal1Out	=@nominal1Out,
	nominal2Out	=@nominal2Out,
	nominal3Out	=@nominal3Out,
	nominal4Out	=@nominal4Out,
	datetime1	=@datetime1,
	datetime2	=@datetime2,
	dateOut		=@dateOut,
	CashierOutId  =@CashierOutId,  
	state	=1
	
    where
	id=@RouteListId	

	


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

