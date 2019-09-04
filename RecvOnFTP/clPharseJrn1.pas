unit clPharseJrn1;

interface
uses
	Classes
   , WIndows
   , SysUtils
   , Registry
   , ADODB, DB , activeX , comobj
   , clLogAcceptor1
   ;

const
	ROOTKEY = HKEY_LOCAL_MACHINE;
   WORKKEY = '\Software\FTPLogATM';
   MAXROWTRNS = 150;
type
	TrecTransactions = record
   	State 	: Integer;
      MaxRow	: Integer;
      CntRow 	: Integer;
      Date		: TDateTime;
      DateTime	: TDateTime;
      TimeCard	: TDateTime;
      TimeTaken: TDateTime;
      TimeEnd	: TDateTime;
      TypePS	: Integer;
      Card		: String;
   	Success	: byte;
   end;

type
	TPharseJrn = class
   	private
      	fLog 				: TLogAcceptor;
         fReg 				: TRegistry;
         fFilName 		: String;
         fFilNameOrg		: String;
         fSuccessParse 	: boolean;
         fF					: TextFile;
         fATM 				: String;
         fFUIB 			: String;
         fTmpStr 			: String;
         frecTrns 		: TrecTransactions;

         fSQLServer 		: String;
    		fSQLDB			: String;
    		fSQLUser			: String;
    		fSQLPsw 			: String;
    		fConn 			: TADOConnection;
    		fProc1			: TADOStoredProc; // status cassetes


         procedure fStateTrnsIPS;
         procedure fStateTrnsDUET;
         procedure fClearRecTrns;

         function fBegTrnDuet		: boolean;
         function fEndUnExp 		: boolean;
         function fEndTrns 		: boolean;
         function fEndFile 		: boolean;
         function fEndNextTrns 	: boolean;

         function fInsSQLTrns : boolean;
         function fRecTrnsReg : boolean;
      public
      	Constructor Create(isLog : boolean ; Name : String);
         Destructor Destroy;
         procedure Start(FileName : String);

         property ATM : String read fATM write fATM;
         property FUIB : String read fFUIB write fFUIB;
			property SQLServer 		: String read fSQLServer 	write  fSQLServer 		 ;
	    	property SQLDB				: String read fSQLDB	 		write  fSQLDB	 			 ;
   	 	property SQLUser			: String read fSQLUser	 	write  fSQLUser	 		 ;
    		property SQLPsw 			: String read fSQLPsw 	 	write  fSQLPsw 	 		 ;

   end;


implementation

{ TPharseJrn }

constructor TPharseJrn.Create(isLog: boolean; Name: String);
begin
   if isLog then fLog := TLogAcceptor.Create(Name + '_PhJrn');
   fReg := TRegistry.Create;
   fReg.RootKey := ROOTKEY;
   fReg.OpenKey(WORKKEY , true);
   if Assigned(fLog) then fLog.Write('Class created');
	fConn := TADOConnection.Create(nil);
   fConn.CommandTimeout := 10000;
   fConn.LoginPrompt := false;
   fConn.KeepConnection := true;
   fConn.ConnectionTimeout := 5000;
	fProc1 := TADOStoredProc.Create(nil);
   fProc1.Connection := fConn;
end;

destructor TPharseJrn.Destroy;
begin
	if Assigned(fReg) then FreeAndNil(fReg);
   if Assigned(fLog) then FreeAndNil(fLog);
  	if Assigned(fProc1) then FreeAndNil(fProc1);
	if Assigned(fConn) then FreeAndNil(fConn);
end;


procedure TPharseJrn.Start(FileName: String);
var
	IsReadyFile : boolean;
