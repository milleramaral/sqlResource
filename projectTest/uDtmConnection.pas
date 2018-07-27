unit uDtmConnection;

interface

uses
  System.SysUtils, System.Classes, DbxDevartInterBase, DbxDevartPostgreSQL, Data.DB, Data.SqlExpr;

type
  TDtmConnection = class(TDataModule)
    ConnectionFirebird: TSQLConnection;
    ConnectionPostgres: TSQLConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DtmConnection: TDtmConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
