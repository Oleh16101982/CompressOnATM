unit clFTPATM1;

interface

uses
	Classes
   , Windows   
   , SysUtils
   , StrUtils
   , DateUtils
   , RxDateUtil
   , Registry
	, ADODB, DB
   , clLogAcceptor1
   , KAZip
   , ComObj
   ;
const
	Attr = faHidden + faSysFile + faArchive + faAnyFile;

	rootKey = HKEY_LOCAL_MACHINE;
   workKey = '\Software\FTPLogATM';
type
	TSQLInfo = record
      Indus : String;
      FUIB : String;
      ZIPName : String;
      ZipSize : Integer;
      FromDate : TDateTime;
      ToDate 	: TDateTime;
      FileName : String;
      FileExt	: String;
      FileSize : Integer;
      FileDate	: TDateTime;
      IsSuccess : Integer;
   end;

type
   TFTPATM = class
      private
         fConn : TADOConnection;
		   fProc1	: TADOStoredProc;
         fProc2	: TADOStoredProc;

	      fSQLServer 	: String;
   	   fSQLDB		: String;
      	fSQLUser		: String;
	      fSQLPsw 		: String;

      	fIndus	: String;
         fFUIB		: String;
         fLog : TLogAcceptor;
         fZip : TKAZip;
         fReg	: TRegistry;
         fSQLInfo : TSQLInfo;
         fOutDir		: String;
         fZipDir 		: String;
         fUnZipDir 	: String;
         fTargetDir 	: String;
         fJrnMask		: String;
         fJrnPath		: String;
         fRcptPath	: String;
         fRcptMask	: String;
         fTracePath	: String;
         fTraceMask	: String;
         fOtherPath	: String;
         fJrnDir		: String;
         fRcptDir 	: String;
         fTraceDir 	: String;
         fWorkKey		: String;
         fSLZipFiles 		: TStringList;
         fSLUnZipFiles 		: TStringList;
         fSLMaskFiles 		: TStringList;
         fSLTargetFiles 	: TStringList;

         fPackTime		: TDateTime;
         procedure fReadSQLParam;
         procedure fUnZipFiles;
         function fTestZip(filName : String) : boolean;
         function fUnZip : boolean;
         procedure fWorkFiles;
         procedure fCreateListMask;
         function fMaskPresent(FilName : String) : boolean;
         procedure fCreateListTarget(Mask : String);
         procedure fWorkWithFiles;
         function fRestoreOrgName(FilName : String) : String;
         function fRetDatePresentInFileName (FilName : String) : String;
         function fDefDestDir(fName : String) : Integer;
	      function fIsJrnFile(FilName : String) : boolean;
   	   function fIsTraceFile(FilName : String) : boolean;
      	function fIsReceiptFile(FilName : String) : boolean;
         function fAppendFile(Sour , Dest : String): Integer;
         procedure fPharseTraceFile(FilNam : String);
         function fIsTypeStrTrace(tmpStr : String) : Integer;
         procedure fInsTrace(TypeStr : Integer ; FilNam : String ; Str : String ; dtDate : TDateTime ; dtTime : TDateTime);
         procedure fWorkPack;
         procedure fPacking;
         procedure fOutInfo; 
         procedure fPack(NameDir : String);
         function fZipFiles(DirName , FilName : String) : boolean;
         function fZipTest(Fil: String): boolean;
         function ExtractDate(sSour : String) : TDateTime;
         function fInsSQL(Info : TSQLInfo) : boolean;
      public
         constructor Create(isLog : boolean ; Name : String);
         destructor Destroy;
         procedure Work;

         property OutDir 		: String read fOutDir 	  write  fOutDir 		;
         property ZipDir 		: String read fZipDir 	  write  fZipDir 		;
         property UnZipDir 	: String read fUnZipDir   write  fUnZipDir 	;
         property TargetDir 	: String read fTargetDir  write  fTargetDir 	;
         property JrnMask		: String	read fJrnMask	 	write	fJrnMask	;
         property JrnPath		: String	read fJrnPath	 	write	fJrnPath	;
         property RcptPath		: String	read fRcptPath 	write	fRcptPath;
         property RcptMask		: String	read fRcptMask 	write	fRcptMask;
         property TracePath	: String	read fTracePath 	write	fTracePath;
         property TraceMask	: String	read fTraceMask 	write	fTraceMask;
         property OtherPath	: String	read fOtherPath 	write	fOtherPath;
         property PackTime		: TDateTime read fPackTime write fPackTime;
         property Indus		: String read fIndus write  fIndus;
         property FUIB			: String read fFUIB	 write fFUIB	;
   end;

implementation

{ TFTPATM }

constructor TFTPATM.Create(isLog : boolean ; Name : String);
begin
	inherited Create;
   if isLog then fLog := TLogAcceptor.Create(Name);
   fZip := TKAZip.Create(nil);
   fZip.Active := false;
   fZip.ApplyAtributes := true;
   fZip.CompressionType := ctMaximum;
   fZip.OverwriteAction := oaOverWriteAll;
   fZip.ReadOnly := false;
   fZip.SaveMethod  := FastSave;
   fZip.StoreFolders := false;
   fZip.StoreRelativePath := false;
   fZip.UseTempFiles := false;
	fSLZipFiles 		:= TStringList.Create;
	fSLUnZipFiles 		:= TStringList.Create;
   fSLMaskFiles 		:= TStringList.Create;
	fSLTargetFiles 	:= TStringList.Create;
   if Assigned(fLog) then fLog.Write('class created');
   fReg := TRegistry.Create;
   fReg.RootKey := rootKey;
   fReg.OpenKey(WORKKEY , true);
   fReadSQLParam;
	fConn := TADOConnection.Create(nil);
	fConn.ConnectionString := 'Provider=SQLOLEDB.1;data source=' + fSQLServer + ';Persist Security Info=false;initial catalog=' + fSQLDB + ';user id=' + fSQLUser + ';password=' + fSQLPsw;
   fConn.CommandTimeout := 10000;
   fConn.LoginPrompt := false;
   fConn.KeepConnection := true;
   fConn.ConnectionTimeout := 5000;
	fProc1 := TADOStoredProc.Create(nil);
   fProc1.Connection := fConn;
	fProc2 := TADOStoredProc.Create(nil);
   fProc2.Connection := fConn;

   fProc1.ProcedureName := 'P_FTPUnZIPLog_I';

   fWorkKey := Name;
   if not fReg.KeyExists(fWorkKey) then
   	fReg.CreateKey(fWorkKey);
   fReg.OpenKey(fWorkKey, false);
end;

destructor TFTPATM.Destroy;
begin
   if Assigned(fSLZipFiles)    then FreeAndNil(fSLZipFiles)  ;
   if Assigned(fSLUnZipFiles)  then FreeAndNil(fSLUnZipFiles);
   if Assigned(fSLMaskFiles)  then FreeAndNil(fSLMaskFiles);
   if Assigned(fSLTargetFiles) then FreeAndNil(fSLTargetFiles);
	if Assigned(fProc1) then FreeAndNil(fProc1);
   if Assigned(fProc2) then FreeAndNil(fProc2);
   if fConn.Connected then
   	fConn.Connected := false;
	if Assigned(fConn) then FreeAndNil(fConn);

   if Assigned(fReg) then
   	begin
      	fReg.CloseKey;
         FreeAndNil(fReg);
      end;
   if Assigned(fLog) then FreeAndNil(fLog);
   if Assigned(fZip) then
   	begin
		   fZip.Entries.Clear;
		   if fZip.Active then fZip.Active := false;
         FreeAndNil(fZip);
      end;
   inherited
