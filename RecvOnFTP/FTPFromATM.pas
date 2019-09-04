unit FTPFromATM;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls
  , clThWork1;

type
  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    M1: TMemo;
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fThWork : TThWork;
    fIsTerminated : boolean;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
begin
   if fThWork.Suspended then
   	fThWork.Resume;
   fIsTerminated := false;
   M1.Lines.Add('Thread started');
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
   if not fThWork.Suspended then
   	fThWork.Suspend;
	fIsTerminated := false;
   M1.Lines.Add('Thread paused');
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
	if fThWork.Suspended then
      fThWork.Resume;
   M1.Lines.Add('Thread terminated');
   fThWork.Terminate;
   fIsTerminated := true;
end;

procedure TForm3.Button4Click(Sender: TObject);
begin
   if not fIsTerminated then
   	begin
			if fThWork.Suspended then
   			fThWork.Resume;
		   fThWork.Terminate;
      end;
   M1.Lines.Add('Thread destroyed');	      
	fThWork.Destroy;
end;



procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	if Assigned(fThWork) then FreeAndNil(fThWork);
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
   fThWork := TThWork.Create(true , true);
   fIsTerminated := false;
   M1.Lines.Clear;
end;

end.