begin
	fConn.ConnectionString := 'Provider=SQLOLEDB.1;data source=' + fSQLServer + ';Persist Security Info=false;initial catalog=' + fSQLDB + ';user id=' + fSQLUser + ';password=' + fSQLPsw;
	if not FileExists(FileName) then
   	begin
      	if Assigned(fLog) then fLog.Write('File - ' + FileName + ' does not exists');
         exit;
      end;
   fFilName := FileName;
   fFilNameOrg := Copy(ExtractFileName(fFilName) , 1 , Pos('__' , ExtractFileName(fFilName)) - 1) + ExtractFileExt(fFilName);
   if Assigned(fLog) then fLog.Write('Start parsing. ' + fFilName + '. Org - ' + fFilNameOrg);
	fSuccessParse := false;
	IsReadyFile := true;
   try
   	if not fConn.Connected  then
	   	fConn.Connected := true;
   except
   	on E : Exception do
      	begin
         	fLog.Write('Error connect. ' + E.Message + '. ' + E.ClassName);
//            Result := false;
            exit;
         end;
      end;
   if not fConn.Connected  then
   	begin
//      	Result := false;
         exit;
      end;

	try
		AssignFile(fF , fFilName);
	except
		on E : Exception do
   		begin
				if Assigned(fLog) then fLog.Write('Exception assigned file. ' + fFilName + '. Msg - ' + E.Message + '. ' + E.ClassName );
	      	IsReadyFile := false;
   	   end;
	end;
	try
		Reset(fF);
	except
		on E : Exception do
   		begin
				if Assigned(fLog) then fLog.Write('Exception Reset file. ' + fFilName + '. Msg - ' + E.Message + '. ' + E.ClassName );
	      	IsReadyFile := false;
   	   end;
	end;
   fClearRecTrns;
if Assigned(fLog) then fLog.Write('before while not EOF');

   while not Eof(fF) do
		begin
			Readln(fF , fTmpStr);
// if Assigned(fLog) then fLog.Write('read - ' + ftmpStr);         
         fStateTrnsIPS;
//         fStateTrnsDUET;

      end;
   CloseFile(fF);
if Assigned(fLog) then fLog.Write('After while not EOF');   
   if fConn.Connected then
   	fConn.Connected := false;
	fSuccessParse := true;
end;

procedure TPharseJrn.fStateTrnsDUET;
var
	promStr : String;
   ind : Integer;
begin
if fBegTrnDuet then
	begin
   	frecTrns.State := 1;
      frecTrns.TypePS := 1;
      frecTrns.Date := StrToDate(Copy(ftmpStr , 1 , 8));
   end;
if frecTrns.State = 0 then exit;
Inc(frecTrns.CntRow);
end;

procedure TPharseJrn.fStateTrnsIPS;
var
	promStr : String;
   ind : Integer;
begin
if Assigned(fLog) then fLog.Write('State - ' + IntToStr(frecTrns.State) + '. ' + ftmpStr);
if Pos('-> Õ¿◊¿ÀŒ “–¿Õ«¿ ÷»»' , fTmpStr) <> 0 then
	begin
   	frecTrns.State := 1;
      frecTrns.TypePS := 1;
      fRecTrns.Date := StrToDateTime(Copy(ftmpStr , 1 , 10));
      fRecTrns.DateTime := StrToDateTime(Copy(ftmpStr , 1 , 19));
      exit;
   end;
if frecTrns.State = 0 then exit;
Inc(frecTrns.CntRow);
if fEndTrns then
   begin
      frecTrns.TimeEnd := frecTrns.Date + StrToDateTime(Copy(ftmpStr , 1 , 8));
      frecTrns.Success := 1;
      if Assigned(fLog) then fLog.Write('Success End of transaction. ' + ftmpStr);
      if fInsSQLTrns then
	      fClearRecTrns
      else
      	begin
         	if Assigned(fLog) then fLog.Write('error insert into Databasde. ' + fFilName + '. ' + DateTimeToStr(frecTrns.DateTime));
         end;
      exit;
   end;
