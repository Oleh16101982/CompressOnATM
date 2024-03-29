if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_RouteList_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_RouteList_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE P_RouteList_I
	@atmId 	int	,  	--номер банкомата
	@number 	varchar (50), 	--номер маршрутного листа
	@cassete1Out	varchar(5) =NULL,     	--номер 1-й кассеты
	@cassete2Out 	varchar(5) =NULL,	--номер 2-й кассеты
	@cassete3Out 	varchar(5)=NULL ,	--номер 3-й кассеты
	@cassete4Out 	varchar(5) =NULL,	--номер 4-й кассеты
	@cassete5Out 	varchar(5) =NULL,	--номер 5-й кассеты
	@cassete1 	varchar(5) =NULL,     	--номер 1-й кассеты
	@cassete2 	varchar(5) =NULL,	--номер 2-й кассеты
	@cassete3 	varchar(5)=NULL ,	--номер 3-й кассеты
	@cassete4 	varchar(5) =NULL,	--номер 4-й кассеты
	@cassete5 	varchar(5) =NULL,	--номер 5-й кассеты
	@nominal1 	int =NULL,	--номинал 1-й кассеты
	@nominal2 	int =NULL,	--номинал 2-й кассеты
	@nominal3 	int=NULL ,	--номинал 3-й кассеты
	@nominal4 	int =NULL,	--номинал 4-й кассеты
	@count1In 	int =NULL,	--Кол-во загруженных купюр в первую кассету
	@count2In 	int =NULL, 	--Кол-во загруженных купюр во вторую кассету
	@count3In 	int =NULL, 	--Кол-во загруженных купюр в третью кассету
	@count4In 	int =NULL, 	--Кол-во загруженных купюр в четвертую кассету
	@IncassatorInId 	int =NULL, 	--Инкассатор
	@IncassatorIn 	varchar(100) =NULL, 	--Инкассатор
	@err		int	OUTPUT, --признак ошибки
       	@Mess 		varchar(100) OUTPUT --тест ошибки

 AS
	
	declare
		@cashierInId	int,
		@datetime	datetime

	select  @datetime=getdate()

	select  @cashierInId=id from Cashiers where LoginName=suser_sname() and enabled=1

	if @cashierInId is null begin
		select @Mess='Кассир '+suser_sname()+' не найден!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end

	if exists(select 1 from RouteLists where number=@number and state<>5) begin
		select @Mess='Маршрутный лист в БД с номером '+@number+' уже существует!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end

/*	if (isnull(@nominal1,0)*isnull(@count1In,0)+
	   isnull(@nominal2,0)*isnull(@count2In,0)+
	   isnull(@nominal3,0)*isnull(@count3In,0)+
	   isnull(@nominal4,0)*isnull(@count4In,0) )=0 begin
		select @Mess='Нулевая загрузка не возможна!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end*/

    if ((@cassete1 = '-') or (@cassete1 is null)) select nominal1=0,count1in=0
    if ((@cassete2 = '-') or (@cassete2 is null)) select nomina2l=0,count2in=0
    if ((@cassete3 = '-') or (@cassete3 is null)) select nominal3=0,count3in=0
    if ((@cassete4 = '-') or (@cassete4 is null)) select nominal4=0,count4in=0

	

    insert
	Routelists(
		number,
		AtmId,
		cassete1Out,
		cassete2Out,
		cassete3Out,
		cassete4Out,
		cassete5Out,
		cassete1,
		cassete2,
		cassete3,
		cassete4,
		cassete5,
		nominal1,
		nominal2,
		nominal3,
		nominal4,
		count1In,
		count2In,
		count3In,
		count4In,
		IncassatorInId,
		IncassatorIn,
		datetime,
		CashierInId
		)values(
		@number	,
		@Atmid		,
		@cassete1Out	,
		@cassete2Out	,
		@cassete3Out	,
		@cassete4Out	,
		@cassete5Out	,
		@cassete1 	,
		@cassete2 	,
		@cassete3 	,
		@cassete4 	,
		@cassete5 	,
		@nominal1 	,
		@nominal2 	,
		@nominal3 	,
		@nominal4 	,
		@count1In 	,
		@count2In 	,
		@count3In 	,
		@count4In 	,
		@IncassatorInId ,
		@IncassatorIn ,
		@datetime,
		@CashierInId
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

