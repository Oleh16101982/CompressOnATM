unit clThWork1;

interface
uses
   	Windows
   ,	Classes
	,	SysUtils
   , Registry
   , 	clLogAcceptor1
	, ADODB, DB
   , activeX
   , clThATMFtp1
   ;
const
	rootKey = HKEY_LOCAL_MACHINE;
   workKey = '\Software\FTPLogATM';
type
	TrecCommon = record
      SQLServer : String;
      SQLDB			: String;
      SQLUser		: String;
      SQLPsw : String;
      DelayWorkCycle : Integer;
      WorkCycle : Integer;
   end;
type
	TrecFTPParam = record
      FTPDrive : String;
      FTPDir : String;
      FTPInDir : String;
      FTPOutDir : String;
      FromFTPDrive : String;
      FromFTPDir : String;
      FromFTPTmpDir : String;
   end;
type
	TrecATM	= record
      Indus : String;
      FUIB : String;
   end;

type
   TThWork = class(TThread)
   private
      fLog : TLogAcceptor;
      fReg : TRegistry;
      fConn : TADOConnection;
      fSQL1	: TADOQuery;
      frecCommon : TrecCommon;
      frecFTPParam : TrecFTPParam;
      frecATM : array of TrecATM;
      fThFTpATM : array of TThFTPATM;

      procedure fReadRegCommon;
      procedure fReadRegFTPParam;
      function fReadSQLParam : boolean;
      procedure fWorked;
      function fCheckDir : boolean;
      function fCreateDir(dir : String) : boolean;
      procedure fCreateThFTPATM;
   public
   	constructor Create(CreateSuspended : boolean ; IsLog : boolean);
      destructor Destroy;
      procedure Execute; override;
      procedure Terminate;


   end;

implementation

{ TThWorkFTPServer }

constructor TThWork.Create(CreateSuspended, IsLog: boolean);
begin
	inherited Create(CreateSuspended);
	if IsLog then fLog := TLogAcceptor.Create('ThWork');
	fConn := TADOConnection.Create(nil);
   fConn.CommandTimeout := 10000;
   fConn.LoginPrompt := false;
   fConn.KeepConnection := true;
   fConn.ConnectionTimeout := 5000;
	fSQL1 := TADOQuery.Create(nil);
   fSQL1.Connection := fConn;
   fReg := Tregistry.Create;
   fReg.RootKey := rootKey;

end;

destructor TThWork.Destroy;
begin
	if Assigned(fReg) then FreeAndNil(fReg);
	if Assigned(fSQL1) then FreeAndNil(fSQL1);
	if Assigned(fConn) then FreeAndNil(fConn);
	if Assigned(fLog) then FreeAndNil(fLog);
end;

procedure TThWork.Execute;
var
i : Integer;
cntCycle : Integer;
begin
  inherited;
  CoInitialize(nil);
  fReadRegCommon;
  fReadRegFTPParam;
  if not fReadSQLParam then
  	begin
      fLog.Write('Error read SQL Param');
   end
  else
	  if not fCheckDir then
  			begin
				if Assigned(fLog) then fLog.Write('ERROR for CHECK FTP DIR');
		   end;
  cntCycle := 0;
  fCreateThFTPATM;
  while not Terminated do
  	begin
      sleep(fRecCommon.DelayWorkCycle);
      Inc(cntCycle);
      if cntCycle >= fRecCommon.WorkCycle then
      	begin
            cntCycle := 0;
            fWorked;
         end;
   end;
  if fConn.Connected then
  	fConn.Connected := false;
  CoUnInitialize;
	for i := 0 to Length(fThFTPATM) - 1 do
   	begin
      	if Assigned(fThFTPATM[i]) then
         	begin
               if fThFTPATM[i].Suspended then
               	fThFTPATM[i].Resume;
               fThFTPATM[i].Terminate;
            end;
      end;
end;

function TThWork.fCheckDir: boolean;
var
 i : Integer;
 tmpFTPPath 		: String;
 tmpFromFTPPath 	: String;
 tmpATMFTPDir			: String;
 tmpATMFromFTPDir			: String;
