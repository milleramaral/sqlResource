program SqlResourceTest;

{$R 'queries.res' 'queries.rc'}

uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {frmMain},
  uDtmConnection in 'uDtmConnection.pas' {DtmConnection: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDtmConnection, DtmConnection);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