end;

function TFTPATM.ExtractDate(sSour: String): TDateTime;
var
   sYY , sMM , sDD : String;
   iYY , iMM , iDD : Word;

   sHH , sMN , sSS : String;
   iHH , iMN , iSS : Word;

begin
   sYY := '20' + Copy(sSour , 1 , 2);
   sMM := Copy(sSour , 3 , 2);
   sDD := Copy(sSour , 5 , 2);
   sHH := Copy(sSour , 7 , 2);
   sMN := Copy(sSour , 9 , 2);
   sSS := Copy(sSour , 11 , 2);

   iYY := StrToInt(sYY);
   iMM := StrToInt(sMM);
   iDD := StrToInt(sDD);
   iHH := StrToInt(sHH);
   iMN := StrToInt(sMN);
   iSS := StrToInt(sSS);
   Result := EncodeDate(iYY , iMM , iDD) + EncodeTime(iHH , iMN , iSS , 0);
end;

function TFTPATM.fAppendFile(Sour, Dest: String): Integer;
var
   DestFS : TFileStream;
   SourFS : TFileStream;
   SourSize : Int64;
   CopySize : Int64;
begin
	Result := 0;
	if not FileExists(Dest) then
		DestFS := TFileStream.Create(Dest , fmCreate or fmOpenWrite)
	else
		DestFS := TFileStream.Create(Dest , fmOpenReadWrite);
	SourFS := TFileStream.Create(Sour ,  fmOpenRead);
	DestFS.Seek(0 , soFromEnd);
	sourSize := SourFS.Seek(0 , soFromEnd);
if Assigned(fLog) then	fLog.Write(Sour + '. Size - ' + IntToStr(sourSize));
	SourFS.Seek(0 , soFromBeginning);
	CopySize := DestFS.CopyFrom(SourFS , sourSize);
	FreeAndNil(DestFS);
	FreeAndNil(SourFS);
	if CopySize = sourSize then
   	begin
         if fIsTraceFile(ExtractFileName(Dest)) then fPharseTraceFile(Sour);
         
			SysUtils.DeleteFile(Sour);
         Result := CopySize;
         exit;
      end;
end;

procedure TFTPATM.fCreateListMask;
var
	i : Integer;
   tmpName : String;
   tmpExt : String;
   tmpFullName : String;
begin
	if fSLUnZipFiles.Count > 0 then
   	begin
         for i := 0 to fSLUnZipFiles.Count - 1 do
            begin
               tmpFullName := ExtractFileName(fSLUnZipFiles.Strings[i]);
               if not fMaskPresent(tmpFullName) then
                  begin
                  	tmpName := Copy(tmpFullName , 1 , Pos('__' , tmpFullName) - 1);
                     tmpExt := ExtractFileExt(tmpFullName);
							if Assigned(fLog) then fLog.Write('Mask NOT Present - ' + tmpName + '*' + tmpExt);
                     fSLMaskFiles.Add(tmpName + '*' + tmpExt);
                  end
               else
               	begin
							if Assigned(fLog) then fLog.Write('Mask Present - ' + tmpName + '*' + tmpExt);
                  end;
            end;
      end;
	if Assigned(fLog) then fLog.Write('Count of Mask - ' + IntToStr(fSLMaskFiles.Count));
end;

procedure TFTPATM.fCreateListTarget(Mask: String);
var
	sr : TSearchRec;
