unit SqlResourceRegister;

interface

procedure register;

implementation

uses
  DesignIntf,
  ToolsAPI,
  SQLResource,
  System.Classes,
  System.SysUtils,
  uFrmReplaceItemsWithRegex,
  uFrmReplaceItems;

function GetCurrentProjectPath: String;
var
  LProject: IOTAProject;
begin
  LProject := GetActiveProject;
  Result := ExtractFilePath(LProject.FileName);
end;

procedure register;
begin
  RegisterComponents('Designa', [TSQLResource]);

  RegisterPropertyEditor(TypeInfo(TStrings), TSQLResource, 'ReplaceItems', TReplaceItemsProperty);
  RegisterPropertyEditor(TypeInfo(TStrings), TSQLResource, 'ReplaceItemsWithRegex', TReplaceItemsWithRegexProperty);

  UnlistPublishedProperty(TSQLResource , 'CommandText');
  UnlistPublishedProperty(TSQLResource , 'CommandType');
  UnlistPublishedProperty(TSQLResource , 'DbxCommandType');
  UnlistPublishedProperty(TSQLResource , 'GetMetadata');
  UnlistPublishedProperty(TSQLResource , 'MaxBlobSize');
  UnlistPublishedProperty(TSQLResource , 'NumericMapping');
  UnlistPublishedProperty(TSQLResource , 'ObjectView');
  UnlistPublishedProperty(TSQLResource , 'ParamCheck');
  UnlistPublishedProperty(TSQLResource , 'SchemaName');
  UnlistPublishedProperty(TSQLResource , 'SortFieldNames');

  SQLResource.GetCurrentProjectPath := GetCurrentProjectPath;
end;


end.
