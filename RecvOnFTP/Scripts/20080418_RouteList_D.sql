if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_RouteList_D]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_RouteList_D]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE P_RouteList_D
	@RouteListId 		int	,
	@err			int	OUTPUT,
       	@Mess 			varchar(100) OUTPUT

 AS
	
	if exists(select 1 from RouteLists	where	id=@RouteListId and state>1)  begin
		select @Mess='Состояние маршрутного листа не позволяет его удаление!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end

/*	if exists(select 1 from RouteLists	where	(@count1Out>count1In) or (@count2Out>count2In) or (@count3Out>count3In) or (@count4Out>count4In))  begin
		select @Mess='Невозможно выгрузить больше чем загрузить!',@err=1
		RaisError(@Mess,16,1)
		return 1
	end*/


    update
	Routelists
    set
	state	=5
	
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

