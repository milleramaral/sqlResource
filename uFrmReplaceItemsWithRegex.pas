unit uFrmReplaceItemsWithRegex;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DesignIntf, DesignEditors, Data.DB, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Datasnap.DBClient;

type
  TFrmReplaceItemsWithRegex = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    ClientDataSet1KEY: TStringField;
    ClientDataSet1VALUE: TStringField;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetValue(AList: TStringList);
  end;

  TReplaceItemsWithRegexProperty = class(TStringProperty)
  public
    function GetValue: string; override;
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

implementation

uses
  SQLResource;

{$R *.dfm}

{ TReplaceItensProperty }

procedure TReplaceItemsWithRegexProperty.Edit;
var
  frmReplaceItemsWithRegex: TfrmReplaceItemsWithRegex;
begin
  inherited;
  frmReplaceItemsWithRegex := TfrmReplaceItemsWithRegex.Create(nil);
  frmReplaceItemsWithRegex.SetValue(TSqlResource(GetComponent(0)).ReplaceItemsWithRegex);
  if frmReplaceItemsWithRegex.ShowModal = mrOk then
  begin
    TSqlResource(GetComponent(0)).ReplaceItemsWithRegex.Clear;
    frmReplaceItemsWithRegex.ClientDataSet1.First;
    while not frmReplaceItemsWithRegex.ClientDataSet1.Eof do
    begin
      if frmReplaceItemsWithRegex.ClientDataSet1KEY.AsString <> '' then
        TSqlResource(GetComponent(0)).ReplaceItemsWithRegex.Values[frmReplaceItemsWithRegex.ClientDataSet1KEY.AsString] := frmReplaceItemsWithRegex.ClientDataSet1VALUE.AsString;

      frmReplaceItemsWithRegex.ClientDataSet1.Next;
    end;
  end;
  FreeAndNil(frmReplaceItemsWithRegex);
end;

function TReplaceItemsWithRegexProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

function TReplaceItemsWithRegexProperty.GetValue: string;
begin
  Result := TSQLResource(GetComponent(0)).ReplaceItemsWithRegex.Text;
end;

procedure TFrmReplaceItemsWithRegex.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ClientDataSet1.State in [dsEdit, dsInsert] then
    ClientDataSet1.Post;
end;

procedure TFrmReplaceItemsWithRegex.FormCreate(Sender: TObject);
begin
  ClientDataSet1.CreateDataSet;
end;

procedure TFrmReplaceItemsWithRegex.SetValue(AList: TStringList);
var
  i: Integer;
begin
  for I := AList.Count-1 downto 0 do
  begin
    ClientDataSet1.Insert;
    ClientDataSet1KEY.AsString := AList.Names[i];
    ClientDataSet1VALUE.AsString := AList.ValueFromIndex[i];
    ClientDataSet1.Post;
  end;
end;

end.
