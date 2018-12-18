unit SQLResource;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr;

const
  DEFAULT_DESIGNER_FOLDER_NAME = 'Queries';

type
  TOnResourceNotFoundEvent = procedure(AResourceName, AResourceType: string) of object;

  TSQLResource = class(TSQLDataSet)
  strict private
    function LoadResourceString(const aResourceName: string; aResourceType: string = 'SQL' ): string;

  private
    FInitialParameters: TParams;
    FDesignerUseSingleFile: Boolean;
    FReplaceItems: TStringList;
    FReplaceItemsWithRegex: TStringList;
    FAddOnWhere: string;
    FDesignerFolderName: string;
    FOnResourceNotFound: TOnResourceNotFoundEvent;
    FForceResourceName: string;
    FForceLoadFile: string;

    function resourceFilePath: string;
    function getDesignerFile: string;
    function getResourceName: string;
    function getDesignerPath: string;
    function formatSqlFileName(AType: string): string;
    function getSql: string;
    function DesignerFolderNameIsStored: Boolean;
    procedure SetForceResourceName(const Value: string);
    function forceResourceNameIsStored: Boolean;
    procedure SetForceLoadFile(const Value: string);
    function forceLoadFileIsStored: Boolean;

  protected // Custom
    function GetFromPosition(SqlClause: string): Integer; virtual;
    function ReplaceTextsOnSQL(ASql: string): string; virtual;
    function ReplaceTextsOnSQLWithRegex(ASql: string): string; virtual;
    function loadSql: string; virtual;
    function insertTextOnWhere(SqlClause, SqlFilter: string): string; virtual;
    function getResourceType: string; virtual;
    procedure loadInitialParameters; virtual;

  protected // Override
    procedure SetCommandText(const Value: string); override;
    procedure OpenCursor(InfoQuery: Boolean); override;
    procedure CloseCursor; override;
    function PSGetTableName: string; override;
    function PSGetCommandText: string; override;
  public
    constructor Create(AOwner: TComponent); overload; override;
    destructor Destroy; override;

    function ExecSQL(ExecDirect: Boolean = False): Integer; override;

  published
    property CommandText stored false;
    property OnResourceNotFound: TOnResourceNotFoundEvent read FOnResourceNotFound write FOnResourceNotFound;

    property AddOnWhere: string read FAddOnWhere write FAddOnWhere;
    property ReplaceItems: TStringList read FReplaceItems write FReplaceItems;
    property ReplaceItemsWithRegex: TStringList read FReplaceItemsWithRegex write FReplaceItemsWithRegex;

    property ResourceName: string read getResourceName;
    property ForceResourceName: string read FForceResourceName write SetForceResourceName stored forceResourceNameIsStored;
    property ForceLoadFile: string read FForceLoadFile write SetForceLoadFile stored forceLoadFileIsStored;

    property ResourceType: string read getResourceType;
    property Sql: string read getSql;

    property DesignerUseSingleFile: boolean read FDesignerUseSingleFile write FDesignerUseSingleFile default true;
    property DesignerFile: string read getDesignerFile;
    property DesignerPath: string read getDesignerPath;
    property DesignerFolderName: string read FDesignerFolderName write FDesignerFolderName stored DesignerFolderNameIsStored;
  end;
var
  GetCurrentProjectPath: TFunc<String>;

implementation

uses
  System.RegularExpressions,
  System.StrUtils,
  Data.DBCommon,
  Vcl.Forms,
  Winapi.Windows,
  Vcl.Dialogs,
  System.IOUtils, Data.DBXCommon;

function GetIdOption(Connection: TSQLConnection): IDENTIFIEROption;
var
  MetaData: TDBXDatabaseMetaData;
begin
  Result := idMixCase;
  if (Assigned(Connection) and Assigned(Connection.DBXConnection)) then
  begin
    MetaData := Connection.MetaData;
    if Assigned(MetaData) and (MetaData.MetaDataVersion = DBXVersion40) then
    begin
      if not MetaData.SupportsLowerCaseIdentifiers then
        Result := idMakeUpperCase
      else if not MetaData.SupportsUpperCaseIdentifiers then
        Result := idMakeLowerCase;
    end;
  end;
end;

{ TSQLResource }

constructor TSQLResource.Create(AOwner: TComponent);
begin
  inherited;
  FInitialParameters := TParams.Create(Self);
  FDesignerUseSingleFile := true;
  FDesignerFolderName := DEFAULT_DESIGNER_FOLDER_NAME;

  FReplaceItems := TStringList.Create;
  FReplaceItems.Delimiter := '|';
  FReplaceItems.QuoteChar := '"';
  FReplaceItems.StrictDelimiter := true;
  FReplaceItems.Sorted := false;

  FReplaceItemsWithRegex := TStringList.Create;
  FReplaceItemsWithRegex.Delimiter := '|';
  FReplaceItemsWithRegex.QuoteChar := '"';
  FReplaceItemsWithRegex.StrictDelimiter := true;
  FReplaceItemsWithRegex.Sorted := false;