begin
   if FindFirst(Mask , Attr , sr) = 0 then
   repeat
   	fSLTargetFiles.Add(UnZipDir + '\' + sr.Name);
   until FindNext(sr) <> 0;
   FindClose(sr);
end;

function TFTPATM.fDefDestDir(fName : String): Integer;
begin   
	if fIsJrnFile(fName) 		then begin Result := 1; exit end;
	if fIsReceiptFile(fName) 	then begin Result := 3; exit end;
	if fIsTraceFile(fName) 		then begin Result := 2; exit end;
   Result := 4;         
end;

procedure TFTPATM.fInsTrace(TypeStr: Integer; FilNam : String ; Str: String; dtDate, dtTime: TDateTime);
var
iretErr : Integer;
   function fRetValue(cParam : String) : String;
   var
   	PosParam : Integer;
      PosEnd : Integer;
	begin
      PosParam := Pos(cParam , Str);
      if PosParam = 0 then
      	begin
         	Result := '';
            exit;
         end;
      PosEnd := PosEx(',' , Str , PosParam + 1);
      if PosEnd = 0 then
       	PosEnd := PosEx(';' , Str , PosParam + 1);
      PosParam := PosParam + Length(cParam) + 1 ; // next after equal symbol
// if Assigned(fLog) then fLog.Write(Str);
if Assigned(fLog) then fLog.Write(cParam + '. Start - ' + IntToStr(PosParam) + '. End - ' + IntToStr(PosEnd) + '. Ret - ' + Copy(Str , PosParam , PosEnd - PosParam));
		Result := Copy(Str , PosParam , PosEnd - PosParam);
	end;

	procedure fInsInfo;
   var
      partCmd : String;
      partMsg : String;
   begin
      partCmd := Trim(Copy(Str , 16 , PosEx(':' , Str , 16)));
      partMsg := Trim(Copy(Str , PosEx(':' , Str , 16) + 1 ));
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

      fProc2.ProcedureName := 'P_LogTraceInfo_I';
	   fProc2.Parameters.CreateParameter('@ATM' 			, ftString 		, pdInput 	, 10 		, fSQLInfo.Indus		);
   	fProc2.Parameters.CreateParameter('@FUIB' 		, ftString 		, pdInput 	, 10 		, fSQLInfo.FUIB		);
	   fProc2.Parameters.CreateParameter('@Date'			, ftDateTime	, pdInput 	, 8 		, dtDate					);
   	fProc2.Parameters.CreateParameter('@Time'			, ftDateTime	, pdInput 	, 8 		, dtTime					);
	   fProc2.Parameters.CreateParameter('@DateTime'	, ftDateTime	, pdInput 	, 8 		, dtDate + dtTime		);
	   fProc2.Parameters.CreateParameter('@FileName'	, ftString 		, pdInput 	, 150 	, fSQLInfo.FileName	);
	   fProc2.Parameters.CreateParameter('@CmdText'		, ftString 		, pdInput 	, 150 	, partCmd				);
	   fProc2.Parameters.CreateParameter('@CmdInfo'		, ftString 		, pdInput 	, 150 	, partMsg				);
	   fProc2.Parameters.CreateParameter('@err'        , ftInteger 	, pdOutput 	, 4 , 0								);
   	fProc2.Parameters.CreateParameter('@Mess'       , ftString  	, pdOutput 	, 100 , 0 							);
	   iRetErr := 0;
   	try
   		fProc2.ExecProc ;
	   except
   		on E : EOleException do
      		begin
					if Assigned(fLog) then fLog.Write('EOleException exec proc.  ' + fProc1.ProcedureName + '. Code - ' + IntToStr(E.ErrorCode) + '. MSG - '  + E.Message + '. ' + E.ClassName ) ;
					iRetErr := E.ErrorCode;
				end;
			on E : Exception do
      		begin
         		if Assigned(fLog) then fLog.Write('Exception exec proc2 in insert Trace Info. ' + E.Message + '. ' + E.ClassName ) ;
	            iRetErr := -1;
   	      end;
      	end;
		fConn.Connected := false;
	end;
	procedure fInsCmdDispense;
   var
		NumCass1 		: String;
		CountCass1     : String;
		KolCass1       : String;
		StatusCass1    : String;
		NumCass2       : String;
		CountCass2     : String;
		KolCass2       : String;
		StatusCass2    : String;
		NumCass3       : String;
		CountCass3     : String;
		KolCass3       : String;
		StatusCass3    : String;
		NumCass4       : String;
		CountCass4     : String;
		KolCass4       : String;
		StatusCass4    : String;
      tmpPos : Integer;
   begin
      NumCass1 		:= Copy(Str , 39 , 1);
      CountCass1 		:= Copy(Str , 41 , 2);
      KolCass1 		:= Copy(Str , 44 , 3);
      StatusCass1 	:= Copy(Str , 48 , 1);
      NumCass2 		:= Copy(Str , 50 , 1);
      CountCass2		:= Copy(Str , 52 , 2);
      KolCass2 		:= Copy(Str , 55 , 3);
      StatusCass2 	:= Copy(Str , 59 , 1);
      NumCass3 		:= Copy(Str , 61 , 1);
      CountCass3 		:= Copy(Str , 63 , 2);
      KolCass3 		:= Copy(Str , 66 , 3);
      StatusCass3 	:= Copy(Str , 70 , 1);
      NumCass4 		:= Copy(Str , 72 , 1);
      CountCass4 		:= Copy(Str , 74 , 2);
      KolCass4 		:= Copy(Str , 77 , 3);
      StatusCass4 	:= Copy(Str , 81 , 1);
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

      fProc2.ProcedureName := 'P_LogTraceCmdDispense_I';
	   fProc2.Parameters.CreateParameter('@ATM' 			, ftString 		, pdInput 	, 10 		, fSQLInfo.Indus		);
   	fProc2.Parameters.CreateParameter('@FUIB' 		, ftString 		, pdInput 	, 10 		, fSQLInfo.FUIB		);
	   fProc2.Parameters.CreateParameter('@Date'			, ftDateTime	, pdInput 	, 8 		, dtDate					);
   	fProc2.Parameters.CreateParameter('@Time'			, ftDateTime	, pdInput 	, 8 		, dtTime					);
	   fProc2.Parameters.CreateParameter('@DateTime'	, ftDateTime	, pdInput 	, 8 		, dtDate + dtTime		);
	   fProc2.Parameters.CreateParameter('@FileName'	, ftString 		, pdInput 	, 150 	, fSQLInfo.FileName	);

	   fProc2.Parameters.CreateParameter('@NumCass1'		, ftString 		, pdInput 	, 10 	, NumCass1			);
	   fProc2.Parameters.CreateParameter('@CountCass1'		, ftString 		, pdInput 	, 10 	, CountCass1		);
	   fProc2.Parameters.CreateParameter('@KolCass1'		, ftString 		, pdInput 	, 10 	, KolCass1			);
	   fProc2.Parameters.CreateParameter('@StatusCass1'	, ftString 		, pdInput 	, 10 	, StatusCass1		);
	   fProc2.Parameters.CreateParameter('@NumCass2'		, ftString 		, pdInput 	, 10 	, NumCass2			);
	   fProc2.Parameters.CreateParameter('@CountCass2'		, ftString 		, pdInput 	, 10 	, CountCass2		);
	   fProc2.Parameters.CreateParameter('@KolCass2'		, ftString 		, pdInput 	, 10 	, KolCass2			);
	   fProc2.Parameters.CreateParameter('@StatusCass2'	, ftString 		, pdInput 	, 10 	, StatusCass2		);
	   fProc2.Parameters.CreateParameter('@NumCass3'		, ftString 		, pdInput 	, 10 	, NumCass3			);
	   fProc2.Parameters.CreateParameter('@CountCass3'		, ftString 		, pdInput 	, 10 	, CountCass3		);
	   fProc2.Parameters.CreateParameter('@KolCass3'		, ftString 		, pdInput 	, 10 	, KolCass3			);
	   fProc2.Parameters.CreateParameter('@StatusCass3'	, ftString 		, pdInput 	, 10 	, StatusCass3		);
	   fProc2.Parameters.CreateParameter('@NumCass4'		, ftString 		, pdInput 	, 10 	, NumCass4			);
	   fProc2.Parameters.CreateParameter('@CountCass4'		, ftString 		, pdInput 	, 10 	, CountCass4		);
	   fProc2.Parameters.CreateParameter('@KolCass4'		, ftString 		, pdInput 	, 10 	, KolCass4			);
	   fProc2.Parameters.CreateParameter('@StatusCass4'	, ftString 		, pdInput 	, 10 	, StatusCass4		);

	   fProc2.Parameters.CreateParameter('@err'        , ftInteger 	, pdOutput 	, 4 , 0								);
   	fProc2.Parameters.CreateParameter('@Mess'       , ftString  	, pdOutput 	, 100 , 0 							);
	   iRetErr := 0;
   	try
   		fProc2.ExecProc ;
	   except
   		on E : EOleException do
      		begin
					if Assigned(fLog) then fLog.Write('EOleException exec proc.  ' + fProc1.ProcedureName + '. Code - ' + IntToStr(E.ErrorCode) + '. MSG - '  + E.Message + '. ' + E.ClassName ) ;
					iRetErr := E.ErrorCode;
				end;
			on E : Exception do
      		begin
         		if Assigned(fLog) then fLog.Write('Exception exec proc2 in insert Trace Cmd Dispense. ' + E.Message + '. ' + E.ClassName ) ;
	            iRetErr := -1;
   	      end;
      	end;
		fConn.Connected := false;

   end;
	procedure fInsCasstte;
   var
      tmpVal : String;
   begin
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

      fProc2.ProcedureName := 'P_LogTraceCassette_I';
	   fProc2.Parameters.CreateParameter('@ATM' 			, ftString 		, pdInput 	, 10 		, fSQLInfo.Indus		);
   	fProc2.Parameters.CreateParameter('@FUIB' 		, ftString 		, pdInput 	, 10 		, fSQLInfo.FUIB		);
	   fProc2.Parameters.CreateParameter('@Date'			, ftDateTime	, pdInput 	, 8 		, dtDate					);
   	fProc2.Parameters.CreateParameter('@Time'			, ftDateTime	, pdInput 	, 8 		, dtTime					);
	   fProc2.Parameters.CreateParameter('@DateTime'	, ftDateTime	, pdInput 	, 8 		, dtDate + dtTime		);
	   fProc2.Parameters.CreateParameter('@FileName'	, ftString 		, pdInput 	, 150 	, fSQLInfo.FileName	);

      tmpVal := fRetValue('LEN');
	   fProc2.Parameters.CreateParameter('@Len'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',RSTA');
      fProc2.Parameters.CreateParameter('@RSTA'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',RACT');
      fProc2.Parameters.CreateParameter('@RACT'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',RRET');
      fProc2.Parameters.CreateParameter('@RRET'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1STA');
      fProc2.Parameters.CreateParameter('@1STA'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1NUM');
      fProc2.Parameters.CreateParameter('@1NUM'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1CUR');
      fProc2.Parameters.CreateParameter('@1CUR'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1REL');
      fProc2.Parameters.CreateParameter('@1REL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1VAL');
      fProc2.Parameters.CreateParameter('@1VAL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1LEN');
      fProc2.Parameters.CreateParameter('@1LEN'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1TOL');
      fProc2.Parameters.CreateParameter('@1TOL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1ACT');
      fProc2.Parameters.CreateParameter('@1ACT'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1LOW');
      fProc2.Parameters.CreateParameter('@1LOW'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1L_D');
      fProc2.Parameters.CreateParameter('@1L_D'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',1REJ');
      fProc2.Parameters.CreateParameter('@1REJ'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2STA');
      fProc2.Parameters.CreateParameter('@2STA'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2NUM');
      fProc2.Parameters.CreateParameter('@2NUM'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2CUR');
      fProc2.Parameters.CreateParameter('@2CUR'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2REL');
      fProc2.Parameters.CreateParameter('@2REL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2VAL');
      fProc2.Parameters.CreateParameter('@2VAL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2LEN');
      fProc2.Parameters.CreateParameter('@2LEN'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2TOL');
      fProc2.Parameters.CreateParameter('@2TOL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2ACT');
      fProc2.Parameters.CreateParameter('@2ACT'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2LOW');
      fProc2.Parameters.CreateParameter('@2LOW'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2L_D');
      fProc2.Parameters.CreateParameter('@2L_D'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',2REJ');
      fProc2.Parameters.CreateParameter('@2REJ'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3STA');
      fProc2.Parameters.CreateParameter('@3STA'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3NUM');
      fProc2.Parameters.CreateParameter('@3NUM'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3CUR');
      fProc2.Parameters.CreateParameter('@3CUR'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3REL');
      fProc2.Parameters.CreateParameter('@3REL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3VAL');
      fProc2.Parameters.CreateParameter('@3VAL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3LEN');
      fProc2.Parameters.CreateParameter('@3LEN'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3TOL');
      fProc2.Parameters.CreateParameter('@3TOL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3ACT');
      fProc2.Parameters.CreateParameter('@3ACT'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3LOW');
      fProc2.Parameters.CreateParameter('@3LOW'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3L_D');
      fProc2.Parameters.CreateParameter('@3L_D'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',3REJ');
      fProc2.Parameters.CreateParameter('@3REJ'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4STA');
      fProc2.Parameters.CreateParameter('@4STA'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4NUM');
      fProc2.Parameters.CreateParameter('@4NUM'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4CUR');
      fProc2.Parameters.CreateParameter('@4CUR'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4REL');
      fProc2.Parameters.CreateParameter('@4REL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4VAL');
      fProc2.Parameters.CreateParameter('@4VAL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4LEN');
      fProc2.Parameters.CreateParameter('@4LEN'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4TOL');
      fProc2.Parameters.CreateParameter('@4TOL'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4LOW');
      fProc2.Parameters.CreateParameter('@4ACT'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4ACT');
      fProc2.Parameters.CreateParameter('@4LOW'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4L_D');
      fProc2.Parameters.CreateParameter('@4L_D'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',4REJ');
      fProc2.Parameters.CreateParameter('@4REJ'		, ftString 		, pdInput 	, 10 	, tmpVal);

	   fProc2.Parameters.CreateParameter('@err'        , ftInteger 	, pdOutput 	, 4 , 0								);
   	fProc2.Parameters.CreateParameter('@Mess'       , ftString  	, pdOutput 	, 100 , 0 							);
	   iRetErr := 0;
   	try
   		fProc2.ExecProc ;
	   except
   		on E : EOleException do
      		begin
					if Assigned(fLog) then fLog.Write('EOleException exec proc.  ' + fProc1.ProcedureName + '. Code - ' + IntToStr(E.ErrorCode) + '. MSG - '  + E.Message + '. ' + E.ClassName ) ;
					iRetErr := E.ErrorCode;
				end;
			on E : Exception do
      		begin
         		if Assigned(fLog) then fLog.Write('Exception exec proc2 in insert Trace Cmd Dispense. ' + E.Message + '. ' + E.ClassName ) ;
	            iRetErr := -1;
   	      end;
      	end;
		fConn.Connected := false;

   end;
	procedure fInsDespenser;
   var
   	tmpVal : String;

   begin
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

      fProc2.ProcedureName := 'P_LogTraceDispenser_I';
	   fProc2.Parameters.CreateParameter('@ATM' 			, ftString 		, pdInput 	, 10 		, fSQLInfo.Indus		);
   	fProc2.Parameters.CreateParameter('@FUIB' 		, ftString 		, pdInput 	, 10 		, fSQLInfo.FUIB		);
	   fProc2.Parameters.CreateParameter('@Date'			, ftDateTime	, pdInput 	, 8 		, dtDate					);
   	fProc2.Parameters.CreateParameter('@Time'			, ftDateTime	, pdInput 	, 8 		, dtTime					);
	   fProc2.Parameters.CreateParameter('@DateTime'	, ftDateTime	, pdInput 	, 8 		, dtDate + dtTime		);
	   fProc2.Parameters.CreateParameter('@FileName'	, ftString 		, pdInput 	, 150 	, fSQLInfo.FileName	);
      
      tmpVal := fRetValue('LEN');
	   fProc2.Parameters.CreateParameter('@Len'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',S_SW');
	   fProc2.Parameters.CreateParameter('@S_SW'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',DLOC');
	   fProc2.Parameters.CreateParameter('@DLOC'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',CAS');
	   fProc2.Parameters.CreateParameter('@CAS'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',SHERR');
	   fProc2.Parameters.CreateParameter('@SHERR'	, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',SHUT');
      fProc2.Parameters.CreateParameter('@SHUT'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',MON');
      fProc2.Parameters.CreateParameter('@MON'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',TER');
      fProc2.Parameters.CreateParameter('@TER'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',TS');
      fProc2.Parameters.CreateParameter('@TS'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',TF');
      fProc2.Parameters.CreateParameter('@TF'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',SR');
      fProc2.Parameters.CreateParameter('@SR'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',DIS');
      fProc2.Parameters.CreateParameter('@DIS'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',CEX');
      fProc2.Parameters.CreateParameter('@CEX '		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',DOOR');
      fProc2.Parameters.CreateParameter('@DOOR'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',DO_S');
      fProc2.Parameters.CreateParameter('@DO_S'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',TYPE');
      fProc2.Parameters.CreateParameter('@TYPE'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',N_VM');
      fProc2.Parameters.CreateParameter('@N_VM'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',SEDM');
      fProc2.Parameters.CreateParameter('@SEDM'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',LCMD');
      fProc2.Parameters.CreateParameter('@LCMD'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',LSTA');
      fProc2.Parameters.CreateParameter('@LSTA'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',SCLE');
      fProc2.Parameters.CreateParameter('@SCLE'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',SRES');
      fProc2.Parameters.CreateParameter('@SRES'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',TST');
      fProc2.Parameters.CreateParameter('@TST'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',SCOD');
      fProc2.Parameters.CreateParameter('@SCOD'		, ftString 		, pdInput 	, 10 	, tmpVal);
      tmpVal := fRetValue(',OR');
      fProc2.Parameters.CreateParameter('@OR'		, ftString 		, pdInput 	, 10 	, tmpVal);

	   fProc2.Parameters.CreateParameter('@err'        , ftInteger 	, pdOutput 	, 4 , 0								);
   	fProc2.Parameters.CreateParameter('@Mess'       , ftString  	, pdOutput 	, 100 , 0 							);
	   iRetErr := 0;
   	try
   		fProc2.ExecProc ;
	   except
   		on E : EOleException do
      		begin
					if Assigned(fLog) then fLog.Write('EOleException exec proc.  ' + fProc1.ProcedureName + '. Code - ' + IntToStr(E.ErrorCode) + '. MSG - '  + E.Message + '. ' + E.ClassName ) ;
					iRetErr := E.ErrorCode;
				end;
			on E : Exception do
      		begin
         		if Assigned(fLog) then fLog.Write('Exception exec proc2 in insert Trace Cmd Dispense. ' + E.Message + '. ' + E.ClassName ) ;
	            iRetErr := -1;
   	      end;
      	end;
		fConn.Connected := false;

   end;
	procedure fInsUnknown;
   var
      partCmd : String;
      partMsg : String;
   begin
      partCmd := 'Unknomn';
      partMsg := Str;
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

      fProc2.ProcedureName := 'P_LogTraceInfo_I';
	   fProc2.Parameters.CreateParameter('@ATM' 			, ftString 		, pdInput 	, 10 		, fSQLInfo.Indus		);
   	fProc2.Parameters.CreateParameter('@FUIB' 		, ftString 		, pdInput 	, 10 		, fSQLInfo.FUIB		);
	   fProc2.Parameters.CreateParameter('@Date'			, ftDateTime	, pdInput 	, 8 		, dtDate					);
   	fProc2.Parameters.CreateParameter('@Time'			, ftDateTime	, pdInput 	, 8 		, dtTime					);
	   fProc2.Parameters.CreateParameter('@DateTime'	, ftDateTime	, pdInput 	, 8 		, dtDate + dtTime		);
	   fProc2.Parameters.CreateParameter('@FileName'	, ftString 		, pdInput 	, 150 	, fSQLInfo.FileName	);
	   fProc2.Parameters.CreateParameter('@CmdText'		, ftString 		, pdInput 	, 150 	, partCmd				);
	   fProc2.Parameters.CreateParameter('@CmdInfo'		, ftString 		, pdInput 	, 150 	, partMsg				);
	   fProc2.Parameters.CreateParameter('@err'        , ftInteger 	, pdOutput 	, 4 , 0								);
   	fProc2.Parameters.CreateParameter('@Mess'       , ftString  	, pdOutput 	, 100 , 0 							);
	   iRetErr := 0;
   	try
   		fProc2.ExecProc ;
	   except
   		on E : EOleException do
      		begin
					if Assigned(fLog) then fLog.Write('EOleException exec proc.  ' + fProc1.ProcedureName + '. Code - ' + IntToStr(E.ErrorCode) + '. MSG - '  + E.Message + '. ' + E.ClassName ) ;
					iRetErr := E.ErrorCode;
				end;
			on E : Exception do
      		begin
         		if Assigned(fLog) then fLog.Write('Exception exec proc2 in insert Trace Unkonown. ' + E.Message + '. ' + E.ClassName ) ;
	            iRetErr := -1;
   	      end;
      	end;
		fConn.Connected := false;

   end;

begin
   fProc2.Close;
   fProc2.Parameters.Clear;
   case TypeStr of
   	1 : fInsInfo;
      2 : fInsCmdDispense;
      3 : fInsCasstte;
      4 : fInsDespenser;
      5 : fInsUnknown;
   end;
end;

function TFTPATM.fInsSQL(Info : TSQLInfo): boolean;
var
iretErr : Integer;
begin
   try
   	fConn.Connected := true;
   except
   	on E : Exception do
      	begin
         	fLog.Write('Error connect. ' + E.Message + '. ' + E.ClassName);
            Result := false;
            exit;
         end;
      end;
   if not fConn.Connected  then
   	begin
      	Result := false;
         exit;
      end;
   fProc1.Parameters.Clear;
   fProc1.Parameters.CreateParameter('@ATM' 			, ftString 		, pdInput 	, 10 		, fSQLInfo.Indus		);
   fProc1.Parameters.CreateParameter('@FUIB' 		, ftString 		, pdInput 	, 10 		, fSQLInfo.FUIB		);
   fProc1.Parameters.CreateParameter('@ZipName'		, ftString 		, pdInput 	, 150 	, fSQLInfo.ZIPName	);
   fProc1.Parameters.CreateParameter('@ZipSize'    , ftInteger 	, pdInput 	, 4 		, fSQLInfo.ZipSize	);
   fProc1.Parameters.CreateParameter('@FromDate'	, ftDateTime	, pdInput 	, 8 		, fSQLInfo.FromDate	);
   fProc1.Parameters.CreateParameter('@ToDate'		, ftDateTime	, pdInput 	, 8 		, fSQLInfo.ToDate		);
   fProc1.Parameters.CreateParameter('@FileName'	, ftString 		, pdInput 	, 150 	, fSQLInfo.FileName	);
   fProc1.Parameters.CreateParameter('@FileExt'		, ftString 		, pdInput 	, 10 		, fSQLInfo.FileExt	);
   fProc1.Parameters.CreateParameter('@FileSize'   , ftInteger 	, pdInput 	, 4 		, fSQLInfo.FileSize	);
   fProc1.Parameters.CreateParameter('@FileDate'	, ftDateTime	, pdInput 	, 8 		, fSQLInfo.FileDate	);
   fProc1.Parameters.CreateParameter('@IsSucces'	, ftInteger		, pdInput 	, 8 		, fSQLInfo.IsSuccess	);

   fProc1.Parameters.CreateParameter('@err'         	, ftInteger , pdOutput 	, 4 , 0);
   fProc1.Parameters.CreateParameter('@Mess'        	, ftString  , pdOutput 	, 100 , 0 );
   iRetErr := 0;
   try
   	fProc1.ExecProc ;
   except
   	on E : EOleException do
      	begin
if Assigned(fLog) then fLog.Write('EOleException exec proc.  ' + fProc1.ProcedureName + '. Code - ' + IntToStr(E.ErrorCode) + '. MSG - '  + E.Message + '. ' + E.ClassName ) ;
				iRetErr := E.ErrorCode;
			end;
		on E : Exception do
      	begin
         	if Assigned(fLog) then fLog.Write('Exception exec proc1 in insert Balancing. ' + E.Message + '. ' + E.ClassName ) ;
            iRetErr := -1;
         end;
      end;
	fConn.Connected := false;
	if iretErr = 0 then Result := true else Result := false;
end;

function TFTPATM.fIsJrnFile(FilName: String): boolean;
var
	tmpDate : String;
   tmpInt : Integer;
begin
   if not (
   			(
            	TryStrToInt(Copy(FilName , 1 , 4) , tmpInt)
             )
             and
   			(
            	TryStrToInt(Copy(FilName , 5 , 4) , tmpInt)
             )
         	)
            then
   	begin
      	Result := false;
         exit;
      end;
	tmpDate := '';
   tmpDate := Copy(FilName , 7 , 2) + '.' + Copy(FilName , 5 , 2) + '.' + Copy(FilName , 1 , 4);
   if not ValidDate(StrToDate(tmpDate)) then
   	begin
      	Result := false;
      	exit;
      end;
   if UPPERCASE(ExtractFileExt(FilName)) = UPPERCASE(ExtractFileExt(fJrnMask)) then
      Result := true
   else
   	Result := false;

end;

function TFTPATM.fIsReceiptFile(FilName: String): boolean;
var
	tmpDate : String;
   tmpTime : String;
   tmpInt : Integer;
begin
   if not (UpperCase(Copy(FilName , 1 , 1)) = UpperCase('r')) then
   	begin
      	Result := false;
         exit;
      end;
   if not (
   			(
            	TryStrToInt(Copy(FilName , 2 , 5) , tmpInt)
            )
             and
   			(
            	TryStrToInt(Copy(FilName , 5 , 5) , tmpInt)
            )
           )  then
   	begin
      	Result := false;
         exit;
      end;
	tmpDate := '';
   tmpDate := Copy(FilName , 6 , 2) + '.' + Copy(FilName , 4 , 2) + '.' + '20' + Copy(FilName , 2 , 2); // + ' ' + Copy(FilName , 8 , 2) + ':' + Copy(FilName , 10 , 2);
   if not ValidDate(StrToDate(tmpDate)) then
   	begin
      	Result := false;
      	exit;
      end;
   if UPPERCASE(ExtractFileExt(FilName)) = UPPERCASE(ExtractFileExt(fRcptMask)) then
      Result := true
   else
   	Result := false;
if Assigned(fLog) then fLog.Write(' 5. fIsReceiptFile');      
end;

function TFTPATM.fIsTraceFile(FilName: String): boolean;
var
	tmpDate : String;
   tmpInt : Integer;
begin
   if not (
   			(
            	TryStrToInt(Copy(FilName , 1 , 4) , tmpInt)
             )
             and
   			(
            	TryStrToInt(Copy(FilName , 5 , 4) , tmpInt)
             )
         	)
            then
   	begin
      	Result := false;
         exit;
      end;
	tmpDate := '';
   tmpDate := Copy(FilName , 7 , 2) + '.' + Copy(FilName , 5 , 2) + '.' + Copy(FilName , 1 , 4);
   if not ValidDate(StrToDate(tmpDate)) then
   	begin
      	Result := false;
      	exit;
      end;
   if UPPERCASE(ExtractFileExt(FilName)) = UPPERCASE(ExtractFileExt(fTraceMask)) then
      Result := true
   else
   	Result := false;
end;

function TFTPATM.fIsTypeStrTrace(tmpStr: String): Integer;
begin
	Result := 5;
   if Pos('FIRMWARE' , tmpStr) <> 0 then Result := 1;
   if Pos('END' , tmpStr) <> 0 then Result := 1;
   if Pos('WFS_CMD_CDM_PRESENT' , tmpStr) <> 0 then Result := 1;
   if Pos('WFS_SRVE_CDM_BILLSTAKEN' , tmpStr) <> 0 then Result := 1;

   if Pos('CMD_CDM_DISPENSE' , tmpStr) <> 0 then Result := 2;

   if Pos('CNG_STATUS_CS' , tmpStr) <> 0 then Result := 3;
   if Pos('CNG_STATUS_DV' , tmpStr) <> 0 then Result := 4;


end;

function TFTPATM.fMaskPresent(FilName : String) : boolean;
var
	i : Integer;
   tmpName : String;
   tmpExt : String;
   tmpMask : String;
begin
	tmpName := Copy(FilName , 1 , Pos('__' , FilName) - 1);
   tmpExt := ExtractFileExt(FilName);
   tmpMask := tmpName + '*' + tmpExt;
   Result := false;
   for i := 0 to fSLMaskFiles.Count - 1 do
   	begin
         if tmpMask = fSLMaskFiles.Strings[i] then
         	begin
             	Result := true;
               exit;
            end;
      end;
end;

procedure TFTPATM.fOutInfo;
begin

end;

procedure TFTPATM.fPack(NameDir: String);
var
	sr : TSearchRec;
   tmpMask : String;
   FilNameInfo : String;
   F : TextFile;
begin
   if not DirectoryExists(NameDir) then
   	ForceDirectories(NameDir);
   if DirectoryExists(NameDir) then
   	begin
         if Pos('\' + fRcptPath , NameDir ) = 0 then
         	begin
		         if FindFirst(NameDir + tmpMask , Attr , sr) = 0 then
      		   	repeat
            		   if FileDateToDateTime(sr.Time) < Date then
               			begin
				               if ExtractFileExt(sr.Name) <> '.zip' then
      				         	begin
            				         if fZipFiles(NameDir , sr.Name) then
                                 	begin
                                    	FilNameInfo := fOutDir + '\' + sr.Name;
                                       AssignFile(F , FilNameInfo);
                                       Rewrite(F);
                                       Writeln(F , IntToStr(sr.Size));
                                       CloseFile(F);
	                  				      DeleteFile(NameDir + '\' + sr.Name);
                                    end;
		                  		end;
		                  end;
      		      until FindNext(sr) <> 0;
		         FindClose(sr);
            end;
      end;
end;

procedure TFTPATM.fPacking;
var
   dtFromDate : TDateTime;
   tmpDate : TDateTime;
   tmpMask : String;
   tmpTarget : String;
   sYY , sMM , sDD : String;
   wYY , wMM , wDD : Word;
   i : Integer;
begin
   dtFromDate := IncDay(Now , -3);
   for i := 0 to 1 do
   	begin
         tmpDate := IncDay(dtFromDate , i);
			DecodeDate(tmpDate , wYY , wMM , wDD);
         sYY := IntToStr(wYY);sMM := IntToStr(wMM);sDD := IntToStr(wDD);
         if Length(sYY) = 2 then sYY := '20' + sYY;
         if wMM  < 10 then sMM := '0' + sMM;
         tmpTarget := fTargetDir + '\' +  sYY + '\' + sMM;
         if not DirectoryExists(tmpTarget) then
            if ForceDirectories(tmpTarget) then
	         	begin
   	            fPack(tmpTarget + '\' + fJrnPath);
      	         fPack(tmpTarget + '\' + fRcptPath);
         	      fPack(tmpTarget + '\' + fTracePath);
            	   fPack(tmpTarget + '\' + fOtherPath);
	            end
				else
            	begin
               	if Assigned(fLog) then fLog.Write('Error create target directories - ' + tmpTarget);
                  
               end;
      end;
end;

procedure TFTPATM.fPharseTraceFile(FilNam: String);
var
	F : TextFile;
   tmpStr : String;
   tmpFil : String;
   sYY , sMM , sDD : String;
   dtDate : TDateTime;
   sFilTime : String;
   dtFilTime : TDateTime;
begin
   tmpFil := ExtractFileName(FilNam);
   sYY := Copy(tmpFil , 1 , 4);
   sMM := Copy(tmpFil , 5 , 2);
   sDD := Copy(tmpFil , 7 , 2);
   dtDate := EncodeDate(StrToInt(sYY) , StrToInt(sMM) , StrToInt(sDD));
	fProc2.Close;
   fProc2.Parameters.Clear;
   AssignFile(F , FilNam);
   Reset(F);
   while not EOF(F) do
   	begin
      	Readln(F , tmpStr);
         if Pos('Time' , tmpStr) = 1 then
         	begin
            	sFilTime := Trim(Copy(tmpStr , 7 , 8));
               dtFilTime := StrToTime(sFilTime);
            	fInsTrace(fIsTypeStrTrace(tmpStr) , ExtractFileName(FilNam) , tmpStr , dtDate , dtFilTime);
            end;
      end;
   CloseFile(F);
end;

procedure TFTPATM.fReadSQLParam;
begin
   if not fReg.ValueExists('SQLServer') then
   	fReg.WriteString('SQLServer' , 'S-Europay');
   if not fReg.ValueExists('SQLDB') then
   	fReg.WriteString('SQLDB' , 'translog');
   if not fReg.ValueExists('SQLUser') then
   	fReg.WriteString('SQLUser' , 'ATM');
   if not fReg.ValueExists('SQLPsw') then
   	fReg.WriteString('SQLPsw' , 'atm');

   fSQLServer := fReg.ReadString('SQLServer');
   fSQLDB	  := fReg.ReadString('SQLDB' 	);
   fSQLUser	  := fReg.ReadString('SQLUser' 	);
   fSQLPsw 	  := fReg.ReadString('SQLPsw' 	);
end;

function TFTPATM.fRestoreOrgName(FilName: String): String;
var
tmpFilName : String;
tmpName : String;
tmpExt : String;
begin
	tmpFilName := ExtractFileName(FilName);
	tmpName := Copy(tmpFilName , 1 , Pos('__' , tmpFilName) - 1);
   tmpExt := ExtractFileExt(tmpFilName);
	Result := tmpName + tmpExt;
end;

function TFTPATM.fRetDatePresentInFileName(FilName: String): String;
var
   sCurrYear4 : String;
   sPrevYear4 : String;
   sCurrYear2 : String;
   sPrevYear2 : String;
   isDate : boolean;
begin
   sCurrYear4 := IntToStr(YearOf(Now));
   sPrevYear4 := IntToStr(YearOf(IncYear(Now , -1)));
   sCurrYear2 := Copy(sCurrYear4 , 3 , 2);
   sPrevYear2 := Copy(sPrevYear4 , 3 , 2);
   if (
   		(Pos(sCurrYear4 , FilName) = 0)
         and
   		(Pos(sPrevYear4 , FilName) = 0)
         and
   		(Pos(sCurrYear2 , FilName) = 0)
         and
   		(Pos(sPrevYear2 , FilName) = 0)
   	) then
   begin
   	Result := '';
      exit;
   end
   else
      if Pos(sCurrYear4 , FilName) > 0 then
         Result := Copy(FilName , Pos(sCurrYear4 , FilName) , 8)
      else
	      if Pos(sPrevYear4 , FilName) > 0 then
   	      Result := Copy(FilName , Pos(sPrevYear4 , FilName) , 8)
	      else
		      if Pos(sCurrYear2 , FilName) > 0 then
   		      Result := Copy(FilName , Pos(sCurrYear2 , FilName) , 6)
            else
			      if Pos(sPrevYear2 , FilName) > 0 then
   			      Result := Copy(FilName , Pos(sPrevYear2 , FilName) , 6);
end;

function TFTPATM.fTestZip(filName: String): boolean;
begin
	fZip.Close;
	if fZip.Entries.Count > 0 then
   	begin
      	fZip.Entries.Clear;
      end;
	try
		fZip.Open(filName);
      Result := true;
	   fSQLInfo.FileName := fZip.Entries.Items[0].FileName;
      fSQLInfo.FileExt := ExtractFileExt(fSQLInfo.FileName);
		fSQLInfo.ZipSize := fZip.Entries.Items[0].SizeCompressed;
   	fSQLInfo.FileSize := fZip.Entries.Items[0].SizeUncompressed;
	   fSQLInfo.FileDate := fZip.Entries.Items[0].Date;
		if fZip.HasBadEntries then
         begin
         	fLog.Write('BAD ZIP. ' + filName);
   	   	Result := false
         end
      else
      	begin
	      	Result := true;
         end;
   except
   	fLog.Write('Except OPEN. ' + filName);
   	Result := false;
   end;
end;

function TFTPATM.fUnZip: boolean;
begin
   if fZip.Active then
   	begin
      	try
	         fZip.ExtractAll(fUnZipDir);
         except
         	on E : Exception do
            	begin
if Assigned(fLog) then fLog.Write('except Exctract ALL');
					   fZip.Entries.Clear;
					   fZip.Close;
               	Result := false;
                  exit;
               end;
         end;
      end;
	fSQLInfo.IsSuccess := 1;      
   fZip.Entries.Clear;
   fZip.Close;         
   Result := true;
end;

procedure TFTPATM.fUnZipFiles;
var
	tmpMask : String;
	sr : TSearchRec;
   i : Integer;
   sFromDate 	: String;
   sToDate 		: String;
begin
   fSlZipFiles.Clear;
	tmpMask := fZipDir + '\*.*.zip';
   if FindFirst(tmpMask , Attr , sr) = 0 then
   	repeat
      	fSLZipFiles.Add(fZipDir + '\' + sr.Name );
      until FindNext(sr) <> 0;;
   FindClose(sr);
   if fSLZipFiles.Count > 0 then
   	begin
         for i := 0 to fSLZipFiles.Count - 1 do
         	begin
               fSQLInfo.Indus := '';
               fSQLInfo.FUIB := '';
               fSQLInfo.ZIPName := '';
               fSQLInfo.FromDate := 0;
               fSQLInfo.ToDate := 0;
               fSQLInfo.ZipSize := 0;
               fSQLInfo.FileName := '';
               fSQLInfo.FileSize := 0;
               fSQLInfo.FileDate := 0;
               fSQLInfo.IsSuccess := 0;
		         if fTestZip(fSLZipFiles.Strings[i]) then
               	begin
                     fSQLInfo.Indus := fIndus;
                     fSQLInfo.FUIB := fFUIB;
                     fSQLInfo.ZIPName := ExtractFileName(fSLZipFiles.Strings[i]);
				         sFromDate 	:= Copy(fSQLInfo.ZIPName , Pos('__' , fSQLInfo.ZIPName) + 2  ,12);
				         sToDate 		:= Copy(fSQLInfo.ZIPName , Pos('__' , fSQLInfo.ZIPName) + 14 ,12);

		               fSQLInfo.FromDate := ExtractDate(sFromDate);
                     fSQLInfo.ToDate := ExtractDate(sToDate);
                     if fUnZip then
                     	if not DeleteFile(fSLZipFiles.Strings[i]) then
                        	begin
if Assigned(fLog) then fLog.Write('ERROR delete file ' + fSLZipFiles.Strings[i] + ' after Unzip');
                           end
                        else
                        	begin

                           end
                     else
                     	begin
if Assigned(fLog) then fLog.Write('ERROR UNZIP file ' + fSLZipFiles.Strings[i]);
                        end;
                  end
            	else
               	begin
if Assigned(fLog) then fLog.Write('ERROR TEST ZIP file ' + fSLZipFiles.Strings[i]);                  
                  end;
            	if not fInsSQL(fSQLInfo) then
               	if Assigned(fLog) then fLog.Write('Error Insert in SQL');
            end;
      end;
end;

procedure TFTPATM.fWorkFiles;
var
	sr : TSearchRec;
   i , j : Integer;
begin
   fSLUnZipFiles.Clear;
	if FindFirst(fUnZipDir + '\*.*' , Attr , sr) <> 0 then
      begin
         if Assigned(fLog) then fLog.Write('No such Files in - ' + fUnZipDir);
         exit;
      end;
   FindClose(sr);
   if FindFirst(fUnZipDir + '\*.*' , Attr , sr) = 0 then
   	repeat
         fSLUnZipFiles.Add(fUnZipDir + '\' + sr.Name);
      until FindNext(sr) <> 0;
   FindClose(sr);
if Assigned(fLog) then fLog.Write('Count Files - ' + IntToStr(fSLUnZipFiles.Count));
   fSLMaskFiles.Clear;
   fCreateListMask;
	for i := 0 to fSLMaskFiles.Count - 1 do
   	begin
      	if Assigned(fLog) then fLog.Write('i = ' + IntToStr(i) + '. ' + fSLMaskFiles.Strings[i]);
		   fSLTargetFiles.Clear;
		   fCreateListTarget(fUnZipDir + '\' + fSLMaskFiles.Strings[i]);
         fSLTargetFiles.Sorted := true;
         fWorkWithFiles;
      end;
end;

procedure TFTPATM.fWorkPack;
var
   LastDatePack : TDateTime;
begin
   if not fReg.ValueExists('LastPack') then
      fReg.WriteDateTime('LastPack' , IncDay(Now , -1));
	LastDatePack := fReg.ReadDate('LastPack');
	if Date > LastDatePack then
  	begin
      if Time > fPackTime then
      	begin
            fPacking;
        end;
    end;
end;

procedure TFTPATM.fWorkWithFiles;
var
	i : Integer;
   OrgFName 		: String;
   DestFileName 	: String;
   FullDestFileName 	: String;
   DateInFile		: String;
   sFromDate			: String;
   sToDate			: String;
   tmpFName 		: String;
   DirYear , DirMonth : String;
   DestDir			: String;
   FullDestDirName : String;
   CopySize : Integer;
begin
	for i := 0 to fSLTargetFiles.Count - 1 do
   	begin
      	tmpFName := ExtractFileName(fSLTargetFiles.Strings[i]);
      	OrgFName := fRestoreOrgName(fSLTargetFiles.Strings[i]);
         sFromDate 	:= Copy(tmpFName , Pos('__' , tmpFName) + 2  ,12);
         sToDate 		:= Copy(tmpFName , Pos('__' , tmpFName) + 14 ,12);
      	DateInFile := fRetDatePresentInFileName(OrgFName);
         if DateInFile = '' then
         	begin
               DirYear := '20' + Copy(sFromDate , 1 , 2);
               DirMonth := Copy(sFromDate , 3 , 2);
               DestFileName := Copy(OrgFNAme , 1 , Pos('.' , OrgFNAme) - 1) + '_20' + Copy(sFromDate , 1 , 6) + ExtractFileExt(OrgFName);
            end
         else
         	begin
               if Copy(DateInFile , 1 , 2) <> '20' then
               	begin
	                  DirYear := '20' + Copy(DateInFile , 1 , 2);
                     DirMonth := Copy(DateInFile , 3 , 2);
                  end
               else
               	begin
	                  DirYear := Copy(DateInFile , 1 , 4);
                     DirMonth := Copy(DateInFile , 5 , 2);
                  end;
               DestFileName := OrgFName;
            end;
         case fDefDestDir(OrgFName) of
         	1 : DestDir := fJrnPath;
            2 : DestDir := fTracePath;
            3 : DestDir := fRcptPath;
            4 : DestDir := fOtherPath;
         else
         	DestDir := '';          
         end;
         FullDestDirName := fTargetDir + '\' + DirYear + '\' + DirMonth + '\' + DestDir;
         if not DirectoryExists(FullDestDirName) then
         	if not ForceDirectories(FullDestDirName) then
            	begin
	            	if Assigned(fLog) then fLog.Write('Error Create Directory - ' + FullDestDirName);
                  break;
               end;
       	FullDestFileName := FullDestDirName + '\' + DestFileName ;
         CopySize := fAppendFile(fSLTargetFiles.Strings[i] , FullDestFileName);
         if CopySize = 0  then
         	begin
            	if Assigned(fLog) then fLog.Write('Error Append from - ' + fSLTargetFiles.Strings[i] + ' To - ' + FullDestFileName);
            end
         else
            begin

            end;
      end;
end;

function TFTPATM.fZipFiles(DirName, FilName: String): boolean;
var
   FS : TFileStream;
   FilNameZip : String;
begin
	if not DirectoryExists(DirName + '\Archive') then
   	if not ForceDirectories(DirName + '\Archive') then
      	begin
         	if Assigned(fLog) then fLog.Write('Error Create Directory - ' + DirName + '\Archive');
            exit;
         end;          
	if not fZip.Active then
   	fZip.Active := true;
   fZip.Close;
   if fZip.Entries.Count > 0 then
   	fZip.Entries.Clear;
	FilNameZip := DirName + '\Archive\' + FilName + '.zip';
   fZip.Active := true;
   fZip.Close;
	try
	   FS := TFileStream.Create(FilNameZip , fmOpenReadWrite or FmCreate);
   	fZip.CreateZip(FS);
   finally
      FreeAndNil(FS);
   end;
   fZip.Open(FilNameZip);
   fZip.AddFile(DirName + '\' + FilName);
   Result := fZipTest(FilNameZip);
   fZip.Close;
   fZip.Active := false;
end;

function TFTPATM.fZipTest(Fil: String): boolean;
var
	retVal  : boolean;
begin
   try
     if fZip.Entries.Items[0].Test Then
      	retVal := true
     else
      	retVal := false;
   except
   	retVal := false;
   end;
	Result := retVal;
end;

procedure TFTPATM.Work;
begin
   fUnZipFiles;
   fWorkFiles;
   fOutInfo;
   fWorkPack;
end;

end.
