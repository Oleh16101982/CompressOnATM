unit clThPharseTrace1;

interface

uses
  Classes
  , Registry
  , SysUtils
	, ADODB, DB
   , activeX

  , clLogAcceptor1

  ;
type
  ThPharseTrace = class(TThread)
  private
    { Private declarations }
    fLog 			: TLogAcceptor;
    fReg 			: TRegistry;
    fIndus 			: String;
    fFUIB 			: String;
    fSQLServer 	: String;
    fSQLDB			: String;
    fSQLUser		: String;
    fSQLPsw 		: String;
    fConn 			: TADOConnection;
    fProc1			: TADOStoredProc; // status cassetes
    fProc2			: TADOStoredProc; // status dispenser
    fProc3			: TADOStoredProc; // info Message
    fProc4			: TADOStoredProc; // cdm dispense message        


  protected
    procedure Execute; override;

  public
  	constructor Create(CreateSuspended , isLog : boolean ; Name : String);
   Destructor Destroy;
   procedure Terminate;


  		property Indus 			: String read fIndus 		write  fIndus 				 ;
		property FUIB 				: String read fFUIB 			write  fFUIB 				 ;
		property SQLServer 		: String read fSQLServer 	write  fSQLServer 		 ;
    	property SQLDB				: String read fSQLDB	 		write  fSQLDB	 			 ;
    	property SQLUser			: String read fSQLUser	 	write  fSQLUser	 		 ;
    	property SQLPsw 			: String read fSQLPsw 	 	write  fSQLPsw 	 		 ;

  end;

implementation

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure ThPharseTrace.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ ThPharseTrace }

constructor ThPharseTrace.Create(CreateSuspended, isLog: boolean; Name: String);
begin
	inherited Create(CreateSuspended);
	if IsLog then fLog := TLogAcceptor.Create('ThPharseATM_' + Name);
	fConn := TADOConnection.Create(nil);
   fConn.CommandTimeout := 10000;
   fConn.LoginPrompt := false;
   fConn.KeepConnection := true;
   fConn.ConnectionTimeout := 5000;
	fProc1 := TADOStoredProc.Create(nil);
   fProc1.Connection := fConn;
   fProc1.ProcedureName := 'LogTraceCassette';
	fProc2 := TADOStoredProc.Create(nil);
   fProc2.Connection := fConn;
   fProc1.ProcedureName := 'LogTraceDispenser';
	fProc3 := TADOStoredProc.Create(nil);
   fProc3.Connection := fConn;
   fProc1.ProcedureName := 'LogTraceInfo';
	fProc4 := TADOStoredProc.Create(nil);
   fProc4.Connection := fConn;
   fProc1.ProcedureName := 'LogTraceCmdDispense';

{
   fReg := TRegistry.Create;
   fReg.RootKey := rootKey;
   fReg.OpenKey(workKey , false);
   fFTPATM := TFTPATM.Create(true , 'ATM_' + Name);
   fReadCommonParam;
}
end;

destructor ThPharseTrace.Destroy;
begin
	if Assigned(fReg) then FreeAndNil(fReg);
	if Assigned(fProc1) then FreeAndNil(fProc1);
	if Assigned(fProc2) then FreeAndNil(fProc2);
	if Assigned(fProc3) then FreeAndNil(fProc3);
	if Assigned(fProc4) then FreeAndNil(fProc4);
	if Assigned(fConn) then FreeAndNil(fConn);
	if Assigned(fLog) then FreeAndNil(fLog);
end;

procedure ThPharseTrace.Execute;
begin
  { Place thread code here }

   while not Terminated do
   	begin
      	if Assigned(fLog) then fLog.Write('In while not Terminated');
         sleep(1000);
      end;
end;

procedure ThPharseTrace.Terminate;
begin

end;

end.
