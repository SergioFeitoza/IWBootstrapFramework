unit IWBSCustomEvents;

interface

uses System.Classes, System.StrUtils,
     IWApplication, IWBSRestServer;

type
  TIWBSCustomAsyncEvent = class (TCollectionItem)
  private
    FEventName: string;
    FAsyncEvent: TIWCallbackFunction;
    FAsyncEventFunc: string;
    FParams: string;
  protected
    function GetDisplayName: string; override;
    procedure SetEventName(const AValue: string);
  public
    procedure RegisterEvent(AApplication: TIWApplication; const AComponentName: string);
    procedure ParseParamEvent(AScript: TStringList);
  published
    property EventName: string read FEventName write SetEventName;
    property Params: string read FParams write FParams;
    property OnAsyncEvent: TIWCallbackFunction read FAsyncEvent write FAsyncEvent;
  end;

  TIWBSCustomRestEvent = class (TCollectionItem)
  private
    FParseFileUpload: boolean;
    FEventName: string;
    FRestEvent: TIWBSRestCallBackFunction;
    FRestEventPath: string;
  protected
    function GetDisplayName: string; override;
    procedure SetEventName(const AValue: string);
  public
    procedure RegisterEvent(AApplication: TIWApplication; const AComponentName: string);
    procedure ParseParamEvent(AScript: TStringList);
  published
    property EventName: string read FEventName write SetEventName;
    property OnRestEvent: TIWBSRestCallBackFunction read FRestEvent write FRestEvent;
    property ParseFileUpload: boolean read FParseFileUpload write FParseFileUpload default False;
  end;

implementation

uses IWBSCommon;

function TIWBSCustomAsyncEvent.GetDisplayName: string;
begin
  Result := FEventName;
  if Result = '' then Result := inherited GetDisplayName;
end;

procedure TIWBSCustomAsyncEvent.SetEventName(const AValue: string);
begin
  // here we need to check that is a valid event name
  FEventName := AValue;
end;

procedure TIWBSCustomAsyncEvent.RegisterEvent(AApplication: TIWApplication; const AComponentName: string);
var
  sl: TstringList;
  LParams: string;
  i: integer;
begin
  AApplication.RegisterCallBack(AComponentName+'.'+FEventName, FAsyncEvent);
  LParams := '';
  if FParams <> '' then begin
    sl := TstringList.Create;
    try
      sl.CommaText := FParams;
      LParams := '';
      for i := 0 to sl.Count-1 do begin
        TIWBSCommon.ValidateParamName(sl[i]);
        if i > 0 then
          LParams := LParams+'+';
        LParams := LParams+'"&'+sl[i]+'="+'+sl[i];
      end;
    finally
      sl.Free;
    end;
  end;
  if LParams = '' then
    LParams := '""';
  FAsyncEventFunc := 'executeAjaxEvent('+LParams+', null, "'+AComponentName+'.'+FEventName+'", true, null, true);';
end;

procedure TIWBSCustomAsyncEvent.ParseParamEvent(AScript: TStringList);
begin
  if AScript.Count > 0 then
    AScript.Text := ReplaceStr(AScript.Text,'%'+FEventName+'%',FAsyncEventFunc);
end;

function TIWBSCustomRestEvent.GetDisplayName: string;
begin
  Result := FEventName;
  if Result = '' then Result := inherited GetDisplayName;
end;

procedure TIWBSCustomRestEvent.SetEventName(const AValue: string);
begin
  // here we need to check that is a valid event name
  FEventName := AValue;
end;

procedure TIWBSCustomRestEvent.RegisterEvent(AApplication: TIWApplication; const AComponentName: string);
begin
  FRestEventPath := IWBSRegisterRestCallBack(AApplication, AComponentName+'.'+FEventName, FRestEvent, FParseFileUpload);
end;

procedure TIWBSCustomRestEvent.ParseParamEvent(AScript: TStringList);
begin
  if AScript.Count > 0 then
    AScript.Text := ReplaceStr(AScript.Text,'%'+FEventName+'%',FRestEventPath);
end;

end.