if fEndUnExp then
   begin
      frecTrns.TimeEnd := frecTrns.Date + StrToDateTime(Copy(ftmpStr , 1 , 8));
      if Assigned(fLog) then fLog.Write('Unexpected End of transaction not success. ' + ftmpStr);
      if fInsSQLTrns then
	      fClearRecTrns
      else
      	begin
         	if Assigned(fLog) then fLog.Write('error insert into Databasde. ' + fFilName + '. ' + DateTimeToStr(frecTrns.DateTime));
         end;
      exit;
   end;
if fEndNextTrns then
   begin
      frecTrns.TimeEnd := frecTrns.Date + StrToDateTime(Copy(ftmpStr , 1 , 8));
      if Assigned(fLog) then fLog.Write('Next Transaction begin End of transaction not success. ' + ftmpStr);
      if fInsSQLTrns then
	      fClearRecTrns
      else
      	begin
         	if Assigned(fLog) then fLog.Write('error insert into Databasde. ' + fFilName + '. ' + DateTimeToStr(frecTrns.DateTime));
         end;
      exit;
   end;
if fEndFile then
   begin
      frecTrns.TimeEnd := frecTrns.Date + StrToDateTime(Copy(ftmpStr , 1 , 8));
      if Assigned(fLog) then fLog.Write('End of File End of transaction not success. ' + ftmpStr);
      if fRecTrnsReg then
	      fClearRecTrns
      else
      	begin
         	if Assigned(fLog) then fLog.Write('error insert into Databasde. ' + fFilName + '. ' + DateTimeToStr(frecTrns.DateTime));
         end;
      exit;
   end;
if frecTrns.State = 1 then
	begin
   	if Pos('Track 2 data' , ftmpStr) <> 0 then
         begin
	      	frecTrns.Card := Copy(ftmpStr , 24);
if Assigned(fLog) then fLog.Write('PAN card - ' + frecTrns.Card );
            frecTrns.TimeCard := frecTrns.Date + StrToDateTime(Copy(ftmpStr , 1 , 8));
         end;
      frecTrns.State := 2;
      exit;
   end;
if frecTrns.State = 2 then
	begin
   	if ((Pos('Card' , ftmpStr) <> 0) and (Pos('taken' , ftmpStr) <> 0)) then
         begin
            frecTrns.TimeTaken := frecTrns.Date + StrToDateTime(Copy(ftmpStr , 1 , 8));
         end;
      frecTrns.State := 3;
      exit;
   end;
end;

function TPharseJrn.fBegTrnDuet: boolean;
var
   tmpBool : boolean;
   tmpDate : TDateTime;
   dtFmt : TFormatSettings;
begin
	Result := false;
	dtFmt.ShortDateFormat := 'dd.mm.yyyy';
   tmpBool := TryStrToDate(Copy(ftmpStr , 1 , 8) , tmpDate , dtFmt);
   if ((tmpBool) and (Copy(ftmpStr , 12 , 20) = '********************')) then
      Result := true;
end;

procedure TPharseJrn.fClearRecTrns;
begin
	frecTrns.State := 0;
   frecTrns.CntRow := 0;
   frecTrns.TypePS := 0;
   frecTrns.Card := '';
   frecTrns.Date := 0;
   frecTrns.DateTime := 0;
   frecTrns.TimeCard := 0;
   frecTrns.TimeTaken := 0;
   frecTrns.TimeEnd := 0;
   frecTrns.MaxRow := MAXROWTRNS;
   frecTrns.Success := 0;
end;

function TPharseJrn.fEndFile: boolean;
begin
	Result := false;
   if EOF(fF) then
   	begin
			Result := true;
      end;
end;

function TPharseJrn.fEndNextTrns: boolean;
begin
	Result := false;
   if frecTrns.State <> 1 then
   	begin
		   if Pos('-> Õ¿◊¿ÀŒ “–¿Õ«¿ ÷»»' , fTmpStr) <> 0 then
   			begin
					Result := true;
	      	end;
	   	if fBegTrnDuet then
   			begin
					Result := true;
	      	end;
      end;
