if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[P_FTPUnZIPLog_I]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[P_FTPUnZIPLog_I]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO


CREATE PROCEDURE dbo.P_FTPUnZIPLog_I
	@ATM 		varchar (10),
	@FUIB		varchar(10),
	@ZipName 		varchar(150),
	@ZipSize 		int,
	@FromDate		datetime,
	@ToDate 		datetime,
	@FileName 	varchar(150) ,
	@FileExt 	varchar(10) ,
	@FileSize 	int,
	@FileDate 	datetime,
	@isSuccess 	tinyint,
	@err		int	OUTPUT, 
     @Mess 		varchar(100) OUTPUT 

 AS
    insert
	FTPUnZIPLog(
	ATM 		,
	FUIB		,
	ZipName 	,
	ZipSize 	,
	FromDate	,
	ToDate 		,
	FileName 	,
	FileExt 	,
	FileSize 	,
	FileDate 	,
	isSuccess 	
		)
	VALUES
	(
	@ATM 		,
	@FUIB		,
	@ZipName 	,
	@ZipSize 	,
	@FromDate	,
	@ToDate 	,
	@FileName 	,
	@FileExt 	,
	@FileSize 	,
	@FileDate 	,
	@isSuccess 	
	)
	


	if @@rowcount<>1 begin
		select @Mess='=õ üþóº ôþñðòøª¹ ò +-' ,@err=1
		RaisError(@Mess,16,1)
		return 1
	end		
	select @Mess='L¸ÿõ°ýþ!!!'
	select @err=0
	return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

