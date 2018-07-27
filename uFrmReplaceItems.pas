unit uFrmReplaceItems;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DesignIntf, DesignEditors, Data.DB, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Datasnap.DBClient;

type
  TfrmReplaceItems = class(TForm)
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

  TReplaceItemsProperty = class(TStringProperty)
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

procedure TReplaceItemsProperty.Edit;
var
  frmReplaceItems: TfrmReplaceItems;
begin
  inherited;
  frmReplaceItems := TfrmReplaceItems.Create(nil);
  frmReplaceItems.SetValue(TSqlResource(GetComponent(0)).ReplaceItems);
  if frmReplaceItems.ShowModal = mrOk then
  begin
    TSqlResource(GetComponent(0)).ReplaceItems.Clear;
    frmReplaceItems.ClientDataSet1.First;
    while not frmReplaceItems.ClientDataSet1.Eof do
    begin
      if frmReplaceItems.ClientDataSet1KEY.AsString <> '' then
        TSqlResource(GetComponent(0)).ReplaceItems.Values[frmReplaceItems.ClientDataSet1KEY.AsString] := frmReplaceItems.ClientDataSet1VALUE.AsString;

      frmReplaceItems.ClientDataSet1.Next;
    end;
  end;
  FreeAndNil(frmReplaceItems);
end;

function TReplaceItemsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

function TReplaceItemsProperty.GetValue: string;
begin
  Result := TSQLResource(GetComponent(0)).ReplaceItems.Text;
end;

procedure TfrmReplaceItems.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ClientDataSet1.State in [dsEdit, dsInsert] then
    ClientDataSet1.Post;
end;

procedure TfrmReplaceItems.FormCreate(Sender: TObject);
begin
  ClientDataSet1.CreateDataSet;
end;

procedure TfrmReplaceItems.SetValue(AList: TStringList);
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