end;

function TSQLResource.DesignerFolderNameIsStored: Boolean;
begin
  Result := FDesignerFolderName <> DEFAULT_DESIGNER_FOLDER_NAME;
end;

destructor TSQLResource.Destroy;
begin
  if Assigned(FInitialParameters) then
    FreeAndNil(FInitialParameters);

  FreeAndNil(FReplaceItems);
  FreeAndNil(FReplaceItemsWithRegex);
  inherited;
end;

function TSQLResource.ExecSQL(ExecDirect: Boolean): Integer;
begin
  CommandText := getSql;
  loadInitialParameters;
  Result := inherited ExecSQL(ExecDirect);
end;

procedure TSQLResource.CloseCursor;
begin
  inherited;
  loadInitialParameters;
end;

procedure TSQLResource.SetCommandText(const Value: string);
begin
  FInitialParameters.Clear;
  if Params.Count > 0 then
    FInitialParameters.Assign(Params);

  inherited;
end;

function TSQLResource.getResourceType: string;
begin
  if self.SQLConnection = nil then
    result := ''
  else result := self.SQLConnection.DriverName;
end;

procedure TSQLResource.SetForceLoadFile(const Value: string);
begin
  if Trim(Value) <> '' then
    ForceResourceName := '';

  FForceLoadFile := Trim(Value);
end;

procedure TSQLResource.SetForceResourceName(const Value: string);
begin
  if Trim(Value) <> '' then
    ForceLoadFile := '';

  FForceResourceName := Trim(Value);
end;

function TSQLResource.PSGetCommandText: string;
begin
  Result := sql;
end;

function TSQLResource.PSGetTableName: string;
begin
  Result := GetTableNameFromSQLEx(Sql, GetIdOption(SQLConnection));
end;

procedure TSQLResource.loadInitialParameters;
begin
  if FInitialParameters.Count > 0 then
  begin
    if ParamCount = 0 then
      Params.Assign(FInitialParameters)
    else Params.AssignValues(FInitialParameters);
  end;
end;

function loadFromFile(AFileName: string): string;
var
  sqlFile: TStringList;
begin
  if (FileExists(AFileName)) then
  begin
    sqlFile := TStringList.Create;
    try
      sqlFile.LoadFromFile(AFileName);
      Result := sqlFile.Text;
    finally
      FreeAndNil(sqlFile);
    end;
  end
  else Result := Format('file "%s" not found.', [AFileName]);
end;

function TSQLResource.loadSql: string;
begin
  Result := '';

  if resourceType.IsEmpty then
    result := 'set the property "resourceType"'
  else if (FForceLoadFile <> '') then
      result := loadFromFile(FForceLoadFile)
  else if (csDesigning in ComponentState) then
    result := loadFromFile(DesignerFile)
  else Result := LoadResourceString(resourceName, resourceType);
end;

procedure TSQLResource.OpenCursor(InfoQuery: Boolean);
begin
  if resourceType.IsEmpty then
    raise Exception.Create('Property resourceType not defined');

  CommandText := getSql;
  loadInitialParameters;

  inherited;
end;

function TSQLResource.getSql: string;
begin
  Result := loadSql;

  if AddOnWhere <> '' then
    Result := insertTextOnWhere(Result, AddOnWhere);

  Result := ReplaceTextsOnSQL(Result);
  Result := ReplaceTextsOnSQLWithRegex(Result);
end;

function TSQLResource.insertTextOnWhere(SqlClause, SqlFilter: string): string;
var
  FromPosition, WherePosition: Integer;
  WhereClause: String;
begin
  if (Trim(SqlClause) <> '') and (Trim(SqlFilter) <> '') then
  begin
    SqlClause := UpperCase(SqlClause);

    FromPosition := GetFromPosition(SqlClause);
    WherePosition := PosEx('WHERE', SqlClause, FromPosition);

    if (WherePosition = 0) then
    begin
      WhereClause:=  ' WHERE (' + SqlFilter + ' ) ';

      WherePosition := PosEx('GROUP', SqlClause, FromPosition);
      if (WherePosition = 0) then
      begin
        WherePosition := PosEx('ORDER', SqlClause, FromPosition);
      end;
      if (WherePosition = 0) then
      begin
        WherePosition := Length(SqlClause) + 1;
      end;
    end
    else
    begin
      WhereClause:= ' ( ' + SqlFilter + ' ) AND ';

      WherePosition := WherePosition + Length('WHERE');
    end;

    SqlClause:= Copy(SqlClause, 1, WherePosition - 1) + #13 + WhereClause + #13 + Copy(SqlClause, WherePosition, Length(SqlClause));
  end;
  Result:= SqlClause;