end;

function TPharseJrn.fEndTrns: boolean;
begin
	Result := false;
   if Pos('<-  ŒÕ≈÷ “–¿Õ«¿ ÷»»' , fTmpStr) <> 0 then
   	begin
			Result := true;
      end;
end;

function TPharseJrn.fEndUnExp: boolean;
begin
	Result := false;
   if Pos('œ–»ÀŒ∆≈Õ»≈ «¿œ”Ÿ≈ÕŒ' , fTmpStr) <> 0 then
   	begin
			Result := true;
      end;
end;

function TPharseJrn.fInsSQLTrns: boolean;
var
	retVal : Integer;
begin
   if not fConn.Connected then
   	begin
         Result := false;
         exit;
      end;
   fProc1.Close;
   fProc1.Parameters.Clear;
   fProc1.ProcedureName := 'P_JRNTransactions_I';
	fProc1.Parameters.CreateParameter('@RETURN_VALUE', ftInteger	, pdReturnValue	, 4 	, 0);

	fProc1.Parameters.CreateParameter('@ATM' 			,	ftString 	, pdInput 	, 50	, fATM 					);
	fProc1.Parameters.CreateParameter('@FUIB' 		,	ftString		, pdInput   , 50  , fFUIB              );
	fProc1.Parameters.CreateParameter('@FileName'	,	ftString		, pdInput   , 150 , fFilName   			);
	fProc1.Parameters.CreateParameter('@FileNameOrg',	ftString		, pdInput   , 150 , fFilNameOrg			);
	fProc1.Parameters.CreateParameter('@Date'	 		,	ftDateTime	, pdInput   , 8   , frecTrns.Date      );
	fProc1.Parameters.CreateParameter('@DateTime' 	,	ftDateTime	, pdInput   , 8   , frecTrns.DateTime  );
	fProc1.Parameters.CreateParameter('@TypePS' 		,	ftInteger	, pdInput   , 10  , frecTrns.TypePS    );
	fProc1.Parameters.CreateParameter('@Card'	 		,	ftString		, pdInput   , 20  , frecTrns.Card      );
	fProc1.Parameters.CreateParameter('@DateCard'	,	ftDateTime	, pdInput   , 8   , frecTrns.TimeCard  );
	fProc1.Parameters.CreateParameter('@DateTaken'	,	ftDateTime	, pdInput   , 8   , frecTrns.TimeTaken );
	fProc1.Parameters.CreateParameter('@DateEnd'		,	ftDateTime	, pdInput   , 8   , frecTrns.TimeEnd   );
	fProc1.Parameters.CreateParameter('@Success'		,	ftInteger	, pdInput   , 4   , frecTrns.Success   );
	fProc1.Parameters.CreateParameter('@err'			,	ftInteger	, pdOutput	, 4   , 0);
	fProc1.Parameters.CreateParameter('@Mess' 		,	ftString		, pdOutput  , 100 , 0);
   try
   	fProc1.ExecProc ;
      retVAl := fProc1.Parameters.ParamValues['@RETURN_VALUE'];
if Assigned(fLog) then fLog.Write('retVal - ' + IntToStr(retVal));
     
   except
   	on E : EOleException do
      	begin
         	if Assigned(fLog) then fLog.Write('EOleException exec proc.  ' + fProc1.ProcedureName + '. Code - ' + IntToStr(E.ErrorCode) + '. MSG - '  + E.Message + '. ' + E.ClassName ) ;
         end;
	   on E : Exception do
   		begin
         	if Assigned(fLog) then fLog.Write('Exception exec proc1 in insert Trace Cmd Dispense. ' + E.Message + '. ' + E.ClassName ) ;
         end;
   end;

end;

function TPharseJrn.fRecTrnsReg: boolean;
begin

end;

end.
