#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GUIListBox.au3>
#include <array.au3>
#include <IE.au3>
#include <ScreenCapture.au3>
#include <WindowsConstants.au3>

Local $oIE = _IECreateEmbedded()
Local $oIE1 = _IECreateEmbedded()
GUICreate("妙资财富电话中心", @DesktopWidth, @DesktopHeight, 0, 0, _
        $WS_OVERLAPPEDWINDOW + $WS_CLIPSIBLINGS + $WS_CLIPCHILDREN)
GUICtrlCreateObj($oIE, 0, 20, @DesktopWidth, @DesktopHeight)
GUICtrlCreateObj($oIE1, 0, 20, @DesktopWidth, @DesktopHeight)
Global $g_idError_Message = GUICtrlCreateLabel("", 100, 500, 500, 30)
GUICtrlSetColor(-1, 0xff0000)
GUISetState(@SW_SHOW) ;Show GUI
;login()
_call()
;http://10.10.20.128:5110/call/index.htm?mobile=15267167751
;_IENavigate($oIE1, "http://10.10.20.39:8888/1.txt")
;_IELoadWait($oie1)
;$answer=_IEBodyReadText($oIE1)
;WinActivate("妙资财富电话中心")
;send(@HOUR&":"&@MIN&":"&@SEC&" 来电"&$answer&"!s")
;loginfo

;genghuanmima()
;genghuanjiaoyimima()
;chuzu()
;login
Exit


;http://www.mzmoney.com/yymeq/10541.htm
; Waiting for user to close the window
While 1
    Local $iMsg = GUIGetMsg()
    Select
        Case $iMsg = $GUI_EVENT_CLOSE
            ExitLoop
    EndSelect
WEnd

GUIDelete()

Exit



Func _call();呼叫查询
   $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
   $oHTTP.Open("post","http://10.10.20.240:81/xml?method=gw.account.login&id51=kk/*0905",false)
   $oHTTP.setRequestHeader("Cache-Control", "no-cache")
   $oHTTP.setRequestHeader("Content-Type","application/x-www-form-urlencoded")
   $oHTTP.Send ()
   $s=$oHTTP.responseText
      Local $aArray = StringRegExp($s, 'cookie="(\d+?)"', 1)
	  $cookie=$aarray[0]
$alltelold=""
While 1
   $msg = GUIGetMsg()
   If $msg = $GUI_EVENT_CLOSE Then exit
   $alltel=""
   $url="http://10.10.20.240:81/xml?method=gw.log.download&id=1&cookie="&$cookie&"tmp=0.06999614043161273"
   $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
   $oHTTP.Open("get",$url,false)
   $oHTTP.setRequestHeader("Referer","http://10.10.20.240:81/msglogcfg.htm")
   $oHTTP.setRequestHeader("cookie",$cookie)
   $oHTTP.Send()
   for $i1=1 to 9
	  $url="http://10.10.20.240:81/t"&$i1&".log"
	  $oHTTP.Open("get",$url,false)
      $oHTTP.setRequestHeader("Referer","http://10.10.20.240:81/msglogcfg.htm")
	  $oHTTP.setRequestHeader("cookie",$cookie)
	  $oHTTP.Send()
	  $s=$oHTTP.responseText
	  if StringLen($s)>200 then ExitLoop
   next
   $ohttp.close
   ;ConsoleWrite($s)
   ConsoleWrite("a"&@CRLF)
   ;Local $aArray = StringRegExp($s, 'sip:(\d+?)@222.46.88.77', 3)
   Local $aArray = StringRegExp($s, 'Trying[\s\S]+?sip:(\d{8,12}?)@222.46.88.77', 3)
   Local $aMatch = 0
   For $i = 0 To UBound($aArray) - 1
	  ;MsgBox(0, "RegExp Test with Option 3 - " & $i, $aArray[$i])
	  if stringlen($aArray[$i])>8 then
		 $alltel=$alltel&";"& $aArray[$i]
	  EndIf
   Next
   $newtelno=StringReplace($alltel,$alltelold,"")
   if $newtelno<>"" Then
	  $newtelno=StringReplace($newtelno,";","")
	  $oIE1=_iecreate("http://10.10.20.128:5110/app/mobvip.htm?mobile="&$newtelno)
   EndIf
