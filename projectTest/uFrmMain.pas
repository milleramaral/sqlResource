unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, DbxDevartInterBase, Datasnap.DBClient, Datasnap.Provider, Data.SqlExpr,
  Vcl.DBCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Data.FMTBcd, SQLResource, DbxDevartPostgreSQL;

type
  TfrmMain = class(TForm)
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Splitter1: TSplitter;
    mmoSql: TMemo;
    SqlCnsTable: TSQLResource;
    DspCnstable: TDataSetProvider;
    CdsCnsTable: TClientDataSet;
    DBNavigator1: TDBNavigator;
    DtsCnsTable: TDataSource;
    rdgConnection: TRadioGroup;
    GroupBox1: TGroupBox;
    edtResourceName: TEdit;
    procedure CdsCnsTableReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind;
      var Action: TReconcileAction);
    procedure rdgConnectionClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uDtmConnection;

{$R *.dfm}

procedure TfrmMain.CdsCnsTableReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind;
  var Action: TReconcileAction);
begin
  ShowMessage(E.Message);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  rdgConnectionClick(rdgConnection);
end;

procedure TfrmMain.rdgConnectionClick(Sender: TObject);
begin
  DtmConnection.ConnectionFirebird.Close;
  DtmConnection.ConnectionPostgres.Close;

  CdsCnsTable.Close;
  if rdgConnection.ItemIndex = 0 then
  begin
    SqlCnsTable.SQLConnection := DtmConnection.ConnectionFirebird;
    SqlCnsTable.ReplaceItemsWithRegex.AddPair('(?:(?<![\w\d\S])LIMIT(?![\w\d\S]))/i', 'ROWS');
  end
  else begin
    SqlCnsTable.SQLConnection := DtmConnection.ConnectionPostgres;
    SqlCnsTable.ReplaceItemsWithRegex.AddPair('(?:(?<![\w\d\S])ROWS(?![\w\d\S]))/i', 'LIMIT');
    SqlCnsTable.ReplaceItemsWithRegex.AddPair('\bcount\((([^()]++|\(\g<1>\))*)\)/i', 'CAST( COUNT( $1 ) AS INTEGER )');
  end;
  CdsCnsTable.Open;

  mmoSql.Text := SqlCnsTable.Sql;
  edtResourceName.Text := SqlCnsTable.ResourceType;
end;

end.
