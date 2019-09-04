unit clThATMFtp1;

interface

uses
  Classes
  , Windows
  , SysUtils
  , Registry
  , clFTPATM1
  , clLogAcceptor1;
const
	rootKey = HKEY_LOCAL_MACHINE;
   workKey = '\Software\FTPLogATM';
   commonKey = 'Common';
type
	TrecCommon = record
      DelayWorkCycle			: Integer;
      WorkCycle				: Integer;
      JrnDir					: String;
      JrnMask					: String;
      RcptDir					: String;
      RcptMask					: String;
      TraceDir					: String;
      TraceMask				: String;
      OtherDir					: String;
      PackTime					: String;
   end;
type
  TThFTPATM = class(TThread)
  private
    { Private declarations }
    fLog 				: TLogAcceptor;
    fReg 				: TRegistry;
    fFTPATM 			: TFTPATM;
    fIndus 				: String;
    fFUIB 				: String;
    fFTPInPath 		: String;
    fFTPOutPath 		: String;
    fFromFTPPath 		: String;
    fFromFTPTmpPath 	: String;
    frecCommon  : TrecCommon;
    procedure fReadCommonParam;
    procedure fWorked;
  public
  	constructor Create(CreateSuspended , isLog : boolean ; Name : String);
   Destructor Destroy;
   procedure Execute; override;
   procedure Terminate;

   property Indus 			: String read fIndus 			write  fIndus 				;
   property FUIB 				: String read fFUIB 				write  fFUIB 				;
   property FTPInPath 		: String read fFTPInPath 		write  fFTPInPath 		;
   property FTPOutPath 		: String read fFTPOutPath 		write  fFTPOutPath 		;
   property FromFTPPath 	: String read fFromFTPPath 	write  fFromFTPPath 		;
   property FromFTPTmpPath : String read fFromFTPTmpPath write  fFromFTPTmpPath 	;


  end;

implementation

{ TThFTPATM }

constructor TThFTPATM.Create(CreateSuspended, isLog : boolean ; Name : String);
begin
	inherited Create(CreateSuspended);
	if IsLog then fLog := TLogAcceptor.Create('ThATM_' + Name);
   fReg := TRegistry.Create;
   fReg.RootKey := rootKey;
   fReg.OpenKey(workKey , false);
   fFTPATM := TFTPATM.Create(true , 'ATM_' + Name);
   fReadCommonParam;   
end;

destructor TThFTPATM.Destroy;
begin
   fReg.CloseKey;
   if Assigned(fReg) then FreeAndNil(fReg);
   if Assigned(fFTPATM) then FreeAndNil(fFTPATM);
	if Assigned(fLog) then FreeAndNil(fLog);
   inherited;
end;

procedure TThFTPATM.Execute;
var
   cntCycles : Integer;
begin
	if Assigned(fLog) then fLog.Write(fIndus 			);
   if Assigned(fLog) then fLog.Write(fFUIB 			);
   if Assigned(fLog) then fLog.Write(fFTPInPath 	);
   if Assigned(fLog) then fLog.Write(fFTPOutPath 	);
   if Assigned(fLog) then fLog.Write(fFromFTPPath 	);
   if Assigned(fLog) then fLog.Write(fFromFTPTmpPath);
   fFTPATM.Indus  	:= fIndus;
   fFTPATM.FUIB	   := fFUIB;
   fFTPATM.OutDir    := fFTPOutPath;
   fFTPATM.ZipDir    := fFTPInPath;
   fFTPATM.UnZipDir 	:= fFromFTPTmpPath;
   fFTPATM.TargetDir	:= fFromFTPPath;
   fFTPATM.JrnPath   := frecCommon.JrnDir;
   fFTPATM.JrnMask   := frecCommon.JrnMask;
   fFTPATM.RcptPath  := frecCommon.RcptDir;
   fFTPATM.RcptMask  := frecCommon.RcptMask;
   fFTPATM.TracePath := frecCommon.TraceDir;
   fFTPATM.TraceMask := frecCommon.TraceMask;
   cntCycles := 0;
  while not Terminated do
  	begin
   	if Assigned(fLog) then fLog.Write('In while not terminated');
      Inc(cntCycles);
      sleep(frecCommon.DelayWorkCycle);
      if cntCycles >= frecCommon.WorkCycle then
      	begin
		   	if Assigned(fLog) then fLog.Write('In while not terminated. Go Work Cycle');         
         	fWorked;
            cntCycles := 0;
         end;
   end;
