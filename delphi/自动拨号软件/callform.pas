unit Callform;
{
	*** TAPI Monitor ***
        by Davide Moretti <dave@rimini.com>

	This is a TAPI Test
	It uses TAPI interface to place outgoing calls.
	You can also monitor these calls with the Monitor...
}

interface

uses
	SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
ShellAPI,SHDocVw,	Forms, Dialogs, StdCtrls, Tapi, ExtCtrls, AppEvnts;
  const
WM_BARICON=WM_USER+200;
type
	TfrmTAPICall = class(TForm)
		Edit1: TEdit;
		btnCall: TButton;
    Memo1: TMemo;
    Timer1: TTimer;
    Timer2: TTimer;
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCallClick(Sender: TObject);
    procedure btnDropCallClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
	private

		lineApp: THLineApp;
		line: THLine;
		call: THCall;
		CallParams: TlineCallParams;
procedure WMSysCommand(var Message: TMessage); message WM_SYSCOMMAND;
procedure WMBarIcon(var Message:TMessage);message WM_BARICON;
	public
		{ Public declarations }
	end;

var
	frmTAPICall: TfrmTAPICall;
 scall1, s:string;
implementation

{$R *.DFM}


var
	buf:array[0..1023] of char;
	callinfo: TLineCallInfo absolute buf;
	{
		these two variables points to the same address.
		since lineGetCallInfo expects a buffer with a TLineCallInfo on top.
	}

{
	TAPI Callback procedure: called for TAPI messages
	you MUST use 'stdcall' since it is called by Windows
}

function Replace(Dest, SubStr, Str: string): string;
var
  Position: Integer;
begin
  while Pos(SubStr, Dest) > 0 do
  begin
    Position := Pos(SubStr, Dest);
    Delete(Dest, Position, Length(SubStr));
    Insert(Str, Dest, Position);
  end;
  Result := Dest;
end;
function GetSelectedIEtext: string;
var
  x: Integer;
  Sw: IShellWindows;
  IE: HWND;
begin
  IE := FindWindow('IEFrame', nil);
if ie=0 then exit;
  sw := CoShellWindows.Create;
  for x := SW.Count - 1 downto 0 do

    if (Sw.Item(x) as IWebbrowser2).hwnd = IE then begin
      Result := variant(Sw.Item(x)).Document.Selection.createRange.Text;
      break;
    end;
end;

procedure lineCallback(hDevice, dwMsg, dwCallbackInstance,
		dwParam1, dwParam2, dwParam3: LongInt);
{$IFDEF WIN32}
		stdcall;
{$ELSE}
		export;
{$ENDIF}
	var
		s: string;
		hCall: THCall;
	begin
	if dwMsg = LINE_REPLY then { result of LineMakeCall }
		if dwParam2 < 0 then
//			frmTAPICall.Memo1.Lines.Add('Reply error')
		else
//			frmTAPICall.Memo1.Lines.Add('LINE_REPLY ok')
	else if dwMsg = LINE_CALLSTATE then	{ change in line state }
		begin
		hCall := THCall(hDevice);
		case dwParam1 of
			LINECALLSTATE_IDLE:		{ call terminated }
				if hcall <> 0 then
					begin
					lineDeallocateCall(hCall);	{ you must deallocate the call }
//					frmTAPICall.Memo1.Lines.Add('Idle - call deallocated');
					frmTAPICall.btnCall.Enabled := True;
 //			frmTAPICall.btnDropCall.Enabled := False;
					end;
			LINECALLSTATE_CONNECTED:	{ Service connected }
				if hCall <> 0 then
					begin
					s := 'Connected: ';
					callinfo.dwTotalSize := 1024;
					if lineGetCallInfo(hCall, callinfo) = 0 then
						if callinfo.dwAppNameSize > 0 then
{$IFDEF WIN32}
							s := s + (buf + callinfo.dwAppNameOffset); { this is more C-ish... }
{$ELSE}
							s := s + StrPas((buf + callinfo.dwAppNameOffset)); { this is more C-ish... }
{$ENDIF}
//					frmTAPICall.Memo1.Lines.Add(s);
					end;
			LINECALLSTATE_PROCEEDING:		{ call proceeding (dialing) }
				frmTAPICall.Memo1.Lines.Add('Proceeding');
			LINECALLSTATE_DIALING:			{ dialing }
				frmTAPICall.Memo1.Lines.Add('Dialing');
		LINECALLSTATE_DISCONNECTED:	{ disconnected }
				begin
				s := 'Disconnected: ';
				if dwParam2 = LINEDISCONNECTMODE_NORMAL then
					s := s + 'normal'
				else if dwParam2 = LINEDISCONNECTMODE_BUSY then
					s := s + 'busy';
				frmTAPICall.Memo1.Lines.Add(s);
//		frmTAPICall.btnDropCall.Click;
				end;
			LINECALLSTATE_BUSY: { busy }
				frmTAPICall.Memo1.Lines.Add('Busy');
			end;
		end;
	end;

procedure TfrmTAPICall.FormCreate(Sender: TObject);
	var
		nDevs, tapiVersion: Longint;
		extid: TLineExtensionID;
	begin