;   ConsoleWrite($newtelno&@CRLF)
;   ConsoleWrite($alltel&@CRLF)
   $alltelold=$alltel
WEnd

EndFunc
Func _bu_yb();异步识别按钮
	Local $TimeOut = 15 * 1000 ;设置超时时间15秒
	;函数使用参数 _uu_asyn_upload('验证码图片路径','用户名','密码'[,'验证码类型=1004'][,'自动登陆=1']) 成功返回一个数组 [0]为验证码ID [1]为验证码结果 失败返回错误代码
	;如果不想自动登陆将第五个参数设置为0即可
	$rHandle = _uu_asyn_upload(@TempDir&'\GDIPlus_Image2.jpg','aontimer','jmdjsj903291A')
	If @error Then
;		_echo_log('上传图片失败,错误代码['&$rHandle&']')
		Return
	EndIf
;	_echo_log('正在等待识别结果')
	Local $lInit = TimerInit()
	While 1
		Sleep(1)
		$rRs = _uu_asyn_Result($rHandle)
		If @error<>-1102 Then ExitLoop
		If TimerDiff($lInit) >= $TimeOut Then
			$rRs = '识别超时'
			ExitLoop
		EndIf
	WEnd
	If IsArray($rRs) Then
	;	msgbox(0,0,'识别结果[' & $rRs[1] & ']')
	Else
	;	msgbox(0,0,'识别失败，错误代码['&$rRs&']')
	EndIf
	;######下面注释这句是调用报错函数。可以放在验证码识别错误的时候使用！#######
	;If IsArray($rRs) Then  _uu_reporterror($rRs[0])
	;###########################################################################
	_uu_asyn_close($rHandle)
	;函数使用参数 _uu_asyn_close('句柄')
	;由_uu_asyn_upload()返回
	Return $rRs[1]
 EndFunc   ;==>_bu_yb


Func _bu_login();登陆按钮

	If Not @error Then
		MsgBox(0,0,'登陆成功，用户ID为：[' & $rMsg & ']')
	ElseIf @error = -1 Then
	Else
	EndIf
 EndFunc   ;==>_bu_login

Func CheckError($sMsg, $iError, $iExtended)
    If $iError Then
        $sMsg = "Error using " & $sMsg & " button (" & $iExtended & ")"
    Else
        $sMsg = ""
    EndIf
    GUICtrlSetData($g_idError_Message, $sMsg)
EndFunc   ;==>CheckError

func shouji()
   ;1手机验证
_IENavigate($oIE, "http://www.mzmoney.com/password/index.jspx")
_IEAction($oIE, "stop")
_ScreenCapture_Capture(@TempDir&"\GDIPlus_Image2.jpg",573,437,573+80,437+34)
$oIE.document.parentWindow.jvForm.username.value="13291488404"
$s=_uu_start($softid,$softkey,$softcrckey);软件初始化，_uu_start('软件ID','软件KEY'，'DLL校验KEY')
$captcha=_bu_yb()
$oIE.document.parentWindow.jvForm.captcha.value= $captcha
$oIE.document.parentWindow.jvForm.submit.click()
sleep(1000)
_IELoadWait($oie)
$oIE.document.parentWindow.jvForm.timer.click()



endfunc


func yizhuce()
   ;1手机号已注册 用户已注册
_IENavigate($oIE, "http://www.mzmoney.com/register.jspx")
_IEAction($oIE, "stop")
_ScreenCapture_Capture(@TempDir&"\GDIPlus_Image2.jpg",573,437,573+80,437+34)
$oIE.document.parentWindow.jvForm.username.value="13291488404"
$s=_uu_start($softid,$softkey,$softcrckey);软件初始化，_uu_start('软件ID','软件KEY'，'DLL校验KEY')
$captcha=_bu_yb()
$oIE.document.parentWindow.jvForm.username.value= "aontimer"
$oIE.document.parentWindow.jvForm.mobile.value="13291488404"
sleep(1000)
_IELoadWait($oie)
$oIE.document.parentWindow.jvForm.timer.click()

endfunc
func genghuanshouji()
   ;1更换手机号