end;

procedure TThFTPATM.fReadCommonParam;
begin
	fReg.CloseKey;
   fReg.OpenKey(workKey , false);
   if not fReg.KeyExists(commonKey) then
   	fReg.CreateKey(commonKey);
	fReg.CloseKey;
   fReg.OpenKey(workKey + '\' + commonKey , false);
   if not fReg.ValueExists('DelayWorkCycle'	) then fReg.WriteInteger('DelayWorkCycle' , 1);
   if not fReg.ValueExists('WorkCycle'			) then fReg.WriteInteger('WorkCycle'      , 300);
   if not fReg.ValueExists('JrnDir'				) then fReg.WriteString ('JrnDir'         , 'Journal');
   if not fReg.ValueExists('JrnMask'			) then fReg.WriteString ('JrnMask'        , 'YYYYMMDD.jrn');
   if not fReg.ValueExists('RcptDir'			) then fReg.WriteString ('RcptDir'        , 'Receipt');
   if not fReg.ValueExists('RcptMask'			) then fReg.WriteString ('RcptMask'       , 'rYYMMDDHHMN.log');
   if not fReg.ValueExists('TraceDir'			) then fReg.WriteString ('TraceDir'       , 'Trace');
   if not fReg.ValueExists('TraceMask'			) then fReg.WriteString ('TraceMask'      , 'YYYYMMDD.trc');
   if not fReg.ValueExists('OtherDir'			) then fReg.WriteString ('OtherDir'      , 'Other');
   if not fReg.ValueExists('PackTime'			) then fReg.WriteString ('PackTime'      , '03:30:00');

   frecCommon.DelayWorkCycle	:=	fReg.ReadInteger('DelayWorkCycle') * 1000;
   frecCommon.WorkCycle 		:=	fReg.ReadInteger('WorkCycle'     );
   frecCommon.JrnDir 			:=	fReg.ReadString ('JrnDir'        );
   frecCommon.JrnMask 			:=	fReg.ReadString ('JrnMask'       );
   frecCommon.RcptDir 			:=	fReg.ReadString ('RcptDir'       );
   frecCommon.RcptMask 			:=	fReg.ReadString ('RcptMask'      );
   frecCommon.TraceDir 			:=	fReg.ReadString ('TraceDir'      );
   frecCommon.TraceMask 		:=	fReg.ReadString ('TraceMask'     );
   frecCommon.OtherDir	 		:=	fReg.ReadString ('OtherDir'     );
   frecCommon.PackTime	 		:=	fReg.ReadString ('PackTime'     );
   fFTPATM.JrnMask		:= fRecCommon.JrnMask;
   fFTPATM.JrnPath  		:= fRecCommon.JrnDir;
   fFTPATM.RcptMask		:= fRecCommon.RcptMask;
   fFTPATM.RcptPath		:= fRecCommon.RcptDir;
   fFTPATM.TraceMask		:= fRecCommon.TraceMask;
   fFTPATM.TracePath		:= fRecCommon.TraceDir;
   fFTPATM.OtherPath		:= fRecCommon.OtherDir;
   fFTPATM.PackTime		:= StrToTime(fRecCommon.PackTime);
end;

procedure TThFTPATM.fWorked;
begin
	fFTPATM.Work;
end;

procedure TThFTPATM.Terminate;
begin
   if Assigned(fLog) then fLog.Write('In terminate');
	inherited;
end;

end.