scall1:='scall1';


	{ Initialize TAPI }
	{ Zeros CallParams structure }
	FillChar(CallParams, sizeof(CallParams), 0);
	with CallParams do
		begin
		dwTotalSize := sizeof(CallParams);
		dwBearerMode := LINEBEARERMODE_VOICE;
		dwMediaMode := LINEMEDIAMODE_INTERACTIVEVOICE;
{		dwMediaMode := LINEMEDIAMODE_DATAMODEM;}
		{ if you don't want the dialing dialog use LINEMEDIAMODE_DATAMODEM }
		end;
	if lineInitialize(lineApp, HInstance,
			lineCallback, nil, nDevs) < 0 then		{ < 0 is an error }
		lineApp := 0
	else if nDevs = 0 then		{ no TAPI devices?? }
		begin
		lineShutDown(lineApp);
		lineApp := 0;
		end
	else if lineNegotiateAPIVersion(lineApp, 0, $00010000, $10000000,
			tapiVersion, extid) < 0 then	{ Check for version (copied from a TAPI sample) }
		begin
		lineShutDown(lineApp);
		lineApp := 0;
		end
	{ Open a line for outbound calls (here I use first device, normally the modem) }
	else if lineOpen(lineApp, LINEMAPPER, line, tapiVersion, 0, 0,
			LINECALLPRIVILEGE_NONE, 0, @CallParams) < 0 then
		begin
		lineShutDown(lineApp);
		lineApp := 0;
		line := 0;
		end;
	if line = 0 then
		Memo1.Lines.Add('Error!!');
	end;

procedure TfrmTAPICall.FormDestroy(Sender: TObject);
	begin
	{ Terminate TAPI }
	if line <> 0 then
		lineClose(line);
	if lineApp <> 0 then
		lineShutDown(lineApp);
//	frmMain.Call := False;
	end;

procedure TfrmTAPICall.FormClose(Sender: TObject;
		var Action: TCloseAction);
	begin
	Action := caFree;
	end;

procedure TfrmTAPICall.btnCallClick(Sender: TObject);
	var
		c: array[0..30] of char;
	begin
		CallParams.dwMediaMode := LINEMEDIAMODE_INTERACTIVEVOICE;


	if Length(Edit1.Text) > 0 then
		begin
		Memo1.Lines.Clear;
		StrPCopy(c, Edit1.Text);
		if lineMakeCall(line, call, c, 0, @CallParams) < 0 then
			Memo1.Lines.Add('Error in lineMakeCall')
		else
			begin
 //			btnCall.Enabled := False;
//	btnDropCall.Enabled := True;
			end;
		end;
	end;

procedure TfrmTAPICall.btnDropCallClick(Sender: TObject);
	begin
	if LineDrop(call, nil, 0) < 0 then
		Memo1.Lines.Add('Error in lineDrop')
	end;

procedure TfrmTAPICall.Timer1Timer(Sender: TObject);
begin

frmTAPICall.Caption:='旅贸通';
try
s:=Replace(GetSelectedIEtext,'-','');
s:=inttostr(strtoint(s));
except
end;
edit1.Text:=s;
if ((length(s)>0 ) and (length(s)<13))and (scall1<>s) then
  begin
  btnCallClick(Sender);
  scall1:=s;
  frmTAPICall.Caption:='正在拨打'+scall1;
  end;
end;
procedure TfrmTAPICall.WMSysCommand(var Message:TMessage);
var
   lpData:PNotifyIconData;
begin
if Message.WParam = SC_ICON then
begin
     //?????????????????????????
     lpData := new(PNotifyIconDataA);
     lpData.cbSize := 88;
     lpData.Wnd := frmTAPICall.Handle;
     lpData.hIcon := Application.Icon.Handle;
     lpData.uCallbackMessage := WM_BARICON;
     lpData.uID :=0;
     lpData.szTip := '旅贸通电话拨号';
     lpData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
     Shell_NotifyIcon(NIM_ADD,lpData);
     dispose(lpData);
     frmTAPICall.Visible := False;
end
else
begin
     //??????SystemCommand?????????????????
   DefWindowProc(frmTAPICall.Handle,Message.Msg,Message.WParam,Message.LParam);
end;

end;

procedure TfrmTAPICall.WMBarIcon(var Message:TMessage);
var
   lpData:PNotifyIconData;
begin
if (Message.LParam = WM_LBUTTONDOWN) then
   begin
     //???????????????????????
     lpData := new(PNotifyIconDataA);
     lpData.cbSize := 88;//SizeOf(PNotifyIconDataA);
     lpData.Wnd := frmTAPICall.Handle;
     lpData.hIcon:=Application.Icon.Handle;
     lpData.uCallbackMessage := WM_BARICON;
     lpData.uID :=0;
     lpData.szTip := '旅贸通电话拨号';
     lpData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
     Shell_NotifyIcon(NIM_DELETE,lpData);
     dispose(lpData);
     frmTAPICall.Visible := True;
   end;
end;
procedure TfrmTAPICall.Timer2Timer(Sender: TObject);

var
   lpData:PNotifyIconData;
begin
      lpData := new(PNotifyIconDataA);
     lpData.cbSize := 88;
     lpData.Wnd := frmTAPICall.Handle;
     lpData.hIcon := Application.Icon.Handle;
     lpData.uCallbackMessage := WM_BARICON;
     lpData.uID :=0;
     lpData.szTip := '旅贸通电话拨号';
     lpData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
     Shell_NotifyIcon(NIM_ADD,lpData);
     dispose(lpData);
     frmTAPICall.Visible := False;
     timer2.Enabled:=false;
     end;

end.