_IENavigate($oIE, "http://www.mzmoney.com/security/index.jspx")
_IEAction($oIE, "stop")
;修改没有id号没法测
_ScreenCapture_Capture(@TempDir&"\GDIPlus_Image2.jpg",573,437,573+80,437+34)
$oIE.document.parentWindow.jvForm.origMobile.value="13291488404"
$s=_uu_start($softid,$softkey,$softcrckey);软件初始化，_uu_start('软件ID','软件KEY'，'DLL校验KEY')
$captcha=_bu_yb()
$oIE.document.parentWindow.jvForm.username.value= "aontimer"
$oIE.document.parentWindow.jvForm.mobile.value="13291488404"
sleep(1000)
_IELoadWait($oie)
$oIE.document.parentWindow.jvForm.timer.click()

endfunc

func genghuanjiaoyimima()
_IENavigate($oIE, "http://www.mzmoney.com/security/index.jspx")
_IEAction($oIE, "stop")
$oIE.document.parentWindow.payPwdForm.origPayPassword.value="jmdjsj903291A"
$oIE.document.parentWindow.payPwdForm.payPassword.value="jmdjsj903291AA"
$oIE.document.parentWindow.payPwdForm.confirmPayPwd.value="jmdjsj903291AA"
$oIE.document.parentWindow.payPwdForm.payPwdSubmit.click()
sleep(1000)
_IELoadWait($oie)
s('找回交易密码')
_IENavigate($oIE, "http://www.mzmoney.com/security/index.jspx")
_IEAction($oIE, "stop")
$oIE.document.parentWindow.payPwdForm.origPayPassword.value="jmdjsj903291AA"
$oIE.document.parentWindow.payPwdForm.payPassword.value="jmdjsj903291A"
$oIE.document.parentWindow.payPwdForm.confirmPayPwd.value="jmdjsj903291A"
$oIE.document.parentWindow.payPwdForm.payPwdSubmit.click()
sleep(1000)
_IELoadWait($oie)
endfunc

func genghuanmima()
   _IENavigate($oIE, "http://www.mzmoney.com/security/index.jspx")
_IELoadWait($oie)
$oIE.document.parentWindow.pwdForm.origPassword.value="111111"
$oIE.document.parentWindow.pwdForm.Password.value="1111111"
$oIE.document.parentWindow.pwdForm.confirmPwd.value="1111111"
$oIE.document.parentWindow.pwdForm.pwdSubmit.click()
sleep(1000)
_IELoadWait($oie)
s('找密码')
_IENavigate($oIE, "http://www.mzmoney.com/security/index.jspx")
_IELoadWait($oie)
$oIE.document.parentWindow.pwdForm.origPassword.value="1111111"
$oIE.document.parentWindow.pwdForm.Password.value="111111"
$oIE.document.parentWindow.pwdForm.confirmPwd.value="111111"
$oIE.document.parentWindow.pwdForm.pwdSubmit.click()
sleep(1000)

EndFunc

func zhaohuimima()
   ;1找回忘记的登录密码
_IENavigate($oIE, "http://www.mzmoney.com/password/index.jspx")
_IEAction($oIE, "stop")
_ScreenCapture_Capture(@TempDir&"\GDIPlus_Image2.jpg",573,437,573+80,437+34)
$oIE.document.parentWindow.jvForm.username.value="13291488404"
$s=_uu_start($softid,$softkey,$softcrckey);软件初始化，_uu_start('软件ID','软件KEY'，'DLL校验KEY')
$captcha=_bu_yb()
$oIE.document.parentWindow.jvForm.captcha.value= $captcha
$oIE.document.parentWindow.jvForm.submit.click()
sleep(1000)
_IELoadWait($oie)
$oIE.document.parentWindow.jvForm.timer.click()



endfunc
;

func touzi()
   ;1生成待付款订单
_IENavigate($oIE, "http://www.mzmoney.com/nnh6/10535.htm")
_IEAction($oIE, "stop")
$oIE.document.parentWindow.jvForm.amount.value="1000"
$s=_uu_start($softid,$softkey,$softcrckey);软件初始化，_uu_start('软件ID','软件KEY'，'DLL校验KEY')
$oIE.document.parentWindow.jvForm.button.click()
sleep(1000)
_IELoadWait($oie)
$oIE.document.parentWindow.jvForm.submit.click()
sleep(1000)
_IELoadWait($oie)
$oIE.document.parentWindow.jvForm.bankCardNo.value=5218990177587721
$oIE.document.parentWindow.jvForm.phone.value=13291488404
$oIE.document.parentWindow.jvForm.submit.click()
sleep(5000)
_IELoadWait($oie)
$oIE.document.parentWindow.jvForm.payPassword.value="jmdjsj903291A"
$oIE.document.parentWindow.jvForm.verifyCode.value=683941
;$oIE.document.parentWindow.jvForm.submit.click()
sleep(5000)

