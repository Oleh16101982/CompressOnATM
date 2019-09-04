program Main;

uses
  Forms,
  FTPFromATM in 'FTPFromATM.pas' {Form3},
  clThWork1 in 'clThWork1.pas',
  clThATMFtp1 in 'clThATMFtp1.pas',
  clFTPATM1 in 'clFTPATM1.pas',
  clThPharseTrace1 in 'clThPharseTrace1.pas',
  clPharseJrn1 in 'clPharseJrn1.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