end;

function TSQLResource.GetFromPosition(SqlClause: string): Integer;
var
  SelectPosition,
  FromPosition: Integer;
begin
  SelectPosition := PosEx('SELECT', SqlClause, 2);
  FromPosition := Pos('FROM', SqlClause);
  while (SelectPosition <> 0) and (SelectPosition < FromPosition) do
  begin
    SelectPosition := PosEx('SELECT', SqlClause, SelectPosition + 1);
    FromPosition := PosEx('FROM', SqlClause, FromPosition + 1);
  end;
  Result := FromPosition;
end;

function TSQLResource.ReplaceTextsOnSQL(ASql: string): string;
var
  I: Integer;
begin
  Result := ASql;
  for I := 0 to ReplaceItems.Count-1 do
   Result := StringReplace(Result, ReplaceItems.Names[i], ReplaceItems.ValueFromIndex[i], [rfReplaceAll]);
end;

function TSQLResource.ReplaceTextsOnSQLWithRegex(ASql: string): string;
var
  I: Integer;
  Options: TRegExOptions;
  RegexValue: string;
begin
  Result := ASql;
  for I := 0 to ReplaceItemsWithRegex.Count-1 do
  begin
    RegexValue := ReplaceItemsWithRegex.Names[i];
    Options := [];

    if (TRegex.IsMatch(RegexValue, '\/[msi]{1,3}$', [roIgnoreCase])) then
    begin
      if (TRegex.IsMatch(RegexValue, '\/.{0,2}i.{0,2}$')) then
        Options := Options + [roIgnoreCase];
      if (TRegex.IsMatch(RegexValue, '\/.{0,2}m.{0,2}$')) then
        Options := Options + [roMultiLine];
      if (TRegex.IsMatch(RegexValue, '\/.{0,2}s.{0,2}$')) then
        Options := Options + [roSingleLine];

      RegexValue := TRegex.replace(RegexValue, '\/[msi]{1,3}$', '', [roIgnoreCase]);
    end;

    Result := TRegEx.Replace(Result, RegexValue, ReplaceItemsWithRegex.ValueFromIndex[i], Options);
  end;
end;

function TSQLResource.getDesignerPath: string;
begin
  result := GetCurrentProjectPath;
end;

function TSQLResource.resourceFilePath: string;
begin
  Result := TPath.Combine(GetCurrentProjectPath, FDesignerFolderName);
end;

function TSQLResource.getResourceName: string;
begin
  if FForceLoadFile <> '' then
    result := ''
  else if FForceResourceName <> '' then
    Result := FForceResourceName
  else begin
    Result := Format('%s%s', [
      Owner.ClassName,
      Name
    ]);
  end;
end;

function TSQLResource.forceLoadFileIsStored: Boolean;
begin
  Result := FForceLoadFile <> '';
end;

function TSQLResource.forceResourceNameIsStored: Boolean;
begin
  Result := FForceResourceName <> '';
end;

function TSQLResource.formatSqlFileName(AType: string): string;
begin
  if AType <> '' then
    AType := '.' + AType;

  Result := Format('%s%s.sql', [
    ResourceName,
    lowerCase(AType)
  ]);
end;

function TSQLResource.getDesignerFile: string;
var
  fileNameSql: string;
  fileNameWithType: string;
begin
  if not(csDesigning in ComponentState) then
  begin
    Result := '';
    exit;
  end;

  if resourceType.IsEmpty then
  begin
    result := 'set the property "resourceType"';
    exit;
  end;

  fileNameWithType := TPath.Combine(resourceFilePath, formatSqlFileName(resourceType));
  fileNameSql := TPath.Combine(resourceFilePath, formatSqlFileName(''));

  if DesignerUseSingleFile then
  begin
    if not(FileExists(fileNameSql)) and (FileExists(fileNameWithType)) then
      Result := fileNameWithType
    else Result := fileNameSql;
  end
  else result := fileNameWithType;
end;

function TSQLResource.LoadResourceString(const aResourceName: string; aResourceType: string = 'SQL' ): string;
var
  streamResource: TResourceStream;
  SQL: TStringList;
begin
  if FindResource(HInstance, PWideChar(aResourceName), pWidechar(aResourceType)) <> 0 then
  begin
    streamResource := TResourceStream.Create(HInstance, aResourceName, pchar(aResourceType));
    try
      SQL := TStringList.Create;
      try
        streamResource.Position := 0;
        SQL.Clear;
        SQL.LoadFromStream(streamResource);
        Result := SQL.Text;
      finally
        SQL.DisposeOf;
      end;
    finally
      streamResource.DisposeOf;
    end;
  end
  else begin
    if Assigned(FOnResourceNotFound) then
      FOnResourceNotFound(resourceName, resourceType);

    Result := '';
  end;
end;

end.