_IELoadWait($oie)


endfunc

func daifukuan()
s('待付款删除')
_IENavigate($oIE, "http://www.mzmoney.com/part/history.jspx")
_IEAction($oIE, "stop")
s('查看详情')
_IENavigate($oIE, "http://www.mzmoney.com/part/201412011454166885.jspx")
_IEAction($oIE, "stop")

s('投资列表中查看')
_IENavigate($oIE, "http://www.mzmoney.com/part/201412011454166885.jspx")
_IEAction($oIE, "stop")

s('站内信')
_IENavigate($oIE, "http://www.mzmoney.com/member/message_list.jspx?box=0")
_IEAction($oIE, "stop")

endfunc

func chuzu()
_IENavigate($oIE, "http://post.58.com/79/8/s5?ver=npost")
sleep(1000)
_IELoadWait($oie)
$xiaoqu=_IEGetObjByname($oie,"isBiz")
$xiaoqu.click()
$oIE.document.parentWindow.aspnetForm.jushishuru.value="2"
$oIE.document.parentWindow.aspnetForm.huxingting.value="1"
$oIE.document.parentWindow.aspnetForm.huxingwei.value="1"
$oIE.document.parentWindow.aspnetForm.Floor.value=4
$xiaoqu=_IEGetObjById($oie,"xiaoqu")
$xiaoqu.value="下沙景冉佳园"
$oIE.document.parentWindow.aspnetForm.zonglouceng.value=20
$oIE.document.parentWindow.aspnetForm.Toward.value=2
$oIE.document.parentWindow.aspnetForm.FitType.value=4
$oIE.document.parentWindow.aspnetForm.Title.value='300-500出租景冉佳园有房出租大小都有包物业宽带，配家具家电价格双休日预约看房'
$oIE.document.parentWindow.aspnetForm.area.value=66
$oIE.document.parentWindow.aspnetForm.MinPrice.value=500
$oIE.document.parentWindow.aspnetForm.goblianxiren.value="蒋先生"
$oIE.document.parentWindow.aspnetForm.Phone.value="15314649829"
;$oIE.document.parentWindow.aspnetForm.cbxFreeDivert.click()
run("c:\upload.exe c:\11.jpg")
$xiaoqu=_IEGetObjById($oie,"fileUploadInput")
$xiaoqu.click()
;run("c:\upload.exe c:\12.jpg")
;$xiaoqu=_IEGetObjById($oie,"fileUploadInput")
;$xiaoqu.click()
;run("c:\upload.exe c:\13.jpg")
;$xiaoqu=_IEGetObjById($oie,"fileUploadInput")
;$xiaoqu.click()
;run("c:\upload.exe c:\1.jpg")
;$xiaoqu=_IEGetObjById($oie,"fileUploadInput")
;$xiaoqu.click()
;run("c:\upload.exe c:\2.jpg")
;$xiaoqu=_IEGetObjById($oie,"fileUploadInput")
;$xiaoqu.click()

$oIE.document.parentWindow.aspnetForm.IM.value="2100803"
$oFrame1 = _IEFrameGetCollection($oIE,0)
_IEPropertySet($oFrame1, "innertext", "1. 说说出租间  出租的房间是经济的隔断间，限女生。"& @CRLF & "  2. 公用区描述  整套房子是多功能的大宅，配有基础的家具、电器。中间楼层，您能比楼上的住户更亲近风景，比楼下的邻居更感惬意！"& @CRLF & "  3.周边配套  小区周边配套丰富，饭店，超市，生活十分便利！")
$oIE.document.parentWindow.aspnetForm.fabu.click()
sleep(1000)
_IELoadWait($oie)
sleep(5000)

   endfunc

func login()
   ;登录
_IENavigate($oIE, "http://10.10.20.240")
sleep(1000)
_IELoadWait($oie)
$oIE.document.parentWindow.autoform.id51.value="kk/*0905"
$oIE.document.parentWindow.autoform.loginbutton.click()
sleep(1000)
endfunc
func s($message)
   msgbox(0,0,$message)
endfunc