begin
	tmpFTPPath 		:= frecFTPParam.FTPDrive + '\' + frecFTPParam.FTPDir;
	tmpFromFTPPath := frecFTPParam.FromFTPDrive + '\' + frecFTPParam.FROMFTPDir;

   if not fCreateDir(tmpFTPPath) then
   	begin
      	Result := false;
         exit;
      end;
   if not fCreateDir(tmpFromFTPPath) then
   	begin
      	Result := false;
         exit;
      end;
	for i := 0 to Length(frecATM) - 1 do
   	begin
      	tmpATMFTPDir := tmpFTPPath + '\' + frecATM[i].Indus;
		   if not fCreateDir(tmpATMFTPDir) then
         	begin
	         	Result := false;
   	         exit;
      	   end;
		   if not fCreateDir(tmpATMFTPDir + '\' + frecFTPParam.FTPInDir) then
         	begin
	         	Result := false;
   	         exit;
      	   end;
         if not fCreateDir(tmpATMFTPDir + '\' + frecFTPParam.FTPOutDir) then
         	begin
	         	Result := false;
   	         exit;
      	   end;


      	tmpATMFromFTPDir := tmpFromFTPPath + '\' + frecATM[i].Indus + '_' + frecATM[i].FUIB;
		   if not fCreateDir(tmpATMFromFTPDir) then
         	begin
	         	Result := false;
   	         exit;
      	   end;
         if not fCreateDir(tmpATMFromFTPDir + '\' + frecFTPParam.FromFTPTmpDir) then
         	begin
	         	Result := false;
   	         exit;
      	   end;
      end;
end;

function TThWork.fCreateDir(dir: String): boolean;
begin
	Result := true;
   if not DirectoryExists(Dir) then
   	if not ForceDirectories(Dir) then
      	begin
         	if Assigned(fLog) then fLog.Write('Error create dir - ' + Dir);
            Result := false;
            exit;
         end;
end;

procedure TThWork.fCreateThFTPATM;
var
	i : Integer;
begin
	SetLength(fThFTPATM , Length(frecATM));
   for i := 0 to Length(frecATM) - 1 do
    	begin
         fThFTPATM[i] := TThFTPATM.Create(true , true , frecATM[i].Indus);
         fThFTPATM[i].Indus 				:= frecATM[i].Indus;
         fThFTPATM[i].FUIB 				:= frecATM[i].FUIB;
         fThFTPATM[i].FTPInPath 			:= frecFTPParam.FTPDrive + '\' + frecFTPParam.FTPDir + '\' + frecATM[i].Indus + '\' + frecFTPParam.FTPInDir;
         fThFTPATM[i].FTPOutPath 		:= frecFTPParam.FTPDrive + '\' + frecFTPParam.FTPDir + '\' + frecATM[i].Indus + '\' + frecFTPParam.FTPOutDir;
         fThFTPATM[i].FromFTPPath 		:= frecFTPParam.FromFTPDrive + '\' + frecFTPParam.FromFTPDir + '\' + frecATM[i].Indus + '_' + frecATM[i].FUIB;
         fThFTPATM[i].FromFTPTmpPAth 	:= frecFTPParam.FromFTPDrive + '\' + frecFTPParam.FromFTPDir + '\' + frecATM[i].Indus + '_' + frecATM[i].FUIB + '\' + frecFTPParam.FromFTPTmpDir;
		end;
end;

procedure TThWork.fReadRegCommon;
begin
	fReg.CloseKey;
   if not fReg.KeyExists(WorkKey) then
   	fReg.CreateKey(WorkKey);
   fReg.OpenKey(workKey , false);
   if not fReg.ValueExists('SQLServer') then
   	fReg.WriteString('SQLServer' , 'S-Europay');
   if not fReg.ValueExists('SQLDB') then
   	fReg.WriteString('SQLDB' , 'translog');
   if not fReg.ValueExists('SQLUser') then
   	fReg.WriteString('SQLUser' , 'ATM');
   if not fReg.ValueExists('SQLPsw') then
   	fReg.WriteString('SQLPsw' , 'atm');
   if not fReg.ValueExists('DelayWorkCycle') then
   	fReg.WriteInteger('DelayWorkCycle' , 1);
   if not fReg.ValueExists('WorkCycle') then
   	fReg.WriteInteger('WorkCycle' , 1);

   fRecCommon.SQLServer := fReg.ReadString('SQLServer');
   fRecCommon.SQLDB := fReg.ReadString('SQLDB');
   fRecCommon.SQLUser := fReg.ReadString('SQLUser');
   fRecCommon.SQLPsw := fReg.ReadString('SQLPsw');
   fRecCommon.DelayWorkCycle := fReg.ReadInteger('DelayWorkCycle') * 1000;
   fRecCommon.WorkCycle := fReg.ReadInteger('WorkCycle');
end;

procedure TThWork.fReadRegFTPParam;
begin
	fReg.CloseKey;
   if not fReg.KeyExists(WorkKey) then
   	fReg.CreateKey(WorkKey);
   fReg.OpenKey(workKey , false);
   if not fReg.ValueExists('FTPDrive') then
   	fReg.WriteString('FTPDrive' , 'C:');
   if not fReg.ValueExists('FTPDir') then
   	fReg.WriteString('FTPDir' , 'FTP\ATM');
   if not fReg.ValueExists('FTPInDir') then
   	fReg.WriteString('FTPInDir' , 'IN');
   if not fReg.ValueExists('FTPOutDir') then
   	fReg.WriteString('FTPOutDir' , 'OUT');
   if not fReg.ValueExists('FromFTPDrive') then
   	fReg.WriteString('FromFTPDrive' , 'D:');
   if not fReg.ValueExists('FromFTPDir') then
   	fReg.WriteString('FromFTPDir' , 'FromFTP');
   if not fReg.ValueExists('FromFTPTMPDir') then
   	fReg.WriteString('FromFTPTMPDir' , 'TMP');

   fRecFTPParam.FTPDrive			:= fReg.ReadString('FTPDrive');
   fRecFTPParam.FTPDir				:= fReg.ReadString('FTPDir');
   fRecFTPParam.FTPInDir			:= fReg.ReadString('FTPInDir');
   fRecFTPParam.FTPOutDir			:= fReg.ReadString('FTPOutDir');
   fRecFTPParam.FromFTPDrive		:= fReg.ReadString('FromFTPDrive');
   fRecFTPParam.FromFTPDir			:= fReg.ReadString('FromFTPDir');
   fRecFTPParam.FromFTPTmpDir    := fReg.ReadString('FromFTPTmpDir');
end;

function TThWork.fReadSQLParam: boolean;
var
	tmpIndus : string;
   i : Integer;
begin
//   fConn.ConnectionString := 'data source=S-EUROPAY;user id=ATM;password=atm;initial catalog=Translog';
//   fConn.ConnectionString := 'Provider=SQLOLEDB.1;data source=S-EUROPAY;Integrated Security=SSPI;initial catalog=Translog';
//	fConn.ConnectionString := 'Provider=SQLOLEDB.1;data source=S-EUROPAY;Integrated Security=SSPI;initial catalog=Translog';
	fConn.ConnectionString := 'Provider=SQLOLEDB.1;data source=' + frecCommon.SQLServer + ';Integrated Security=SSPI;initial catalog=' + frecCommon.SQLDB + ';user id=' + frecCommon.SQLUser + ';password=' + frecCommon.SQLPsw;
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
   fSQL1.Close;
   fSQL1.SQL.Clear;
   fSQL1.SQL.Add('select atm_id , atm_number1 , atm_number2 from V_ATMS order by atm_number1');
   try
	   fSQL1.Open;
   except
   	on E : Exception do
      	begin
         	fLog.Write('Error connect. ' + E.Message + '. ' + E.ClassName);
            Result := false;
            exit;
         end;
   end;
   if fSQL1.RecordCount = 0 then
   	begin
      	fLog.Write('No record in V_ATMS');
         Result := false;
         exit;
      end;

   SetLength(frecATM , fSQL1.RecordCount);
   fSQL1.First;
   i := 0;
   while not fSQL1.Eof do
   	begin
      	tmpIndus := Trim(fSQL1.FieldByName('atm_number1').AsString);
      	if StrToInt(tmpIndus) < 10 then
         	begin
	         	tmpIndus := '00' + tmpIndus;
            end
         else
         	begin
		      	if StrToInt(tmpIndus) < 100 then
               	begin
	   		      	tmpIndus := '0' + tmpIndus;
                  end
      	      else
               	begin
	         	   	tmpIndus := tmpIndus;
                  end;
            end;
         frecATM[i].Indus := tmpIndus;
         frecATM[i].FUIB := fSQL1.FieldByName('atm_number2').AsString;
         Inc(i);
      	fSQL1.Next;
      end;
   fSQL1.Close;
   fSQL1.SQL.Clear;
   fConn.Connected := false;
   Result := true;
end;

procedure TThWork.fWorked;
var
	i : Integer;
begin
if Assigned(fLog) then fLog.Write('In Worked');
   for i := 0 to Length(frecATM) - 1 do
    	begin
		   if fThFTPATM[i].Suspended then
   			fThFTPATM[i].Resume;
      end;



end;

procedure TThWork.Terminate;
begin
	inherited;
end;

end.
