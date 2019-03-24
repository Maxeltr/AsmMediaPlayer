.686 
.MMX 
.XMM
.model flat,stdcall
option casemap:none

include WinForVid.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov hInstance,eax
	invoke GetCommandLine
	mov	CommandLine,eax
	invoke _CreateMailSlot,CommandLine
	test eax,eax
	jz @f
	mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
    mov icex.dwICC,0FFFFh
    invoke InitCommonControlsEx,ADDR icex
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	@@:
	.data
		szStart	db "MaxPlayer: ExitProcess",0
	.code 
	invoke WriteLogFile,addr szStart
	invoke ExitProcess,NULL

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	
;	RGB   226,226,228
;	invoke CreateSolidBrush,eax
;	mov wc.hbrBackground,  EAX
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,hInst,600
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	mov hMainIcon,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	call AVIInit

	invoke CmdLineProc,CmdLine
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret
WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL ps:PAINTSTRUCT
LOCAL Rct:RECT
LOCAL Rct_Min:RECT
LOCAL rs:RECT
LOCAL RctTBR:RECT
LOCAL STC1_Rct:RECT
LOCAL Rct_Screen:RECT
LOCAL loc_RctTBR2:RECT
LOCAL PLw:DWORD
LOCAL PLh:DWORD
LOCAL hOld:dword
LOCAL hDC:HDC
LOCAL newY:dword
LOCAL newX:dword
LOCAL content[108] :BYTE
LOCAL Buffer [512]:BYTE
LOCAL lvi:LV_ITEM
LOCAL lPoint:POINT
LOCAL lhBrush:DWORD
LOCAL lhOld:DWORD
LOCAL lb:LOGBRUSH
LOCAL lRct:RECT
LOCAL lBufferVolumeBmp [32]:BYTE
LOCAL lBufferForBlendText [128]:BYTE
LOCAL lpt:POINT
;LOCAL mem16:WORD
LOCAL MenuStruct:MENUINFOA


	mov eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		invoke GetModuleFileName,NULL,addr szCurrentDir,256
		
		invoke WriteLogFile,addr AppName
		;invoke MessageBox,0,addr szCurrentDir,addr AppName,MB_OK
		invoke IniProc,toRead
		
		invoke GetDlgItem, hWin,IDC_STC1
		mov hSTC1,eax
		invoke GetDlgItem, hWin,IDC_STC2
		mov hSTC2,eax
		invoke GetDlgItem, hWin,IDC_BTN1
		mov hBTN1,eax
		invoke GetDlgItem, hWin,IDC_BTN2
		mov hBTN2,eax
		invoke GetDlgItem, hWin,IDC_BTN3
		mov hBTN3,eax
		invoke GetDlgItem, hWin,IDC_BTN4
		mov hBTN4,eax
		invoke GetDlgItem, hWin,IDC_BTN5
		mov hBTN5,eax
		invoke GetDlgItem, hWin,IDC_BTN6
		mov hBTN6,eax
		invoke GetDlgItem, hWin,IDC_TBR1
		mov hTBR1,eax
		invoke GetDlgItem, hWin,IDC_TBR2
		mov hTBR2,eax
		invoke  GetMenu,hWnd
		mov hMenu,eax
		
		invoke CreateBrushes
		invoke LoadBitmaps
		
		
		mov MenuStruct.cbSize,sizeof MENUINFOA
		mov MenuStruct.fMask,MIM_BACKGROUND
		mov eax,hBrushMain
		mov MenuStruct.hbrBack,eax
		invoke SetMenuInfo,hMenu, addr MenuStruct
		
		
		invoke SetWindowLong,hSTC1,GWL_WNDPROC,addr WndProc2
		mov OldWndProc,eax
		invoke SetWindowLong,hTBR1,GWL_WNDPROC,addr WndTBRProc2
		mov OldWndTBRProc2,eax
		invoke SetWindowLong,hTBR2,GWL_WNDPROC,addr WndTBR2Proc2
		mov OldWndTBR2Proc2,eax
		invoke SetWindowLong,hBTN1,GWL_WNDPROC,addr WndBTN1Proc2
		mov OldWndBTN1Proc2,eax
		invoke SetWindowLong,hBTN2,GWL_WNDPROC,addr WndBTN2Proc2
		mov OldWndBTN2Proc2,eax
		invoke SetWindowLong,hBTN3,GWL_WNDPROC,addr WndBTN3Proc2
		mov OldWndBTN3Proc2,eax
		invoke SetWindowLong,hBTN4,GWL_WNDPROC,addr WndBTN4Proc2
		mov OldWndBTN4Proc2,eax
		invoke SetWindowLong,hBTN5,GWL_WNDPROC,addr WndBTN5Proc2
		mov OldWndBTN5Proc2,eax
		invoke SetWindowLong,hBTN6,GWL_WNDPROC,addr WndBTN6Proc2
		mov OldWndBTN6Proc2,eax
		
		invoke LoadImage,NULL,ADDR Picture,IMAGE_BITMAP,0,0,LR_LOADFROMFILE or LR_DEFAULTSIZE 
		.if eax==0
			;invoke MessageBox,0,addr szPicNotFound,addr AppName,MB_OK
			mov fFhonNotFound,1
		.endif
		mov hPic,eax 
		
		
		
		;invoke GetWindowLong, hWnd, GWL_EXSTYLE
		;add eax, WS_EX_LAYERED
		;invoke SetWindowLong, hWnd, GWL_EXSTYLE, eax
		;invoke SetLayeredWindowAttributes,hWnd, 0, 100, LWA_ALPHA
		
		invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_SETRANGEMIN,FALSE,0
		invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_SETRANGEMAX,FALSE,65535
		invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_SETLINESIZE,FALSE,65
		
		invoke GetMasterVolume
		.if eax == MIXER_ERROR
			invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_SETPOS,TRUE,0
		.else
			invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_SETPOS,TRUE,eax
		.endif
		
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETRANGEMIN,FALSE,0
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETRANGEMAX,FALSE,sto
		invoke SendDlgItemMessage,hWin,IDC_TBR1,TBM_SETLINESIZE,FALSE,1
		
		invoke EnableWindow,hTBR1,FALSE
		;invoke EnableWindow,hTBR2,FALSE
		
		;invoke GetWindowRect,hWnd,addr Rct_MainWindow
		invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr Rct_MainWindow,0
		.if Wwd_MainWindow<255 || Wht_MainWindow<140
			mov Wwd_MainWindow,379
			mov Wht_MainWindow,385
		.endif
		.if fNotRememberPos==1
			jmp @f
		.endif
		mov eax,Wtx_MainWindow
		mov ecx,Wtx_MainWindow
		mov ebx,Wty_MainWindow
		mov edx,Wty_MainWindow
		add ecx,Wwd_MainWindow
		add edx,Wht_MainWindow
		cmp eax,0
		jl @f
		cmp ebx,0
		jl @f
		.if ecx>Rct_MainWindow.right || edx>Rct_MainWindow.bottom
			@@:
			invoke GetSystemMetrics,SM_CXSCREEN  
			invoke TopXY,Wwd_MainWindow,eax
			mov Wtx_MainWindow, eax
			invoke GetSystemMetrics,SM_CYSCREEN
			invoke TopXY,Wht_MainWindow,eax
			mov Wty_MainWindow, eax
		.endif
		invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,Wht_MainWindow,TRUE
		;int 3		
		;.if IsPLVisible==1
			call CreatePlayList
		;.endif
		
		;invoke CreateThread,0,0,addr WaitEvent,0,0,0
		;invoke CloseHandle,eax
		
		invoke CreatePopupMenu
		mov hPopupMenu,eax
		invoke AppendMenu,hPopupMenu,MF_STRING,IDM_GetScreenShot,addr szGetScreenShot
		invoke AppendMenu,hPopupMenu,MF_STRING,IDM_UseAsFhon,addr szUseAsFhon
		
		invoke CreatePopupMenu
		mov hPopupMenuTray,eax
		invoke AppendMenu,hPopupMenuTray,MF_STRING,IDM_RestoreFromTray,addr szRestore
		invoke AppendMenu,hPopupMenuTray,MF_STRING,IDM_ExitFromTray,addr szExit

		
		
		
		invoke RegisterHotKey,hWnd,IDC_HOT1,MOD_ALT,VK_RETURN
		invoke RegisterHotKey,hWnd,IDC_HOT2,MOD_CONTROL	,VK_PGUP
		invoke RegisterHotKey,hWnd,IDC_HOT3,MOD_CONTROL	,VK_PGDN
		invoke RegisterHotKey,hWnd,IDC_HOT4,MOD_CONTROL	,VK_UP
		invoke RegisterHotKey,hWnd,IDC_HOT5,MOD_CONTROL	,VK_DOWN
		
	.elseif eax==WM_SIZE
		.if wParam==SIZE_MINIMIZED
			.if fTray==1
				mov note.cbSize,sizeof NOTIFYICONDATA
				push hWnd
				pop note.hwnd
				mov note.uID,IDI_TRAY
				mov note.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP
				
				mov note.uCallbackMessage,WM_SHELLNOTIFY
				;invoke LoadIcon,NULL,IDI_WINLOGO
				mov eax,hMainIcon
				mov note.hIcon,eax
				invoke lstrcpy,addr note.szTip,addr AppName
				
				invoke ShowWindow,hWnd,SW_HIDE
				invoke Shell_NotifyIcon,NIM_ADD,addr note
				mov fHideInTray,1
			.endif
;			.if fPause==0 && fRun==1 && fAudio==0 && fTray
;				mov fPause,1
;				mctrl     Pause_, pControl
;				;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPlay
;				invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
;			.endif
			mov fMinimized,1
			mov fMaximized,0
		.elseif wParam==SIZE_RESTORED
			.if fMaximized==1 || fMinimized==1 || fFullScreen==1
				.if IsPLVisible==1 
					invoke GetWindowRect,hWnd,addr Rct_Min
					.if fGlueR==1
						invoke MoveWindow,hPL,Rct_Min.right ,Rct_Min.top ,Wwd,Wht,TRUE
						;invoke ShowWindow,hPL,SW_SHOWNORMAL
					.elseif fGlueL==1
						mov eax,Rct_Min.left
						sub eax,Wwd
						invoke MoveWindow,hPL,eax ,Rct_Min.top ,Wwd,Wht,TRUE
						;invoke ShowWindow,hPL,SW_SHOWNORMAL
					.elseif fGlueB==1
						invoke MoveWindow,hPL,Rct_Min.left ,Rct_Min.bottom ,Wwd,Wht,TRUE
						;invoke ShowWindow,hPL,SW_SHOWNORMAL
					.endif
				.endif
			.endif
			mov fMaximized,0
			mov fMinimized,0
			mov fFullScreen,0
		.elseif wParam==SIZE_MAXIMIZED
			mov fMaximized,1
		.endif
		mov eax,lParam
		mov edx,eax
		and eax,0ffffh
		mov newX,eax
		shr edx,16
		sub edx,70
		mov newY,edx
		invoke MoveWindow,hSTC1,0,0,eax,edx,TRUE
		mov ebx,newY
		add ebx,45
		mov eax,newX
		xor edx,edx
		mov ecx,2
		div ecx
		sub eax,45
		invoke MoveWindow,hSTC2,eax,ebx,90,20,TRUE
		invoke MoveWindow,hBTN1, 0, newY, 40,20,TRUE
		invoke MoveWindow,hBTN2, 40, newY, 40,20,TRUE
		invoke MoveWindow,hBTN3, 80, newY, 40,20,TRUE
		mov eax,newY
		add eax,25
		invoke MoveWindow,hTBR1,1,eax,newX,20,TRUE
		mov eax,newY
		mov edx,newX
		push eax
		add eax,5
		push edx
		sub edx,70
		invoke MoveWindow,hTBR2, edx,eax , 70,20,TRUE
		pop edx
		pop eax
		add eax,45
		sub edx,50
		invoke MoveWindow,hBTN4, edx, eax, 20,20,TRUE
		mov eax,newY
		mov edx,newX
		add eax,45
		sub edx,25
		invoke MoveWindow,hBTN5, edx, eax, 20,20,TRUE
		mov eax,newY
		mov edx,newX
		add eax,45
		sub edx,75
		invoke MoveWindow,hBTN6, edx, eax, 20,20,TRUE
		.if fRun==1 && fAudio==0
			invoke VideoSize
		.endif
		cmp fMinimized,1
		je @f
		invoke GetWindowRect,hWnd,addr Rct_MainWindow ;remember width and height of main window
		mov eax,Rct_MainWindow.right
		sub eax,Rct_MainWindow.left
		.if eax>254
			mov Wwd_MainWindow,eax
		.endif
		mov eax,Rct_MainWindow.bottom
		sub eax,Rct_MainWindow.top
		.if eax>123
			mov Wht_MainWindow,eax
		.endif
		@@:
	.elseif	eax==WM_GETMINMAXINFO
		mov	edx,lParam
		assume	edx:ptr MINMAXINFO
		mov	[edx].ptMinTrackSize.x,255
		mov	[edx].ptMinTrackSize.y,124
		assume	edx:nothing
		xor	eax,eax
		ret
	.elseif eax==WM_WINDOWPOSCHANGING
		invoke GlueMain,lParam
		mov edi,lParam
		mov eax,[edi+8]		;указатель на координату левой стороны
		mov edx,[edi+12]
		.if eax!=0 && edx!=0
			call IsGlue
			cmp fGlue,0
			je @f
			mov eax,Rct1.right
			sub eax,Rct1.left
			mov PLw,eax
			mov eax,Rct1.bottom
			sub eax,Rct1.top
			mov PLh,eax
			mov edi,lParam
			mov eax,[edi+8]			;new x
			mov edx,[edi+12]		;new y
			.if fGlueL==1
				sub eax,PLw
				invoke MoveWindow,hPL, eax, edx,PLw,PLh,TRUE
			.elseif fGlueR==1
				add eax,[edi+16]
				invoke MoveWindow,hPL, eax, edx, PLw,PLh,TRUE
			.elseif fGlueB==1
				add edx,[edi+20]
				invoke MoveWindow,hPL, eax, edx, PLw,PLh,TRUE
			.endif
			@@:
		.endif
		invoke GetWindowRect,hWnd,addr Rct_MainWindow	;remember x and y Of main window
		invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr Rct_Screen,0
		mov eax,Rct_MainWindow.left
		.if eax>=Rct_Screen.left && eax<Rct_Screen.right
			mov Wtx_MainWindow,eax
		.endif
		mov eax,Rct_MainWindow.top
		.if eax>=Rct_Screen.top && eax<Rct_Screen.bottom
			mov Wty_MainWindow,eax
		.endif
	.elseif eax==WM_ERASEBKGND
;		mov eax,1
;		ret
	.elseif eax==WM_CTLCOLORSTATIC
		mov eax,lParam
		.if eax==hSTC2 || eax==hTBR1 || eax==hTBR2
			.if fSilver==1
				mov edx,MainColour2
			.else
				mov edx,MainColour
			.endif
			invoke SetBkColor,wParam,edx
			mov eax,hBrushMain
		.else
			invoke DefWindowProc, hWin, uMsg, wParam,lParam
		.endif
		ret
;	.elseif uMsg==WM_DISPLAYCHANGE
;		.if fRun==1
;			vmr_wcontrol9 DisplayModeChanged,pWControl9
;		.endif
	.elseif eax==WM_PAINT
		invoke BeginPaint,hWnd, ADDR ps
		mov    hDC,eax
		
;		.if fRun==1 && fBlendText==1
;			invoke UpdateText,0
;		.endif
		
		invoke GetClientRect,hWnd,ADDR lRct
		invoke SetMapMode,hDC,MM_ANISOTROPIC
		;invoke SetWindowExtEx,hDC,0,0,0
		invoke SetViewportExtEx,hDC,lRct.right,lRct.bottom,0
		
		mov lb.lbStyle, BS_SOLID
		.if fSilver==1
			mov eax,MainColour2
		.else 
			mov eax,MainColour
		.endif
		mov lb.lbColor,eax       ; blue
		mov lb.lbHatch, NULL
		invoke CreateBrushIndirect,ADDR lb
		mov lhBrush, eax	
		invoke SelectObject,hDC,lhBrush 
		mov hOld, eax
		invoke Rectangle,hDC,lRct.left,lRct.top,lRct.right,lRct.bottom
		
		invoke SelectObject,hDC,hOld
		invoke DeleteObject,lhBrush
		
		invoke EndPaint,hWnd, ADDR ps
		
	.elseif eax==WM_INITMENU
		.if fSaveVideoRatio==1 
			 invoke  CheckMenuItem,hMenu,IDM_SaveVideoRatio,MF_BYCOMMAND or MF_CHECKED
		.else
			invoke  CheckMenuItem,hMenu,IDM_SaveVideoRatio,MF_BYCOMMAND or MF_UNCHECKED
		.endif
		.if fChangeWindowSize==1
			invoke  CheckMenuItem,hMenu,IDM_ChangeWindowSize,MF_BYCOMMAND or MF_CHECKED
		.else
			invoke  CheckMenuItem,hMenu,IDM_ChangeWindowSize,MF_BYCOMMAND or MF_UNCHECKED
		.endif
		.if fNoScrollCaption==1
			invoke  CheckMenuItem,hMenu,IDM_NoScrollCaption,MF_BYCOMMAND or MF_CHECKED
		.else
			invoke  CheckMenuItem,hMenu,IDM_NoScrollCaption,MF_BYCOMMAND or MF_UNCHECKED
		.endif
		.if fHideVideo==1
			invoke  CheckMenuItem,hMenu,IDM_HideVideo,MF_BYCOMMAND or MF_CHECKED
		.else
			invoke  CheckMenuItem,hMenu,IDM_HideVideo,MF_BYCOMMAND or MF_UNCHECKED
		.endif
		.if fTray==1
			invoke  CheckMenuItem,hMenu,IDM_HideInTray,MF_BYCOMMAND or MF_CHECKED
		.else
			invoke  CheckMenuItem,hMenu,IDM_HideInTray,MF_BYCOMMAND or MF_UNCHECKED
		.endif
		.if fTopmost==1
			invoke  CheckMenuItem,hMenu,IDM_TOPMOST,MF_BYCOMMAND or MF_CHECKED
		.else
			invoke  CheckMenuItem,hMenu,IDM_TOPMOST,MF_BYCOMMAND or MF_UNCHECKED
		.endif
		.if fSilver==1
			invoke  CheckMenuItem,hMenu,IDM_ColourSilver,MF_BYCOMMAND or MF_CHECKED
			invoke  CheckMenuItem,hMenu,IDM_ColourStandart,MF_BYCOMMAND or MF_UNCHECKED
		.else
			invoke  CheckMenuItem,hMenu,IDM_ColourSilver,MF_BYCOMMAND or MF_UNCHECKED
			invoke  CheckMenuItem,hMenu,IDM_ColourStandart,MF_BYCOMMAND or MF_CHECKED
		.endif

	.elseif eax==WM_COMMAND
		mov		eax,wParam
		;and		eax,0FFFFh
		.if ax==IDM_RestoreFromTray
			invoke Shell_NotifyIcon,NIM_DELETE,addr note
			invoke ShowWindow,hWnd,SW_RESTORE
			mov fHideInTray,0
		.elseif ax==IDM_ExitFromTray
			invoke Shell_NotifyIcon,NIM_DELETE,addr note
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif ax==IDM_FILE_EXIT
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif ax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.elseif ax==IDM_TOPMOST
			.if fTopmost==0
				invoke SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
				mov fTopmost,1
			.else
				invoke SetWindowPos,hWnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
				invoke SetWindowPos,hToolTip,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
				mov fTopmost,0
			.endif
		.elseif ax==IDM_HideInTray
			.if fTray==0
				mov fTray,1
			.else
				mov fTray,0
			.endif
		.elseif ax==IDM_SaveVideoRatio
			.if fSaveVideoRatio==1
				mov fSaveVideoRatio,0
				;vmr_wcontrol9 SetAspectRatioMode,pWControl9,VMR_ARMODE_NONE
				.if fRun==1 && fAudio==0
					invoke VideoSize
				.endif
			.else
				mov fSaveVideoRatio,1
				;vmr_wcontrol9 SetAspectRatioMode,pWControl9,VMR_ARMODE_LETTER_BOX
				.if fRun==1 && fAudio==0
					invoke VideoSize
				.endif
			.endif
		.elseif ax==IDM_ChangeWindowSize
			.if fChangeWindowSize==1
				mov fChangeWindowSize,0
			.else
				mov fChangeWindowSize,1
			.endif
		.elseif ax==IDM_HideVideo
			.if fHideVideo==1
				mov fHideVideo,0
				.if Wht_MainWindowSaved!=0 && fAudioWasPrev==1
					push Wht_MainWindowSaved
					pop Wht_MainWindow
					invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,Wht_MainWindow,TRUE
					mov fAudioWasPrev,0
				.endif
			.else
				mov fHideVideo,1
				.if fAudio==1
					mov fAudioWasPrev,1
					.if fFullScreen==1
						mov fFullScreen,0
						invoke ShowWindow,hScreenFhon,SW_HIDE
					.endif
					mov edx,125
					.if Wht_MainWindow>124
						push Wht_MainWindow
						pop Wht_MainWindowSaved
					.endif
					.if edx!=0 && edx<1000
						invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,edx,TRUE
					.endif
				.endif
			.endif
		.elseif ax==IDM_NoScrollCaption
			.if fNoScrollCaption==1
				mov fNoScrollCaption,0
				cmp fRun,1
				jne @f
				mov fExitScrollThread,0
				invoke CreateThread,0,0,addr ScrollCaptionThread,0,0,0
				invoke CloseHandle,eax
				@@:
			.else
				mov fNoScrollCaption,1
				mov fExitScrollThread,1
			.endif
		.elseif ax==IDM_OpenFile
			invoke  SendMessage,hWnd,WM_COMMAND,IDC_BTN1,NULL
		.elseif ax==IDM_AddFileToPL
			.if fCreatePL==0 || IsPLVisible==0
				invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN4,NULL
			.endif
			invoke SendMessage,hPL,WM_COMMAND,IDM_AddFile,NULL
		.elseif ax==IDM_AddFolderToPL
			.if fCreatePL==0 || IsPLVisible==0
				invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN4,NULL
			.endif
			invoke SendMessage,hPL,WM_COMMAND,IDM_AddDir,NULL
		.elseif ax==IDM_GetScreenShot
			invoke GetScreenShot,0
		.elseif ax==IDM_UseAsFhon
			invoke GetScreenShot,1
		.elseif ax==IDM_TurnOffMonitor
			.if fWndWarnTurnOffMonitorIs==0
				invoke CreateDialogParam,hInstance,IDD_DIALOG6,hWnd,addr WndWarnTurnOffMonitor,0;lParam
				mov hDlg6,eax
				mov fWndWarnTurnOffMonitorIs,1
			.endif
			
		.elseif ax==IDM_Help
			invoke CreateDialogParam,hInstance,IDD_DIALOG7,hWnd,addr WndHelpProc,lParam
			mov hDlg7,eax
			
			
		.elseif ax==IDM_ColourSilver
			.if fSilver==0
				mov fSilver,1
				invoke DeleteObject,hBrushMain
				invoke CreateBrushes
				invoke DestroyBitmaps
				invoke LoadBitmaps
				mov eax,MainColour2
				push eax
				invoke SendMessage,hList,LVM_SETBKCOLOR,0,eax
				pop eax
				invoke SendMessage,hList,LVM_SETTEXTBKCOLOR,0,eax
				
				mov MenuStruct.cbSize,sizeof MENUINFOA
				mov MenuStruct.fMask,MIM_BACKGROUND
				mov eax,hBrushMain
				mov MenuStruct.hbrBack,eax
				invoke SetMenuInfo,hMenu, addr MenuStruct
				
;				invoke GetDC,hTBR1
;				push eax
;				invoke SendMessage,hWnd,WM_CTLCOLORSTATIC,eax,hTBR1
;				pop eax
;				invoke ReleaseDC,hTBR1,eax
				
				invoke DrawMenuBar,hWnd
				;invoke InvalidateRect,hTBR1,0,TRUE
				invoke InvalidateRect,hPL,0,TRUE
				invoke InvalidateRect,hWnd,0,TRUE
			.endif
			
			
		.elseif ax==IDM_ColourStandart
			.if fSilver==1
				mov fSilver,0
				invoke DeleteObject,hBrushMain
				invoke CreateBrushes
				invoke DestroyBitmaps
				invoke LoadBitmaps
				mov eax,MainColour
				push eax
				invoke SendMessage,hList,LVM_SETBKCOLOR,0,eax
				pop eax
				invoke SendMessage,hList,LVM_SETTEXTBKCOLOR,0,eax
				
				mov MenuStruct.cbSize,sizeof MENUINFOA
				mov MenuStruct.fMask,MIM_BACKGROUND
				mov eax,hBrushMain
				mov MenuStruct.hbrBack,eax
				invoke SetMenuInfo,hMenu, addr MenuStruct
				
;				;int 3
;				invoke GetDC,hTBR1
;				push eax
;				invoke SendMessage,hWnd,WM_CTLCOLORSTATIC,eax,hTBR1
;				pop eax
;				invoke ReleaseDC,hTBR1,eax
				
				invoke DrawMenuBar,hWnd
				;invoke InvalidateRect,hTBR1,0,TRUE
				invoke InvalidateRect,hPL,0,TRUE
				invoke InvalidateRect,hWnd,0,TRUE
			.endif
			
			
			
		.elseif ax==IDC_BTN1	;open----------------------------
			shr eax,16
			.if ax==BN_CLICKED
				.if fRun==0
					call StopTimer
					invoke AVIOpenFile,0
					cmp fFileLoad,1
					jne @f
					;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPause
					invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp
					@@:
				.else
					;call StopTimer
					;call AVIStop
					invoke AVIOpenFile,0
					cmp fFileLoad,1
					jne @f
					;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPause
					invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp
					@@:
				.endif
			.endif
		.elseif ax==IDC_BTN2	;play
			shr eax,16
			.if ax==BN_CLICKED
				.if fRun==1
					.if fPause==1
						mctrl Run,pControl
						mov fPause,0
						;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPause
						invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp
					.else
						mov fPause,1
						mctrl Pause_,pControl
						;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPlay
						invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
					.endif
				.else
					invoke FilterProc,addr szFileName
					.if eax==AUDIO_TYPE
						mov fAudio,1
					.endif
					push PLFocusSaved
					pop PLFocus
					call StopTimer
					call AVIPlay
					invoke InvalidateRect,hPL,0,TRUE
					;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPause
					invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp
					.if fPlayOfPlComplete==1
						invoke ClearVPL,hVPL
						invoke ClearVPL,hVPL2
						invoke ClearVPL,hVPL3
						invoke LoadVPL,hList
						mov fPlayOfPlComplete,0
					.endif
				.endif
			.endif
		.elseif ax==IDC_BTN3	;stop
			shr eax,16
			.if ax==BN_CLICKED
				.if fRun==1
					call StopTimer
					call AVIStop
					mov fRun,0
					;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPlay
					invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
					invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,0
					push PLFocus 
					pop PLFocusSaved
					mov PLFocus,-1
					invoke InvalidateRect,hPL,0,TRUE
				.endif
			.endif
		.elseif ax==IDC_BTN4	;playlist
			shr eax,16
			.if ax==BN_CLICKED
				.if fCreatePL==1 && IsPLVisible==0
					invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr rs,0
					invoke GetWindowRect,hPL,addr Rct
					mov eax,Rct.left
					cmp eax,rs.left		;check left and if not in screen,move pl to visible part of screen
					jnl @f
						push rs.left
						pop Rct.left
						invoke MoveWindow,hPL,rs.left,Rct.top,Wwd,Wht,TRUE
					@@:
					mov eax,Rct.top
					cmp eax,rs.top
					jnl @f
						push rs.top
						pop Rct.top
						invoke MoveWindow,hPL, Rct.left,rs.top,Wwd,Wht,TRUE
					@@:
					mov eax,Rct.bottom
					.if eax>rs.bottom
						mov eax,rs.bottom
						sub eax,Wht
						mov Rct.top,eax
						invoke MoveWindow,hPL, Rct.left, eax,Wwd,Wht,TRUE
					.endif
					mov eax,Rct.right
					.if eax>rs.right
						mov eax,Wwd
						sub rs.right,eax
						invoke MoveWindow,hPL, rs.right, Rct.top,Wwd,Wht,TRUE
					.endif
					invoke ShowWindow,hPL,SW_SHOW
					mov IsPLVisible,1
				.elseif fCreatePL==0
					mov IsPLVisible,1
					call CreatePlayList
				.elseif fCreatePL==1 && IsPLVisible==1
					invoke SendMessage,hPL,WM_CLOSE,0,0
				.endif
			.endif
		.elseif ax==IDC_BTN5	;next
			shr eax,16
			.if ax==BN_CLICKED
				.if PLFocus==-1
					push PLFocusSaved
					pop PLFocus
				.endif
				.if fRandomPlay==1	
					;invoke     SendMessage, hList,LVM_GETITEMCOUNT,0,0
					;cmp HavePlayed,eax
					;je @@@1
					push PLFocus
					pop PrevFile
					invoke RandomPlay,hList
					.if eax==-1
						invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0
						mov PLFocus,-1
						mov PLFocusSaved,-1
						mov fPlayOfPlComplete,1
						invoke InvalidateRect,hPL,0,TRUE
						xor eax,eax
						ret
					.endif
					;mov PLFocus,eax
					;.if fNoScrollPL==0
					;	invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
					;	mov eax,PLFocus
					;.endif
					;dec PLFocus
					;inc HavePlayed
				.else
					@@:
					invoke     SendMessage, hList, LVM_GETNEXTITEM,PLFocus,LVNI_BELOW
					.if eax==-1
						invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0
						mov PLFocus,-1
						mov PLFocusSaved,-1
						invoke InvalidateRect,hPL,0,TRUE
						xor eax,eax
						ret
					.endif
				.endif
				mov PLFocus,eax
				invoke AVIPlay3,eax
				.if fNoScrollPL==0
					invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
				.endif
				;mov     lvi.iItem, eax
				;mov     lvi.iSubItem, 0
				;mov     lvi.imask, LVIF_TEXT
				;lea     eax, Buffer
				;mov     lvi.pszText, eax
				;mov     lvi.cchTextMax, 512
				;inc lvi.iSubItem
				;inc lvi.iSubItem
				;invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
				;invoke AVIPlay2,addr Buffer
				;invoke InvalidateRect,hPL,0,TRUE
				;inc PLFocus
			.endif
		.elseif ax==IDC_BTN6	;previous
			shr eax,16
			.if ax==BN_CLICKED
				.if PLFocus==-1
					push PLFocusSaved
					pop PLFocus
				.endif
				.if fRandomPlay==1	
					;invoke     SendMessage, hList,LVM_GETITEMCOUNT,0,0
					;cmp HavePlayed,eax
					;je @@@1
					push PrevFile
					pop eax
					push PLFocus
					pop PrevFile
					;invoke RandomPlay,hList
					cmp eax,-1
					je @f
					;mov PLFocus,eax
					;.if fNoScrollPL==0
					;	invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
					;	mov eax,PLFocus
					;.endif
					;dec PLFocus
					;inc HavePlayed
				.else
					
					invoke SendMessage, hList, LVM_GETNEXTITEM,PLFocus,LVNI_ABOVE
					.if eax==-1
						@@:
						invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0
						mov PLFocus,-1
						mov PLFocusSaved,-1
						invoke InvalidateRect,hPL,0,TRUE
						xor eax,eax
						ret
					.endif
				.endif
				
				mov PLFocus,eax
				invoke AVIPlay3,eax
				.if fNoScrollPL==0
					invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
				.endif
				;mov     lvi.iItem, eax
				;mov     lvi.iSubItem, 0
				;mov     lvi.imask, LVIF_TEXT
				;lea     eax, Buffer
				;mov     lvi.pszText, eax
				;mov     lvi.cchTextMax, 512
				;inc lvi.iSubItem
				;inc lvi.iSubItem
				;INVOKE     SendMessage, hList, LVM_GETITEM, 0, addr lvi
				;invoke AVIPlay2,addr Buffer
				;invoke InvalidateRect,hPL,0,TRUE
				;dec PLFocus
			.endif
		.endif
	.elseif eax==WM_HSCROLL
		mov eax,wParam
		.if ax==TB_THUMBTRACK
			mov eax,lParam
			.if eax==hTBR2
				invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_GETPOS,0,0
				invoke SetMasterVolume,eax
			.elseif eax==hTBR1
				cmp fRun,1
				jne @f
				.if fPause==0
					mov fPause,1
					mctrl Pause_,pControl
				.endif
				invoke SetPosition
				invoke UpdateSTC2,2
				@@:
			.endif
		.elseif ax==TB_ENDTRACK
			mov eax,lParam
			.if eax==hTBR2
				invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_GETPOS,0,0
;				mov eax,-10
;				mov volume,eax
;				;fild volume
;				;fstp volume
;				baudio put_Volume,pAudio, volume;addr volume
;				;int 3
				invoke SetMasterVolume,eax
			.elseif eax==hTBR1
				cmp fRun,1
				jne @f
				.if fPause==1
					mctrl Run,pControl
					mov fPause,0
					;invoke SetDlgItemText,hWin,IDC_BTN2,addr szPause
					invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp
				.endif
				@@:
			.endif
		.elseif ax==TB_PAGEUP 
			mov eax,lParam
			.if eax==hTBR2
				invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_GETPOS,0,0
				invoke SetMasterVolume,eax
			.elseif eax==hTBR1
				cmp fRun,1
				jne @f
				.if fPause==0
					mov fPause,1
					mctrl Pause_,pControl
				.endif
				;int 3
				invoke GetCursorPos,addr curPos
				;invoke SendMessage,hTBR1,TBM_GETCHANNELRECT,0,addr RctTBR
				;invoke ScreenToClient,hTBR1,addr curPos
				invoke GetWindowRect,hTBR1,addr RctTBR
				mov edx,curPos.x
				mov eax,RctTBR.left
				mov ebx,RctTBR.right
				sub RctTBR.right,eax
				sub curPos.x,eax
				;int 3
				mov eax,RctTBR.right
				xor edx,edx
				mov ecx,3
				div ecx
				mov edx,eax
				add edx,eax
				fsave content
				.if curPos.x>edx
					add curPos.x,5
				.elseif curPos.x<eax
					sub curPos.x,5
				.endif
				fild curPos.x
				fild sto
				fmul
				fild RctTBR.right
				fdiv
				fistp curPos.x
				frstor  content
				invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,curPos.x
				invoke SetPosition
				@@:
			.endif
		.elseif ax==TB_PAGEDOWN
			mov eax,lParam
			.if eax==hTBR2
				invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_GETPOS,0,0
				invoke SetMasterVolume,eax
			.elseif eax==hTBR1
				cmp fRun,1
				jne @f
				.if fPause==0
					mov fPause,1
					mctrl Pause_,pControl
				.endif
				;int 3
				invoke GetCursorPos,addr curPos
				;invoke SendMessage,hTBR1,TBM_GETCHANNELRECT,0,addr RctTBR
				invoke GetWindowRect,hTBR1,addr RctTBR
				mov eax,RctTBR.left
				sub RctTBR.right,eax
				sub curPos.x,eax
				mov eax,RctTBR.right
				xor edx,edx
				mov ecx,3
				div ecx
				mov edx,eax
				add edx,eax
				fsave content
				.if curPos.x>edx
					add curPos.x,5
				.elseif curPos.x<eax
					sub curPos.x,5
				.endif
				fild curPos.x
				fild sto
				fmul
				fild RctTBR.right
				fdiv
				fistp curPos.x
				frstor  content
				invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,curPos.x
				invoke SetPosition
				@@:
			.endif
		.elseif ax==TB_LINEUP
			mov eax,lParam
			.if eax==hTBR2
				invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_GETPOS,0,0
				invoke SetMasterVolume,eax
			.elseif eax==hTBR1
				cmp fRun,1
				jne @f
				.if fPause==0
					mov fPause,1
					mctrl Pause_,pControl
				.endif
				invoke SetPosition
				@@:
			.endif
		.elseif ax==TB_LINEDOWN
			mov eax,lParam
			.if eax==hTBR2
				invoke SendDlgItemMessage,hWin,IDC_TBR2,TBM_GETPOS,0,0
				invoke SetMasterVolume,eax
			.elseif eax==hTBR1
				cmp fRun,1
				jne @f
				.if fPause==0
					mov fPause,1
					mctrl Pause_,pControl
				.endif
				invoke SetPosition
				@@:
			.endif
		.endif
	.elseif eax==WM_NCHITTEST
		invoke GetCursorPos,addr lPoint
		invoke GetWindowRect,hSTC1,addr STC1_Rct
		invoke DefWindowProc,hWin,uMsg,wParam,lParam 
		mov edx,lPoint.y
		.if eax==HTCLIENT && edx>STC1_Rct.bottom
			mov eax,HTCAPTION
		.endif 
		ret
	.elseif eax==WM_LBUTTONDBLCLK
		.if fFullScreen==1 
			call ClearFullScreen
			call VideoSize
		.else
			call SetFullScreen
			call VideoSize
		.endif
	.elseif eax==WM_LBUTTONUP
		.if fRun==1
			.if fFullScreen==1 && fCurHidden==1
				invoke ShowCursor,TRUE
				mov fCurHidden,0
			.endif
			.if fNoPause==0
				invoke  SendMessage,hWnd,WM_COMMAND,IDC_BTN2,NULL
			.else
				mov fNoPause,0
			.endif
			
		.endif
	.elseif eax==WM_RBUTTONUP
		.if fRun==1 && fAudio==0
			.if fFullScreen==1 && fCurHidden==1
				invoke ShowCursor,TRUE
				mov fCurHidden,0
			.endif
			invoke GetCursorPos,addr curPos
			mov eax,curPos.x
			mov edx,curPos.y
			invoke TrackPopupMenu,hPopupMenu, TPM_LEFTBUTTON,eax,edx,0,hWnd,0
		.endif
;	.elseif eax==WM_MOUSEMOVE
;		.if fFullScreen==1
;			.if fCurHidden==1 
;				invoke ShowCursor,TRUE
;				mov fCurHidden,0
;			.endif
;			invoke GetCursorPos,addr lPoint
;			.if lPoint.y==0 && fProgressWindowHidden==1
;				invoke ShowWindow,hProgressWindow,SW_SHOW
;				mov fProgressWindowHidden,0
;				mov fHoverProgWin,1
;			.elseif lPoint.y>20
;				mov fHoverProgWin,0
;			.endif
;		.endif
	.elseif eax==WM_MBUTTONUP
		.if WheelFunc==0
			mov WheelFunc,1	;equ wheelVolume
			invoke BlendText,addr szWheelVolume,16,addr szFontName
		.else
			mov WheelFunc,0	;equ wheelFrameStep
			invoke BlendText,addr szWheelFrameStep,16,addr szFontName
		.endif
	.elseif eax==WM_MOUSEWHEEL
		mov eax,wParam
		shr eax,16
		cmp ax,0
		jl BackRotateWheel
		.if WheelFunc==wheelFrameStep && fAudio==0
			invoke GetCursorPos,addr curPos
			invoke GetWindowRect,hTBR2,addr loc_RctTBR2
			mov eax,curPos.x
			mov edx,curPos.y
			.if eax>loc_RctTBR2.left && eax<loc_RctTBR2.right && edx>loc_RctTBR2.top && edx<loc_RctTBR2.bottom
				mov eax,wParam
				shr eax,16
				cmp ax,0
				jl BackRotate
				invoke GetMasterVolume
				.if eax == MIXER_ERROR
					jmp @f
				.endif
				add eax,1000
				.if eax>65535
					mov eax,65534
				.endif
				push eax
				invoke SetMasterVolume,eax
				pop eax
				invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
				jmp @f
				BackRotate:
				invoke GetMasterVolume
				.if eax == MIXER_ERROR || eax<0
					jmp @f
				.endif
				sub eax,1000
				cmp eax,0
				jnl @@f
				mov eax,0
				@@f:
				push eax
				invoke SetMasterVolume,eax
				pop eax
				invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
				@@:
				invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_GETPOS,0,0
				mov edx,eax
				invoke dw2a,edx,addr lBufferVolumeBmp
				invoke BlendText,addr lBufferVolumeBmp,18,addr szFontName
				xor eax,eax
				ret
			.endif
			.if fPause==0
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
			vfstep Step,pStep,1,0
			.if eax==VFW_E_FRAME_STEP_UNSUPPORTED
				.if fPause==1
					invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
				.endif
				jmp Exit_MOUSEWHEEL
			.endif
			invoke GetPosition
			invoke UpdateSTC2,1
		.else;if WheelFunc==wheelVolume
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp Exit_MOUSEWHEEL
			.endif
			add eax,1000
			.if eax>65535
				mov eax,65534
			.endif
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_GETPOS,0,0
			mov edx,eax
			invoke dw2a,edx,addr lBufferVolumeBmp
			invoke BlendText,addr lBufferVolumeBmp,18,addr szFontName
		.endif
		jmp Exit_MOUSEWHEEL
		BackRotateWheel:	;<----------------------------back rotate wheel-------
		.if WheelFunc==wheelFrameStep && fAudio==0
			invoke GetCursorPos,addr curPos
			invoke GetWindowRect,hTBR2,addr loc_RctTBR2
			mov eax,curPos.x
			mov edx,curPos.y
			.if eax>loc_RctTBR2.left && eax<loc_RctTBR2.right && edx>loc_RctTBR2.top && edx<loc_RctTBR2.bottom
				mov eax,wParam
				shr eax,16
				cmp ax,0
				jl _BackRotate
				invoke GetMasterVolume
				.if eax == MIXER_ERROR
					jmp @f
				.endif
				add eax,1000
				.if eax>65535
					mov eax,65534
				.endif
				push eax
				invoke SetMasterVolume,eax
				pop eax
				invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
				jmp @f
				_BackRotate:
				invoke GetMasterVolume
				.if eax == MIXER_ERROR || eax<0
					jmp @f
				.endif
				sub eax,1000
				cmp eax,0
				jnl @@ff
				mov eax,0
				@@ff:
				push eax
				invoke SetMasterVolume,eax
				pop eax
				invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
				@@:
				invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_GETPOS,0,0
				mov edx,eax
				invoke dw2a,edx,addr lBufferVolumeBmp
				invoke BlendText,addr lBufferVolumeBmp,18,addr szFontName
				xor eax,eax
				ret
			.endif
			;vfstep CancelStep,pStep
;			fsave content
;			fild position
;			fild try
;			fsub 
;			frndint
;			fistp position
;			frstor  content
;			mseeking SetPositions,pSeeking,addr position,AM_SEEKING_AbsolutePositioning,\
;			NULL, AM_SEEKING_NoPositioning
;			invoke GetPosition
		.else;if WheelFunc==wheelVolume
			invoke GetMasterVolume
			.if eax == MIXER_ERROR || eax<0
				jmp Exit_MOUSEWHEEL
			.endif
			sub eax,1000
			cmp eax,0
			jnl @f
			mov eax,0
			@@:
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_GETPOS,0,0
			mov edx,eax
			invoke dw2a,edx,addr lBufferVolumeBmp
			invoke BlendText,addr lBufferVolumeBmp,18,addr szFontName
		.endif
		
		Exit_MOUSEWHEEL:
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif eax==WM_KEYDOWN
		mov eax,wParam
		;and eax,0FFFFh
		.if ax==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif eax==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
;		.elseif eax==VK_LEFT
;			invoke MessageBox,0,addr AppName,addr AppName,MB_OK
;		;.elseif eax==VK_RIGHT
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax	
			invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_GRAPHNOTIFY
		meventex  GetEvent, pEvent, ADDR evCode, ADDR param1, ADDR param2, 1000
		meventex  FreeEventParams, pEvent, ADDR evCode, ADDR param1, ADDR param2
		.if fCreatePL==0
			.if evCode==EC_COMPLETE; or EC_USERABORT;01h
				.data
					szWndProc1	db "WndProc:Message EC_COMPLETE was received fCreatePL==0",0
				.code 
				invoke WriteLogFile,addr szWndProc1
				invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0
			.elseif evCode==EC_PAUSED	;0Eh
				meventex  WaitForCompletion, pEvent,0,addr evCode
				.if evCode==EC_COMPLETE; or EC_USERABORT
					invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0
				.endif
			.elseif evCode==EC_VIDEO_SIZE_CHANGED
				cmp fChangeWindowSize,1
				jne @f
				mov eax,param1
				mov edx,eax
				and eax,0FFFFh
				add eax,10
				shr edx,16
				add edx,130
				invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, eax,edx,TRUE
				@@:
				.if fSaveVideoRatio==1 && fChangeWindowSize==0
					invoke VideoSize
				.endif
				.data
					szWndProc2	db "WndProc:EC_VIDEO_SIZE_CHANGED fCreatePL==0",0
				.code 
				invoke WriteLogFile,addr szWndProc2
			;.elseif evCode==EC_FULLSCREEN_LOST
				;invoke MessageBox,0,addr AppName,addr AppName,MB_OK
			.endif
		.else	;------------------------------------------PL was created---
			.if evCode==EC_COMPLETE; or EC_USERABORT
				.data
					szWndProc	db "WndProc:Message EC_COMPLETE was received fCreatePL==1",0
				.code 
				invoke WriteLogFile,addr szWndProc
				.if PLFocus==-1
					push PLFocusSaved
					pop PLFocus
				.endif
				.if fRandomPlay==1
					;invoke     SendMessage, hList,LVM_GETITEMCOUNT,0,0
					;cmp HavePlayed,eax
					;je @@@1
					push PLFocus
					pop PrevFile
					invoke RandomPlay,hList
					.if eax==-1 ;|| eax==0
						invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0 ;stop
						.if fFullScreen==1
							invoke ShowWindow,hScreenFhon,SW_HIDE
							mov fFullScreen,0
						.endif
						xor eax,eax
						mov PLFocus,-1
						mov fPlayOfPlComplete,1
						ret
					.endif
					mov PLFocus,eax
					
				.else
					@@:
					;int 3
					invoke     SendMessage, hList, LVM_GETNEXTITEM,PLFocus,LVNI_BELOW
					.if eax==0 || eax==-1
						;@@@1:
						invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0 ;stop
						.if fFullScreen==1
							invoke ShowWindow,hScreenFhon,SW_HIDE
							mov fFullScreen,0
						.endif
						xor eax,eax
						mov PLFocus,-1
						ret
					.endif
				.endif
				mov PLFocus,eax
				invoke AVIPlay3,eax
				.if fNoScrollPL==0
					invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
				.endif
				
			.elseif evCode==EC_PAUSED	;--------------------------2way---
				.data
					szWndProc3	db "WndProc:EC_PAUSED Start WaitForCompletion 100ms (2 way)",0
				.code 
				invoke WriteLogFile,addr szWndProc3
				meventex  WaitForCompletion, pEvent,100,addr evCode
				.data
					szWndProc33	db "WndProc:EC_PAUSED end WaitForCompletion(2 way)",0
				.code 
				invoke WriteLogFile,addr szWndProc33
				.if evCode==EC_COMPLETE; or EC_USERABORT
					.data
						szWndProc4	db "WndProc:WaitForCompletion --> EC_COMPLETE(2 way)",0
					.code 
					invoke WriteLogFile,addr szWndProc4
					.if PLFocus==-1
						push PLFocusSaved
						pop PLFocus
					.endif
					.if fRandomPlay==1
						;invoke     SendMessage, hList,LVM_GETITEMCOUNT,0,0
						push PLFocus
						pop PrevFile
						invoke RandomPlay,hList
						.if eax==-1 ;|| eax==0
							invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0 ;stop
							.if fFullScreen==1
								invoke ShowWindow,hScreenFhon,SW_HIDE
								mov fFullScreen,0
							.endif
							xor eax,eax
							mov PLFocus,-1
							mov fPlayOfPlComplete,1
							ret
						.endif
						mov PLFocus,eax
						
					.else
						@@:
						;int 3
						invoke     SendMessage, hList, LVM_GETNEXTITEM,PLFocus,LVNI_BELOW
						.if eax==0 || eax==-1
							;@@@2:
							invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0 ;stop
							.if fFullScreen==1
								invoke ShowWindow,hScreenFhon,SW_HIDE
								mov fFullScreen,0
							.endif
							xor eax,eax
							mov PLFocus,-1
							ret
						.endif
					.endif
					mov PLFocus,eax
					invoke AVIPlay3,eax
					.if fNoScrollPL==0
						invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
					.endif
					
				.endif
			.elseif evCode==EC_VIDEO_SIZE_CHANGED
				cmp fChangeWindowSize,1
				jne @f
				mov eax,param1
				mov edx,eax
				and eax,0FFFFh
				add eax,10
				shr edx,16
				add edx,130
				invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, eax,edx,TRUE
				@@:
				.if fSaveVideoRatio==1 && fChangeWindowSize==0
					invoke VideoSize
				.endif
				.data
					szWndProc10	db "WndProc:EC_VIDEO_SIZE_CHANGED ",0
				.code 
				invoke WriteLogFile,addr szWndProc10
			;.elseif evCode==EC_FULLSCREEN_LOST
				;invoke MessageBox,0,addr AppName,addr AppName,MB_OK
			.endif
		.endif
	.elseif eax==WM_TIMER
		mov eax,wParam
		.if eax==IDC_TIMER2
			;int 3
			mov fCallCmdProcFromWaitEvent,0
			invoke CmdLineProc,addr _CmdLine
			invoke KillTimer,hWnd,hTimer2
			mov hTimer2,0
			lea edi,_CmdLine
			mov ecx,1024
			xor eax,eax
			rep stosb
			.data
				szWndProc8	db "WndProc: KillTimer (hTimer2)",0
			.code 
			invoke WriteLogFile,addr szWndProc8
			ret
		.endif
		.if fRun==1
			.if fPause==0
				invoke GetPosition
				invoke UpdateSTC2,1
			.endif
			.if fAudio==0 && fRun==1 && fHideInTray==0
				invoke SetThreadExecutionState,ES_DISPLAY_REQUIRED
			.endif
			
			.if fFullScreen==1 && fCurHidden==0 && fProgressWindowHidden==1 && fVideoOptionCreated==0
				inc CountForMouse
				.if CountForMouse>7 
					invoke ShowCursor,FALSE
					mov CountForMouse,0
					mov fCurHidden,1
				.endif
			.endif
			.if fFullScreen==1 && fProgressWindowHidden==0 && fHoverProgWin==0
				inc CountForProgressWindow
				.if CountForProgressWindow>4
					invoke ShowWindow,hProgressWindow,SW_HIDE
					mov fProgressWindowHidden,1
					mov CountForProgressWindow,0
					.if fBlendTextShowTime==1
						mov CountForBlendText,5
						mov fBlendTextShowTime,0
					.endif
				.endif
				
			.endif
			.if fBlendTextShowTime==1
				invoke GetWindowText,hSTC2,addr lBufferForBlendText,128
				invoke lstrlen,addr lBufferForBlendText
				mov edx,eax
				invoke BlendText,addr lBufferForBlendText,edx,addr szFontName
			.endif
			.if fBlendText==1
				inc CountForBlendText
				.if CountForBlendText>5
					mov CountForBlendText,0
					mov fBlendText,0
					invoke UpdateText,1
				.endif
			.endif
			;int 3
			fsave content
			fild position	;current position
			fild duration	;duration
			fcom
			fstsw ax
			sahf
			jp 	@f		;jump if error
			;jc @f			;jump if st0 <st1 
			jnz @f 			; jump if st0!=st1
			add CountForCompleting,1
			.if CountForCompleting==3
				.data
					szWndProc9	db "WndProc: duration & position are equal. Message (IDC_BTN5) will be sent!!!",0
				.code 
				invoke WriteLogFile,addr szWndProc9
				;meventex  WaitForCompletion, pEvent,100,addr evCode	;3 way
				;.if evCode==EC_COMPLETE
					;.data
					;	szWndProc9	db "WndProc:WaitForCompletion --> EC_COMPLETE (3 way).",0
					;.code 
					;invoke WriteLogFile,addr szWndProc9
					invoke PostMessage,hWnd,WM_COMMAND,IDC_BTN5,0
				;.endif
				mov CountForCompleting,0
			.endif
			@@:
			frstor  content
		.endif
		mov fNoPause,0
		mov fError,0
	.elseif eax==WM_HOTKEY
		mov eax,wParam
		.if eax==IDC_HOT1
			.if fFullScreen==1 
				call ClearFullScreen
				call VideoSize
			.else
				call SetFullScreen
				call VideoSize
			.endif
		.elseif eax==IDC_HOT2
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN6, NULL
		.elseif eax==IDC_HOT3
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN5, NULL
		.elseif eax==IDC_HOT4
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			add eax,1000
			.if eax>65534
				mov eax,65534
			.endif
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			@@:
		.elseif eax==IDC_HOT5
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			sub eax,1000
			cmp eax,0
			jnl @@ff1
			mov eax,0
			@@ff1:
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			@@:
		.endif
	.elseif eax==WM_SHELLNOTIFY
		.if wParam==IDI_TRAY
			.if lParam==WM_RBUTTONDOWN
				invoke GetCursorPos,addr lpt
				invoke SetForegroundWindow,hWnd
				invoke TrackPopupMenu,hPopupMenuTray,TPM_RIGHTALIGN,lpt.x,lpt.y,NULL,hWnd,NULL
				invoke PostMessage,hWnd,WM_NULL,0,0
			.elseif lParam==WM_LBUTTONDBLCLK
				invoke SendMessage,hWnd,WM_COMMAND,IDM_RestoreFromTray,0
			.endif
		.endif
	.elseif eax==WM_POWERBROADCAST
		mov eax,wParam
		.if eax==PBT_APMRESUMESUSPEND
			
		.elseif eax==PBT_APMQUERYSUSPEND
			.data
				szWndProc77	db "WndProc: PBT_APMQUERYSUSPEND",0
			.code 
			invoke WriteLogFile,addr szWndProc77
		.elseif eax==PBT_APMSUSPEND
			.data
				szWndProc777	db "WndProc: PBT_APMSUSPEND",0
			.code 
			invoke WriteLogFile,addr szWndProc777
		.endif
	.elseif eax==WM_QUERYENDSESSION
		.data
			szWndProc88	db "WndProc: WM_QUERYENDSESSION",0
		.code 
		invoke WriteLogFile,addr szWndProc88
		invoke IniProc,toWrite
		mov eax,TRUE
		ret
	.elseif eax==WM_ENDSESSION 
		.data
			szWndProc888	db "WndProc: WM_ENDSESSION",0
		.code 
		invoke WriteLogFile,addr szWndProc888
	.elseif eax==WM_CLOSE
		call KillAllProc
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,NULL
		.data
			szWndProc7	db "WndProc: PostQuitMessage",0
		.code 
		invoke WriteLogFile,addr szWndProc7
	.elseif eax==WM_APPCOMMAND
		mov eax,lParam
		shr eax,16
		.if ax==APPCOMMAND_MEDIA_NEXTTRACK
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN5, NULL
		.elseif ax==APPCOMMAND_MEDIA_PLAY_PAUSE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif ax==APPCOMMAND_MEDIA_PREVIOUSTRACK
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN6, NULL
		.elseif ax==APPCOMMAND_MEDIA_STOP
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN3, NULL
		.elseif ax==APPCOMMAND_VOLUME_DOWN
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			sub eax,1000
			cmp eax,0
			jnl @@ff11
			mov eax,0
			@@ff11:
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			@@:
		.elseif ax==APPCOMMAND_VOLUME_MUTE
			.if fMute==0
				invoke GetMasterVolume
				.if eax == MIXER_ERROR
					jmp @f
				.endif
				mov volumeForMute,eax
				invoke SetMasterVolume,NULL
				mov fMute,1
				@@:
			.else
				invoke SetMasterVolume,volumeForMute
				mov fMute,0
			.endif
		.elseif ax==APPCOMMAND_VOLUME_UP
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			add eax,1000
			.if eax>65534
				mov eax,65534
			.endif
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			@@:
		.else
			invoke DefWindowProc,hWin,uMsg,wParam,lParam
			ret
		.endif
		mov eax,TRUE
		ret
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret
WndProc endp

WndProc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL ps:PAINTSTRUCT
LOCAL Rct:RECT
LOCAL hOld:dword
LOCAL hDC:HDC
LOCAL memDC:dword
LOCAL WndProc2Buffer [512]:BYTE
LOCAL lb:LOGBRUSH
LOCAL hBrush:DWORD
LOCAL hPen:DWORD
LOCAL hPen2:DWORD
LOCAL hBMP:DWORD
LOCAL bmp:BITMAP
LOCAL l_Point:POINT

	.if uMsg==WM_PAINT
		.if fRun!=1 || fAudio==1
			.if fFhonNotFound==0
				invoke BeginPaint,hWin, ADDR ps
				mov    hDC,eax
				invoke CreateCompatibleDC,hDC	
				mov memDC, eax
				invoke SelectObject,memDC,hPic 
				mov hOld, eax 
				invoke GetClientRect,hSTC1,ADDR Rct
				invoke GetBrushOrgEx,hDC,addr l_Point
				invoke SetStretchBltMode,hDC,HALFTONE
				invoke SetBrushOrgEx,hDC,0,0,addr l_Point
				mov edx,SIZEOF BITMAP
				invoke GetObject,hPic,edx,addr bmp
				mov ebx,bmp.bmWidth
				mov edx,bmp.bmHeight
				invoke StretchBlt,hDC,0,0,Rct.right,Rct.bottom,memDC,0,0,ebx,edx,SRCCOPY
				invoke SelectObject,hDC,hOld
				invoke DeleteDC,memDC
				invoke EndPaint,hWin, ADDR ps
			.else
				;int 3
				invoke BeginPaint,hWin, ADDR ps
				mov    hDC,eax
				invoke GetClientRect,hSTC1,ADDR Rct
				invoke SetMapMode,hDC,MM_ANISOTROPIC
				invoke SetWindowExtEx,hDC,100,100,0
				invoke SetViewportExtEx,hDC,Rct.right,Rct.bottom,0
				
				mov lb.lbStyle, BS_SOLID
				mov eax,BackdropColour
				mov lb.lbColor,eax 
				mov lb.lbHatch, NULL
				invoke CreateBrushIndirect,ADDR lb
				mov hBrush, eax	
				invoke SelectObject,hDC,hBrush 
				mov hOld, eax
				invoke Rectangle,hDC,0,0,100,100
				
				mov lb.lbStyle,BS_SOLID
				mov lb.lbColor,00191919h
				mov lb.lbHatch,0
				invoke ExtCreatePen,PS_SOLID or PS_GEOMETRIC or PS_ENDCAP_ROUND or PS_JOIN_ROUND,5,ADDR lb,0,0
				mov hPen,eax
				invoke SelectObject,hDC,hPen
				invoke MoveToEx,hDC,67,65,0
				invoke LineTo,hDC,75,40
				invoke LineTo,hDC,47,65
				invoke LineTo,hDC,55,40
				invoke LineTo,hDC,27,65
				
				mov lb.lbStyle,BS_SOLID
				mov lb.lbColor,00000FFh
				mov lb.lbHatch,0
				invoke ExtCreatePen,PS_SOLID or PS_GEOMETRIC or PS_ENDCAP_ROUND or PS_JOIN_ROUND,5,ADDR lb,0,0
				mov hPen2,eax
				invoke SelectObject,hDC,hPen2
				invoke MoveToEx,hDC,67,65,0
				invoke LineTo,hDC,67,20
				invoke LineTo,hDC,47,65
				invoke LineTo,hDC,47,20
				invoke LineTo,hDC,27,65
				
				invoke SelectObject,hDC,hOld
				invoke DeleteObject,hBrush
				invoke DeleteObject,hPen
				invoke DeleteObject,hPen2
				;invoke DeleteDC,memDC
				invoke EndPaint,hWin, ADDR ps
			.endif
		.endif
	.elseif uMsg==WM_DROPFILES
		invoke  DragQueryFile, wParam, 0, addr WndProc2Buffer, 512 
		invoke FilterProc,addr WndProc2Buffer
		.if eax==MEDIA_TYPE || eax==AUDIO_TYPE
			invoke LoadPL,addr WndProc2Buffer,hList,0
			;invoke AVIPlay2,addr WndProc2Buffer
			push PLFocus
			pop PLFocusSaved
			mov PLFocus,eax
			invoke InvalidateRect,hPL,0,TRUE
		.elseif eax==MPL_TYPE
			.if fCreatePL==0 || IsPLVisible==0
				invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN4,NULL
			.endif
			invoke LoadPL,addr WndProc2Buffer,hList,0
		.else
			invoke MessageBox,0,addr szInvalidFile,addr AppName,MB_OK
		.endif
		xor eax,eax
		ret
	;.elseif uMsg==WM_KEYDOWN
		;int 3
		;invoke HotButtonsProc,wParam
	.endif
	invoke CallWindowProc,OldWndProc,hWin,uMsg,wParam,lParam
	
	ret
WndProc2 endp

AVIOpenFile proc	fNoPlay:DWORD

	.data
		szAVIOpenFile	db "AVIOpenFile proc start",0
	.code 
  	invoke WriteLogFile,addr szAVIOpenFile
  	
  		
	lea     esi, buf
    mov     ecx, 256
    xor     eax, eax
    @@:
    mov     dword ptr [esi+ecx*4], eax
    loop    @B
    
    lea     esi, szFileName
    mov     ecx, 1024
    xor     eax, eax
    @@:
    mov     dword ptr [esi+ecx*4], eax
    loop    @B
    
    lea     esi, szfilename
    mov     ecx, 1024
    xor     eax, eax
    @@:
    mov     dword ptr [esi+ecx*4], eax
    loop    @B

    push    hWnd
    pop     hwndOwner
    ;int 3
    invoke  GetOpenFileName, ADDR lStructSize



    test    eax, eax
    jz	noload
    .if fRun==1 && fNoPlay==0
		call AVIStop
 	.endif
	mov fFileLoad,1
	mov fNoPause,1
    lea     esi, szFileName
    xor     ebx, ebx
    @@:
    mov     al, [esi]
    test    al, al
    jz      @F
    inc     esi
    inc     ebx
    jmp     @B
    @@:
	;invoke lstrlen,addr szFileName
 	;lea edi,szFileName
 	;add edi,eax
 	;mov ecx,eax
 	;mov al,'.'
	;std
	;repne scasb 
	;cld
	;inc edi
 	;invoke lstrcmpi,edi,addr szMpl
 	;jne @f
 	invoke WriteLogFile,addr szFileName
 	
 	invoke FilterProc,addr szFileName
 	.if eax==MPL_TYPE
		mov IsPLVisible,1
		call CreatePlayList
		invoke LoadPL,addr szFileName,hList,0
		.if fHideVideo==1
			mov edx,124
			invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,Wht_MainWindow,TRUE
		.endif
		.data
			szAVIOpenFile21	db "AVIOpenFile proc end",0
		.code 
		invoke WriteLogFile,addr szAVIOpenFile21
		ret
 	.elseif eax==AUDIO_TYPE
		 mov fAudio,1
		.if fHideVideo==1
			mov fAudioWasPrev,1
			.if fFullScreen==1
				mov fFullScreen,0
				invoke ShowWindow,hScreenFhon,SW_HIDE
			.endif
			mov edx,124
			.if Wht_MainWindow>124
				push Wht_MainWindow
				pop Wht_MainWindowSaved
			.endif
			invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,edx,TRUE
		.endif
	.elseif eax==MEDIA_TYPE
		.if Wht_MainWindowSaved!=0 && fAudioWasPrev==1
			push Wht_MainWindowSaved
			pop Wht_MainWindow
			invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,Wht_MainWindow,TRUE
			mov fAudioWasPrev,0
		.endif
	.else
		
		invoke OpenFiles,addr szFileName
		cmp eax,-1
		je noload
		.if fRun==1 && fNoPlay==0
			call AVIStop
		.endif
		.if fNoPlay!=1
			invoke AVIPlay3,eax
		.endif
		ret
 	.endif
 	
    invoke  MultiByteToWideChar,CP_ACP,0,ADDR szFileName,ebx,ADDR buf,1024
    
    invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,0
    .if fCreatePL==1
		invoke LoadPL,addr szFileName,hList,1
    .elseif
		call CreatePlayList
		invoke LoadPL,addr szFileName,hList,1
    .endif
    .if fNoPlay!=1
		push PLFocus
		pop PLFocusSaved
		mov PLFocus,eax
		call  AVIPlay 
    .endif
    invoke InvalidateRect,hPL,0,TRUE
    
	.data
		szAVIOpenFile2	db "AVIOpenFile proc end",0
	.code 
  	invoke WriteLogFile,addr szAVIOpenFile2
  	
    ret
    
noload:
	invoke CommDlgExtendedError
	.if eax==FNERR_BUFFERTOOSMALL
		invoke MessageBox,0,addr szNotEnoughMemory,addr szWarning,MB_OK
		.data
			szAVIOpenFile3	db "AVIOpenFile: buffer too small",0
		.code 
		invoke WriteLogFile,addr szAVIOpenFile3		
	.endif
	
    ;invoke SetDlgItemText,hWnd,IDC_BTN2,addr szPlay
    invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
    .if fRun==0
		invoke EnableWindow,hTBR1,FALSE
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,0
    .endif
    ;mov fRun,0
    mov fFileLoad,0
    ;invoke EnableWindow,hTBR2,FALSE
    lea edi,szFileName
    mov ecx,nMaxFile
    xor al,al
    rep stosb
    
	.data
		szAVIOpenFile1	db "AVIOpenFile proc no load",0
	.code 
  	invoke WriteLogFile,addr szAVIOpenFile1
  	
    ret
 AVIOpenFile endp
 AVIStop  proc
 
	.data
		szAVIStop	db "AVIStop start",0
	.code 
  	invoke WriteLogFile,addr szAVIStop
	
	
 	.if fCurHidden==1
		invoke ShowCursor,TRUE
		mov fCurHidden,0
 	.endif
 	
 	;invoke lstrcpy,addr note.szTip,addr AppName
 	
 	call StopTimer
 	mov fExitScrollThread,1
 	mov fRun,0
 	mov fPause,0
 	mov fAudio,0
 	
 	
    mov     eax, pControl
    test    eax, eax
    jz      @F
    mctrl   Stop, pControl
   
    call  AVIClose
    call AVIInit
    @@:
 	invoke EnableWindow,hTBR1,FALSE
    ;invoke EnableWindow,hTBR2,FALSE
    invoke SetWindowText,hSTC2,addr szSTC2
    .if fNoScrollCaption==1
		invoke SetWindowText,hWnd,addr AppName
    .endif
    
	.data
		szAVIStop1	db "AVIStop end",0
	.code 
  	invoke WriteLogFile,addr szAVIStop1
  	
    ret
 AVIStop endp

 AVIPlay proc
  
	.data
		szAVIPlay	db "AVIPlay proc start",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay
  	
  	;---------------------VideoMixingRenderer------------------------	
	.if fAudio==1 || fVMR9Created==1
		jmp NoVMR9
	.endif
	
	invoke CoCreateInstance,addr CLSID_VideoMixingRenderer9, NULL,\
           CLSCTX_INPROC_SERVER,addr ID_IBaseFilter,addr pVMR9
    cmp eax,0
	jz @f
    .data
		szAVIInit2	db "Create pVMR9 failed",0
	.code 
  	invoke WriteLogFile,addr szAVIInit2
  	jmp NoVMR9
  	@@:
  	       
	gbuilder AddFilter,pGraph,pVMR9,addr szVMR9
	
  	
    vmr_fconfig9 QueryInterface, pVMR9, addr ID_IVMRFilterConfig9, addr pConfig9
	vmr_fconfig9 SetRenderingMode,pConfig9,VMRMode_Windowed
	vmr_fconfig9 SetNumberOfStreams,pConfig9, MaxStream
	
	
    ;vmr_wcontrol9 QueryInterface,pVMR9,addr ID_IVMRWindowlessControl9,addr pWControl9
    ;vmr_wcontrol9 SetVideoClippingWindow,pWControl9,hSTC1
    ;vmr_wcontrol9 GetNativeVideoSize,pWControl9,addr NativeVideoWidth,addr NativeVideoHeight,0,0
	;invoke GetClientRect,hSTC1,addr clientwindow
	;.if fSaveVideoRatio==1
	;	vmr_wcontrol9 SetAspectRatioMode,pWControl9,VMR_ARMODE_LETTER_BOX
	;.else
	;	vmr_wcontrol9 SetAspectRatioMode,pWControl9,VMR_ARMODE_NONE
	;.endif
	;vmr_wcontrol9 SetVideoPosition,pWControl9,NULL,addr clientwindow
	
	
	vmr_mixercontrol9 QueryInterface,pVMR9,addr ID_IVMRMixerControl9,addr pMControl9
	;vmr_mixercontrol SetAlpha,pMControl,1,0
	
  	
	vmr_mbitmap9 QueryInterface,pVMR9,addr ID_IVMRMixerBitmap9,addr pMBitmap9
	mov fVMR9Created,1
	NoVMR9:
	;------------------------------------------------------------------

  	
    gbuilder  RenderFile, pGraph, addr buf, NULL
    
    test    eax, eax
    jz      Continue
	mov fFileLoad,0
	mov fRun,0
	;invoke SetDlgItemText,hWnd,IDC_BTN2,addr szPlay
	invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
	;invoke  MessageBox, 0, ADDR szAVIOpenError, ADDR szWarning, 0
	invoke MessageBeep,0FFFFFFFFh
	invoke SetWindowText,hWnd,addr szAVIOpenError
	invoke Sleep,1000
	invoke SetWindowText,hWnd,addr AppName
	inc fError
	cmp fError,5
	ja @@@1
	.if PLFocus==-1
		push PLFocusSaved
		pop PLFocus
	.endif
	.if fRandomPlay==1
		invoke     SendMessage, hList,LVM_GETITEMCOUNT,0,0
		cmp HavePlayed,eax
		;je @@@1
		invoke RandomPlay,hList
		cmp eax,-1
		je @f
		mov PLFocus,eax
		inc HavePlayed
	.else
		@@:
		invoke     SendMessage, hList, LVM_GETNEXTITEM,PLFocus,LVNI_BELOW
		;int 3
		.if eax==-1 || eax==0
			@@@1:
			invoke SendMessage,hWnd,WM_COMMAND,IDC_BTN3,0
			xor eax,eax
			mov PLFocus,-1
			ret
		.endif
	.endif
	mov PLFocus,eax
	invoke AVIPlay3,eax
	.if fNoScrollPL==0
		invoke     SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE
	.endif
	
	.data
		szAVIPlay21	db "AVIPlay proc error",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay21
  		
    ret
    Continue:
	
	cmp fAudio,1
	je @f
	;int 3
	vwindow   put_MessageDrain,pWindow,hWnd 
	vwindow   put_Owner, pWindow, hSTC1
	vwindow   put_WindowStyle, pWindow, WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN
	bvideo GetVideoSize,pVideo,addr NativeVideoWidth,addr NativeVideoHeight
	vwindow  SetWindowForeground,pWindow, TRUE
	@@:
	
	meventex  SetNotifyWindow, pEvent, hWnd, WM_GRAPHNOTIFY, NULL
	
	.if fVideoOptionsSaved==1
		invoke SetVideoOption,ProcAmpControl9_Brightness,Brightness
		invoke SetVideoOption,ProcAmpControl9_Contrast,Contrast
		invoke SetVideoOption,ProcAmpControl9_Hue,Hue
		invoke SetVideoOption,ProcAmpControl9_Saturation,Saturation
	.endif
	
	.if fFullScreen==1
		.if fAudio==0
			vwindow put_Owner, pWindow, hScreenFhon
			vwindow put_MessageDrain,pWindow,hScreenFhon
			invoke VideoSize
		.else
			call ClearFullScreen
		.endif
	.endif
	
	
	
	mseeking GetDuration,pSeeking,addr duration
	
	invoke GetTime,0
	
	;mseeking SetTimeFormat,pSeeking,addr _TIME_FORMAT_SAMPLE
	;mseeking GetTimeFormat,pSeeking,addr BufferTimaFormat
	;call TIME_FORMAT_Proc
	;mseeking SetTimeFormat,pSeeking,addr _TIME_FORMAT_BYTE
	;call TIME_FORMAT_Proc
	
	invoke EnableWindow,hTBR1,TRUE
    invoke SetWindowText,hWnd,addr szFileName
    
    ;invoke lstrcpy,addr note.szTip,addr szFileName
    
    .if fNoScrollCaption==0
		mov fExitScrollThread,0
		invoke CreateThread,0,0,addr ScrollCaptionThread,0,0,0
		invoke CloseHandle,eax
	.endif
	
	invoke SetTimer,hWnd,IDC_TIMER,400,NULL
	mov hTimer,eax
	.data
		szAVIPlay2	db "AVIPlay: Timer was created",0
	.code 
	invoke WriteLogFile,addr szAVIPlay2
	
	mov fRun,1
	mctrl     Run, pControl
	
	invoke VideoSize
	
	
	invoke EnumFilters,pGraph
	
  	
	.data
		szAVIPlay112	db "AVIPlay proc end",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay112
  	
    ret
 AVIPlay  endp
AVIInit proc
 
	.data
		szAVIInit	db "AVIInit proc start",0
	.code 
  	invoke WriteLogFile,addr szAVIInit
  	
  	
	invoke    CoInitialize, NULL

    invoke    CoCreateInstance,ADDR CLSID_FilterGraph,NULL,CLSCTX_INPROC_SERVER,\
	          ADDR ID_IGraphBuilder, ADDR pGraph
	

    mctrl     QueryInterface, pGraph, ADDR ID_IMediaControl, ADDR pControl
    
  	
    meventex  QueryInterface, pGraph, ADDR ID_IMediaEventEx, ADDR pEvent  
	
	
    bvideo    QueryInterface, pGraph, ADDR ID_IBasicVideo, ADDR pVideo
    
  	
    vwindow   QueryInterface, pGraph, ADDR ID_IVideoWindow, ADDR pWindow	
	
	

	mseeking QueryInterface, pGraph, ADDR ID_IMediaSeeking, ADDR pSeeking
	
  	
	baudio   QueryInterface, pGraph, ADDR ID_IBasicAudio, ADDR pAudio
	
  	
	vfstep   QueryInterface, pGraph, ADDR ID_IVideoFrameStep, ADDR pStep
	


	.data
		szAviInit	db "AviInit proc end",0
	.code 
  	invoke WriteLogFile,addr szAviInit
  		
	ret
AVIInit endp
  AVIClose proc
	
	
	.data
		szAVIClose	db "AVIClose proc start",0
	.code 
  	invoke WriteLogFile,addr szAVIClose
	;int 3
	
	
  	
	vfstep Release,pStep
	
 	baudio Release,pAudio
 	
 	mseeking  Release,pSeeking
 	
 	;vwindow put_MessageDrain,pWindow,0
    vwindow   Release, pWindow
    
    bvideo    Release, pVideo
    
    ;meventex  SetNotifyWindow, pEvent, 0, 0, 0
    meventex  Release, pEvent
  
    mctrl     Release, pControl
	;mov pControl,0

    gbuilder  Release, pGraph 
	
	.if fVMR9Created==1
		vmr_mbitmap9 Release,pMBitmap9
		;vmr_wcontrol9 Release,pWControl9
		vmr_mixercontrol9 Release,pMControl9
		vmr_fconfig9 Release,pConfig9
		bfilter Release,pVMR9
		mov fVMR9Created,0
  	.endif
  	
    invoke CoUninitialize
    
	.data
		szAviClose	db "AviClose proc end",0
	.code 
  	invoke WriteLogFile,addr szAviClose
  	
    ret
 AVIClose endp
 
CreatePlayList proc
LOCAL Rct2  :RECT
LOCAL wc:WNDCLASSEX
LOCAL msg:MSG

	.data
		szCreatePlayList	db "CreatePlayList: start",0
	.code 
  	invoke WriteLogFile,addr szCreatePlayList
  	
  	.if fCreatePL==1
		.data
			szCreatePlayList2	db "CreatePlayList: already created",0
		.code 
		invoke WriteLogFile,addr szCreatePlayList2
		jmp Quit
  	.endif
	
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov   wc.lpfnWndProc, OFFSET WndProc3
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_BTNFACE+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET WinClassName
	
	invoke LoadIcon,hInstance,600
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax

	invoke RegisterClassEx, addr wc
	
	invoke GetWindowRect,hWnd,addr Rct2
	.if Wwd<50 || Wht<90
		mov Wwd,90
		mov Wht,300
	.endif
	mov eax,StartGlue 
	.if eax==1		;left
		mov eax,Rct2.left
		sub eax,Wwd
		mov Wtx,eax
		mov edx,Rct2.top
		mov Wty,edx
	.elseif eax==2		;riht
		mov eax,Rct2.right
		mov Wtx,eax
		mov edx,Rct2.top
		mov Wty,edx
	.elseif eax==3		;bottom
		mov eax,Rct2.left
		mov Wtx,eax
		mov edx,Rct2.bottom
		mov Wty,edx
	.else
		
		invoke GetSystemMetrics,SM_CXSCREEN  
		invoke TopXY,Wwd,eax
		mov Wtx, eax
		invoke GetSystemMetrics,SM_CYSCREEN
		invoke TopXY,Wht,eax
		mov Wty, eax
	.endif
      
	INVOKE CreateWindowEx,WS_EX_LEFT,ADDR WinClassName,ADDR AppName,\
    WS_THICKFRAME or WS_SYSMENU,Wtx,Wty,Wwd,Wht,hWnd,0,hInstance,0
	mov   hPL,eax

	.if IsPLVisible==1
		invoke ShowWindow, hPL,SW_SHOWNORMAL
		invoke UpdateWindow, hPL
	.endif
	;invoke GetWindowLong, hPL, GWL_EXSTYLE
    ; add eax, WS_EX_LAYERED
    ;invoke SetWindowLong, hPL, GWL_EXSTYLE, eax
	;invoke SetLayeredWindowAttributes,hPL, 0, 200, LWA_ALPHA
	invoke CreateVPL
	mov hVPL,eax
	invoke CreateVPL
	mov hVPL2,eax
	invoke CreateVPL
	mov hVPL3,eax
 	mov fCreatePL,1
 	call ToolTip
 	Quit:
 	
 .data
szCreatePlayList1	db "CreatePlayList: end",0
.code 
  	invoke WriteLogFile,addr szCreatePlayList1
  	
 	ret

 CreatePlayList endp
 
WndProc3 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL lvc:LV_COLUMN
LOCAL rs:RECT
LOCAL ro:RECT
LOCAL loc_RctTBR2:RECT
LOCAL Buffer [512]:BYTE
LOCAL lBuffer [1024]:BYTE
LOCAL lBuffer2 [32]:BYTE
LOCAL lBufferForSort1 [32]:BYTE
LOCAL lBufferForSort2 [32]:BYTE
LOCAL lvi:LV_ITEM
LOCAL lvf:LVFINDINFO
LOCAL lPoint:POINT
 
LOCAL menuII:MENUITEMINFO
 
LOCAL lTME:TRACKMOUSEEVENT
LOCAL lWht:DWORD
LOCAL lWwd:DWORD
LOCAL lrs:RECT
LOCAL lRct:RECT
LOCAL lItemCount:DWORD
LOCAL lItemSelected:DWORD
LOCAL TME:TRACKMOUSEEVENT
 
 	push hWin
 	pop hPL
 	.if uMsg==WM_CREATE
		invoke  GetSystemMenu, hPL,FALSE 
		mov	hSysMenu,eax
		
		invoke AppendMenu, hSysMenu, MF_SEPARATOR, 0,0
		invoke AppendMenu,hSysMenu,MF_STRING,IDM_AddFile,addr szAddFile
		invoke AppendMenu,hSysMenu,MF_STRING,IDM_AddDir,addr szAddDir
		invoke AppendMenu,hSysMenu,MF_STRING,IDM_DelAll,addr szDelAll
		invoke AppendMenu,hSysMenu,MF_STRING,IDM_Save,addr szSave
		invoke CreatePopupMenu
		mov hPopMenu,eax
		invoke CreatePopupMenu
		mov hPopMenu2,eax
		invoke CreatePopupMenu
		mov hPopMenu3,eax
		invoke CreatePopupMenu
		mov hPopMenu4,eax
		
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_AddFile,addr szAddFile
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_AddDir,addr szAddDir
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_Del,addr szDel
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_FileInfo,addr szFileInfo
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_SearchPL,addr szSearchPL
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_FindPL,addr szFindPL
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_Rename,addr szRenameFile
		
		mov menuII.cbSize,sizeof menuII
		mov menuII.fMask,MIIM_STRING or MIIM_SUBMENU or MIIM_ID
		mov eax,hPopMenu2
		mov menuII.hSubMenu,eax
		mov menuII.wID,IDM_Options1
		lea eax,szOptions
		mov menuII.dwTypeData,eax
		invoke InsertMenuItem,hPopMenu,0,FALSE,addr menuII
		
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_DelAll,addr szDelAll
		invoke AppendMenu,hPopMenu,MF_STRING,IDM_Save,addr szSave
		
		mov menuII.cbSize,sizeof menuII
		mov menuII.fMask,MIIM_STRING or MIIM_SUBMENU or MIIM_ID
		mov eax,hPopMenu3
		mov menuII.hSubMenu,eax
		mov menuII.wID,IDM_Priority
		lea eax,szPriority
		mov menuII.dwTypeData,eax
		invoke InsertMenuItem,hPopMenu2,0,FALSE,addr menuII
		
		mov menuII.cbSize,sizeof menuII
		mov menuII.fMask,MIIM_STRING or MIIM_SUBMENU or MIIM_ID
		mov eax,hPopMenu4
		mov menuII.hSubMenu,eax
		mov menuII.wID,IDM_SortList
		lea eax,szSortList
		mov menuII.dwTypeData,eax
		invoke InsertMenuItem,hPopMenu2,0,FALSE,addr menuII
		
		invoke AppendMenu,hPopMenu2,MF_STRING,IDM_Rand,addr szRand
		invoke AppendMenu,hPopMenu2,MF_STRING,IDM_NoScrollPL,addr szNoScrollPL
		
		invoke AppendMenu,hPopMenu3,MF_STRING,IDM_Priority0,addr szPriority0
		invoke AppendMenu,hPopMenu3,MF_STRING,IDM_Priority1,addr szPriority1
		invoke AppendMenu,hPopMenu3,MF_STRING,IDM_Priority2,addr szPriority2
		invoke AppendMenu,hPopMenu3,MF_STRING,IDM_Priority3,addr szPriority3
		
		invoke AppendMenu,hPopMenu4,MF_STRING,IDM_SortByTitle,addr szSortByTitle
		invoke AppendMenu,hPopMenu4,MF_STRING,IDM_SortByExten,addr szSortByExten
		invoke AppendMenu,hPopMenu4,MF_STRING,IDM_SortByPath,addr szSortByPath
		
		mov lTME.cbSize,sizeof lTME
		mov lTME.dwFlags,TME_LEAVE
		mov eax,hList
		mov lTME.hwndTrack,eax
		invoke TrackMouseEvent,addr lTME
		
		
		invoke     CreateWindowEx,WS_EX_ACCEPTFILES  , addr ListClassName, NULL,\
		WS_CHILD or WS_VISIBLE or LVS_REPORT  or LVS_NOCOLUMNHEADER ,\
		0,0, 392, 210, hPL, NULL, hInstance, NULL
		mov     hList, eax
		invoke SetWindowLong,hList,GWL_WNDPROC,addr WndListProc
		mov WndListOldProc,eax
		mov     eax,LVS_EX_ONECLICKACTIVATE or  LVS_EX_FULLROWSELECT\
		or LVS_EX_TRACKSELECT or LVS_EX_DOUBLEBUFFER;LVS_EX_INFOTIP ;LVS_EX_HEADERDRAGDROP
		invoke     SendMessage, hList, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, eax
		mov     lvc.imask, LVCF_TEXT or LVCF_WIDTH or LVCF_SUBITEM
		mov     lvc.pszText, 0;offset szColName
		mov     lvc.lx,10
		invoke     SendMessage, hList, LVM_INSERTCOLUMN, 0, addr lvc
		or     lvc.imask, LVCF_FMT
		mov     lvc.fmt, LVCFMT_LEFT
		mov     lvc.pszText, 0;offset szColSize
		mov     lvc.lx, 150
		invoke     SendMessage, hList, LVM_INSERTCOLUMN, 1, addr lvc 
		or     lvc.imask, LVCF_FMT
		mov     lvc.fmt, LVCFMT_LEFT
		mov     lvc.pszText,0; offset szColSize
		mov     lvc.lx,0
		invoke     SendMessage, hList, LVM_INSERTCOLUMN, 2, addr lvc 
		or     lvc.imask, LVCF_FMT
		mov     lvc.fmt, LVCFMT_LEFT
		mov     lvc.pszText,0; offset szColSize
		mov     lvc.lx,0
		invoke     SendMessage, hList, LVM_INSERTCOLUMN, 3, addr lvc 
		
		RGB 0,0,0
		invoke SendMessage,hList,LVM_SETTEXTCOLOR,0,eax
		.if fSilver==1
			mov eax,MainColour2
		.else
			mov eax,MainColour
		.endif
		invoke SendMessage,hList,LVM_SETBKCOLOR,0,eax
		.if fSilver==1
			mov eax,MainColour2
		.else
			mov eax,MainColour
		.endif
		invoke SendMessage,hList,LVM_SETTEXTBKCOLOR,0,eax
		;mov fFirstLoad,1
		;invoke LoadPL,addr PLName,hList,0
	.elseif uMsg==WM_ERASEBKGND
		
	.elseif uMsg == WM_NOTIFY
		mov edx,lParam
		.if [edx.NMHDR].code == NM_DBLCLK
			invoke     ReleaseCapture
			invoke     SendMessage, hList, LVM_GETNEXTITEM, -1, LVNI_FOCUSED
			cmp eax,-1
			jne @f
			xor eax,eax
			ret
			@@:
			mov PLFocus,eax
			invoke AVIPlay3,eax
			.if fPlayOfPlComplete==1
				invoke ClearVPL,hVPL
				invoke ClearVPL,hVPL2
				invoke ClearVPL,hVPL3
				invoke LoadVPL,hList
				mov fPlayOfPlComplete,0
			.endif
		.elseif [edx.NMHDR].code==NM_RCLICK
			invoke     SendMessage, hList, LVM_GETNEXTITEM, -1, LVNI_SELECTED
			cmp eax,-1
			je @f
			mov PLSelected,eax
			
			.if fRandomPlay==1 
				 invoke  CheckMenuItem,hPopMenu,IDM_Rand,MF_BYCOMMAND or MF_CHECKED
			.else
				invoke  CheckMenuItem,hPopMenu,IDM_Rand,MF_BYCOMMAND or MF_UNCHECKED
			.endif
			.if fNoScrollPL==1 
				 invoke  CheckMenuItem,hPopMenu,IDM_NoScrollPL,MF_BYCOMMAND or MF_CHECKED
			.else
				invoke  CheckMenuItem,hPopMenu,IDM_NoScrollPL,MF_BYCOMMAND or MF_UNCHECKED
			.endif
			
			push PLSelected
			pop lvi.iItem
			mov lvi.iSubItem, 3
			mov lvi.imask, LVIF_TEXT
			lea edi, lBuffer2			;priority
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov lvi.cchTextMax, 32
			invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov eax,dword ptr lBuffer2
			.if eax==0 
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority0,MF_BYCOMMAND or MF_CHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority1,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority2,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority3,MF_BYCOMMAND or MF_UNCHECKED
			.elseif eax==1
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority1,MF_BYCOMMAND or MF_CHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority0,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority2,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority3,MF_BYCOMMAND or MF_UNCHECKED
			.elseif eax==2
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority2,MF_BYCOMMAND or MF_CHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority1,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority0,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority3,MF_BYCOMMAND or MF_UNCHECKED
			.elseif eax==3
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority3,MF_BYCOMMAND or MF_CHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority1,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority2,MF_BYCOMMAND or MF_UNCHECKED
				invoke  CheckMenuItem,hPopMenu3,IDM_Priority0,MF_BYCOMMAND or MF_UNCHECKED
			.endif
			
			invoke GetCursorPos,addr curPos
			mov eax,curPos.x
			mov edx,curPos.y
			invoke TrackPopupMenu,hPopMenu, TPM_LEFTBUTTON,eax,edx,0,hPL,0
			
			invoke InvalidateRect,hPL,0,TRUE
			@@:
		.elseif [edx.NMHDR].code==NM_CLICK
			invoke     SendMessage, hList, LVM_GETNEXTITEM, -1, LVNI_SELECTED
			cmp eax,-1
			je @f
			mov PLSelected,eax
			invoke InvalidateRect,hPL,0,TRUE
			@@:
		.elseif [edx.NMHDR].code==NM_CUSTOMDRAW	
			mov eax,lParam
			mov ebx,[eax.NMCUSTOMDRAW].dwDrawStage
			.if ebx==CDDS_PREPAINT  
				mov eax,CDRF_NOTIFYITEMDRAW
				ret
			.elseif ebx==CDDS_ITEMPREPAINT	;draw items
				mov edx,lParam
				mov ecx,PLFocus
				mov ebx,PLSelected
				.if [edx.NMCUSTOMDRAW].dwItemSpec==ecx
					.if ecx==ebx
						RGB 49,106,197
					.else
						RGB 200,200,200
					.endif
					mov [edx.NMLVCUSTOMDRAW].clrTextBk,eax	;set backcolor of item
					mov eax,CDRF_NEWFONT
					ret

				.elseif [edx.NMCUSTOMDRAW].dwItemSpec==ebx
					RGB 49,106,197
					mov [edx.NMLVCUSTOMDRAW].clrTextBk,eax
					RGB 255,255,255
					mov [edx.NMLVCUSTOMDRAW].clrText,eax	;set textcolor of item
					mov eax,CDRF_NEWFONT
					ret
				.endif
			.endif
		;.elseif [edx.NMHDR].code==NM_SETFOCUS
			
		.elseif [edx.NMHDR].code==NM_HOVER
			invoke HoverPL
			.if eax!=-1
				mov TME.cbSize,sizeof TME
				mov TME.dwFlags,TME_LEAVE
				mov eax,hList
				mov TME.hwndTrack,eax
				invoke TrackMouseEvent,addr TME
				invoke ShowWindow,hToolTip,SW_SHOWNOACTIVATE
				mov fToolTipVisible,1
			.endif
			mov eax,TRUE
			ret
		.endif
	.elseif uMsg==WM_SYSCOMMAND 
		mov eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_AddFile
			invoke AVIOpenFile,1
			@@:
		.elseif eax==IDM_AddDir
			;invoke BrowseForFolder,hWin,ADDR Buffer2,ADDR szSelectDir,ADDR AppName
			;cmp eax,0
			;je @f
			invoke CreateThread,0,0,addr FindFilesThread,0,0,0
			invoke CloseHandle,eax
			;invoke FindFiles,addr Buffer2;,hList
			;@@:
		.elseif eax==IDM_DelAll
			invoke SendMessage, hList, LVM_DELETEALLITEMS,0,0;addr lvi
			invoke ClearVPL,hVPL
			invoke ClearVPL,hVPL2
			invoke ClearVPL,hVPL3
		.elseif eax==IDM_Save
			invoke SavePL,hList
		.endif
		invoke DefWindowProc, hWin, uMsg, wParam,lParam
		ret
	.elseif uMsg==WM_COMMAND 
		mov eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_AddFile
			invoke AVIOpenFile,1
			@@:
		.elseif eax==IDM_AddDir
			invoke CreateThread,0,0,addr FindFilesThread,0,0,0
			invoke CloseHandle,eax
		.elseif eax==IDM_Save
			invoke SavePL,hList
		.elseif eax==IDM_Del
			;int 3
			@@:
			invoke SendMessage,hList,LVM_GETSELECTEDCOUNT,0,0
			.if eax==0
				mov lItemCount,1
				mov eax,PLSelected
				jmp UsePLSelected
			.endif
			mov lItemCount,eax
			mov lItemSelected,-1
			
			invoke SendMessage,hList,LVM_GETNEXTITEM,lItemSelected,LVNI_SELECTED
			UsePLSelected:
			mov lItemSelected,eax
			
			.if PLFocus>eax
				dec PLFocus
			.elseif PLFocus==eax
				mov PLFocus,-1
			.endif
			invoke SendMessage, hList, LVM_DELETEITEM, lItemSelected, NULL
			
			dec lItemCount
			.if lItemCount!=0
				jmp @b
			.endif
			
			invoke FillFirstColumn,hList
			invoke InvalidateRect,hPL,0,TRUE
			invoke ClearVPL,hVPL
			invoke ClearVPL,hVPL2
			invoke ClearVPL,hVPL3
			invoke LoadVPL,hList
		.elseif eax==IDM_DelAll
			invoke     SendMessage, hList, LVM_DELETEALLITEMS,0,0
			invoke ClearVPL,hVPL
			invoke ClearVPL,hVPL2
			invoke ClearVPL,hVPL3
		.elseif eax==IDM_Rand
			.if fRandomPlay==0
				mov fRandomPlay,1
				mov HavePlayed,0
			.else
				mov fRandomPlay,0
				mov HavePlayed,0
			.endif
		.elseif eax==IDM_NoScrollPL
			.if fNoScrollPL==0
				mov fNoScrollPL,1
			.else
				mov fNoScrollPL,0
			.endif
		.elseif eax==IDM_SearchPL
			invoke CreateDialogParam,hInstance,IDD_DIALOG2,hPL,addr WndSearchPLProc,lParam
			mov hDlg,eax
		.elseif eax==IDM_Rename
			invoke CreateDialogParam,hInstance,IDD_DIALOG3,hPL,addr WndRenameProc,lParam
			mov hDlg3,eax
		.elseif eax==IDM_FindPL
			.if FindExist!=1
				invoke CreateDialogParam,hInstance,IDD_DIALOG8,hPL,addr WndFindPLProc,lParam
				mov hDlg8,eax
				mov FindExist,1
			.endif
		.elseif eax==IDM_FileInfo
			invoke CreateDialogParam,hInstance,IDD_DIALOG4,hPL,addr WndFileInfoProc,lParam
			mov hDlg4,eax
			
			invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr lrs,0
			invoke GetWindowRect,hDlg4,addr lRct
			mov edx,lRct.bottom
			sub edx,lRct.top			;edx=Height
			mov lWht,edx
			mov edx,lRct.right
			sub edx,lRct.left		;edx==Width
			mov lWwd,edx
			mov eax,lRct.bottom
			.if eax>lrs.bottom
				mov eax,lrs.bottom
				sub eax,lWht
				mov lRct.top,eax
				invoke MoveWindow,hDlg4,lRct.left,lRct.top,lWwd,lWht,TRUE
			.endif
			mov eax,lRct.right
			.if eax>lrs.right
				mov eax,lWwd
				sub lrs.right,eax
				invoke MoveWindow,hDlg4,lrs.right,lRct.top,lWwd,lWht,TRUE
			.endif
		.elseif eax==IDM_Priority0
			;int 3
			invoke SendMessage,hList,LVM_GETSELECTEDCOUNT,0,0
			mov lItemCount,eax
			mov lItemSelected,-1
			@@:
			invoke SendMessage,hList,LVM_GETNEXTITEM,lItemSelected,LVNI_SELECTED
			.if eax==-1
				xor eax,eax
				ret
			.endif
			mov lItemSelected,eax
			
			push eax
			pop lvi.iItem
			mov lvi.iSubItem, 3
			mov lvi.imask, LVIF_TEXT
			lea edi,lBuffer2			;priority
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov lvi.cchTextMax, 32
			invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov eax,dword ptr lBuffer2
			
			.if eax==1
				invoke DeleteCellVPL,hVPL,lItemSelected
			.elseif eax==2
				invoke DeleteCellVPL,hVPL2,lItemSelected
			.elseif eax==3
				invoke DeleteCellVPL,hVPL3,lItemSelected
			.endif
			
			mov lvi.imask, LVIF_TEXT
			push lItemSelected
			pop lvi.iItem
			mov lvi.iSubItem,3
			lea edi,lBuffer2
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			invoke     SendMessage,hList, LVM_SETITEM,0, addr lvi
			dec lItemCount
			.if lItemCount!=0
				jmp @b
			.endif
			
		.elseif eax==IDM_Priority1
			invoke SendMessage,hList,LVM_GETSELECTEDCOUNT,0,0
			mov lItemCount,eax
			mov lItemSelected,-1
			@@:
			invoke SendMessage,hList,LVM_GETNEXTITEM,lItemSelected,LVNI_SELECTED
			.if eax==-1
				xor eax,eax
				ret
			.endif
			mov lItemSelected,eax
			
			push eax
			pop lvi.iItem
			mov lvi.iSubItem, 3
			mov lvi.imask, LVIF_TEXT
			lea edi, lBuffer2			;priority
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov lvi.cchTextMax, 32
			invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov eax,dword ptr lBuffer2
			
			.if eax==1
				invoke DeleteCellVPL,hVPL,lItemSelected
			.elseif eax==2
				invoke DeleteCellVPL,hVPL2,lItemSelected
			.elseif eax==3
				invoke DeleteCellVPL,hVPL3,lItemSelected
			.endif
			
			invoke AddStrVPL,hVPL,lItemSelected
			
			mov lvi.imask, LVIF_TEXT
			push lItemSelected
			pop lvi.iItem
			mov lvi.iSubItem,3
			lea edi,lBuffer2
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov eax,1
			mov dword ptr lBuffer2, eax
			invoke SendMessage,hList, LVM_SETITEM,0, addr lvi
			dec lItemCount
			.if lItemCount!=0
				jmp @b
			.endif
			
		.elseif eax==IDM_Priority2
			invoke SendMessage,hList,LVM_GETSELECTEDCOUNT,0,0
			mov lItemCount,eax
			mov lItemSelected,-1
			@@:
			invoke SendMessage,hList,LVM_GETNEXTITEM,lItemSelected,LVNI_SELECTED
			.if eax==-1
				xor eax,eax
				ret
			.endif
			mov lItemSelected,eax
			
			push eax
			pop lvi.iItem
			mov lvi.iSubItem, 3
			mov lvi.imask, LVIF_TEXT
			lea edi, lBuffer2			;priority
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov lvi.cchTextMax, 32
			invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov eax,dword ptr lBuffer2
			
			.if eax==1
				invoke DeleteCellVPL,hVPL,lItemSelected
			.elseif eax==2
				invoke DeleteCellVPL,hVPL2,lItemSelected
			.elseif eax==3
				invoke DeleteCellVPL,hVPL3,lItemSelected
			.endif
			
			invoke AddStrVPL,hVPL2,lItemSelected
			
			mov lvi.imask, LVIF_TEXT
			push lItemSelected
			pop lvi.iItem
			mov lvi.iSubItem,3
			lea edi,lBuffer2
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov eax,2
			mov dword ptr lBuffer2,eax
			invoke     SendMessage,hList, LVM_SETITEM,0, addr lvi
			dec lItemCount
			.if lItemCount!=0
				jmp @b
			.endif
			
		.elseif eax==IDM_Priority3
			invoke SendMessage,hList,LVM_GETSELECTEDCOUNT,0,0
			mov lItemCount,eax
			mov lItemSelected,-1
			@@:
			invoke SendMessage,hList,LVM_GETNEXTITEM,lItemSelected,LVNI_SELECTED
			.if eax==-1
				xor eax,eax
				ret
			.endif
			mov lItemSelected,eax
			
			push eax
			pop lvi.iItem
			mov lvi.iSubItem, 3
			mov lvi.imask, LVIF_TEXT
			lea edi, lBuffer2			;priority
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov lvi.cchTextMax, 32
			invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov eax,dword ptr lBuffer2
			
			.if eax==1
				invoke DeleteCellVPL,hVPL,lItemSelected
			.elseif eax==2
				invoke DeleteCellVPL,hVPL2,lItemSelected
			.elseif eax==3
				invoke DeleteCellVPL,hVPL3,lItemSelected
			.endif
			
			invoke AddStrVPL,hVPL3,lItemSelected
			
			mov lvi.imask, LVIF_TEXT
			push lItemSelected
			pop lvi.iItem
			mov lvi.iSubItem,3
			lea edi,lBuffer2
			mov lvi.pszText, edi
			xor al,al
			mov ecx,32
			rep stosb
			mov eax,3
			mov dword ptr lBuffer2,eax
			invoke     SendMessage,hList, LVM_SETITEM,0, addr lvi
			dec lItemCount
			.if lItemCount!=0
				jmp @b
			.endif
			
		.elseif eax==IDM_SortByTitle
			mov lvi.iSubItem, 0				;save PLFocus
			mov lvi.imask, LVIF_TEXT
			lea eax,lBufferForSort1
			mov lvi.pszText, eax
			mov lvi.cchTextMax, 32
			mov eax,PLFocus
			mov lvi.iItem, eax
			invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov lvi.iSubItem, 0				;save PLSelected
			mov lvi.imask, LVIF_TEXT
			lea eax,lBufferForSort2
			mov lvi.pszText, eax
			mov lvi.cchTextMax, 32
			mov eax,PLSelected
			mov lvi.iItem, eax
			invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
			
			invoke SendMessage,hList,LVM_SORTITEMS,1,addr CompareFunc
			invoke FindStringInPl,addr lBufferForSort1,hList,0
			mov PLFocus,eax
			invoke FindStringInPl,addr lBufferForSort2,hList,0
			mov PLSelected,eax
			invoke FillFirstColumn,hList
			invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLSelected,FALSE
			invoke ClearVPL,hVPL
			invoke ClearVPL,hVPL2
			invoke ClearVPL,hVPL3
			invoke LoadVPL,hList
		.elseif eax==IDM_SortByExten
			mov lvi.iSubItem, 0				;save PLFocus
			mov lvi.imask, LVIF_TEXT
			lea eax,lBufferForSort1
			mov lvi.pszText, eax
			mov lvi.cchTextMax, 32
			mov eax,PLFocus
			mov lvi.iItem, eax
			invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov lvi.iSubItem, 0				;save PLSelected
			mov lvi.imask, LVIF_TEXT
			lea eax,lBufferForSort2
			mov lvi.pszText, eax
			mov lvi.cchTextMax, 32
			mov eax,PLSelected
			mov lvi.iItem, eax
			invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
			
			invoke SendMessage,hList,LVM_SORTITEMS,2,addr CompareFunc
			invoke FindStringInPl,addr lBufferForSort1,hList,0
			mov PLFocus,eax
			invoke FindStringInPl,addr lBufferForSort2,hList,0
			mov PLSelected,eax
			invoke FillFirstColumn,hList
			invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLSelected,FALSE
			invoke ClearVPL,hVPL
			invoke ClearVPL,hVPL2
			invoke ClearVPL,hVPL3
			invoke LoadVPL,hList
		.elseif eax==IDM_SortByPath
			mov lvi.iSubItem, 0				;save PLFocus
			mov lvi.imask, LVIF_TEXT
			lea eax,lBufferForSort1
			mov lvi.pszText, eax
			mov lvi.cchTextMax, 32
			mov eax,PLFocus
			mov lvi.iItem, eax
			invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
			mov lvi.iSubItem, 0				;save PLSelected
			mov lvi.imask, LVIF_TEXT
			lea eax,lBufferForSort2
			mov lvi.pszText, eax
			mov lvi.cchTextMax, 32
			mov eax,PLSelected
			mov lvi.iItem, eax
			invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
			
			invoke SendMessage,hList,LVM_SORTITEMS,3,addr CompareFunc
			invoke FindStringInPl,addr lBufferForSort1,hList,0
			mov PLFocus,eax
			invoke FindStringInPl,addr lBufferForSort2,hList,0
			mov PLSelected,eax
			invoke FillFirstColumn,hList
			invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLSelected,FALSE
			invoke ClearVPL,hVPL
			invoke ClearVPL,hVPL2
			invoke ClearVPL,hVPL3
			invoke LoadVPL,hList
		.endif		
	.elseif uMsg==WM_KEYDOWN
		mov eax,wParam
		.if ax==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif eax==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hPL
		.endif
	.elseif uMsg==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg == WM_WINDOWPOSCHANGING
		invoke GetWindowRect,hWnd,addr rs
		mov edi,lParam
		mov eax,[edi+4]
		mov eax,[edi+8]		;указатель на координату левой стороны
		mov ro.left,eax
		mov ro.right,eax
		mov eax,[edi+12]		;указатель на координату верха
		mov ro.top,eax
		mov ro.bottom,eax
		mov eax,[edi+16]		;указатель ширина
		mov [edi+16],eax
		add ro.right,eax
		mov eax,[edi+20]		;указатель высота
		mov [edi+20],eax
		add ro.bottom,eax
		
		mov eax,rs.left		;check left
		sub eax,ro.right
		jnl @f
		neg eax
		@@:
		mov ebx,rs.top
		cmp ebx,0
		jnl @f
		neg ebx
		@@:
		mov edx,rs.bottom
		.if ro.top>=ebx && ro.top<=edx
			.if eax<35
				mov eax,rs.left
				sub eax,[edi+16]
				mov [edi+8],eax
				mov fGlue,1
			.endif
		.endif
		mov eax,rs.bottom		;check bottom
		sub eax,ro.top
		jnl @f
		neg eax
		@@:
		mov ebx,rs.left
		cmp ebx,0
		jnl @f
		neg ebx
		@@:
		mov edx,rs.right
		.if ro.left>=ebx && ro.left<=edx
			.if eax<35
				mov eax,rs.bottom
				mov [edi+12],eax
				mov fGlue,1
			.endif
		.endif
		mov eax,rs.right		;check right
		sub eax,ro.left
		jnl @f
		neg eax
		@@:
		mov ebx,rs.top
		cmp ebx,0
		jnl @f
		neg ebx
		@@:
		mov edx,rs.bottom
		.if ro.top>=ebx && ro.top<=edx
			.if eax<35
				mov eax,rs.right
				mov [edi+8],eax
				mov fGlue,1
			.endif
		.endif
		call IsGlue
	.elseif uMsg==WM_SIZE	
		mov eax,lParam
		mov edx,eax
		and eax,0ffffh
		shr edx,16
		add edx,16
		push eax
		invoke MoveWindow,hList, 0, 0, eax,edx,TRUE
		pop eax
		invoke SendMessage, hList, LVM_SETCOLUMNWIDTH, 1, eax
		invoke GetWindowRect,hPL,addr Rct1
		mov eax,Rct1.right
		sub eax,Rct1.left
		jnl @f
		mov eax,180
		@@:
		.if eax!=0
			mov Wwd,eax
		.endif
		mov eax,Rct1.bottom
		sub eax,Rct1.top
		jnl @f
		mov eax,380
		@@:
		.if eax!=0
			mov Wht,eax
		.endif
	;.elseif uMsg==WM_MOVE
		;call IsGlue
;	.elseif uMsg==WM_MOUSEMOVE
;		invoke ShowWindow,hToolTip,SW_HIDE
	.elseif uMsg==WM_MOUSEWHEEL	
		invoke GetCursorPos,addr curPos
		;invoke SendMessage,hTBR1,TBM_GETCHANNELRECT,0,addr RctTBR
		;invoke ScreenToClient,hTBR1,addr curPos
		invoke GetWindowRect,hTBR2,addr loc_RctTBR2
		mov eax,curPos.x
		mov edx,curPos.y
		.if eax>loc_RctTBR2.left && eax<loc_RctTBR2.right && edx>loc_RctTBR2.top && edx<loc_RctTBR2.bottom
			mov eax,wParam
			shr eax,16
			cmp ax,0
			jl BackRotate
			
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			add eax,1000
			.if eax>65535
				mov eax,65534
			.endif
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			jmp @f
			BackRotate:
			invoke GetMasterVolume
			.if eax == MIXER_ERROR || eax<0
				jmp @f
			.endif
			sub eax,1000
			cmp eax,0
			jnl @@f
			mov eax,0
			@@f:
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			@@:
		.else
			invoke SendMessage, hList , WM_MOUSEWHEEL ,wParam,lParam
			;invoke DefWindowProc, hWin, uMsg, wParam,lParam
			ret
		.endif
	.elseif uMsg==WM_ACTIVATEAPP
		.if wParam==1
			invoke SetForegroundWindow,hWnd
			invoke SetFocus,hPL
		.endif
 	.elseif uMsg==WM_DESTROY
		invoke ShowWindow,hPL,SW_HIDE
		mov IsPLVisible,0
		mov fGlue,0
		mov fGlueL,0
		mov fGlueR,0
		mov fGlueB,0
		;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	.elseif eax==WM_APPCOMMAND
	int 3 ; не работают мультимедийные кнопки в плэйлисте
		mov eax,lParam
		shr eax,16
		.if ax==APPCOMMAND_MEDIA_NEXTTRACK
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN5, NULL
		.elseif ax==APPCOMMAND_MEDIA_PLAY_PAUSE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif ax==APPCOMMAND_MEDIA_PREVIOUSTRACK
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN6, NULL
		.elseif ax==APPCOMMAND_MEDIA_STOP
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN3, NULL
		.elseif ax==APPCOMMAND_VOLUME_DOWN
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			sub eax,1000
			cmp eax,0
			jnl @@ff11
			mov eax,0
			@@ff11:
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			@@:
		.elseif ax==APPCOMMAND_VOLUME_MUTE
			.if fMute==0
				invoke GetMasterVolume
				.if eax == MIXER_ERROR
					jmp @f
				.endif
				mov volumeForMute,eax
				invoke SetMasterVolume,NULL
				mov fMute,1
				@@:
			.else
				invoke SetMasterVolume,volumeForMute
				mov fMute,0
			.endif
		.elseif ax==APPCOMMAND_VOLUME_UP
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			add eax,1000
			.if eax>65534
				mov eax,65534
			.endif
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			@@:
		.else
			invoke DefWindowProc,hWin,uMsg,wParam,lParam
			ret
		.endif
		mov eax,TRUE
		ret
		;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		
	.elseif uMsg==WM_CLOSE
		invoke ShowWindow,hPL,SW_HIDE
		mov IsPLVisible,0
		mov fGlue,0
		mov fGlueL,0	
		mov fGlueR,0
		mov fGlueB,0
	.else
		invoke DefWindowProc, hWin, uMsg, wParam,lParam
		ret
	.endif
	xor    eax,eax
 	ret
 WndProc3 endp
 
WndListProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL    lvi:LV_ITEM
LOCAL WndListProcBuffer [512]:BYTE
LOCAL loc_RctTBR2:RECT
LOCAL lPointToolTip:POINT
LOCAL lItemSelected:DWORD
LOCAL lItemCount:DWORD
LOCAL lBufferVolumeBmp [32]:BYTE

	mov eax,uMsg
	.if eax==WM_KEYDOWN 
		;int 3
		mov eax,wParam
		.if eax==VK_DELETE
			invoke SendMessage,hPL,WM_COMMAND,IDM_Del,NULL
		.elseif eax==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif eax==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif eax==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.elseif eax==VK_UP
			.if PLSelected>0
				mov	lvi.state,0
				mov	lvi.stateMask,LVIS_SELECTED or LVIS_FOCUSED
				invoke	SendMessage,hList,LVM_SETITEMSTATE,-1,addr lvi
				dec PLSelected
				invoke InvalidateRect,hPL,0,TRUE
				invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLSelected,FALSE
			.endif
		.elseif eax==VK_DOWN
			invoke     SendMessage, hList, LVM_GETITEMCOUNT,0,0
			dec eax 
			.if PLSelected<eax
				mov	lvi.state,0
				mov	lvi.stateMask,LVIS_SELECTED or LVIS_FOCUSED
				invoke	SendMessage,hList,LVM_SETITEMSTATE,-1,addr lvi
				inc PLSelected
				invoke InvalidateRect,hPL,0,TRUE
				invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLSelected,FALSE
			.endif
		.elseif eax==VK_HOME
			invoke SendMessage,hList,WM_VSCROLL,SB_TOP,0
		.elseif eax==VK_END
			invoke SendMessage,hList,WM_VSCROLL,SB_BOTTOM,0
		.elseif eax==21h 	;VK_PGUP
			invoke SendMessage,hList,WM_VSCROLL,SB_PAGEUP,0
		.elseif eax==22h	;VK_PGDN
			invoke SendMessage,hList,WM_VSCROLL,SB_PAGEDOWN,0
		.else
			invoke HotButtonsProc,wParam,hPL
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif eax==WM_CHAR	;in order to disable default search in listview
		
	.elseif eax==WM_DROPFILES
		invoke  DragQueryFile, wParam, 0, addr WndListProcBuffer, 512 
		invoke FilterProc,addr WndListProcBuffer
		.if eax==MEDIA_TYPE || eax==MPL_TYPE || eax==AUDIO_TYPE
			invoke LoadPL,addr WndListProcBuffer,hList,1
		.else
			invoke MessageBox,0,addr szInvalidFile,addr AppName,MB_OK
		.endif
	.elseif eax==WM_MOUSEWHEEL		
		invoke GetCursorPos,addr curPos
		;invoke SendMessage,hTBR1,TBM_GETCHANNELRECT,0,addr RctTBR
		;invoke ScreenToClient,hTBR1,addr curPos
		invoke GetWindowRect,hTBR2,addr loc_RctTBR2
		mov eax,curPos.x
		mov edx,curPos.y
		.if eax>loc_RctTBR2.left && eax<loc_RctTBR2.right && edx>loc_RctTBR2.top && edx<loc_RctTBR2.bottom
			mov eax,wParam
			shr eax,16
			cmp ax,0
			jl BackRotate
			invoke GetMasterVolume
			.if eax == MIXER_ERROR
				jmp @f
			.endif
			add eax,1000
			.if eax>65535
				mov eax,65534
			.endif
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_GETPOS,0,0
			mov edx,eax
			invoke dw2a,edx,addr lBufferVolumeBmp
			invoke BlendText,addr lBufferVolumeBmp,18,addr szFontName
			jmp @f
			BackRotate:
			invoke GetMasterVolume
			.if eax == MIXER_ERROR || eax<0
				jmp @f
			.endif
			sub eax,1000
			cmp eax,0
			jnl @@f
			mov eax,0
			@@f:
			push eax
			invoke SetMasterVolume,eax
			pop eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_SETPOS,TRUE,eax
			invoke SendDlgItemMessage,hWnd,IDC_TBR2,TBM_GETPOS,0,0
			mov edx,eax
			invoke dw2a,edx,addr lBufferVolumeBmp
			invoke BlendText,addr lBufferVolumeBmp,18,addr szFontName
			@@:
		.else
			invoke  CallWindowProc, WndListOldProc, hWin, uMsg, wParam, lParam
			ret
		.endif
	.elseif eax==WM_MOUSELEAVE
		.if fToolTipVisible==1
			invoke ShowWindow,hToolTip,SW_HIDE
			mov fToolTipVisible,0
		.endif
	.elseif eax==WM_MOUSEMOVE
		.if fToolTipVisible==1 && fHoverBusy==0
			invoke CreateThread,0,0,addr HoverPL,0,0,0
			invoke CloseHandle,eax
		.endif
		invoke  CallWindowProc, WndListOldProc, hWin, uMsg, wParam, lParam
		ret
	.elseif eax==WM_LBUTTONDOWN
		mov PLSelected,-1
		invoke InvalidateRect,hPL,0,TRUE
		jmp @f
	.elseif eax==WM_RBUTTONDOWN
		mov PLSelected,-1
		invoke InvalidateRect,hPL,0,TRUE
		jmp @f
	.else
		@@:
		invoke  CallWindowProc, WndListOldProc, hWin, uMsg, wParam, lParam
		ret
	.endif
	xor eax,eax
	ret

WndListProc endp
GlueMain proc lParam:DWORD
LOCAL rs2:RECT
LOCAL ro2:RECT
LOCAL PLw:DWORD
LOCAL PLh:DWORD
 
	invoke IsWindowVisible,hPL
	.if eax==0
		mov fGlue,0
 	.endif

 	invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr rs2,0
 		
 	mov edi,lParam
	mov eax,[edi+4]
	mov eax,[edi+8]		;указатель на координату левой стороны
	mov ro2.left,eax
	mov ro2.right,eax
	mov eax,[edi+12]		;указатель на координату верха
	mov ro2.top,eax
	mov ro2.bottom,eax
	mov eax,[edi+16]		;указатель ширина
	;mov [edi+16],eax
	add ro2.right,eax
	mov eax,[edi+20]		;указатель высота
	;mov [edi+20],eax
	add ro2.bottom,eax
	
	mov eax,Rct1.right
	sub eax,Rct1.left
	mov PLw,eax
	mov eax,Rct1.bottom
	sub eax,Rct1.top	
	mov PLh,eax
	
	mov eax,rs2.left		;check left
	.if fGlueL==1 && fGlue==1
		mov ebx,PLw
		sub ro2.left,ebx
	.endif
	sub eax,ro2.left
	jnl @f
	neg eax
	@@:
	.if eax<15
		cmp eax,0
		je @f
		mov eax,rs2.left
		.if fGlueL==1 && fGlue==1
			add eax,PLw
		.endif
		mov [edi+8],eax
		.if fGlueR==1 && fGlue==1
			add eax,[edi+16]
			invoke MoveWindow,hPL,eax,ro2.top,PLw,PLh,TRUE
		.elseif fGlueB==1 && fGlue==1
			invoke MoveWindow,hPL,eax,ro2.bottom,PLw,PLh,TRUE
		.endif	
		@@:
	.endif
	mov eax,rs2.bottom		;check bottom
	.if fGlueB==1 && fGlue==1
		mov ebx,PLh
		add ro2.bottom,ebx
	.endif
	sub eax,ro2.bottom
	jnl @f
	neg eax
	@@:
	.if eax<15
		mov eax,rs2.bottom
		sub eax,[edi+20]
		.if fGlueB==1 && fGlue==1
			sub eax,PLh
		.endif
		mov [edi+12],eax
		.if fGlueR==1 && fGlue==1
			invoke MoveWindow,hPL,ro2.right,eax,PLw,PLh,TRUE
		.elseif fGlueL==1 && fGlue==1
			invoke MoveWindow,hPL,ro2.left,eax,PLw,PLh,TRUE
		.endif
	.endif
	mov eax,rs2.right		;check right
	.if fGlueR==1 && fGlue==1
		mov ebx,PLw
		add ro2.right,ebx
	.endif	
	sub eax,ro2.right
	jnl @f
	neg eax
	@@:
	.if eax<15
		mov eax,rs2.right
		sub eax,[edi+16]
		.if fGlueR==1 && fGlue==1
			sub eax,PLw
		.endif
		mov [edi+8],eax
		.if fGlueL==1 && fGlue==1
			sub eax,PLw
			invoke MoveWindow,hPL,eax,ro2.top,PLw,PLh,TRUE
		.elseif fGlueB==1 && fGlue==1
			mov ebx,PLh
			sub ro2.bottom,ebx
			invoke MoveWindow,hPL,eax,ro2.bottom,PLw,PLh,TRUE
		.endif
	.endif
	mov eax,rs2.top		;check top
	sub eax,ro2.top
	jnl @f
	neg eax
	@@:
	.if eax<15
		cmp eax,0
		je @f
		mov eax,rs2.top
		mov [edi+12],eax
		.if fGlueL==1 && fGlue==1
			invoke MoveWindow,hPL,ro2.left,eax,PLw,PLh,TRUE
		.elseif	fGlueR==1 && fGlue==1
			mov ebx,PLw
			sub ro2.right,ebx
			invoke MoveWindow,hPL,ro2.right,eax,PLw,PLh,TRUE
		.elseif fGlueB==1 && fGlue==1
			mov ebx,[edi+20]
			add ro2.top,ebx
			invoke MoveWindow,hPL,ro2.left,ro2.top,PLw,PLh,TRUE
		.endif
	@@:
	.endif
 	ret
GlueMain endp
IsGlue proc
LOCAL ro1:RECT
LOCAL rs1:RECT
	mov fGlue,0
	invoke GetWindowRect,hWnd,addr rs1
	invoke GetWindowRect,hPL,addr ro1

	mov eax,ro1.left	;check right
	sub eax,rs1.right
	jnl @f
	neg eax
	@@:
	.if eax<=30
		mov ebx,rs1.top
		mov edx,rs1.bottom
		.if ro1.top>=ebx && ro1.top<=edx
			mov fGlueR,1
			mov fGlueL,0
			mov fGlueB,0
			mov fGlue,1
			mov StartGlue,2
		.endif
	.endif
	mov eax,ro1.right		;check left
	sub eax,rs1.left
	jnl @f
	neg eax
	@@:
	.if eax<=30
		mov ebx,rs1.top
		mov edx,rs1.bottom
		.if ro1.top>=ebx && ro1.top<=edx
			mov fGlueL,1
			mov fGlueR,0
			mov fGlueB,0
			mov fGlue,1
			mov StartGlue,1
		.endif
	.endif
	mov eax,ro1.top		;check bottom
	sub eax,rs1.bottom
	jnl @f
	neg eax
	@@:
	.if eax<=30
		mov ebx,rs1.left
		mov edx,rs1.right
		.if ro1.left>=ebx && ro1.left<=edx
			mov fGlueB,1
			mov fGlueR,0
			mov fGlueL,0
			mov fGlue,1
			mov StartGlue,3
		.endif
	.endif
 	ret
 	ExitProc:
 	mov fGlueB,0
	mov fGlueR,0
	mov fGlueL,0
	mov fGlue,0
	mov StartGlue,0
	ret
IsGlue endp
dw2a proc dwValue:DWORD, lpBuffer:DWORD

        
    ; -------------------------------------------------------------
    ; convert DWORD to ascii string

    ; dwValue is value to be converted
    ; lpBuffer is the address of the receiving buffer
    ; EXAMPLE:
    ; invoke dwtoa,edx,ADDR buffer
    ;
    ; Uses: eax, ecx, edx.
    ; -------------------------------------------------------------

    push ebx
    push esi
    push edi

    mov eax, dwValue
    mov edi, [lpBuffer]

    or eax,eax
    jnz sign
    
  zero:
    mov word ptr [edi],30h
    jmp dw2asc
    
  sign:
    jns pos
    mov byte ptr [edi],'-'
    neg eax
    inc edi

  pos:      
    mov ecx,429496730
    mov esi, edi

    .while (eax > 0)
      mov ebx,eax
      mul ecx
      mov eax,edx
      lea edx,[edx*4+edx]
      add edx,edx
      sub ebx,edx
      add bl,'0'
      mov [edi],bl
      inc edi
    .endw

    mov byte ptr [edi], 0       ; terminate the string

    ; We now have all the digits, but in reverse order.

    .while (esi < edi)
      dec edi
      mov al, [esi]
      mov ah, [edi]
      mov [edi], al
      mov [esi], ah
      inc esi
    .endw

    dw2asc:

    pop edi
    pop esi
    pop ebx

    ret

dw2a endp
StopTimer proc

	.if hTimer!=0
		invoke KillTimer,hWnd,hTimer
		mov hTimer,0
		.data
			szStopTimer	db "StopTimer: Timer was stopped",0
		.code 
		invoke WriteLogFile,addr szStopTimer
	.endif
	ret
StopTimer endp
DestroyBitmaps proc
	
	.if hOpenBtnBmp!=0
		invoke DeleteObject,hOpenBtnBmp
		mov hOpenBtnBmp,0
	.endif
	.if hPlayBtnBmp!=0
		invoke DeleteObject,hPlayBtnBmp
		mov hPlayBtnBmp,0
	.endif
	.if hStopBtnBmp!=0
		invoke DeleteObject,hStopBtnBmp
		mov hStopBtnBmp,0
	.endif
	.if hPrevBtnBmp!=0
		invoke DeleteObject,hPrevBtnBmp
		mov hPrevBtnBmp,0
	.endif
	.if hPlBtnBmp!=0
		invoke DeleteObject,hPlBtnBmp
		mov hPlBtnBmp,0
	.endif
	.if hNextBtnBmp!=0
		invoke DeleteObject,hNextBtnBmp
		mov hNextBtnBmp,0
	.endif
	.if hPauseBtnBmp!=0
		invoke DeleteObject,hPauseBtnBmp
		mov hPauseBtnBmp,0
	.endif
	.if hOpenBtnEmbossBmp!=0
		invoke DeleteObject,hOpenBtnEmbossBmp
		mov hOpenBtnEmbossBmp,0
	.endif
	.if hNextBtnEmbossBmp!=0
		invoke DeleteObject,hNextBtnEmbossBmp
		mov hNextBtnEmbossBmp,0
	.endif
	.if hPlayBtnEmbossBmp!=0
		invoke DeleteObject,hPlayBtnEmbossBmp
		mov hPlayBtnEmbossBmp,0
	.endif
	.if hStopBtnEmbossBmp!=0
		invoke DeleteObject,hStopBtnEmbossBmp
		mov hStopBtnEmbossBmp,0
	.endif
	.if hPlBtnEmbossBmp!=0
		invoke DeleteObject,hPlBtnEmbossBmp
		mov hPlBtnEmbossBmp,0
	.endif
	.if hPrevBtnEmbossBmp!=0
		invoke DeleteObject,hPrevBtnEmbossBmp
		mov hPrevBtnEmbossBmp,0
	.endif
	.if hPauseBtnEmbossBmp!=0
		invoke DeleteObject,hPauseBtnEmbossBmp
		mov hPauseBtnEmbossBmp,0
	.endif
	
	ret
DestroyBitmaps endp
TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    mov eax, sDim
ret
TopXY endp
CmdLineProc proc CmdLine:DWORD
LOCAL CmdLen:DWORD


	.data
		szCmdLineProc	db "CmdLineProc: start",0
	.code 
  	invoke WriteLogFile,addr szCmdLineProc
  	
	.if fCallCmdProcFromWaitEvent==1
		invoke lstrcpy,addr _CmdLine,CmdLine
		invoke SetTimer,hWnd,IDC_TIMER2,100,NULL
		mov hTimer2,eax
		.data
			szCmdLineProc01	db "CmdLineProc: was called from WaitEvent",0
		.code 
  		invoke WriteLogFile,addr szCmdLineProc01
		ret
	.endif  	
	
	;invoke MessageBox,0,CmdLine,addr AppName,MB_OK
	invoke lstrlen,CmdLine
	mov CmdLen,eax

	mov edi,CmdLine
	add edi,eax
	std
	mov ecx,eax
	mov al,'"'
	repne scasb
	inc edi
	cld
	mov al,0
	stosb
	mov ecx,CmdLen
 	mov al,'"'
	std
	repne scasb 
	cld
	inc edi
	inc edi
	push edi
	invoke FilterProc,edi
	mov edx,eax
	pop edi
	.if edx==MPL_TYPE
		.if fRun!=0
			invoke AVIStop
		.endif
		.if IsPLVisible==1
			invoke LoadPL,edi,hList,0
		.elseif IsPLVisible==0 && fCreatePL==1
			invoke ShowWindow,hPL,SW_SHOW
			mov IsPLVisible,1
			invoke LoadPL,edi,hList,0
		.elseif IsPLVisible==0 && fCreatePL==0
			invoke CreatePlayList
			invoke LoadPL,edi,hList,0
		.endif
	.elseif edx==MEDIA_TYPE || edx==AUDIO_TYPE
		;int 3
		push edi
		.if fRun!=0
			invoke AVIStop
		.endif
		invoke LoadPL,edi,hList,0
		pop edi
		push PLFocus
		pop PrevFile
		mov PLFocus,eax
		invoke InvalidateRect,hPL,0,TRUE
		
	.endif
	
	.if fWaitEventActive==0
		invoke CreateThread,0,0,addr WaitEvent,0,0,0
		invoke CloseHandle,eax
	.endif
	
	.data
		szCmdLineProc1	db "CmdLineProc: end",0
	.code 
  	invoke WriteLogFile,addr szCmdLineProc1
  	
	ret

CmdLineProc endp

LoadPL proc PathPL:DWORD  ,hListView:DWORD,fNoPlayFile:DWORD
LOCAL	count :DWORD
LOCAL count2:DWORD
LOCAL Buf_count [32]:BYTE
LOCAL Buf_count2 [32]:BYTE
LOCAL Buffer [1024]:BYTE
LOCAL Buffer2 [512]:BYTE
LOCAL lFileSize:DWORD
LOCAL hlFile:DWORD
LOCAL hlMFile:DWORD
LOCAL hlMVFile:DWORD
LOCAL CurrentPos:DWORD
LOCAL NumberString:DWORD
LOCAL lvi:LV_ITEM
LOCAL PathSize:DWORD
LOCAL lPrioritet:DWORD


	.data
		szLoadPL	db "LoadPL: start",0
	.code 
  	invoke WriteLogFile,addr szLoadPL
  	
  	
 	invoke lstrlen, PathPL
 	mov PathSize,eax
 	mov edi,PathPL
 	add edi,eax
 	mov ecx,eax
 	mov al,'.'
	std
	repne scasb 
	cld
	inc edi
 	invoke lstrcmpi,edi,addr szMpl
 	je @f
 	
 	mov edi,PathPL
 	add edi,PathSize
 	mov ecx,PathSize
 	mov al,'\'
 	std
 	repne scasb
 	cld
 	inc edi
 	inc edi
 	
 	invoke lstrcpy,addr Buffer2,edi
 	invoke lstrcpy,addr Buffer,PathPL
 	invoke SendMessage, hListView, LVM_GETITEMCOUNT,0,0
 	;mov PLFocus,eax
 	
 	.if eax==0
		mov edx,1
	.else
		mov edx,eax
		inc edx
 	.endif
 	mov NumberString,eax
 	invoke dw2a,edx,addr Buf_count2
 	;int 3
	;invoke AddStr,addr Buf_count2,addr Buffer2,addr Buffer,NumberString,hListView
	mov lPrioritet,1
   	invoke AddStr,addr Buf_count2,addr Buffer2,addr Buffer,addr lPrioritet, NumberString,hListView   		
	;int 3
	invoke AddStrVPL,hVPL,NumberString
	
	.if fNoPlayFile==0
		invoke AVIPlay3,NumberString
	.endif
	invoke SendMessage, hList, LVM_ENSUREVISIBLE,NumberString,FALSE	
	invoke InvalidateRect,hPL,0,TRUE
	mov eax,NumberString
	.data
		szLoadPL1	db "LoadPL: end",0
	.code 
  	invoke WriteLogFile,addr szLoadPL1
  	
 	ret
 	@@:
 	invoke SendMessage, hListView, LVM_DELETEALLITEMS,0,0
 	invoke ClearVPL,hVPL
 	invoke ClearVPL,hVPL2
 	invoke ClearVPL,hVPL3
 	invoke CreateFile,PathPL,GENERIC_READ or GENERIC_WRITE, \
	FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_EXISTING,NULL,NULL
	.if eax==INVALID_HANDLE_VALUE 
		;invoke MessageBox, NULL, ADDR InvalidPL, ADDR AppName, MB_OK
		mov fFirstLoad,0
		.data
			szLoadPL11	db "LoadPL: error with opening PL",0
		.code 
		invoke WriteLogFile,addr szLoadPL11
		ret
	.endif 
	mov hlFile,eax
	invoke GetFileSize,hlFile,NULL
	.if eax==0
		invoke MessageBox,0,addr InvalidPL,addr AppName,MB_OK
		jmp closeFile
	.endif
	mov lFileSize,eax
	invoke CreateFileMapping,hlFile,NULL,PAGE_READWRITE,0,lFileSize,NULL
	.IF eax==NULL
		invoke MessageBox, NULL, ADDR InvalidPL, ADDR AppName, MB_OK
		jmp closeFile
	.ENDIF
	mov hlMFile,eax
	invoke MapViewOfFile,hlMFile,FILE_MAP_WRITE,0,0,0
	.IF eax==NULL
		invoke MessageBox, NULL, ADDR InvalidPL, ADDR AppName, MB_OK
		jmp closeMapFile
	.ENDIF
	mov hlMVFile,eax
	
	push hlMVFile
	pop CurrentPos
	xor eax,eax
	mov count,eax
	mov count2,eax
	lea edi,Buf_count
	stosd
	
	mov NumberString,-1
	cld
	
	Repeate:
	mov edi,CurrentPos
	mov ecx,lFileSize
	sub ecx,edi
	mov al,0Ah
	repne scasb
	jne Quit
	push edi
	;------------------
	push edi
	sub edi,6
	mov eax,[edi]
	.if eax>3
		mov eax,1
	.endif
	mov dword ptr lPrioritet,eax 
	pop edi
	;------------------
	sub edi,CurrentPos
	mov ecx,edi
	add count2,edi
	dec ecx
	dec ecx
	mov esi,CurrentPos
	lea edi,Buffer
	rep movsb
	mov al,0
	stosb
	pop edi
	mov CurrentPos,edi
	inc count
   	inc NumberString
    invoke dw2a, count,addr Buf_count
   	invoke lstrlen,addr Buffer
   	lea edi,Buffer
   	add edi,eax
   	mov ecx,eax
   	std
   	mov al,'\'
   	repne scasb
   	inc edi
   	inc edi
   	cld
   	invoke lstrcpy,addr Buffer2,edi
   	;invoke AddStr,addr Buf_count,addr Buffer2,addr Buffer, NumberString,hListView

   	invoke AddStr,addr Buf_count,addr Buffer2,addr Buffer,addr lPrioritet, NumberString,hListView
	.if lPrioritet==1
		invoke AddStrVPL,hVPL,NumberString
	.elseif lPrioritet==2
		invoke AddStrVPL,hVPL2,NumberString
	.elseif lPrioritet==3
		invoke AddStrVPL,hVPL3,NumberString
	.endif
   	mov eax,count2
	cmp lFileSize,eax
	jle @f
	jmp Repeate
	@@:
	.if fFirstLoad==1
		mov fFirstLoad,0
		jmp Quit
	.endif
;    mov     lvi.iItem, 0
;	mov     lvi.iSubItem, 0
;	mov     lvi.imask, LVIF_TEXT
;	lea     eax, Buffer
;	mov     lvi.pszText, eax
;	mov     lvi.cchTextMax, 512
;	inc lvi.iSubItem
;	inc lvi.iSubItem
;	invoke     SendMessage, hListView, LVM_GETITEM, 0, addr lvi

	.if fRun==1
		invoke AVIStop
	.endif
	.if fRandomPlay==1
		invoke RandomPlay,hListView
		mov PLFocus,eax
	.else
		mov PLFocus,0
	.endif
	.if fNoScrollPL==0
		invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLFocus,FALSE	
	.endif
	mov PLSelected,-1
	invoke AVIPlay3,PLFocus

	Quit:
	invoke UnmapViewOfFile, hlMVFile    
   	closeMapFile: 
	invoke CloseHandle,hlMFile
	closeFile:
	invoke CloseHandle,hlFile
	
	invoke InvalidateRect,hPL,0,TRUE
	
	.data
		szLoadPL2	db "LoadPL: end",0
	.code 
  	invoke WriteLogFile,addr szLoadPL2
  	
	ret	
LoadPL endp

AddStr proc Text_Column1:DWORD,Text_Column2:DWORD,Text_Column3:DWORD,Text_Column4:DWORD,NumberOfString:DWORD,ahListVeiw:DWORD
LOCAL    lvi:LV_ITEM

	mov lvi.imask, LVIF_TEXT or LVIF_PARAM;or LVIF_IMAGE 
	push NumberOfString
	pop lvi.iItem
	mov lvi.iSubItem,0
	mov eax,Text_Column1
	mov lvi.pszText, eax
	push NumberOfString
	pop lvi.lParam
	invoke     SendMessage, ahListVeiw, LVM_INSERTITEM,0, addr lvi

	mov lvi.imask,LVIF_TEXT
	inc lvi.iSubItem
	mov edx,Text_Column2
	mov lvi.pszText,edx
	;INVOKE     MessageBox, NULL, Text_Column2, addr AppName, MB_OK
	invoke     SendMessage, ahListVeiw, LVM_SETITEM, 0, addr lvi
	
	mov lvi.imask,LVIF_TEXT 
	inc lvi.iSubItem
	mov edx,Text_Column3		;pathname
	mov lvi.pszText,edx
	invoke     SendMessage, ahListVeiw, LVM_SETITEM, 0, addr lvi
	
	mov lvi.imask,LVIF_TEXT 
	inc lvi.iSubItem
	mov edx,Text_Column4		;prioritet
	mov lvi.pszText,edx
	invoke     SendMessage, ahListVeiw, LVM_SETITEM, 0, addr lvi
	
	
	invoke lstrlen,Text_Column1
	.if eax==0 || eax==1
		;mov eax,10
		invoke     SendMessage, ahListVeiw, LVM_SETCOLUMNWIDTH, 0,10
	.elseif eax==2
		;mov eax,20
		invoke     SendMessage, ahListVeiw, LVM_SETCOLUMNWIDTH, 0,20
	.elseif eax==3
		;mov eax,30
		invoke     SendMessage, ahListVeiw, LVM_SETCOLUMNWIDTH, 0,30
	.elseif eax==4
		;mov eax,40
		invoke     SendMessage, ahListVeiw, LVM_SETCOLUMNWIDTH, 0,40
	.else
		;mov eax,70
		invoke     SendMessage, ahListVeiw, LVM_SETCOLUMNWIDTH, 0,70
	.endif
	ret
AddStr endp

FillFirstColumn proc fhListView:DWORD
LOCAL    lvi:LV_ITEM
LOCAL count:DWORD
LOCAL count2 [32]:BYTE
LOCAL NumberOfString:DWORD
LOCAL ItemCount:DWORD
 
  	
	invoke     SendMessage, fhListView, LVM_GETITEMCOUNT,0,0
	.if eax==0
		mov eax,-1
		ret
	.endif
	mov ItemCount,eax
	mov NumberOfString,0
	mov count,1
 	mov     lvi.imask, LVIF_TEXT or LVIF_PARAM;or LVIF_IMAGE 
 	mov     lvi.iSubItem,0
 	@@:
	push  NumberOfString
	pop lvi.iItem
	mov edx,count
	invoke dw2a,edx,addr count2
	lea eax,count2
	mov     lvi.pszText, eax
	push  NumberOfString
	pop lvi.lParam
	invoke     SendMessage, fhListView, LVM_SETITEM,0, addr lvi
	mov eax,NumberOfString
	cmp eax,ItemCount
	je @f
	inc count
	inc NumberOfString
	jmp @b
	@@:
	invoke lstrlen,addr count2
	.if eax==0 || eax==1
		;mov eax,10
		invoke     SendMessage, fhListView, LVM_SETCOLUMNWIDTH, 0,10
	.elseif eax==2

		;mov eax,20
		invoke     SendMessage, fhListView, LVM_SETCOLUMNWIDTH, 0,20
	.elseif eax==3
		;mov eax,30
		invoke     SendMessage, fhListView, LVM_SETCOLUMNWIDTH, 0,30
	.elseif eax==4
		;mov eax,40
		invoke     SendMessage, fhListView, LVM_SETCOLUMNWIDTH, 0,40
	.else
		;mov eax,70
		invoke     SendMessage, fhListView, LVM_SETCOLUMNWIDTH, 0,70
	.endif
	

	ret

FillFirstColumn endp
IniProc proc w_r:DWORD
LOCAL wpos  :DWORD
LOCAL Rct:RECT
LOCAL hFile:DWORD
LOCAL hMFile:DWORD
LOCAL hMVFile:DWORD
LOCAL FileSize:DWORD
LOCAL szCurrentDir2 [512]:BYTE

	.data
		szIniProc	db "IniProc: start",0
	.code 
  	invoke WriteLogFile,addr szIniProc
  	
  	
	invoke lstrcpy,addr szCurrentDir2,addr szCurrentDir
	invoke lstrlen,addr szCurrentDir2
	lea edi,szCurrentDir2
	add edi,eax
	mov ecx,eax
	mov al,'\'
	std 
	repne scasb
	cld
	inc edi
	inc edi
	lea esi,IniFileName
	mov ecx,13
	rep movsb
	mov al,0
	stosb
	invoke CreateFile,ADDR szCurrentDir2,GENERIC_READ or GENERIC_WRITE, \
	FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,NULL,NULL
	.if eax==INVALID_HANDLE_VALUE 
		invoke MessageBox, NULL, ADDR NotOpenIni, ADDR AppName, MB_OK
		.data
			szIniProc1	db "IniProc: error",0
		.code 
		invoke WriteLogFile,addr szIniProc1
		ret
	.endif 
	mov hFile,eax
	invoke GetFileSize,hFile,NULL
	.if eax<120
		mov eax,120
	.endif
	mov FileSize,eax
	invoke CreateFileMapping,hFile,NULL,PAGE_READWRITE,0,FileSize,NULL
	.if eax==NULL
		invoke MessageBox, NULL, ADDR NotOpenIni, ADDR AppName, MB_OK
		jmp closeFile
	.endif
	mov hMFile,eax
	invoke MapViewOfFile,hMFile,FILE_MAP_WRITE,0,0,0
	.if eax==NULL
		invoke MessageBox, NULL, ADDR NotOpenIni, ADDR AppName, MB_OK
		jmp closeMapFile
	.endif
	mov hMVFile,eax

	.if w_r==toWrite
		call IsGlue
		.if fGlue==0
			mov StartGlue,0
		.endif
		mov edi,hMVFile
		mov eax,Wwd
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,Wht
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,StartGlue
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,IsPLVisible
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,Wwd_MainWindow
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,Wht_MainWindow
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		
		add edi,2
		mov eax,Wtx_MainWindow
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,Wty_MainWindow
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,fChangeWindowSize
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,fSaveVideoRatio
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,fNoScrollCaption
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,fRandomPlay
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,fNoScrollPL
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,fHideVideo
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,WheelFunc
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		mov eax,fTray
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		
		mov eax,fSilver
		mov [edi],eax
		add edi,4
		mov ax,endStr
		mov word ptr [edi],ax
		add edi,2
		
		.data
			szIniProc2	db "IniProc: ini was written",0
		.code 
		invoke WriteLogFile,addr szIniProc2
		
	.elseif w_r==toRead
		mov esi,hMVFile
		mov eax,[esi]
		mov Wwd,eax
		add esi,6
		mov eax,[esi]
		mov Wht,eax
		add esi,6
		mov eax,[esi]
		mov StartGlue,eax
		add esi,6
		mov eax,[esi]
		mov IsPLVisible,eax
		add esi,6
		mov eax,[esi]
		mov Wwd_MainWindow,eax
		add esi,6
		mov eax,[esi]
		mov Wht_MainWindow,eax
		add esi,6
		mov eax,[esi]
		mov Wtx_MainWindow,eax
		add esi,6
		mov eax,[esi]
		mov Wty_MainWindow,eax
		add esi,6
		mov eax,[esi]
		mov fChangeWindowSize,eax
		add esi,6
		mov eax,[esi]
		mov fSaveVideoRatio,eax
		add esi,6
		mov eax,[esi]
		mov fNoScrollCaption,eax
		add esi,6
		mov eax,[esi]
		mov fRandomPlay,eax
		add esi,6
		mov eax,[esi]
		mov fNoScrollPL,eax
		add esi,6
		mov eax,[esi]
		mov fHideVideo,eax
		add esi,6
		mov eax,[esi]
		mov WheelFunc,eax
		add esi,6
		mov eax,[esi]
		mov fTray,eax
		
		add esi,6
		mov eax,[esi]
		mov fSilver,eax
		
		.data
			szIniProc3	db "IniProc: ini was read",0
		.code 
		invoke WriteLogFile,addr szIniProc3
		
   	.endif
   	
   	invoke UnmapViewOfFile, hMVFile    
   	closeMapFile: 
	invoke CloseHandle,hMFile
	closeFile:
	invoke CloseHandle,hFile
	ret
IniProc endp

AVIPlay2 proc PathName:DWORD

	.data
		szAVIPlay22	db "AVIPlay2 proc start",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay22
	invoke WriteLogFile,PathName
	
	
	lea esi, buf
    mov ecx, 1024
    xor eax, eax
    @@:
    mov dword ptr [esi+ecx*4], eax
    loop @B
	invoke  MultiByteToWideChar, CP_ACP, 0,PathName, -1, addr buf, 1024
	invoke lstrcpy,addr szFileName, PathName
	mov fFileLoad,1
	mov fNoPause,1
	.if fRun==1
		call StopTimer
		call AVIStop
		invoke FilterProc,PathName
		.if eax==AUDIO_TYPE
			mov fAudio,1
			.if fHideVideo==1
				mov fAudioWasPrev,1
				.if fFullScreen==1
					mov fFullScreen,0
					invoke ShowWindow,hScreenFhon,SW_HIDE
				.endif
				mov edx,124
				.if Wht_MainWindow>124
					push Wht_MainWindow
					pop Wht_MainWindowSaved
				.endif
				invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,edx,TRUE
			.endif
		.else
			.if Wht_MainWindowSaved!=0 && fAudioWasPrev==1
				push Wht_MainWindowSaved
				pop Wht_MainWindow
				invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,Wht_MainWindow,TRUE
				mov fAudioWasPrev,0
			.endif
			mov fAudio,0
		.endif
		call AVIPlay
		;invoke SetDlgItemText,hWnd,IDC_BTN2,addr szPause
		invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp
	.else
		call StopTimer
		;invoke SetDlgItemText,hWnd,IDC_BTN2,addr szPause
		invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp
		invoke FilterProc,PathName
		.if eax==AUDIO_TYPE
			mov fAudio,1
			.if fHideVideo==1
				mov fAudioWasPrev,1
				.if fFullScreen==1
					mov fFullScreen,0
					invoke ShowWindow,hScreenFhon,SW_HIDE
				.endif
				mov edx,124
				.if Wht_MainWindow>124
					push Wht_MainWindow
					pop Wht_MainWindowSaved
				.endif
				invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,edx,TRUE
			.endif
		.else
			.if Wht_MainWindowSaved!=0 && fAudioWasPrev==1
				push Wht_MainWindowSaved
				pop Wht_MainWindow
				invoke MoveWindow,hWnd,Wtx_MainWindow,Wty_MainWindow, Wwd_MainWindow,Wht_MainWindow,TRUE
				mov fAudioWasPrev,0
			.endif
			mov fAudio,0
		.endif
		call AVIPlay
	.endif
	
	.data
		szAVIPlay23	db "AVIPlay2 proc end",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay23
  	
  	
	ret

AVIPlay2 endp

SavePL proc hListView:DWORD
LOCAL    lvi:LV_ITEM
LOCAL SavePLBuffer [512]:BYTE
LOCAL countItem:DWORD
LOCAL AllItems:DWORD
;LOCAL SizeString:DWORD	;for _szFileName
LOCAL hsFile:DWORD
LOCAL _BytesWritten:DWORD
LOCAL FilePos:DWORD
LOCAL SizeOfString:DWORD	;for write to pl
LOCAL _FileSize:DWORD
LOCAL lPrioritet [32]:byte

.data
	_lStructSize       dd sizeof(OPENFILENAME)
    _hwndOwner         dd 0
    _hinstance         dd 400000h
    _lpstrFilter       dd OFFSET _Filter
    _lpstrCustomFilter dd 0
    _nMaxCustFilter    dd 0
    _nFilterIndex      dd 0
    _lpstrFile         dd OFFSET _szFileName
    _nMaxFile          dd 260
    _lpstrFileTitle    dd OFFSET _szfilename
    _nMaxFileTitle     dd 250
    _lpstrInitialDir   dd 0
    _lpstrTitle        dd OFFSET _Title
    _Flags             dd OFN_EXPLORER or OFN_LONGNAMES or OFN_OVERWRITEPROMPT
    _nFileOffset       dw 0
    _nFileExtension    dw 0
    _lpstrDefExt       dd 0
    _lCustData         dd 0
    _lpfnHook          dd 0
    _lpTemplateName    dd 0
   _Filter	          db "Playlist (*.mpl)",0,"*.mpl",0,0;
   
   .code

.data
szSavePL	db "SavePL: start",0
.code 
	invoke WriteLogFile,addr szSavePL
	

	invoke lstrcpy,addr _szFileName,addr PLName2
	invoke lstrcpy,addr _szfilename,addr PLName2
	invoke  GetSaveFileName, ADDR _lStructSize
	test    eax, eax
	jz	ExitProc
	invoke lstrlen,addr _szFileName
	;mov SizeString,eax
	lea edi,_szFileName
	add edi,eax
	mov ecx,eax
 	mov al,'.'
	std
	repne scasb 
	cld
	inc edi
	invoke lstrcmpi,edi,addr szMpl
	je @f
	invoke lstrcat,addr _szFileName,addr szMpl
	@@:
	
	invoke CreateFile,addr _szFileName,GENERIC_READ or GENERIC_WRITE, \
	FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,NULL,NULL
	.IF eax==INVALID_HANDLE_VALUE 
		invoke MessageBox, NULL, ADDR szCannotSave, ADDR AppName, MB_OK
		.data
			szSavePL2	db "SavePL: error",0
		.code 
		invoke WriteLogFile,addr szSavePL2
		ret
	.ENDIF 
	mov hsFile,eax
	invoke GetFileSize,hsFile,NULL
	mov _FileSize,eax
	invoke SendMessage, hListView, LVM_GETITEMCOUNT, 0,0
	mov AllItems,eax
	mov countItem,0
	mov FilePos,0
	cmp eax,0
	je Quit
	
	@@:
	mov lvi.iSubItem, 2
	mov lvi.imask, LVIF_TEXT
	lea eax,SavePLBuffer
	mov lvi.pszText, eax
	mov lvi.cchTextMax, 512
	mov eax,countItem
	mov lvi.iItem, eax
	invoke SendMessage, hListView, LVM_GETITEM, 0, addr lvi
	
	
	mov lvi.iSubItem, 3
	mov lvi.imask, LVIF_TEXT
	lea edi,lPrioritet			;prioritet
	mov lvi.pszText, edi
	xor al,al
	mov ecx,32
	rep stosb
	mov lvi.cchTextMax, 32
	mov eax,countItem
	mov lvi.iItem, eax
	invoke SendMessage, hListView, LVM_GETITEM, 0, addr lvi
	;int 3
	;mov edx,dword ptr lPrioritet

	invoke lstrlen,addr SavePLBuffer
	inc eax
	mov SizeOfString,eax
	invoke SetFilePointer,hsFile,FilePos,0,0
	;mov edx,SizeString
	;int 3
	invoke WriteFile, hsFile,addr SavePLBuffer, SizeOfString , addr _BytesWritten, NULL
	mov eax,SizeOfString
	add FilePos,eax
	
	
	invoke SetFilePointer,hsFile,FilePos,0,0
	invoke WriteFile, hsFile,addr lPrioritet,4, addr BytesWritten, NULL
	add FilePos,4
	
	invoke SetFilePointer,hsFile,FilePos,0,0
	invoke WriteFile, hsFile,addr endStr,2, addr BytesWritten, NULL
	add FilePos,2
	inc countItem
	mov eax,AllItems
	cmp countItem,eax
	jae Quit
	jmp @b
	Quit:
	invoke SetFilePointer,hsFile,FilePos,0,0
	invoke SetEndOfFile,hsFile
	invoke CloseHandle,hsFile
	ExitProc:
	.data
		szSavePL1	db "SavePL: end",0
	.code 
	invoke WriteLogFile,addr szSavePL1
	ret
SavePL endp

FilterProc proc PathName:DWORD

.data
szAsf	db	".asf",0
szAvi	db	".avi",0
szDivx	db	".divx",0
szM1v	db	".m1v",0
szM2v	db	".m2v",0
szMkv	db	".mkv",0
szMov	db	".mov",0
szMp4	db	".mp4",0
szMpe	db	".mpe",0
szMpeg	db	".mpeg",0
szMpg	db	".mpg",0
szMpv	db	".mpv",0
szOgm	db	".ogm",0
szQt	db	".qt",0
szRam	db	".ram",0
szRm	db	".rm",0
szRv	db	".rv",0
szVob	db	".vob",0
szWm	db	".wm",0
szWmv	db	".wmv",0
szMp3	db	".mp3",0
szWav	db 	".wav",0
szWma	db	".wma",0
szAc3	db  ".ac3",0
sz3gp	db	".3gp",0
szMidi	db	".midi",0
szKar	db	".kar",0
szIflv	db	".iflv",0
.code

  	
	invoke lstrlen, PathName
 	mov edi,PathName
 	add edi,eax
 	mov ecx,eax
 	mov al,'.'
	std
	repne scasb 
	cld
	inc edi
 	invoke lstrcmpi,edi,addr szMpl
 	je MplIs
 	
 	invoke ForFilterProc,PathName,addr szMp3
 	cmp eax,1
 	je AudioIs
 	invoke ForFilterProc,PathName,addr szWav
 	cmp eax,1
 	je AudioIs
 	invoke ForFilterProc,PathName,addr szWma
 	cmp eax,1
 	je AudioIs
 	invoke ForFilterProc,PathName,addr szAc3
 	cmp eax,1
 	je AudioIs
 	invoke ForFilterProc,PathName,addr szMidi
 	cmp eax,1
 	je AudioIs
 	invoke ForFilterProc,PathName,addr szKar
 	cmp eax,1
 	je AudioIs
 	
 	
 	invoke ForFilterProc,PathName,addr szAsf
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szAvi
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szDivx
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szM1v
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szM2v
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szMkv
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szMov
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szMp4
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szMpe
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szMpeg
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szMpg
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szMpv
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szOgm
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szQt
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szRam
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szRm
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szRv
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szVob
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szWm
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szWmv
 	cmp eax,1
 	je MediaIs 	
 	invoke ForFilterProc,PathName,addr sz3gp
 	cmp eax,1
 	je MediaIs
 	invoke ForFilterProc,PathName,addr szIflv
 	cmp eax,1
 	je MediaIs
 	
 	NoMedia:
 	mov eax,NOT_MEDIA_TYPE
 	jmp ExitProc
 	MediaIs:
 	mov eax,MEDIA_TYPE
 	jmp ExitProc
 	AudioIs:
 	mov eax,AUDIO_TYPE
 	jmp ExitProc
 	MplIs:
 	mov eax,MPL_TYPE
 	
 	ExitProc:
  	
	ret
FilterProc endp
ForFilterProc proc PathName:DWORD,szExtension:DWORD
	
	invoke lstrlen, PathName
 	mov edi,PathName
 	add edi,eax
 	mov ecx,eax
 	mov al,'.'
	std
	repne scasb 
	cld
	inc edi
 	invoke lstrcmpi,edi,szExtension
 	je 	EqualIs
 	xor eax,eax
	ret
	EqualIs:
	mov eax,1
	ret
ForFilterProc endp

FindFiles proc PathName:DWORD;,hList:DWORD
LOCAL wfd:WIN32_FIND_DATA
LOCAL count:DWORD
LOCAL fBuffer [1024]:BYTE
LOCAL fBuffer2 [512]:BYTE
LOCAL BufferForSearch [1024]:BYTE
LOCAL SizeOfString:DWORD
LOCAL lvi:LV_ITEM
LOCAL lPrioritet:DWORD

	.data
		szFindFiles	db "FindFiles: start",0
	.code 
  	invoke WriteLogFile,addr szFindFiles
  	invoke WriteLogFile,PathName
  	
  	 	
  	cmp fExitFindFiles,1
	je Terminate
	
	invoke     SendMessage, hList, LVM_GETITEMCOUNT,0,0
	mov count,eax
	
	invoke lstrcpy,addr fBuffer,PathName
	invoke lstrlen,addr fBuffer
	lea edi,fBuffer
	add edi,eax
	xor eax,eax
	mov esi,edi
	dec esi
	lodsb
	cmp eax,'\'
	je @f
	mov al,'\'
	stosb
	mov al,0
	stosb
	@@:
	invoke lstrcat,addr fBuffer,addr szFileMask

	invoke FindFirstFile,addr fBuffer,addr wfd
	.if eax==INVALID_HANDLE_VALUE
		;invoke MessageBox,0,addr szErrorSearching,addr AppName,MB_OK
		.data
			szFindFiles1	db "FindFiles: error with FindFirstFile",0
		.code 
		invoke WriteLogFile,addr szFindFiles1
		ret
	.endif	
	mov hSearch,eax
	
	Repeate:
	invoke SetWindowText,hPL,addr fBuffer
	lea edi,fBuffer
	mov ecx,1024
	xor eax,eax
	rep stosb
	
	invoke lstrcmpi,addr szPoint,addr wfd.cFileName
	je FindNext
	invoke lstrcmpi,addr sz2Point,addr wfd.cFileName
	je FindNext
	
	invoke lstrcpy,addr fBuffer,PathName
	invoke lstrlen,addr fBuffer
	lea edi,fBuffer
	add edi,eax
	xor eax,eax
	mov esi,edi
	dec esi
	lodsb
	cmp eax,'\'
	je @f
	mov al,'\'
	stosb
	mov al,0
	stosb
	@@:
	invoke lstrcat,addr fBuffer,addr wfd.cFileName
	
	lea esi,wfd.dwFileAttributes
	mov eax,[esi]
	.if ax & FILE_ATTRIBUTE_DIRECTORY
		pushad
		push hSearch
		lea edi,BufferForSearch
		mov ecx,1024
		xor eax,eax
		rep stosb
		invoke lstrcpy,addr BufferForSearch,addr fBuffer
		invoke lstrlen,addr BufferForSearch
		lea edi,BufferForSearch
		add edi,eax
		mov al,'\'
		stosb
		xor al,al
		stosb
		invoke FindFiles,addr BufferForSearch;,hListView
		pop hSearch
		popad
		cmp fExitFindFiles,1
		je Terminate
	.endif
	invoke lstrcpy,addr fBuffer2,addr wfd.cFileName
	;invoke MessageBox,0,addr fBuffer2,addr AppName,MB_OK
	invoke FilterProc,addr fBuffer
	cmp eax,NOT_MEDIA_TYPE
	je FindNext
	cmp eax,MPL_TYPE
	je FindNext
	mov lPrioritet,1
	invoke AddStr,addr count,addr fBuffer2,addr fBuffer,addr lPrioritet,count,hList
	invoke AddStrVPL,hVPL,count
	inc count
	FindNext:
	invoke FindNextFile,hSearch,addr wfd
	cmp fExitFindFiles,1
	je Terminate
	cmp eax,0
	je Quit
	
	jmp Repeate

	Quit:
	invoke FindClose,hSearch
	;.if fExitFindFiles==1
	;	ret
	;.endif
	invoke FillFirstColumn,hList
	invoke SetWindowText,hPL,addr AppName
	.data
		szFindFiles2	db "FindFiles: end",0
	.code 
  	invoke WriteLogFile,addr szFindFiles2
  	
	ret
	Terminate:
	
	;invoke FindClose,hSearch
	.data
		szFindFiles3	db "FindFiles: terminate",0
	.code 
  	invoke WriteLogFile,addr szFindFiles3
  	mov fTerminateFindFiles,0
  	invoke ExitThread, 0
  	
	
	;ExitProc:
	ret
FindFiles endp

WndBTN1Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL TME:TRACKMOUSEEVENT 	
	mov eax,uMsg
	.if eax==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif eax==WM_MOUSEMOVE
		mov TME.cbSize,sizeof TME
		mov TME.dwFlags,TME_LEAVE
		mov eax,hWin
		mov TME.hwndTrack,eax
		invoke TrackMouseEvent,addr TME
		invoke SendMessage,hBTN1,BM_SETIMAGE,0,hOpenBtnEmbossBmp
		
	.elseif eax==WM_MOUSELEAVE
		invoke SendMessage,hBTN1,BM_SETIMAGE,0,hOpenBtnBmp
		
	.else
		invoke CallWindowProc,OldWndBTN1Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndBTN1Proc2 endp
WndBTN2Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL TME:TRACKMOUSEEVENT 

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_MOUSEMOVE
		mov TME.cbSize,sizeof TME
		mov TME.dwFlags,TME_LEAVE
		mov eax,hWin
		mov TME.hwndTrack,eax
		invoke TrackMouseEvent,addr TME
		.if fRun==1 && fPause==0
			invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnEmbossBmp 
		.else
			invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnEmbossBmp
		.endif
	.elseif uMsg==WM_MOUSELEAVE
		.if fRun==1 && fPause==0
			invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPauseBtnBmp 
		.else
			invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
		.endif
	.else
		invoke CallWindowProc,OldWndBTN2Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndBTN2Proc2 endp
WndBTN3Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL TME:TRACKMOUSEEVENT 

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_MOUSEMOVE
		mov TME.cbSize,sizeof TME
		mov TME.dwFlags,TME_LEAVE
		mov eax,hWin
		mov TME.hwndTrack,eax
		invoke TrackMouseEvent,addr TME
		invoke SendMessage,hBTN3,BM_SETIMAGE,0,hStopBtnEmbossBmp
	.elseif uMsg==WM_MOUSELEAVE
		invoke SendMessage,hBTN3,BM_SETIMAGE,0,hStopBtnBmp
	.else
		invoke CallWindowProc,OldWndBTN3Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndBTN3Proc2 endp
WndBTN4Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL TME:TRACKMOUSEEVENT

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_MOUSEMOVE
		mov TME.cbSize,sizeof TME
		mov TME.dwFlags,TME_LEAVE
		mov eax,hWin
		mov TME.hwndTrack,eax
		invoke TrackMouseEvent,addr TME
		invoke SendMessage,hBTN4,BM_SETIMAGE,0,hPlBtnEmbossBmp
	.elseif uMsg==WM_MOUSELEAVE
		invoke SendMessage,hBTN4,BM_SETIMAGE,0,hPlBtnBmp
	.else
		invoke CallWindowProc,OldWndBTN4Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndBTN4Proc2 endp
WndBTN5Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL TME:TRACKMOUSEEVENT 

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_MOUSEMOVE
		mov TME.cbSize,sizeof TME
		mov TME.dwFlags,TME_LEAVE
		mov eax,hWin
		mov TME.hwndTrack,eax
		invoke TrackMouseEvent,addr TME
		invoke SendMessage,hBTN5,BM_SETIMAGE,0,hNextBtnEmbossBmp
	.elseif uMsg==WM_MOUSELEAVE
		invoke SendMessage,hBTN5,BM_SETIMAGE,0,hNextBtnBmp
	.else
		invoke CallWindowProc,OldWndBTN5Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndBTN5Proc2 endp
WndBTN6Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL TME:TRACKMOUSEEVENT

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_MOUSEMOVE
		mov TME.cbSize,sizeof TME
		mov TME.dwFlags,TME_LEAVE
		mov eax,hWin
		mov TME.hwndTrack,eax
		invoke TrackMouseEvent,addr TME
		invoke SendMessage,hBTN6,BM_SETIMAGE,0,hPrevBtnEmbossBmp
	.elseif uMsg==WM_MOUSELEAVE
		invoke SendMessage,hBTN6,BM_SETIMAGE,0,hPrevBtnBmp
	.else
		invoke CallWindowProc,OldWndBTN6Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndBTN6Proc2 endp
WndTBRProc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;LOCAL memDC:dword
;LOCAL WndProc2Buffer [512]:BYTE
;LOCAL content[108] :BYTE
;LOCAL Xpos:DWORD

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_MOUSEWHEEL
		invoke SendMessage, hWnd , WM_MOUSEWHEEL ,wParam,lParam
	.else
		invoke CallWindowProc,OldWndTBRProc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndTBRProc2 endp
WndTBR2Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.elseif wParam==VK_RETURN
			.if PLSelected==-1
				ret
			.endif
			mov eax,PLSelected
			mov PLFocus,eax
			invoke AVIPlay3,eax
		.else
			invoke HotButtonsProc,wParam,hWnd
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_MOUSEWHEEL
		invoke SendMessage, hWnd , WM_MOUSEWHEEL ,wParam,lParam
	.else
		invoke CallWindowProc,OldWndTBR2Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndTBR2Proc2 endp
UpdateSTC2 proc What_position:DWORD
LOCAL time_buffer [32]:BYTE
LOCAL time_buffer2 [32]:BYTE
LOCAL time_buffer3 [32]:BYTE
LOCAL time_buffer4 [32]:BYTE

	.if What_position==2
		invoke GetTime,2
	.else
		invoke GetTime,1
	.endif
	xor edx,edx
	mov dx,Hours
	invoke dw2a,edx,addr time_buffer
	invoke lstrlen,addr time_buffer
	lea edi,time_buffer
	add edi,eax
	mov al,':'
	stosb
	mov al,0
	stosb
	
	xor edx,edx
	mov dx,Minutes
	.if dx<10
		lea edi,time_buffer2
		mov al,'0'
		stosb
		mov al,0
		stosb
		invoke dw2a,edx,addr time_buffer3
		invoke lstrcat,addr time_buffer2,addr time_buffer3
	.else
		invoke dw2a,edx,addr time_buffer2
	.endif
	invoke lstrcat,addr time_buffer,addr time_buffer2
	invoke lstrlen,addr time_buffer
	lea edi,time_buffer
	add edi,eax
	mov al,':'
	stosb
	mov al,0
	stosb
	
	xor edx,edx
	mov dx,Seconds
	.if dx<10
		lea edi,time_buffer2
		mov al,'0'
		stosb
		mov al,0
		stosb
		invoke dw2a,edx,addr time_buffer3
		invoke lstrcat,addr time_buffer2,addr time_buffer3
	.else
		invoke dw2a,edx,addr time_buffer2
	.endif
	invoke lstrcat,addr time_buffer,addr time_buffer2
	invoke lstrlen,addr time_buffer
	lea edi,time_buffer
	add edi,eax
	mov al,'-'
	stosb
	mov al,'-'
	stosb
	mov al,'>'
	stosb
	mov al,0
	stosb
	
	xor edx,edx
	mov dx,AllHours
	invoke dw2a,edx,addr time_buffer2
	invoke lstrcat,addr time_buffer,addr time_buffer2
	invoke lstrlen,addr time_buffer
	lea edi,time_buffer
	add edi,eax
	mov al,':'
	stosb
	mov al,0
	stosb
	
	xor edx,edx
	mov dx,AllMinutes
	.if dx<10
		lea edi,time_buffer2
		mov al,'0'
		stosb
		mov al,0
		stosb
		invoke dw2a,edx,addr time_buffer3
		invoke lstrcat,addr time_buffer2,addr time_buffer3
	.else
		invoke dw2a,edx,addr time_buffer2
	.endif
	invoke lstrcat,addr time_buffer,addr time_buffer2
	invoke lstrlen,addr time_buffer
	lea edi,time_buffer
	add edi,eax
	mov al,':'
	stosb
	mov al,0
	stosb
	
	xor edx,edx
	mov dx,AllSeconds
	.if dx<10
		lea edi,time_buffer2
		mov al,'0'
		stosb
		mov al,0
		stosb
		invoke dw2a,edx,addr time_buffer3
		invoke lstrcat,addr time_buffer2,addr time_buffer3
	.else
		invoke dw2a,edx,addr time_buffer2
	.endif
	invoke lstrcat,addr time_buffer,addr time_buffer2
	
	invoke SetWindowText,hSTC2,addr time_buffer
	ret

UpdateSTC2 endp
GetTime proc What_Time:DWORD
LOCAL content[108] :BYTE
LOCAL	time:DWORD
;LOCAL mem16:WORD
.data
nano    dd 10000000
.code
	;int 3
	fsave content
	.if What_Time==1
		fild position
	.elseif What_Time==2
		fild position1
	.else
		fild duration
	.endif
	fild nano
	fdiv			
	fist time				;amount of seconds
	frstor  content
	mov eax,time
    xor edx,edx
    mov ecx,3600
    div ecx           ; eax = N div 3600
    .if What_Time==1 || What_Time==2
		mov Hours,ax
    .else
		mov AllHours,ax
	.endif
    xchg edx,eax       ; edx = N mod 3600
    xor edx,edx
    mov cx,60
    div ecx           ; eax = (N mod 3600) div 60, dx = N mod 60
    .if What_Time==1 || What_Time==2
		mov Minutes,ax
		mov Seconds,dx
	.else
		mov AllMinutes,ax
		mov AllSeconds,dx
   	.endif
	ret
GetTime endp
GetPosition	proc
LOCAL content[108] :BYTE
	
	mseeking GetCurrentPosition,pSeeking,addr position
	fsave content
	fild position
	fild sto
	fmul
	fild duration
	fdiv
	frndint
	lea eax,trb_position
	fistp dword ptr [eax]
	frstor  content
	mov eax,trb_position
	invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,eax
	mov eax,trb_position
	invoke SendMessage,hWndProgress,PBM_SETPOS ,eax,0
	ret
GetPosition endp
SetPosition proc
LOCAL content[108] :BYTE
	
	invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_GETPOS,0,0
	mov currentTBRpos,eax
	fsave content
	fild currentTBRpos
	fild duration
	fmul
	fild sto
	fdiv
	frndint
	fistp position1
	frstor  content
	mseeking SetPositions,pSeeking,addr position1,AM_SEEKING_AbsolutePositioning,\
	NULL, AM_SEEKING_NoPositioning
	ret
SetPosition endp

GetMasterVolume proc

        invoke mixerOpen,ADDR MixerHandle,0,0,0,0
        .if eax == MMSYSERR_NOERROR 
            mov mxlc.cbStruct,SIZEOF mxlc
            mov mxlc.dwLineID,SPEAKEROUTLINEID
            mov mxlc.dwControlType,MIXERCONTROL_CONTROLTYPE_VOLUME
            mov mxlc.cControls,1
            mov mxlc.cbmxctrl,SIZEOF mxc
            mov mxlc.pamxctrl,OFFSET mxc
            invoke mixerGetLineControls,MixerHandle,ADDR mxlc,MIXER_GETLINECONTROLSF_ONEBYTYPE
            mov eax,mxc.dwControlID
            mov VolCtlIDMtr,eax
            mov mxcdVol.dwValue,1

            mov mxcd.cbStruct,SIZEOF mxcd
            mov eax,VolCtlIDMtr  
            mov mxcd.dwControlID,eax
            mov mxcd.cChannels,1
            mov mxcd.cMultipleItems,0
            mov mxcd.cbDetails,SIZEOF mxcdVol
            mov mxcd.paDetails,OFFSET mxcdVol
            invoke mixerGetControlDetails,MixerHandle,ADDR mxcd,MIXER_GETCONTROLDETAILSF_VALUE
            mov eax,mxcdVol[0].dwValue
        .else
            mov eax,MIXER_ERROR
        .endif
        ret

GetMasterVolume endp


SetMasterVolume proc VolValue:DWORD

    mov eax,VolValue
    mov mxcdVol[0].dwValue,eax
    mov mxcd.cbStruct,SIZEOF mxcd
    mov eax,VolCtlIDMtr
    mov mxcd.dwControlID,eax
    mov mxcd.cChannels,1
    mov mxcd.cMultipleItems,0
    mov mxcd.cbDetails,SIZEOF mxcdVol
    mov mxcd.paDetails,OFFSET mxcdVol
    invoke mixerSetControlDetails,MixerHandle,ADDR mxcd,MIXER_GETCONTROLDETAILSF_VALUE
    .if eax == MMSYSERR_NOERROR
		mov eax,0
    .else
		mov eax,MIXER_ERROR
    .endif            
    ret

SetMasterVolume endp

CloseMasterVolume proc

    invoke mixerClose,ADDR MixerHandle
       
	.data
		szCloseMasterVolume	db "CloseMasterVolume: Mixer was Closed",0
	.code 
  	invoke WriteLogFile,addr szCloseMasterVolume
    ret

CloseMasterVolume endp
_CreateMailSlot proc CmdLine:DWORD
LOCAL __BytesWritten:DWORD
LOCAL SizeString:DWORD
LOCAL hClientMailslotHandle:DWORD
LOCAL hEvent:DWORD
 

    invoke lstrlen,CmdLine
    mov SizeString,eax
	invoke CreateMailslot,addr szMailSlotName,0,MAILSLOT_WAIT_FOREVER,0
	.if eax==INVALID_HANDLE_VALUE
		invoke GetLastError
		.if eax==ERROR_ALREADY_EXISTS
			invoke CreateFile,addr szMailSlotName,GENERIC_WRITE,FILE_SHARE_READ,\
			 NULL, OPEN_EXISTING,0, NULL
			 mov hClientMailslotHandle,eax
			invoke WriteFile,hClientMailslotHandle,CmdLine, SizeString,ADDR __BytesWritten,NULL
			invoke OpenEvent,EVENT_MODIFY_STATE,FALSE,addr szEventName
			mov hEvent,eax
			invoke SetEvent,hEvent
			invoke CloseHandle,hEvent
			Invoke CloseHandle,hClientMailslotHandle
			xor eax,eax
			ret
		.endif
	.else
		mov hServerMailslotHandle,eax
		invoke CreateEvent,NULL,FALSE,FALSE,addr szEventName
		mov hCommandEvent,eax
		mov eax,1
	.endif
	
	
	ret
_CreateMailSlot endp

WaitEvent proc

LOCAL MessageSize:DWORD
LOCAL BytesRead:DWORD
LOCAL CmdBuffer:DWORD
LOCAL AllMess:DWORD
LOCAL hMailslotHandle:DWORD


.data
szWaitEvent	db "WaitEvent: start",0
.code 
	invoke WriteLogFile,addr szWaitEvent
	
	@@:
	mov fWaitEventActive,1
	invoke WaitForSingleObject,hCommandEvent,INFINITE
	
	
	cmp fExit,1
	je ExitProc
	invoke GetMailslotInfo,hServerMailslotHandle,0,addr MessageSize,addr AllMess,0
;	.if AllMess==MAILSLOT_NO_MESSAGE
;		cmp fExit,1
;		je ExitProc
;		jmp @b
;	.endif
	invoke VirtualAlloc,0, MessageSize,MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE
	mov CmdBuffer,eax
	
	invoke ReadFile,hServerMailslotHandle, CmdBuffer, MessageSize,addr BytesRead,0
	;.if eax!=0
		;invoke MessageBox,0, CmdBuffer,addr AppName,MB_OK
		mov fWaitEventActive,0
		mov fCallCmdProcFromWaitEvent,1
		invoke CmdLineProc, CmdBuffer
		;invoke VirtualFree,CmdBuffer,0,MEM_RELEASE
		;jmp ExitProc
	;.endif
	invoke VirtualFree,CmdBuffer,0,MEM_RELEASE
	;cmp fExit,1
	;jne @b
	ExitProc:
	mov fWaitEventActive,0
	.data
		szWaitEvent1	db "WaitEvent: end",0
	.code 
	invoke WriteLogFile,addr szWaitEvent1
	ret
WaitEvent endp
FindFilesThread proc
LOCAL Buffer2 [512]:BYTE

	.data
		szFindFilesThread	db "FindFilesThread: start",0
	.code 
  	invoke WriteLogFile,addr szFindFilesThread
  	
	invoke BrowseForFolder,hPL,ADDR Buffer2,ADDR AppName,ADDR szSelectDir 

	;invoke SHBrowseForFolder,addr b_hwndOwner
	cmp eax,0
	je @f
	mov fTerminateFindFiles,1
	invoke FindFiles,addr Buffer2
	mov fTerminateFindFiles,0
	;invoke ExitThread,0
	@@:
	.data
		szFindFilesThread1	db "FindFilesThread: end",0
	.code 
  	invoke WriteLogFile,addr szFindFilesThread1
  	
	ret
FindFilesThread endp

ScrollCaptionThread proc
LOCAL SrollBuffer [512]:BYTE

	lea edi,SrollBuffer
	mov ecx,512
	xor al,al
	rep stosb
	invoke GetWindowText,hWnd,addr SrollBuffer,512

	@:
	lea edi,SrollBuffer
	@@:
	invoke SleepProc,20
	cmp eax,0
	je ExitProc
	inc edi
    invoke SetWindowText,hWnd,edi
    cmp byte ptr [edi],0
    jne @b
    invoke SleepProc,50
    invoke SetWindowText,hWnd,addr SrollBuffer
    cmp fExitScrollThread,1
	je ExitProc
	invoke SleepProc,1000
	cmp eax,0
	je ExitProc
	jmp @
	
    ExitProc:
    invoke SetWindowText,hWnd,addr AppName
	ret
ScrollCaptionThread endp

SleepProc	proc Delay:DWORD
LOCAL count:DWORD
	
	mov edx,Delay
	mov count,edx
	@@:
	invoke Sleep,5
	cmp fExitScrollThread,1
	je Terminate
	cmp count,0
	je Exit
	dec count
	jmp @b
	Terminate:
	xor eax,eax
	ret
	Exit:
	mov eax,1
	ret
SleepProc endp
CloseWaitEvent	proc
LOCAL hEvent:DWORD
	mov fExit,1
	invoke OpenEvent,EVENT_MODIFY_STATE,FALSE,addr szEventName
	mov hEvent,eax
	invoke SetEvent,hEvent
	invoke CloseHandle,hEvent
	;mov fExit,0
	.data
		szCloseWaitEvent	db "CloseWaitEvent: Event was set",0
	.code 
  	invoke WriteLogFile,addr szCloseWaitEvent
  	
	ret
CloseWaitEvent endp

CloseFindFiles	proc

.data
szCloseFindFiles	db "CloseFindFiles start",0
.code 
  	invoke WriteLogFile,addr szCloseFindFiles
  	
	cmp fTerminateFindFiles,0
	je ExitProc
	mov fExitFindFiles,1
	xor edi,edi
	@@:
	invoke Sleep,2
	inc edi
	cmp edi,900
	je Error
	cmp fTerminateFindFiles,0
	jne @b
	ExitProc:
	.data
		szCloseFindFiles1	db "CloseFindFiles end",0
	.code 
  	invoke WriteLogFile,addr szCloseFindFiles1
	ret
	Error:
	;invoke MessageBox,0,addr szFFThreadActive,addr szWarning,MB_ICONERROR
	.data
		szCloseFindFiles11	db "CloseFindFiles error",0
	.code 
  	invoke WriteLogFile,addr szCloseFindFiles11
  		
	ret
CloseFindFiles endp
Random  proc    
	push ebp
	.if Rand==0
		invoke GetTickCount
		mov Rand,eax
	.endif
	mov ebp,Rand
    mov     eax, 214013t
    imul    ebp
    sub     edx, edx          ; Prevent divide overflow by caller
    add     eax, 2531011t
    mov     Rand, eax
    pop ebp
    ret
Random  endp
RandomPlay  proc	hListView:DWORD
LOCAL lVPLClear:DWORD
LOCAL lVPLClear2:DWORD
LOCAL lVPLClear3:DWORD

.data
	Probability	dd 0
.code
	
	mov lVPLClear,0
	mov lVPLClear2,0
	mov lVPLClear3,0
	
	@@:
	.if lVPLClear3==1 && lVPLClear2==1 && lVPLClear==1
		.data
			szRandomPlay	db "RandomVPL return -1 error",0
		.code 
		invoke WriteLogFile,addr szRandomPlay
		mov eax,-1
		ret
	.endif

	.if Probability==0 || Probability==3
		invoke RandomVPL,hVPL3
		inc Probability
		.if eax==-1
			.data
				szRandomPlay1	db "RandomPlay VPL3 are clear.",0
			.code 
			invoke WriteLogFile,addr szRandomPlay1
			mov  lVPLClear3,1
			jmp @b
		.endif
	.elseif Probability==1 || Probability==4	
		invoke RandomVPL,hVPL2
		inc Probability
		.if eax==-1
			.data
				szRandomPlay2	db "RandomPlay VPL2 are clear.",0
			.code 
			invoke WriteLogFile,addr szRandomPlay2
			mov lVPLClear2,1
			jmp @b
		.endif
	.elseif Probability==2	
		invoke RandomVPL,hVPL
		inc Probability
		.if eax==-1
			.data
				szRandomPlay3	db "RandomPlay VPL are clear.",0
			.code 
			invoke WriteLogFile,addr szRandomPlay3
			mov lVPLClear,1
			jmp @b
		.endif
	.elseif Probability==5
		invoke RandomVPL,hVPL3
		mov Probability,0
		.if eax==-1
			.data
				szRandomPlay4	db "RandomPlay VPL3 are clear.",0
			.code 
			invoke WriteLogFile,addr szRandomPlay4
			mov lVPLClear3,1
			jmp @b
		.endif
	.endif
	
	
	ret
RandomPlay endp

WndSearchPLProc	 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL Point:POINT

	mov		eax,uMsg

	.if eax==WM_INITDIALOG
		invoke GetCursorPos,addr Point
		invoke MoveWindow,hWin,Point.x,Point.y,200,45,TRUE
		invoke GetDlgItem, hWin,IDC_EDT1
		mov hEDT1,eax
		invoke SetWindowLong,hEDT1,GWL_WNDPROC,addr WndEDT1Proc2
		mov OldWndEDT1Proc2,eax
	.elseif eax==WM_SIZE
		mov eax,lParam
		mov edx,eax
		shr edx,16
		and eax,0FFFFh
		invoke MoveWindow,hEDT1,0,0,eax,edx,TRUE
		
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

WndSearchPLProc endp

WndFileInfoProc	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL Point:POINT
LOCAL lvi:LV_ITEM
LOCAL lBuffer [512]:BYTE
Local Tag:TagStruct


;LOCAL Tit [30]:BYTE
;LOCAL Art [30]:BYTE
;LOCAL Alb [30]:BYTE
;LOCAL Year [4]:BYTE
;LOCAL Com [30]:BYTE
;LOCAL Gen:BYTE

	mov		eax,uMsg

	.if eax==WM_INITDIALOG
		invoke GetCursorPos,addr Point
		invoke MoveWindow,hWin,Point.x,Point.y,350,300,TRUE
		
		invoke GetDlgItem, hWin,IDC_STC9
		mov hSTC9,eax
		invoke GetDlgItem, hWin,IDC_EDT3
		mov hEDT3,eax
		invoke GetDlgItem, hWin,IDC_EDT5
		mov hEDT5,eax
		invoke GetDlgItem, hWin,IDC_EDT6
		mov hEDT6,eax
		invoke GetDlgItem, hWin,IDC_EDT7
		mov hEDT7,eax
		invoke GetDlgItem, hWin,IDC_EDT8
		mov hEDT8,eax
		invoke GetDlgItem, hWin,IDC_CBO1
		mov hCBO1,eax
		invoke SetWindowLong,hEDT3,GWL_WNDPROC,addr WndEDT3Proc2
		mov OldWndEDT3Proc2,eax
		invoke SetWindowLong,hEDT5,GWL_WNDPROC,addr WndEDT5Proc2
		mov OldWndEDT5Proc2,eax
		invoke SetWindowLong,hEDT6,GWL_WNDPROC,addr WndEDT6Proc2
		mov OldWndEDT6Proc2,eax
		invoke SetWindowLong,hEDT7,GWL_WNDPROC,addr WndEDT7Proc2
		mov OldWndEDT7Proc2,eax
		invoke SetWindowLong,hEDT8,GWL_WNDPROC,addr WndEDT8Proc2
		mov OldWndEDT8Proc2,eax
		invoke SetWindowLong,hCBO1,GWL_WNDPROC,addr WndCBO1Proc2
		mov OldWndCBO1Proc2,eax
		
		mov eax,PLSelected
		.if eax==-1
			mov eax,PLFocus
		.endif
		mov lvi.iItem, eax
		mov lvi.iSubItem, 2
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 512	
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		
		invoke SetWindowText,hSTC9,addr lBuffer
		
		invoke ReadTagMp3Proc,addr lBuffer,addr Tag
		.if eax==-1
			lea edi,lBuffer
			mov ecx,512
			xor al,al
			rep stosb
			mov	eax,TRUE
			ret
		.endif
		invoke SetWindowText,hEDT3,addr Tag.Tit
		invoke SetWindowText,hEDT5,addr Tag.Art
		invoke SetWindowText,hEDT6,addr Tag.Alb
		invoke SetWindowText,hEDT7,addr Tag.Year
		invoke SetWindowText,hEDT8,addr Tag.Com
		
		invoke GetGenre,0,0,hWin,IDC_CBO1
		
		lea esi,Tag.Gen
		xor edx,edx
		mov dl,byte ptr [esi]
		invoke GetGenre,edx,addr lBuffer,0,0
		.if eax==-1
			lea edi,lBuffer
			mov ecx,512
			xor al,al
			rep stosb
		.endif
		invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_SELECTSTRING,0,addr lBuffer
		
		
	.elseif eax==WM_COMMAND
		mov eax,wParam
		.if ax==IDC_BTN7
			shr eax,16
			.if ax==BN_CLICKED
				invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_GETCURSEL,0,0
				mov edx,eax
				invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_GETLBTEXT,edx,addr lBuffer
				
				xor al,al
				lea edi,Tag
				mov ecx,135
				rep stosb
				
				invoke GetWindowText,hEDT3,addr Tag.Tit,31
				invoke GetWindowText,hEDT5,addr Tag.Art,31
				invoke GetWindowText,hEDT6,addr Tag.Alb,31
				invoke GetWindowText,hEDT7,addr Tag.Year,5
				invoke GetWindowText,hEDT8,addr Tag.Com,31
				
				invoke GetGenre,0,addr lBuffer,0,0
				mov  Tag.Gen,byte ptr al
				
				mov eax,PLSelected
				mov lvi.iItem, eax
				mov lvi.iSubItem, 2
				mov lvi.imask, LVIF_TEXT
				lea eax,lBuffer
				mov lvi.pszText, eax
				mov lvi.cchTextMax, 512	
				invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
				
				invoke WriteTagMp3Proc,addr lBuffer,addr Tag
				invoke EndDialog,hWin,0
			.endif
		.elseif ax==IDC_BTN8
			shr eax,16
			.if ax==BN_CLICKED
				invoke EndDialog,hWin,0
			.endif
		.endif
	.elseif eax==WM_SIZE
		mov eax,lParam
		mov edx,eax
		shr edx,16
		and eax,0FFFFh
		sub eax,50
		invoke MoveWindow,hSTC9,14,5,eax,15,TRUE
		
		mov eax,PLSelected
		mov lvi.iItem, eax
		mov lvi.iSubItem, 2
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 512	
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		
		invoke SetWindowText,hSTC9,addr lBuffer
		
	;.elseif uMsg==WM_KEYDOWN 
		;.if wParam==VK_ESCAPE
		;	invoke EndDialog,hWin,0
		;.endif	
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	
	ret

WndFileInfoProc endp

WndEDT1Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL BufferSearch [32]:BYTE
LOCAL BufferSearch2 [32]:BYTE
;LOCAL count:DWORD
LOCAL AmountOfItems:DWORD
LOCAL    lvi:LV_ITEM


	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg,WM_CLOSE,0,0
		.elseif wParam==VK_RETURN
			invoke AVIPlay3,PLSelected
			mov HavePlayed,0
			invoke SendMessage,hDlg,WM_CLOSE,0,0
		.endif
	.elseif uMsg==WM_CHAR
		invoke CallWindowProc,OldWndEDT1Proc2,hWin,uMsg,wParam,lParam
		invoke     SendMessage, hList, LVM_GETITEMCOUNT,0,0
		.if eax<2
			jmp Quit
		.endif
		mov AmountOfItems,eax
		
		invoke GetWindowText,hEDT1,addr BufferSearch,32
		;invoke MessageBox,0,addr BufferSearch,addr AppName,MB_OK
		invoke lstrlen,addr BufferSearch
		.if eax==0
			jmp Quit
		.else
			inc eax
		.endif
		;int 3
		mov lvi.iSubItem, 1
		mov lvi.imask, LVIF_TEXT
		lea edx,BufferSearch2
		mov lvi.pszText, edx
		mov lvi.cchTextMax,eax
		xor edi,edi
		;mov count,edi
		Repeate:
		;mov edi,count
		mov     lvi.iItem, edi
		invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
		invoke lstrcmpi,addr BufferSearch,addr BufferSearch2
		jne @f
		push edi;count
		pop PLSelected
		invoke InvalidateRect,hPL,0,TRUE
		invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLSelected,FALSE
		jmp Quit
		@@:
		;mov edi,count
		cmp AmountOfItems,edi
		je Quit
		inc edi;count 
		jmp Repeate
		Quit:
	.else
		invoke CallWindowProc,OldWndEDT1Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndEDT1Proc2 endp

WndRenameProc proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL Point:POINT
LOCAL BufferRename [128]:BYTE
LOCAL lvi:LV_ITEM
	mov		eax,uMsg

	.if eax==WM_INITDIALOG
		
		invoke GetCursorPos,addr Point
		invoke MoveWindow,hWin,Point.x,Point.y,200,45,TRUE
		invoke GetDlgItem, hWin,IDC_EDT2
		mov hEDT2,eax
		invoke SetWindowLong,hEDT2,GWL_WNDPROC,addr WndEDT2Proc2
		mov OldWndEDT2Proc2,eax
		mov eax,PLSelected
		.if eax!=-1
			mov lvi.iItem, eax
			mov lvi.iSubItem, 1
			mov lvi.imask, LVIF_TEXT
			lea eax,BufferRename
			mov lvi.pszText, eax
			mov lvi.cchTextMax,64
			invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
			cmp eax,-1
			je @f
			invoke lstrlen,addr BufferRename
			mov ecx,eax
			lea edi,BufferRename
			add edi,eax
			mov al,'.'
			std
			repne scasb
			cld
			inc edi
			xor al,al
			stosb
			invoke SetWindowText,hEDT2,addr BufferRename
			@@:
		.endif
	.elseif eax==WM_SIZE
		mov eax,lParam
		mov edx,eax
		shr edx,16
		and eax,0FFFFh
		invoke MoveWindow,hEDT2,0,0,eax,edx,TRUE
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE

ret
WndRenameProc	endp

WndHelpProc proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL BytesRead:DWORD
LOCAL hlFile:DWORD
LOCAL hlMem:DWORD
LOCAL hlPMem:DWORD
LOCAL szlCurrentDir [512]:BYTE


	mov	eax,uMsg
	
	.if eax==WM_INITDIALOG
		invoke GetDlgItem, hWin,IDC_EDT4
		mov hEDT4,eax
		;int 3
		invoke SetWindowLong,hEDT4,GWL_WNDPROC,addr WndEDT4Proc2
		mov OldWndEDT4Proc2,eax
		
		invoke lstrcpy,addr szlCurrentDir,addr szCurrentDir
		invoke lstrlen,addr szlCurrentDir
		lea edi,szlCurrentDir
		add edi,eax
		mov ecx,eax
		std
		mov al,'\'
		repne scasb
		cld
		inc edi
		inc edi
		lea esi,szFileHelp
		mov ecx,10
		rep movsb
		xor eax,eax
		stosb
		
		invoke CreateFile,addr szlCurrentDir,GENERIC_READ, \
		FILE_SHARE_READ,NULL,OPEN_EXISTING,NULL,NULL
		.if eax==-1
			invoke MessageBox,0,addr szErrorHelp,addr AppName,MB_OK
			jmp @f
		.endif
		mov hlFile,eax
		
		invoke GlobalAlloc, GMEM_ZEROINIT, 100000
		mov hlMem, eax
		invoke GlobalLock, hlMem
		mov hlPMem, eax
		
		invoke  ReadFile, hlFile, hlPMem, 100000, addr BytesRead, NULL
		invoke SetWindowText,hEDT4,hlPMem
		
		invoke  GlobalUnlock, hlPMem
		invoke  GlobalFree, hlMem
		invoke  CloseHandle, hlFile
		
		@@:
	.elseif eax==WM_SIZE
		mov eax,lParam
		mov edx,eax
		shr edx,16
		and eax,0FFFFh
		invoke MoveWindow,hEDT4,0,0,eax,edx,TRUE
	.elseif eax==WM_CLOSE
		Exit:
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE

ret
WndHelpProc	endp

WndEDT2Proc2	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL BufferRename [512]:BYTE
LOCAL BufferRename2 [64]:BYTE
LOCAL BufferRename3 [512]:BYTE
LOCAL BufferRename4 [8]:BYTE
LOCAL lvi:LV_ITEM


	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg3,WM_CLOSE,0,0
			xor eax,eax
			ret
		.elseif wParam==VK_RETURN
			mov eax,PLSelected
			.if eax!=-1
				mov lvi.iItem, eax
				mov lvi.iSubItem, 2
				mov lvi.imask, LVIF_TEXT
				lea eax,BufferRename
				mov lvi.pszText, eax
				mov lvi.cchTextMax, 512
				
				invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
				cmp eax,-1
				je ErrorRename
				invoke lstrcpy,addr BufferRename3,addr BufferRename
				invoke lstrlen,addr BufferRename
				lea edi,BufferRename
				add edi,eax
				mov ecx,eax
				std
				mov al,'.'
				
				repne scasb
				inc edi
				cld
				push ecx
				push edi
				
				invoke lstrcpy,addr BufferRename4,edi
				pop edi
				pop ecx
				mov al,'\'
				std
				repne scasb 
				cld
				inc edi
				inc edi
				xor al,al
				stosb
				invoke GetWindowText,hEDT2,addr BufferRename2,64
				cmp eax,0
				je ErrorRename
				invoke lstrcat,addr BufferRename,addr BufferRename2
				invoke lstrcat,addr BufferRename,addr BufferRename4
				invoke MoveFileEx,addr BufferRename3,addr BufferRename,MOVEFILE_REPLACE_EXISTING
				cmp eax,0
				je ErrorRename
				invoke lstrcat,addr BufferRename2,addr BufferRename4
				mov     lvi.imask, LVIF_TEXT
				push  PLSelected
				pop lvi.iItem
				mov lvi.iSubItem,1
				lea edx,BufferRename2
				mov lvi.pszText,edx
				invoke     SendMessage, hList, LVM_SETITEM, 0, addr lvi
				
				mov lvi.imask,LVIF_TEXT 
				inc lvi.iSubItem
				lea edx,BufferRename
				mov lvi.pszText,edx
				invoke     SendMessage, hList, LVM_SETITEM, 0, addr lvi
				jmp @f
				ErrorRename:
				invoke GetLastError
				.if eax==ERROR_ACCESS_DENIED
					invoke MessageBox,0,addr szERROR_ACCESS_DENIED,addr szWarning,MB_OK
				.elseif eax==ERROR_FILE_NOT_FOUND
					invoke MessageBox,0,addr szERROR_FILE_NOT_FOUND,addr szWarning,MB_OK
				.endif
				@@:
			.endif
			invoke SendMessage,hDlg3,WM_CLOSE,0,0
			xor eax,eax	
			ret
		.endif
	.endif
	invoke CallWindowProc,OldWndEDT2Proc2,hWin,uMsg,wParam,lParam
	ret

WndEDT2Proc2 endp
WndEDT3Proc2	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg4,WM_CLOSE,0,0
			xor eax,eax
			ret
		;.elseif wParam==VK_RETURN
			
		.endif	
	.endif
	
	invoke CallWindowProc,OldWndEDT3Proc2,hWin,uMsg,wParam,lParam
	ret

WndEDT3Proc2 endp

WndEDT5Proc2	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg4,WM_CLOSE,0,0
			xor eax,eax
			ret
		;.elseif wParam==VK_RETURN
			
		.endif	
	.endif
	
	
	invoke CallWindowProc,OldWndEDT5Proc2,hWin,uMsg,wParam,lParam
	ret

WndEDT5Proc2 endp

WndEDT6Proc2	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg4,WM_CLOSE,0,0
			xor eax,eax
			ret
		;.elseif wParam==VK_RETURN
			
		.endif	
	.endif
	
	
	invoke CallWindowProc,OldWndEDT6Proc2,hWin,uMsg,wParam,lParam
	ret

WndEDT6Proc2 endp

WndEDT7Proc2	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg4,WM_CLOSE,0,0
			xor eax,eax
			ret
		.endif
	.elseif uMsg==WM_CHAR
		mov eax,wParam
		.if al<"0" || al>"9"
			ret
		.endif
	.endif
	
	
	invoke CallWindowProc,OldWndEDT7Proc2,hWin,uMsg,wParam,lParam
	ret

WndEDT7Proc2 endp

WndEDT8Proc2	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg4,WM_CLOSE,0,0
			xor eax,eax
			ret
		;.elseif wParam==VK_RETURN
			
		.endif	
	.endif
	
	
	invoke CallWindowProc,OldWndEDT8Proc2,hWin,uMsg,wParam,lParam
	ret

WndEDT8Proc2 endp

WndCBO1Proc2	proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg4,WM_CLOSE,0,0
			xor eax,eax
			ret
		;.elseif wParam==VK_RETURN
			
		.endif	
	.endif
	invoke CallWindowProc,OldWndCBO1Proc2,hWin,uMsg,wParam,lParam
	ret

WndCBO1Proc2 endp
AVIPlay3	proc	NumberOfItem:DWORD
LOCAL Buffer [1024]:BYTE
LOCAL    lvi:LV_ITEM


	.data
		szAVIPlay32	db "AVIPlay3 proc start",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay32
  	
  	
	xor eax,eax
	mov eax,NumberOfItem
	mov PLFocus,eax
	mov lvi.iItem, eax
	mov lvi.iSubItem, 2
	mov lvi.imask, LVIF_TEXT
	lea eax, Buffer
	mov lvi.pszText, eax
	mov lvi.cchTextMax, 1024
	;inc lvi.iSubItem
	;inc lvi.iSubItem
	invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
   	invoke AVIPlay2,addr Buffer
	invoke InvalidateRect,hPL,0,TRUE
	
	.data
		szAVIPlay33	db "AVIPlay3 proc end",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay33
  	
	ret

AVIPlay3 endp

VideoSize 	proc
LOCAL content[108] :BYTE
	
	.if fRun==0 || fAudio==1 ;|| pVideo==0 || pWindow==0
		
		ret
	.endif
	
	.if fFullScreen==1
		invoke GetSystemMetrics,SM_CXSCREEN
		mov clientwindow.left,0
		sub eax,1
		mov clientwindow.right,eax
		invoke GetSystemMetrics,SM_CYSCREEN
		mov clientwindow.top,0
		sub eax,1
		mov clientwindow.bottom,eax
	.else
		invoke  GetClientRect, hSTC1, ADDR clientwindow
	.endif
	
	vwindow SetWindowPosition,pWindow,clientwindow.left,clientwindow.top,clientwindow.right,clientwindow.bottom
	
	mov eax,clientwindow.left
	sub clientwindow.right,eax
	mov eax,clientwindow.top
	sub clientwindow.bottom,eax
	
	.if fSaveVideoRatio==1
		fsave content
		;fstcw mem16
		;and mem16,1111001111111111b
		;or mem16, 1111111111111111b
		;fldcw mem16
		fild NativeVideoHeight
		fild NativeVideoWidth
		fdiv
		fild clientwindow.bottom
		fild clientwindow.right
		fdiv
		fcom
		fstsw ax
		sahf
		jp 	@@f		;jump if error
		jc @f			;jump if st0 <st1 
		jz @@f 			; jump if st0=st1
		
		;calculate VideoHeihgt, VideoWidth=const
		fxch st(1)		
		fild clientwindow.right
		fxch st(1)
		fmul
		fistp VideoHeight
		push clientwindow.right
		pop VideoWidth
		jmp @@f
		@@:
		;calculate VideoWidth , VideoHeihgt=const
		fxch st(1)
		fild clientwindow.bottom
		fxch st(1)
		fdiv
		fistp VideoWidth
		push clientwindow.bottom
		pop VideoHeight
		@@f:
		;calculate VideoLeft
		fild clientwindow.right
		fild VideoWidth
		fsub
		fild dva
		;fxch st(1)
		fdiv
		frndint
		fistp VideoLeft
		;calculate VideoTop
		fild clientwindow.bottom
		fild VideoHeight
		fsub
		fild dva
		;fxch st(1)
		fdiv
		frndint
		fistp VideoTop
		frstor  content
	.endif
	
	
	;vmr_wcontrol9 SetVideoPosition,pWControl9,NULL,addr clientwindow
	.if fSaveVideoRatio==1
		bvideo SetDestinationPosition,pVideo,VideoLeft,VideoTop,VideoWidth,VideoHeight
	.else
		bvideo SetDestinationPosition,pVideo,clientwindow.left,clientwindow.top,clientwindow.right,clientwindow.bottom
	.endif	
	
	ret

VideoSize endp

ScreenFhon	proc
LOCAL wc:WNDCLASSEX
LOCAL msg:MSG
LOCAL ScreenFhonRect:RECT

	.if fCreateScreenFhon==1
		jmp Quit
	.endif
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov   wc.lpfnWndProc, OFFSET WndScreenFhonProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_BTNFACE+9
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET WinClassName2
	
	;invoke LoadIcon,hInstance,600
	xor eax,eax
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax

	invoke RegisterClassEx, addr wc
	
    invoke GetSystemMetrics,SM_CXSCREEN
	mov ScreenFhonRect.left,0
	mov ScreenFhonRect.right,eax
	invoke GetSystemMetrics,SM_CYSCREEN
	mov ScreenFhonRect.top,0
	mov ScreenFhonRect.bottom,eax
	
	
	invoke CreateWindowEx,WS_EX_TOPMOST,ADDR WinClassName2,0,\
    WS_POPUP or WS_MAXIMIZE or WS_CHILD,ScreenFhonRect.left,ScreenFhonRect.top,\
    ScreenFhonRect.right,ScreenFhonRect.bottom,hWnd,0,hInstance,0
	.if eax!=0
		mov   hScreenFhon,eax
		invoke ShowWindow, hScreenFhon,SW_SHOW
		;invoke UpdateWindow, hScreenFhon
	.endif
	mov fCreateScreenFhon,1
	Quit:
	ret
ScreenFhon	endp

WndScreenFhonProc proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL hDC:DWORD
LOCAL hBrush:DWORD
LOCAL hOld:DWORD
LOCAL lb:LOGBRUSH
LOCAL ps:PAINTSTRUCT
LOCAL hPen:DWORD
LOCAL lPoint:POINT
LOCAL lBufferForBlendText [128]:BYTE

	push hWin
 	pop hScreenFhon
 	
 	mov eax,uMsg
 	.if eax==WM_CREATE
		
;	.elseif uMsg==WM_PAINT
;		invoke BeginPaint,hWnd, ADDR ps
;		mov    hDC,eax
;		
;;		.if fFullScreen==1 
;;			vmr_wcontrol9 RepaintVideo,pWControl9,hScreenFhon,hDC
;;		.endif
;		
;		invoke EndPaint,hWnd, ADDR ps
	.elseif eax==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.else
			invoke HotButtonsProc,wParam,0
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		mov fCreateScreenFhon,0
		invoke DestroyWindow,hScreenFhon
	.elseif eax==WM_LBUTTONDBLCLK
		call ClearFullScreen
	.elseif eax==WM_LBUTTONUP
		invoke SendMessage, hWnd , WM_LBUTTONUP ,wParam,lParam
	.elseif eax==WM_MOUSEWHEEL
		invoke SendMessage, hWnd , WM_MOUSEWHEEL ,wParam,lParam
	.elseif eax==WM_MOUSEMOVE
		.if fFullScreen==1
			.if fCurHidden==1 
				invoke ShowCursor,TRUE
				mov fCurHidden,0
			.endif
			invoke GetCursorPos,addr lPoint
			.if lPoint.y==0 && fProgressWindowHidden==1
				invoke ShowWindow,hProgressWindow,SW_SHOW
				mov fProgressWindowHidden,0
				mov fHoverProgWin,1
				.if fVideoOptionCreated==1
					invoke SendMessage,hDlg5,WM_CLOSE,0,0
				.endif
				invoke GetWindowText,hSTC2,addr lBufferForBlendText,128
				invoke lstrlen,addr lBufferForBlendText
				mov edx,eax
				invoke BlendText,addr lBufferForBlendText,edx,addr szFontName
				mov fBlendTextShowTime,1
			.elseif lPoint.y>20
				mov fHoverProgWin,0
			.endif
		.endif
	.elseif eax==WM_MBUTTONUP
		.if WheelFunc==0
			mov WheelFunc,1	;equ wheelVolume
			invoke BlendText,addr szWheelVolume,16,addr szFontName
		.else
			mov WheelFunc,0	;equ wheelFrameStep
			invoke BlendText,addr szWheelFrameStep,16,addr szFontName
		.endif
	.else
		invoke DefWindowProc, hWin, uMsg, wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret
WndScreenFhonProc endp

ProgressWindow	proc
LOCAL wc:WNDCLASSEX
LOCAL msg:MSG
LOCAL lRect:RECT


	.if fCreateProgressWindow==1
		jmp Quit
	.endif
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov   wc.lpfnWndProc, OFFSET WndProgressWindow
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_BTNFACE+1

	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET WinClassName4
	
	invoke LoadIcon,hInstance,600
	;xor eax,eax
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax

	invoke RegisterClassEx, addr wc
	
    invoke GetSystemMetrics,SM_CXSCREEN
	mov lRect.left,0
	mov lRect.right,eax
	invoke GetSystemMetrics,SM_CYSCREEN
	mov lRect.top,0
	mov lRect.bottom,eax
	
	
	invoke CreateWindowEx,WS_EX_TOPMOST,ADDR WinClassName4,0,\
    WS_POPUP or WS_CHILD,lRect.left,lRect.top,\
    lRect.right,20,hScreenFhon,0,hInstance,0
	.if eax!=0
		mov   hProgressWindow,eax
		invoke ShowWindow, hProgressWindow,SW_SHOW
		;invoke UpdateWindow, hProgressWindow
	.endif
	mov fCreateProgressWindow,1
	Quit:
	ret
ProgressWindow	endp

WndProgressWindow proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL hDC:DWORD
LOCAL hBrush:DWORD
LOCAL hOld:DWORD
LOCAL lb:LOGBRUSH
LOCAL ps:PAINTSTRUCT
LOCAL hPen:DWORD
LOCAL lRect:RECT
LOCAL lPoint:POINT
LOCAL content[108] :BYTE


	push hWin
 	pop hProgressWindow
 	
 	.if uMsg==WM_CREATE
		;int 3
		
		invoke GetSystemMetrics,SM_CXSCREEN
		mov lRect.left,0
		mov lRect.right,eax
		invoke GetSystemMetrics,SM_CYSCREEN
		mov lRect.top,5
		mov lRect.bottom,eax
		invoke CreateWindowEx,NULL,ADDR progressClass,NULL,WS_CHILD or\
		WS_VISIBLE or WS_BORDER or PBS_SMOOTH,lRect.left,lRect.top,\
		lRect.right,10,hProgressWindow,IDC_PROGRESS,\
		hInstance,NULL
		mov hWndProgress,eax
		invoke SetWindowLong,hWndProgress,GWL_WNDPROC,WndProgressProc
		mov OldWndProgressProc,eax
		mov eax,sto
		shl eax,16
		invoke SendMessage,hWndProgress,PBM_SETRANGE,0,eax
		invoke SendMessage,hWndProgress,PBM_SETSTEP,1,0
		
	.elseif uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			call KillAllProc
			invoke PostQuitMessage,0
		.elseif wParam==VK_SPACE
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.else
			invoke HotButtonsProc,wParam,0
		.endif
	.elseif eax==WM_KEYUP
		mov eax,wParam
		.if eax==VK_LEFT || eax==VK_RIGHT
			.if fPause==1
				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
			.endif
		.endif
	.elseif uMsg==WM_CLOSE
		mov fCreateProgressWindow,0
		invoke DestroyWindow,hProgressWindow
	.elseif uMsg==WM_LBUTTONUP
		cmp fFullScreen,1
		jne @f
		invoke GetCursorPos,addr lPoint
		invoke ScreenToClient,hWndProgress,addr lPoint
		invoke GetWindowRect,hWndProgress,addr lRect
		fsave content
		fild lPoint.x
		fild sto
		fmul
		fild lRect.right
		fdiv
		fistp lPoint.x
		frstor  content
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,lPoint.x
		invoke SetPosition
		invoke SendMessage,hWndProgress,PBM_SETPOS ,lPoint.x,0
		@@:
	.elseif uMsg==WM_MOUSEWHEEL
		invoke SendMessage, hWnd , WM_MOUSEWHEEL ,wParam,lParam
	.else
		invoke DefWindowProc, hWin, uMsg, wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret
WndProgressWindow endp

WndProgressProc	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg4,WM_CLOSE,0,0
			xor eax,eax
			ret
		.else
			invoke HotButtonsProc,wParam,0
		.endif	
;	.elseif eax==WM_KEYUP
;		mov eax,wParam
;		.if eax==VK_LEFT || eax==VK_RIGHT
;			.if fPause==1
;				invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
;			.endif
;		.endif
	.elseif uMsg==WM_LBUTTONUP
		invoke SendMessage,hProgressWindow,uMsg,wParam,lParam
	.elseif uMsg==WM_MOUSEWHEEL
		invoke SendMessage, hWnd , WM_MOUSEWHEEL ,wParam,lParam
	.endif
	
	
	invoke CallWindowProc,OldWndProgressProc,hWin,uMsg,wParam,lParam
	ret

WndProgressProc endp

GetScreenShot proc	UseAsFhon:DWORD
LOCAL BitmapBuffer:DWORD
LOCAL BitmapWritten:DWORD
LOCAL hbFile:DWORD
LOCAL bfh:BITMAPFILEHEADER	
LOCAL fSavePause:DWORD
LOCAL CurrentDir [512]:BYTE
LOCAL BitmapName [128]:BYTE
LOCAL count:DWORD

	.if fPause==0
		mov fPause,1
		mctrl Pause_,pControl	
	.else
		mov fSavePause,1
	.endif
	bvideo GetCurrentImage,pVideo,addr BitmapSize,0
	invoke VirtualAlloc,0, BitmapSize,MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE
	mov BitmapBuffer,eax
	bvideo GetCurrentImage,pVideo,addr BitmapSize,BitmapBuffer
	.if fPause==1 && fSavePause!=1
		mctrl Run,pControl
		mov fPause,0
		.if fFullScreen==1
			mov fFullScreen,0
			invoke SendMessage,hWnd,WM_LBUTTONDBLCLK,0,0
		.endif
	.else
		mov fSavePause,0
	.endif

	.if UseAsFhon==0
		invoke lstrlen,addr szFileName
		lea edi,szFileName
		add edi,eax
		mov ecx,eax
		mov al,'\'
		std 
		repne scasb
		cld
		inc edi
		inc edi
		invoke lstrcpy,addr BitmapName,edi
		
		invoke lstrcpy,addr CurrentDir,addr szCurrentDir
		invoke lstrlen,addr CurrentDir
		lea edi,CurrentDir
		add edi,eax
		mov ecx,eax
		mov al,'\'
		std 
		repne scasb
		cld
		inc edi
		inc edi
		mov al,0
		stosb
		invoke lstrcat,addr CurrentDir,addr BitmapName
		
		mov edx,CountOfScreenShots
		inc CountOfScreenShots
		invoke dw2a,edx,addr count
		
		invoke lstrlen,addr CurrentDir
		lea edi,CurrentDir

		add edi,eax
		mov al,'-'
		stosb
		mov eax,count
		stosd
		mov al,0
		stosb
		
		invoke lstrcat,addr CurrentDir,addr szBmpExtension
	.else;if UseAsFhon==1
		invoke lstrcpy,addr CurrentDir,addr szCurrentDir
		invoke lstrlen,addr CurrentDir
		lea edi,CurrentDir
		add edi,eax
		mov ecx,eax
		mov al,'\'
		std 
		repne scasb
		cld
		inc edi
		inc edi
		mov al,0
		stosb
		invoke lstrcat,addr CurrentDir,addr Picture
		invoke DeleteFile,addr CurrentDir
	.endif
	
	invoke CreateFile,addr CurrentDir,GENERIC_READ or GENERIC_WRITE, \
	FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,NULL,NULL
	.if eax==INVALID_HANDLE_VALUE 
;		invoke GetLastError 
;		.if eax==ERROR_FILE_EXISTS
;			invoke MessageBox, NULL, addr szERROR_FILE_EXISTS, addr szWarning, MB_OK
;			ret
;		.endif
		invoke MessageBox, NULL, addr szCannotSave, addr AppName, MB_OK
		ret	
	.endif 
	mov hbFile,eax
	
	mov bfh.bfType,4D42h	;BM
	mov bfh.bfSize,SIZEOF BITMAPFILEHEADER
	mov eax,BitmapSize
	add bfh.bfSize,eax
	mov bfh.bfOffBits,SIZEOF bfh
	mov edi,BitmapBuffer
	mov eax,dword ptr [edi]
	add bfh.bfOffBits,eax
	;add bfh.bfOffBits,4
	mov edx,SIZEOF BITMAPFILEHEADER
	invoke WriteFile, hbFile,addr bfh, edx, ADDR BitmapWritten, NULL
	invoke WriteFile, hbFile, BitmapBuffer,bfh.bfSize, ADDR BitmapWritten, NULL
	
	invoke CloseHandle,hbFile
	invoke VirtualFree,BitmapBuffer,0,MEM_RELEASE
	
	.if UseAsFhon==1
		invoke DeleteObject, hPic
		invoke LoadImage,NULL,ADDR Picture,IMAGE_BITMAP,0,0,LR_LOADFROMFILE or LR_DEFAULTSIZE 
		.if eax==0
			invoke MessageBox,0,addr szPicNotFound,addr AppName,MB_OK
			mov fFhonNotFound,1
		.endif
		mov hPic,eax
	.endif
	
	ret
GetScreenShot endp
OpenFiles	proc	PathName:DWORD
LOCAL lBuffer [512]:BYTE
LOCAL LengthStrInBuf:DWORD
LOCAL PathPos:DWORD
LOCAL count:DWORD
LOCAL lFocus:DWORD

.data
szOpenFiles	db "OpenFiles: start",0
.code 
	invoke WriteLogFile,addr szOpenFiles
	
	.if fCreatePL==0
		call CreatePlayList
	.elseif fCreatePL==1 && IsPLVisible==0
		invoke ShowWindow,hPL,SW_SHOW
		mov IsPLVisible,1
	.endif
	
	;int 3
	invoke lstrlen, PathName
	mov edi,PathName
	add edi,eax
	mov ecx,eax
	mov al,'.'
	std
	repne scasb
	cld
	jne @f
	.data
		szOpenFiles2	db "OpenFiles: error",0
	.code 
	invoke WriteLogFile,addr szOpenFiles2
	xor eax,eax
	dec eax
	ret
	
	@@:
	mov lFocus,-1
	invoke lstrcpy,addr lBuffer, PathName	;copy path of dir where files is
	invoke lstrlen,addr lBuffer
	mov LengthStrInBuf,eax
	lea edi,lBuffer
	add edi,LengthStrInBuf
	mov al,'\'
	stosb
	inc LengthStrInBuf
	xor al,al
	stosb
	
	mov edi,PathName
	add edi,LengthStrInBuf					;first file after path of dir
	@@:
	push edi
	invoke lstrcat,addr lBuffer,edi		;path+file
	invoke LoadPL,addr lBuffer,hList,1
	.if lFocus==-1
		mov lFocus,eax					;save first file for playing
	.endif
	lea edi,lBuffer						;delete filefrom path
	add edi,LengthStrInBuf
	xor al,al
	stosb
	
	pop edi				
	invoke lstrlen,edi
	add edi,eax					;next file
	inc edi
	
	mov eax,[edi]				;last file?
	cmp eax,0
	je Quit
	jmp @b
	
	
	
	Quit:
	.data
		szOpenFiles1	db "OpenFiles: end",0
	.code 
	invoke WriteLogFile,addr szOpenFiles1
	
	lea edi,lBuffer
	mov ecx,512
	xor al,al
	rep stosb
	
	mov eax,lFocus		
	ret
OpenFiles endp

KillAllProc	proc

	.data
		szKillAllProc	db "KillAllProc: start",0
	.code 
  	invoke WriteLogFile,addr szKillAllProc
  	
	;invoke MessageBox,0,addr AppName,addr AppName,MB_OK
	cmp fKillAll,1
	je Quit
	call CloseWaitEvent
	call CloseFindFiles

	invoke IniProc,toWrite
	
	.if hPic!=0
		invoke DeleteObject, hPic
		mov hPic,0
	.endif
	
	invoke DeleteObject,hBrushMain
	invoke DeleteObject,hFont
	
	invoke DestroyMenu,hPopupMenuTray
	invoke DestroyMenu,hPopupMenu
	invoke DestroyMenu,hPopMenu3
	invoke DestroyMenu,hPopMenu2
	invoke DestroyMenu,hPopMenu
	
	
	
	invoke UnregisterHotKey,hWnd,IDC_HOT1
	invoke UnregisterHotKey,hWnd,IDC_HOT2
	invoke UnregisterHotKey,hWnd,IDC_HOT3
	invoke UnregisterHotKey,hWnd,IDC_HOT4
	invoke UnregisterHotKey,hWnd,IDC_HOT5
	
	
	
	call StopTimer
	call AVIClose
	invoke CloseMasterVolume
	call DestroyBitmaps
	invoke CloseHandle,hServerMailslotHandle
	invoke CloseHandle,hCommandEvent
	
	invoke DestroyVPL,hVPL
	invoke DestroyVPL,hVPL2
	invoke DestroyVPL,hVPL3
	
	invoke DestroyWindow,hPL
	invoke DestroyWindow,hToolTip
	invoke DestroyWindow,hProgressWindow
	invoke DestroyWindow,hScreenFhon
	invoke DestroyWindow,hWnd
	
	mov fKillAll,1

	Quit:
	.data
		szKillAllProc1	db "KillAllProc: end",0
	.code 
  	invoke WriteLogFile,addr szKillAllProc1
  		
	ret
KillAllProc endp

SetFullScreen	proc

	cmp fRun,1
	jne @f
	cmp fAudio,0
	jne @f
	
	
	.if fCreateScreenFhon==0
		call ScreenFhon
	.else
		invoke ShowWindow,hScreenFhon,SW_SHOW
	.endif
	
	.if fCreateProgressWindow==0
		invoke ProgressWindow
	.else
		invoke ShowWindow,hProgressWindow,SW_SHOW
		mov fProgressWindowHidden,0
	.endif
	
	vwindow   put_Owner, pWindow, hScreenFhon
	vwindow   put_MessageDrain,pWindow,hScreenFhon 
	
	;vmr_wcontrol9 SetVideoClippingWindow,pWControl9,hScreenFhon
	mov fFullScreen,1
	
	call VideoSize
	@@:
	ret
SetFullScreen endp

ClearFullScreen proc

	
	;vmr_wcontrol9 SetVideoClippingWindow,pWControl9,hSTC1
	cmp pWindow,0
	je @f
	vwindow   put_Owner, pWindow, hSTC1
	vwindow   put_MessageDrain,pWindow,hWnd
	@@:
	mov fFullScreen,0
	call VideoSize
	.if fCurHidden==1
		invoke ShowCursor,TRUE
		mov fCurHidden,0
	.endif
	
	.if fProgressWindowHidden==0
		invoke ShowWindow,hProgressWindow,SW_HIDE
		mov fProgressWindowHidden,1
	.endif
	invoke ShowWindow,hScreenFhon,SW_HIDE
	
	ret

ClearFullScreen endp


ReadTagMp3Proc	proc	PathName:DWORD, TAGStruct:DWORD
LOCAL hlFile:DWORD
LOCAL BytesRead:DWORD
LOCAL lBuffer [64]:BYTE

.data
;TagStruct Struct
;Tag db 4 dup (0)
;Tit db 31 dup (0)
;Art db 31 dup (0)
;Alb db 31 dup (0)
;Year db 5 dup (0)
;Com db 31 dup (0)
;Gen db 2 dup (0)
;TagStruct ends
_szMp3	db	".mp3",0
_szTag	db	"tag",0
.code

	xor al,al
	mov edi,TAGStruct
	mov ecx,135
	rep stosb
	
	invoke lstrlen, PathName
 	mov edi,PathName
 	add edi,eax
 	mov ecx,eax
 	mov al,'.'
	std
	repne scasb 
	cld
	inc edi
 	invoke lstrcmpi,edi,addr _szMp3
 	jne Error

	invoke CreateFile,PathName,GENERIC_READ, \
	FILE_SHARE_READ,NULL,OPEN_EXISTING,NULL,NULL
	.if eax==INVALID_HANDLE_VALUE 
		.data
			szReadTagMp3Proc	db "ReadTagMp3Proc: error openning file",0
		.code 
		invoke WriteLogFile,addr szReadTagMp3Proc
		mov eax,-1
		ret
	.endif 
	mov hlFile,eax	
	
	invoke SetFilePointer,hlFile,-128,0,FILE_END				;TAG 1-3
	invoke ReadFile,hlFile,TAGStruct,3,addr BytesRead,NULL
	
	mov esi,TAGStruct
	lea edi,lBuffer
	mov ecx,3
	rep movsb
	xor al,al
	stosb
	invoke lstrcmpi,addr lBuffer,addr _szTag
	jne Quit
	
	;Title 4-33
	add TAGStruct,4
	invoke ReadFile,hlFile,TAGStruct,30,addr BytesRead,NULL
	
	;Artist 34-63
	add TAGStruct,31
	invoke ReadFile,hlFile,TAGStruct,30,addr BytesRead,NULL
	
	;Album 64-93
	add TAGStruct,31
	invoke ReadFile,hlFile,TAGStruct,30,addr BytesRead,NULL

	
	;Year 94-97
	add TAGStruct,31
	invoke ReadFile,hlFile,TAGStruct,4,addr BytesRead,NULL
	
	;Comment 98-127
	add TAGStruct,5
	invoke ReadFile,hlFile,TAGStruct,30,addr BytesRead,NULL	

	;Genre 128
	add TAGStruct,31
	invoke ReadFile,hlFile,TAGStruct,1,addr BytesRead,NULL
	Quit:
	
	invoke CloseHandle,hlFile
	
	mov eax,TRUE
	ret
	
	Error:
	xor al,al
	mov edi,TAGStruct
	mov ecx,135
	rep stosb
	mov eax,-1
	ret
	
ReadTagMp3Proc endp

WriteTagMp3Proc	proc	PathName:DWORD, TAGStruct:DWORD
LOCAL hlFile:DWORD
LOCAL BytesRead:DWORD
LOCAL lBuffer [64]:BYTE
LOCAL lBytesWritten:DWORD
LOCAL lFileSize:DWORD
.data
;TagStruct Struct
;Tag db 4 dup (0)
;Tit db 31 dup (0)
;Art db 31 dup (0)
;Alb db 31 dup (0)
;Year db 5 dup (0)
;Com db 31 dup (0)
;Gen db 2 dup (0)
;TagStruct ends
__szMp3	db	".mp3",0
__szTag	db	"TAG",0
.code
	
	
	invoke lstrlen, PathName
 	mov edi,PathName
 	add edi,eax
 	mov ecx,eax
 	mov al,'.'
	std
	repne scasb 
	cld
	inc edi
 	invoke lstrcmpi,edi,addr __szMp3
 	jne Error

	invoke CreateFile,PathName,GENERIC_READ or GENERIC_WRITE, \
	FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_EXISTING,NULL,NULL
	.if eax==INVALID_HANDLE_VALUE 
		invoke GetLastError
		.if eax==ERROR_ACCESS_DENIED ;(00000005)
			.data
				szWriteTagMp3Proc	db "WriteTagMp3Proc: ERROR_ACCESS_DENIED",0
			.code 
			invoke WriteLogFile,addr szWriteTagMp3Proc
			invoke MessageBox,0,addr szERROR_ACCESS_DENIED,addr szWarning,MB_OK
		.elseif eax==ERROR_SHARING_VIOLATION ;(00000020)
			.data
				szWriteTagMp3Proc3	db "WriteTagMp3Proc: ERROR_SHARING_VIOLATION",0
			.code 
			invoke WriteLogFile,addr szWriteTagMp3Proc3
			invoke MessageBox,0,addr szERROR_SHARING_VIOLATION,addr szWarning,MB_OK
		.endif
		mov eax,-1
		ret
	.endif 
	mov hlFile,eax	
	
	invoke SetFilePointer,hlFile,-128,0,FILE_END				;TAG 1-3
	invoke ReadFile,hlFile,addr lBuffer,3,addr BytesRead,NULL
	lea edi,lBuffer
	add edi,3
	xor al,al
	stosb
	invoke lstrcmpi,addr lBuffer,addr __szTag
	jne NoTag
	
	;Title 4-33
	add TAGStruct,4
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL
	
	;Artist 34-63
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL
	
	;Album 64-93
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL
	
	;Year 94-97
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,4,addr lBytesWritten,NULL
	
	;Comment 98-127
	add TAGStruct,5
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL	

	;Genre 128
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,1,addr lBytesWritten,NULL
	jmp Quit
	
	NoTag:
	.data
		szWriteTagMp3Proc2	db "WriteTagMp3Proc: it was no tag in file",0
	.code 
	invoke WriteLogFile,addr szWriteTagMp3Proc2
	
	invoke GetFileSize,hlFile,NULL
	mov lFileSize,eax
	
	invoke SetFilePointer,hlFile,lFileSize,0,0				;Tag 1-3
	invoke WriteFile,hlFile,addr __szTag,3,addr lBytesWritten,NULL
	
	;Title 4-33
	add TAGStruct,4
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL
	
	;Artist 34-63
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL
	
	;Album 64-93
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL
	
	;Year 94-97
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,4,addr lBytesWritten,NULL
	
	;Comment 98-127
	add TAGStruct,5
	invoke WriteFile,hlFile,TAGStruct,30,addr lBytesWritten,NULL	

	;Genre 128
	add TAGStruct,31
	invoke WriteFile,hlFile,TAGStruct,1,addr lBytesWritten,NULL
	
	invoke SetEndOfFile,hlFile
	Quit:
	invoke CloseHandle,hlFile

	mov eax,TRUE
	ret
	
	Error:
	.data
		szWriteTagMp3Proc1	db "WriteTagMp3Proc: not mp3 file",0
	.code 
	invoke WriteLogFile,addr szWriteTagMp3Proc1
	xor al,al
	mov edi,TAGStruct
	mov ecx,135
	rep stosb
	mov eax,-1
	ret
	
WriteTagMp3Proc endp
CreateVPL	proc
LOCAL lhVPL:DWORD

.data
szCreateVPL	db "CreateVPL: start",0
.code 
  	invoke WriteLogFile,addr szCreateVPL
  	
  	
	invoke VirtualAlloc,0, 8*1024*1024,MEM_RESERVE,PAGE_READWRITE
	.if eax==0
		.data
			szCreateVPL2	db "CreateVPL: error reserving memory",0
		.code 
		invoke WriteLogFile,addr szCreateVPL2
		mov eax,-1
		ret
	.endif
	mov lhVPL,eax
	
	invoke VirtualAlloc,lhVPL, 4*1024,MEM_COMMIT,PAGE_READWRITE
	.if eax==0
		.data
			szCreateVPL3	db "CreateVPL: error commit memory",0
		.code 
		invoke WriteLogFile,addr szCreateVPL3
		mov eax,-1
		ret
	.endif

	
	mov edi,lhVPL
	mov eax,-1
	mov ecx,4*1024
	rep stosb
	
	
.data
szCreateVPL1	db "CreateVPL: end",0
.code 
  	invoke WriteLogFile,addr szCreateVPL1
  	mov eax,lhVPL
	ret
	
	
CreateVPL endp

DestroyVPL	proc	_hVPL:DWORD

	
	invoke VirtualFree,_hVPL,0,MEM_RELEASE
	
	
.data
szDestroyVPL	db "DestroyVPL: VPl was destroyed",0
.code 
  	invoke WriteLogFile,addr szDestroyVPL
	ret

DestroyVPL endp

LoadVPL	proc	hListView:DWORD
LOCAL lPriority [32]:BYTE
LOCAL lItemCount:DWORD
LOCAL RowNumber:DWORD
LOCAL lvi:LV_ITEM	

.data
	szLoadVPL	db "LoadVPL: start",0
.code 
  	invoke WriteLogFile,addr szLoadVPL
  	
  	
	invoke SendMessage, hListView, LVM_GETITEMCOUNT,0,0
	.if eax==0
		.data
			szLoadVPL3	db "LoadVPL: error",0
		.code 
		invoke WriteLogFile,addr szLoadVPL3
		mov eax,-1
		ret
	.endif
	mov lItemCount,eax
	
	mov RowNumber,0
	
	@@:
	lea edi,lPriority
	xor al,al
	mov ecx,32
	rep stosb
	
	mov eax,RowNumber
	mov lvi.iItem, eax
	mov lvi.iSubItem, 3
	mov lvi.imask, LVIF_TEXT
	lea edi, lPriority
	mov lvi.pszText, edi
	xor al,al
	mov ecx,32
	rep stosb
	mov lvi.cchTextMax, 32
	invoke     SendMessage, hListView, LVM_GETITEM, 0, addr lvi
	.if eax==FALSE
		xor eax,eax
		dec eax
		.data
			szLoadVPL2	db "LoadVPL: end",0
		.code 
		invoke WriteLogFile,addr szLoadVPL2
		ret
	.endif
	mov edx,dword ptr lPriority
	
	;invoke AddStrVPL,Pointer,RowNumber,edx
	
	.if edx==1
		invoke AddStrVPL,hVPL,RowNumber
	.elseif edx==2
		invoke AddStrVPL,hVPL2,RowNumber
	.elseif edx==3
		invoke AddStrVPL,hVPL3,RowNumber
	.endif
	
	inc RowNumber
	mov eax,RowNumber
	.if eax<=lItemCount
		jmp @b
	.endif
	
	.data
		szLoadVPL1	db "LoadVPL: end",0
	.code 
  	invoke WriteLogFile,addr szLoadVPL1
  		
	ret

LoadVPL endp
AddStrVPL	proc	 Pointer1:DWORD,_RowNumber:DWORD
LOCAL lSizeVPL:DWORD
LOCAL lvi:LV_ITEM
LOCAL lPriority [32]:BYTE
LOCAL MBI:MEMORY_BASIC_INFORMATION
LOCAL lBuffer [32]:BYTE
LOCAL lPointer:DWORD

.code

	;int 3

	invoke VirtualQuery,Pointer1,addr MBI,sizeof MBI
	mov eax,MBI.RegionSize
	.if eax==0
		mov eax,-1
		ret
	.endif
	mov lSizeVPL,eax
	@@:
	mov edi,Pointer1			;search empty 
	mov al,-1
	mov ecx,lSizeVPL
	repne scasb
	je @@1
	push Pointer1
	pop lPointer
	call NeedMemory
	@@1:
	.if eax==1
		jmp @b
	.endif
	dec edi
	mov eax,_RowNumber
	stosd					;write
	
	mov eax,TRUE
	ret
	
	
	NeedMemory:
	;int 3
	.data
		szAddStrVPL1	db "AddStrVPL: increase memory: start",0
	.code 
	invoke WriteLogFile,addr szAddStrVPL1
	
	push lSizeVPL
	add lSizeVPL,4*1024
	invoke VirtualAlloc,lPointer,lSizeVPL,MEM_COMMIT,PAGE_READWRITE
	.if eax==0
		;invoke MessageBox,0,addr szErrHeap,addr AppName,MB_OK
		.data
			szAddStrVPL	db "AddStrVPL: error adding memory",0
		.code 
		invoke WriteLogFile,addr szAddStrVPL
		mov eax,-1
		ret
	.endif
	mov edi,lPointer
	pop eax			;restore SizeVPL
	add edi,eax
	mov eax,-1
	mov ecx,4*1024
	rep stosb
	
	;invoke MessageBox,0,addr szNeedMemory,addr AppName,MB_OK
	
	mov ebx,lSizeVPL
	invoke dw2a,ebx,addr lBuffer
	invoke WriteLogFile,addr lBuffer	;amount of memory
	.data
		szAddStrVPL2	db "AddStrVPL: increase memory: end",0
	.code 
	invoke WriteLogFile,addr szAddStrVPL2
	mov eax,1
	pop edx
	jmp edx
	
AddStrVPL endp

RandomVPL	proc	Pointer:DWORD
LOCAL SizeVPL:DWORD
LOCAL lRowNubmer:DWORD
LOCAL MBI:MEMORY_BASIC_INFORMATION


	.data
		szRandomVPL	db "RandomVPL: start",0
	.code 
  	invoke WriteLogFile,addr szRandomVPL
  
  	
  	Begin:
  	
  	
	invoke VirtualQuery,Pointer,addr MBI,sizeof MBI
	mov eax,MBI.RegionSize
	mov SizeVPL,eax
	
	mov esi,Pointer
	xor ecx,ecx			;size
	xor edx,edx			;amount not empty cells
	
	@@:
	mov eax, [esi]
	.if eax!=-1
		add esi,4
		add ecx,4
		inc edx
		.if ecx>=SizeVPL
			jmp @f
		.endif
		jmp @b
	.endif
	@@:
	.if edx==0
		.data
			szRandomVPL3	db "RandomVPL: all cells are empty",0
		.code 
		invoke WriteLogFile,addr szRandomVPL3
		mov eax,-1
		ret
	.endif
	

;	push edx
;	call Random
;	xor edx,edx
;	pop ecx
;	div ecx
;	mov eax,edx		;random number within the limits of array

	invoke RandomRDTSC,0,edx
	dec eax
	jnl @f
	mov eax,0
	@@:


	xor edx,edx
	mov ebx,4
	mul ebx
	mov esi,Pointer
	add esi,eax
	mov eax,[esi]		;got RowNubmer from cell
	.if eax==-1
		.data
			szRandomVPL4	db "RandomVPL: Empty cell was captured !!!",0
		.code 
		invoke WriteLogFile,addr szRandomVPL4
		ret
	.endif
	mov lRowNubmer,eax
	
	
	invoke DeleteCellVPL,Pointer,lRowNubmer
	
	Quit:
	.data
		szRandomVPL1	db "RandomVPL: end",0
	.code 
  	invoke WriteLogFile,addr szRandomVPL1
  	
	mov eax,lRowNubmer
	
	ret

RandomVPL endp

RandomRDTSC proc _From:DWORD, _To:DWORD
	
	;int 3
	pushad
	rdtsc
	and eax, 0FFFh
	or eax, 10h
	mov ecx, eax		; получаем значения счетчика...  (1)

Genner:				; непосредственно генератор...Начальное содержание 
	                ; регистра ebx не важно
	rdtsc
	add ebx, eax
	bswap ebx
	loop Genner

	mov ecx, _To
	sub ecx, _From
	jz RetCur
	
CutRND:				; укорачиваем значение до оптимального. (2)
	mov edx, ebx		
	shr ebx, 1
	cmp ebx, ecx
	ja CutRND
	mov ebx, edx

Cuter:				; Делитель (3)
	sub ebx, ecx
	cmp ebx, ecx
	ja Cuter
	add ebx, _From

GenEnd:				
	mov dword ptr [esp+28],ebx
	popad
	ret

RetCur:				; Определитель (4)
	mov ebx, _From
	jmp GenEnd

RandomRDTSC endp

DeleteCellVPL	proc	Pointer:DWORD, lRowNubmer:DWORD
LOCAL CellsBuffer:DWORD
LOCAL SizeVPL:DWORD
LOCAL lDeletingNumber:DWORD
LOCAL lSizeOFMovingCells:DWORD
LOCAL lLimitOfVPL:DWORD
LOCAL MBI:MEMORY_BASIC_INFORMATION

	.data
		szDeleteCellVPL	db "DeleteCellVPL: start",0
	.code 
  	invoke WriteLogFile,addr szDeleteCellVPL
  	

	
	;int 3
	invoke VirtualQuery,Pointer,addr MBI,sizeof MBI
	mov eax,MBI.RegionSize
	mov SizeVPL,eax
	
	;mov eax,_SizeVPL
	mov esi,Pointer
	
	mov lLimitOfVPL,eax
	add lLimitOfVPL,esi
	
	mov eax,lRowNubmer	;ищем номер в массиве
	xor ecx,ecx
	;int 3
	@@:
	mov ebx,[esi]
	.if eax!=ebx
		add esi,4
		add ecx,4
		.if esi>=lLimitOfVPL
			jmp Error
		.endif
		jmp @b
	.endif
	mov lDeletingNumber,esi		;указатель на номер в массиве
	
	xor ecx,ecx
	add esi,4		;считаем размер оставшегося куска для перемещения
	.if esi>lLimitOfVPL
		jmp @1@
	.endif
	
	;int 3
	@@:
	mov ebx,[esi]
	.if ebx!=-1
		add ecx,4
		add esi,4
		.if esi>=lLimitOfVPL
			jmp @1@
		.endif
		jmp @b
	.endif
	@1@:
	mov lSizeOFMovingCells,ecx	;размер куска для перемещения
	
	.if lSizeOFMovingCells==0
		sub esi,4
		mov eax,-1
		mov [esi],eax
		jmp Quit
	.endif
	
	invoke VirtualAlloc,0, lSizeOFMovingCells,MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE
	mov CellsBuffer,eax

	mov esi,lDeletingNumber		;копируем кусок в буфер
	add esi,4
	mov edi,CellsBuffer
	mov ecx,lSizeOFMovingCells
	rep movsb
	
	mov edi,lDeletingNumber			;забиваем -1
	mov ecx,lSizeOFMovingCells
	add ecx,4
	mov al,-1
	rep stosb
	
	mov edi,lDeletingNumber			;копируем на место удаленного элемента
	mov esi,CellsBuffer
	mov ecx,lSizeOFMovingCells
	rep movsb
	
	invoke VirtualFree,CellsBuffer,0,MEM_RELEASE
	
	Quit:
	.data
		szDeleteCellVPL1	db "DeleteCellVPL: end",0
	.code 
  	invoke WriteLogFile,addr szDeleteCellVPL1
  	mov eax,1
	ret
	
	
	Error:
	;invoke MessageBox,0,addr ErrorDelCell,addr AppName,MB_OK
	.data
		ErrorDelCell	db	"DeleteCellVPL: Cannot find cell of array.",0
	.code
  	invoke WriteLogFile,addr ErrorDelCell
  	
	mov eax,-1
	ret
DeleteCellVPL endp
ClearVPL	proc	Pointer:DWORD
LOCAL SizeVPL:DWORD
LOCAL MBI:MEMORY_BASIC_INFORMATION

.data
szClearVPL	db "ClearVPL start",0
.code 
  	invoke WriteLogFile,addr szClearVPL
  	
  		
	invoke VirtualQuery,Pointer,addr MBI,sizeof MBI
	mov eax,MBI.RegionSize
	mov SizeVPL,eax
	
	mov edi,Pointer
	mov ecx,SizeVPL
	mov eax,-1
	rep stosb
	
	mov eax,TRUE
	
	Quit:
	
.data
szClearVPL1	db "ClearVPL end",0
.code 
  	invoke WriteLogFile,addr szClearVPL1
  	
	ret

ClearVPL endp

ToolTip	proc
LOCAL wc:WNDCLASSEX
LOCAL msg:MSG
LOCAL lToolTipRect:RECT

	.if fCreateToolTip==1
		jmp Quit
	.endif
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov   wc.lpfnWndProc, OFFSET WndToolTipProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_INFOTEXT+2
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET WinClassName3
	
	invoke LoadIcon,hInstance,600
	;xor eax,eax
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax

	invoke RegisterClassEx, addr wc
	
	mov lToolTipRect.left,0
	mov lToolTipRect.right,50 ;eax
	mov lToolTipRect.top,0
	mov lToolTipRect.bottom,50;eax
	
	;invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr ScreenFhonRect,0
	
	invoke CreateWindowEx,WS_EX_TOPMOST,ADDR WinClassName3,0,\;WS_THICKFRAME or \
    WS_POPUP ,lToolTipRect.left,lToolTipRect.top,\
    lToolTipRect.right,lToolTipRect.bottom,hWnd,0,hInstance,0
	.if eax!=0
		mov   hToolTip,eax
		mov fCreateToolTip,1
	.endif
	
	Quit:
	ret
ToolTip	endp


WndToolTipProc	proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL lPoint:POINT
LOCAL hdc:HDC
LOCAL ps:PAINTSTRUCT
LOCAL lBuffer [64]:BYTE


	.data
		__szFontName	db "System",0
	.code

	mov		eax,uMsg

	.if eax==WM_CREATE;WM_INITDIALOG
		
		invoke     CreateWindowEx,0 , addr StaticClassName, NULL,\
		WS_CHILD or WS_VISIBLE ,0,0, 392, 210, hWin,111000, hInstance,0
		mov     hSTCToolTip, eax
		
		invoke CreateFont,14,0,0,0,400,0,0,0,OEM_CHARSET,\
		OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
		DEFAULT_QUALITY,DEFAULT_PITCH,addr __szFontName
		mov hFont,eax
		
		invoke SendMessage,hSTCToolTip,WM_SETFONT,eax,0
		
;	.elseif eax==WM_PAINT
;		invoke BeginPaint,hWin, ADDR ps
;		mov    hdc,eax
;		
;		
;		
;		
;		
;		
;		invoke EndPaint,hWin, ADDR ps
		
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetDlgCtrlID,lParam
		.if eax==111000
			;invoke SetBkMode,wParam,OPAQUE ;TRANSPARENT
			RGB 255,255,225
			;mov edx,eax
			;invoke SetTextColor,wParam,edx
			invoke SetBkColor,wParam,eax
			invoke GetStockObject,NULL_BRUSH
		.else
			invoke DefWindowProc, hWin, uMsg, wParam,lParam
		.endif
		ret
		
	.elseif eax==WM_SIZE
		mov eax,lParam
		mov edx,eax
		shr edx,16
		and eax,0FFFFh
		invoke MoveWindow,hSTCToolTip,0,0,eax,edx,TRUE
		
		
	.elseif uMsg==WM_DESTROY
		invoke ShowWindow,hWin,SW_HIDE
		
	.elseif uMsg==WM_CLOSE
		invoke ShowWindow,hWin,SW_HIDE
		
	.else
		invoke DefWindowProc, hWin, uMsg, wParam,lParam
		ret
	.endif
	xor eax,eax
 	ret	
WndToolTipProc endp
HoverPL	proc
LOCAL lPointToolTip:POINT
LOCAL lToolTipBuffer [1024]:BYTE
LOCAL lToolTipWidth:DWORD
LOCAL lToolTipHeight:DWORD
LOCAL lBuffer3 [1024]:BYTE
LOCAL lSizeBuffer3:DWORD
LOCAL lhDC:DWORD
;LOCAL lTTRect:RECT
LOCAL lSizeRow1:DWORD
LOCAL lSizeRow2:DWORD
LOCAL lSizeRow3:DWORD
LOCAL lvi:LV_ITEM
LOCAL lPoint:POINT
LOCAL lvh:LVHITTESTINFO
LOCAL lBuffer [1024]:BYTE
LOCAL lBuffer2 [32]:BYTE
LOCAL lWht:DWORD
LOCAL lWwd:DWORD
LOCAL lrs:RECT
LOCAL lRct:RECT
LOCAL lOldhDC:DWORD
LOCAL lBufferTag [64]:BYTE
LOCAL lTag:TagStruct
LOCAL lSizeTag_Art:DWORD
LOCAL lfMissArtist:DWORD

 	mov fHoverBusy,1
 	invoke Sleep,150
 	mov lfMissArtist,0
 	
	invoke GetCursorPos,addr lPoint
	invoke ScreenToClient,hList,addr lPoint
	mov eax,lPoint.x
	mov lvh.pt.x,eax
	mov eax,lPoint.y
	mov lvh.pt.y,eax
	invoke SendMessage, hList, LVM_HITTEST, 0,addr lvh
	
	invoke SendMessage, hList, LVM_GETITEMCOUNT,0,0
	.if eax<lvh.iItem
		mov fHoverBusy,0
		mov eax,-1
		ret
	.endif
	
	
	mov edx,lvh.iItem
	push edx				;!!!!
	mov lvi.iItem, edx
	mov lvi.iSubItem, 1
	mov lvi.imask, LVIF_TEXT
	lea eax, lBuffer3			;name
	mov lvi.pszText, eax
	mov lvi.cchTextMax, 1024
	invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
	pop edx					;!!!!
	mov edx,lvh.iItem
	push edx				;!!!!
	mov lvi.iItem, edx
	mov lvi.iSubItem, 2
	mov lvi.imask, LVIF_TEXT
	lea eax, lBuffer			;pathname
	mov lvi.pszText, eax
	mov lvi.cchTextMax, 1024
	invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
	pop lvi.iItem			;!!!!
	mov lvi.iSubItem, 3
	mov lvi.imask, LVIF_TEXT
	lea edi, lBuffer2			;priority
	mov lvi.pszText, edi
	xor al,al
	mov ecx,32
	rep stosb
	mov lvi.cchTextMax, 32
	invoke     SendMessage, hList, LVM_GETITEM, 0, addr lvi
	
	invoke lstrlen,addr lBuffer3	;name
	mov lSizeBuffer3,eax
	
	lea edi,lToolTipBuffer
	mov ecx,eax
	lea esi,lBuffer3
	rep movsb
	
	mov ax,0A0Dh
	stosw
	
	;-------
	push edi
	invoke ReadTagMp3Proc,addr lBuffer,addr lTag
	.if eax==-1
		pop edi
		mov lfMissArtist,1
		jmp MissArtist
	.endif
	pop edi
	
	lea esi,szArtist
	mov ecx,6
	rep movsb
	mov al,':'
	stosb
	mov al,' '
	stosb
	mov lSizeTag_Art,8
	
	push edi
	invoke lstrlen,addr lTag.Art
	pop edi
	mov ecx,eax
	add lSizeTag_Art,eax
	lea esi,lTag.Art
	rep movsb
	
	mov ax,0A0Dh
	stosw
	MissArtist:
	;-------
	
	lea esi,szPriority
	mov ecx,8
	rep movsb
	mov al,':'
	stosb
	mov eax,' '
	stosb
	mov eax,dword ptr lBuffer2		;priority
	.if eax==0
		lea esi,szPriority0
		mov ecx,3
		rep movsb
	.elseif eax==1
		lea esi,szPriority1
		mov ecx,6
		rep movsb
	.elseif eax==2
		lea esi,szPriority2
		mov ecx,6
		rep movsb
	.elseif eax==3
		lea esi,szPriority3
		mov ecx,4
		rep movsb
	.endif
	
	
	xor al,al
	stosb
	
	invoke lstrlen,addr lToolTipBuffer
	.if lfMissArtist==0
		sub eax,4
	.else
		sub eax,2
	.endif
	mov lToolTipWidth,eax
	
	
	
	invoke SetWindowText,hSTCToolTip,addr lToolTipBuffer
	
	
	invoke GetDC,hSTCToolTip
	mov lhDC,eax
	
	invoke SelectObject,lhDC,hFont
	mov lOldhDC,eax
	
	invoke GetTextExtentPoint32,lhDC,addr lToolTipBuffer,lSizeBuffer3,addr FSSize
	push FSSize.w
	pop lSizeRow1
	
	.if lfMissArtist==0
		mov edx,lSizeBuffer3
		add edx,lSizeTag_Art
		invoke GetTextExtentPoint32,lhDC,addr lToolTipBuffer,edx,addr FSSize
		push FSSize.w
		pop eax
		sub eax,lSizeRow1
		mov lSizeRow2,eax
	.else
		mov lSizeRow2,0
	.endif

	invoke GetTextExtentPoint32,lhDC,addr lToolTipBuffer,lToolTipWidth,addr FSSize
	push FSSize.w
	pop eax
	sub eax,lSizeRow1
	sub eax,lSizeRow2
	mov lSizeRow3,eax
	
	.if lfMissArtist==0
		mov eax,lSizeRow1
		.if eax>lSizeRow2
			@@:
			.if eax>lSizeRow3
				jmp @f
			.else
				mov eax,lSizeRow3
			.endif
		.else
			mov eax,lSizeRow2
			jmp @b
		.endif
		@@:
		push eax
		pop FSSize.w
	.else
		mov eax,lSizeRow1
		.if eax>lSizeRow3
			push eax
			pop FSSize.w
		.else
			push lSizeRow3
			pop FSSize.w
		.endif
	.endif
	
	
	
	
	mov eax,FSSize.h
	xor edx,edx
	.if lfMissArtist==0
		mov ecx,3			;amount of row in tooltip
	.else
		mov ecx,2
	.endif
	mul ecx
	mov FSSize.h,eax
	
	invoke SelectObject, lhDC, lOldhDC

	
	invoke GetCursorPos,addr lPointToolTip
	add lPointToolTip.y,24
	add lPointToolTip.x,16
	
	invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr lrs,0
	invoke GetWindowRect,hToolTip,addr lRct
	mov edx,lRct.bottom
	sub edx,lRct.top			;edx=Height
	mov lWht,edx
	mov edx,lRct.right
	sub edx,lRct.left		;edx==Width
	mov lWwd,edx
	mov eax,lPointToolTip.y
	add eax,lWht
	.if eax>lrs.bottom
		mov eax,lWht
		sub lPointToolTip.y,eax
	.endif
	mov eax,lPointToolTip.x
	add eax,lWwd
	.if eax>lrs.right
		mov eax,Wwd
		sub lPointToolTip.x,eax
	.endif
	
	invoke MoveWindow,hToolTip,lPointToolTip.x,lPointToolTip.y,FSSize.w,FSSize.h,TRUE
	
	
	mov fHoverBusy,0
	
	ret

HoverPL endp

WriteLogFile	proc uses eax ebx ecx edx edi esi	szString:DWORD
LOCAL l_CurrentDir2 [512]:BYTE
LOCAL l_hFile:DWORD
LOCAL l_dFileSize:DWORD
LOCAL l_dBytesWritten:DWORD
LOCAL l_dStrSize:DWORD
LOCAL l_Time:SYSTEMTIME
LOCAL l_Buffer [1024]:BYTE


.data
	szLogFileName	db	"MaxPlayerLogFile.txt",0
	szNotOpenLog	db	"Error with openning log file",0
	l_endStr		dd 00000A0Dh
	szFormatOfTime	db "%02u %02u %02u %04u",0
.code
	
	ret ;!!!!!!!!
	
	pushad
	pushfd
	
	lea edi,l_CurrentDir2
	mov ecx,512
	xor al,al
	rep stosb
	
;	invoke GetCurrentDirectory,512,addr l_CurrentDir2
;	.if eax==0
;		ret
;	.endif
;	
;	
;	invoke lstrlen,addr l_CurrentDir2
;	lea edi,l_CurrentDir2
;	add edi,eax
;	mov al,'\'
;	stosb
;	
;	lea esi,szLogFileName
;	mov ecx,20			 ;!!!
;	rep movsb
;	mov al,0
;	stosb
	invoke CreateFile,ADDR szLogFileName,GENERIC_READ or GENERIC_WRITE, \
	FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,NULL,NULL
	.if eax==INVALID_HANDLE_VALUE 
		;invoke MessageBox, NULL, ADDR szNotOpenLog, ADDR AppName, MB_OK
		popfd
		popad
		ret
	.endif 
	mov l_hFile,eax
	invoke GetFileSize,l_hFile,NULL
	.if eax>100000
		mov eax,0
	.endif
	mov l_dFileSize,eax
	
	invoke GetLocalTime,addr l_Time
	
	movsx edx,l_Time.wHour
	movsx ecx,l_Time.wMinute
	movsx ebx,l_Time.wSecond
	movsx eax,l_Time.wMilliseconds
	invoke wsprintf,addr l_Buffer,addr szFormatOfTime,edx,ecx,ebx,eax 
	
	invoke lstrlen,addr l_Buffer
	lea edi,l_Buffer
	add edi,eax
	mov al,' '
	stosb
	push edi
	invoke lstrlen,szString
	mov ecx,eax
	pop edi
	mov esi,szString
	rep movsb
	xor al,al
	stosb
	
	
	
	invoke lstrlen,addr l_Buffer
	mov l_dStrSize,eax
	
	invoke SetFilePointer,l_hFile,l_dFileSize,0,0
	invoke WriteFile,l_hFile,addr l_Buffer,l_dStrSize,addr l_dBytesWritten,NULL
	
	invoke WriteFile, l_hFile,addr l_endStr,3, addr l_dBytesWritten, NULL
	
	invoke SetEndOfFile,l_hFile
	
	invoke CloseHandle,l_hFile
	
	Exit:
	
	popfd
	popad
	
	ret

WriteLogFile endp

CompareFunc	proc	lParam1:DWORD, lParam2:DWORD, SortType:DWORD
LOCAL lBuffer1 [1024]:BYTE
LOCAL lBuffer2 [1024]:BYTE
LOCAL    lvi:LV_ITEM
	
	mov eax,SortType
	.if eax==1
		mov lvi.iSubItem, 1
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer1
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 1024
		mov eax,lParam1
		mov lvi.iItem, eax
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		
		mov lvi.iSubItem, 1
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer2
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 1024
		mov eax,lParam2
		mov lvi.iItem, eax
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		
		invoke lstrcmpi,addr lBuffer1,addr lBuffer2
	.elseif eax==2
		mov lvi.iSubItem, 1
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer1
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 1024
		mov eax,lParam1
		mov lvi.iItem, eax
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		
		mov lvi.iSubItem, 1
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer2
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 1024
		mov eax,lParam2
		mov lvi.iItem, eax
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		;int 3
		invoke lstrlen,addr lBuffer1
		mov ecx,eax
		lea edi,lBuffer1
		add edi,eax
		mov al,'.'
		std
		repne scasb
		cld
		add edi,2
		;jne Error
		push edi
		
		invoke lstrlen,addr lBuffer2
		mov ecx,eax
		lea edi,lBuffer2
		add edi,eax
		mov al,'.'
		std
		repne scasb
		cld
		add edi,2
		pop esi
		
		invoke lstrcmpi,esi,edi
	.elseif eax==3
		mov lvi.iSubItem, 2
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer1
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 1024
		mov eax,lParam1
		mov lvi.iItem, eax
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		
		mov lvi.iSubItem, 2
		mov lvi.imask, LVIF_TEXT
		lea eax,lBuffer2
		mov lvi.pszText, eax
		mov lvi.cchTextMax, 1024
		mov eax,lParam2
		mov lvi.iItem, eax
		invoke SendMessage, hList, LVM_GETITEM, 0, addr lvi
		
		invoke lstrcmpi,addr lBuffer1,addr lBuffer2
	.endif
	
	ret

CompareFunc endp

FindStringInPl	proc	String:DWORD, hListView:DWORD, SubItem:DWORD
LOCAL lvi:LV_ITEM
LOCAL lBuffer [32]:BYTE
LOCAL lItemCount:DWORD


	invoke SendMessage, hListView, LVM_GETITEMCOUNT,0,0
	mov lItemCount,eax
	
	mov eax,SubItem
	mov lvi.iSubItem,eax
	mov lvi.imask, LVIF_TEXT
	lea eax,lBuffer
	mov lvi.pszText, eax
	mov lvi.cchTextMax, 32
	mov lvi.iItem, 0
	
	@@:
	
	invoke SendMessage, hListView, LVM_GETITEM, 0, addr lvi
	invoke lstrcmpi,addr lBuffer,String
	je Quit
	inc lvi.iItem
	mov eax,lvi.iItem
	.if eax>lItemCount
		mov eax,-1
		ret
	.endif
	jmp @b
	
	Quit:
	mov eax,lvi.iItem
	ret
FindStringInPl	endp

HotButtonsProc	proc	wParam:DWORD, Focus:DWORD
LOCAL lRect:RECT
	
	;int 3
	mov eax,wParam
	.if eax==VK_ESCAPE
		call KillAllProc
		invoke PostQuitMessage,0
	.elseif eax==VK_SPACE
		invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
	.elseif eax==VK_RETURN
		.if PLSelected==-1
			ret
		.endif
		mov eax,PLSelected
		mov PLFocus,eax
		invoke AVIPlay3,eax
	.elseif eax==VK_N
		invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN5, NULL
	.elseif eax==VK_B
		invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN6, NULL
	.elseif eax==VK_O
		invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN1, NULL
	.elseif eax==VK_P
		invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
	.elseif eax==VK_S
		invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN3, NULL
	.elseif eax==VK_I
		invoke  SendMessage, hPL , WM_COMMAND , IDM_FileInfo, NULL
		jmp Quit
	.elseif eax==VK_J	
		invoke  SendMessage, hPL , WM_COMMAND , IDM_SearchPL, NULL
		jmp Quit
	.elseif eax==VK_R
		invoke  SendMessage, hPL , WM_COMMAND , IDM_Rename, NULL
		jmp Quit
	.elseif eax==VK_0 || eax==60h ;base and num
		invoke  SendMessage, hPL , WM_COMMAND , IDM_Priority0, NULL
		jmp Quit
	.elseif eax==VK_1 || eax==61h

		invoke  SendMessage, hPL , WM_COMMAND , IDM_Priority1, NULL
		jmp Quit
	.elseif eax==VK_2 || eax==62h
		invoke  SendMessage, hPL , WM_COMMAND , IDM_Priority2, NULL
		jmp Quit
	.elseif eax==VK_3 || eax==63h
		invoke  SendMessage, hPL , WM_COMMAND , IDM_Priority3, NULL
		jmp Quit
	.elseif eax==VK_V
		invoke CreateVideoOptionDLG,TRUE
		.if fFullScreen==1 
			invoke SetForegroundWindow,hDlg5
			.if fCurHidden==1
				invoke ShowCursor,TRUE
				mov fCurHidden,0
			.endif
		.endif
		jmp Quit
	.elseif eax==VK_LEFT
		;int 3
		.if fPause==0
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.endif
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_GETPOS,0,0
		dec eax
		jl @f
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,eax
		invoke SetPosition
		invoke GetPosition
		invoke UpdateSTC2,1
		@@:
	.elseif eax==VK_RIGHT
		.if fPause==0
			invoke  SendMessage, hWnd , WM_COMMAND , IDC_BTN2, NULL
		.endif
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_GETPOS,0,0
		inc eax
		jl @f
		invoke SendDlgItemMessage,hWnd,IDC_TBR1,TBM_SETPOS,TRUE,eax
		invoke SetPosition
		invoke GetPosition
		invoke UpdateSTC2,1
		@@:
	.elseif eax==70h		;F1
		.if fRun==1 && fAudio==0
			vmr_mixercontrol9 SetOutputRect,pMControl9,0,addr NORMALIZEDRECT
		.endif
	.elseif eax==71h		;F2
		.if fRun==1 && fAudio==0
			vmr_mixercontrol9 SetOutputRect,pMControl9,0,addr NORMALIZEDRECT_ZER
		.endif
	.elseif eax==72h		;F3
		.if fRun==1 && fAudio==0
			vmr_mixercontrol9 SetOutputRect,pMControl9,0,addr NORMALIZEDRECT_180
		.endif
	.elseif eax==VK_M
		invoke SendMessage,hWnd,WM_COMMAND,IDM_TurnOffMonitor,0
		
	.elseif eax==VK_F
		invoke  SendMessage, hPL , WM_COMMAND , IDM_FindPL, NULL
		jmp Quit
	.elseif eax==VK_T	;Test
		;mseeking SetRate,pSeeking,Rate3
	.else
		mov eax,0
		ret
	.endif
	
	mov eax,Focus
	.if eax==hWnd
		invoke SetFocus,hWnd
	.elseif eax==hPL
		invoke SetFocus,hPL
	.endif
	Quit:
	mov eax,1
	ret

HotButtonsProc endp

BlendText	proc _AppName:DWORD, _SizeOfType:DWORD, _szFontName:DWORD
LOCAL hDC:DWORD
LOCAL hdcBmp:DWORD
LOCAL lhFont:DWORD
LOCAL hOldFont:DWORD
LOCAL hBmp:DWORD
LOCAL hBmpOld:DWORD
LOCAL LengthStr:DWORD
LOCAL bmpStruct:BITMAP
LOCAL rcText:RECT
	
	
	.if fAudio==1
		ret
	.endif
	
	invoke CreateFont,_SizeOfType,0,0,0,400,0,0,0,OEM_CHARSET,\
	OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
	DEFAULT_QUALITY,DEFAULT_PITCH,_szFontName
	mov lhFont,eax
	
	invoke GetDC,hSTC1	;Create a device context compatible with the current window
	mov hDC,eax
	invoke CreateCompatibleDC,hDC
	mov hdcBmp,eax
	
	invoke SelectObject,hdcBmp,lhFont	;select font into our HDC
	mov hOldFont,eax
	
	invoke lstrlen, _AppName	;Determine the length of the string
	mov LengthStr,eax
	
	invoke GetTextExtentPoint32,hdcBmp, _AppName,LengthStr,addr _FontSizeStruct	;determine the dimensions (in pixels) of the character string using the currently selected font

	invoke CreateCompatibleBitmap,hDC, _FontSizeStruct.x, _FontSizeStruct.y	;Create a new bitmap that is compatible with the current window
	mov hBmp,eax
	invoke ReleaseDC,hSTC1,hDC
	
	invoke GetObject,hBmp,SIZEOF bmpStruct,addr bmpStruct	;Select our bitmap into the device context and save the old one
	invoke SelectObject,hdcBmp,hBmp
	mov hBmpOld,eax
	
	invoke SetRect,addr rcText,0,0, _FontSizeStruct.x, _FontSizeStruct.y	;Set initial bitmap settings
	RGB 255,255,225
	invoke SetBkColor,hdcBmp,eax
	RGB 34,39,238
	invoke SetTextColor,hdcBmp,eax

	invoke TextOut,hdcBmp,0,0, _AppName,LengthStr	;Draw the requested text string onto the bitmap

	mov VMRALPHABITMAP.VMRdwFlags,VMRBITMAP_HDC	;or VMRBITMAP_SRCCOLORKEY;Configure the VMR's bitmap structure
	mov eax,hdcBmp
	mov VMRALPHABITMAP.VMRhdc,eax	
	
	
    mov eax,rcText.left
    mov VMRALPHABITMAP.VMRrSrc.left,eax
    mov eax,rcText.top
    mov VMRALPHABITMAP.VMRrSrc.top,eax
    mov eax,rcText.right
    mov VMRALPHABITMAP.VMRrSrc.right,eax
    mov eax,rcText.bottom
    mov VMRALPHABITMAP.VMRrSrc.bottom,eax
	
	push VMRfAlpha_05
	pop VMRALPHABITMAP.VMRfAlpha
	
	vmr_mbitmap9 SetAlphaBitmap,pMBitmap9,addr VMRALPHABITMAP	;Give the bitmap to the VMR for display

    invoke SelectObject,hdcBmp,hBmpOld	;Clean up resources
    invoke DeleteObject,hBmp
    invoke SelectObject,hdcBmp,hOldFont
    invoke DeleteObject,lhFont
    invoke DeleteDC,hdcBmp
    
    
    mov fBlendText,1
    mov CountForBlendText,0
    
    
	ret
BlendText endp

UpdateText 	proc	_DeleteBmp:DWORD
	
	.if fAudio==1 || fVMR9Created==0
		ret
	.endif
	
	.if _DeleteBmp==1
		mov VMRALPHABITMAP.VMRfAlpha,0
	.endif
	vmr_mbitmap9 UpdateAlphaBitmapParameters,pMBitmap9,addr VMRALPHABITMAP

	ret

UpdateText endp


WndVideoOptionProc	 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL lPoint:POINT
LOCAL TME:TRACKMOUSEEVENT
LOCAL content[108] :BYTE
LOCAL lsto:DWORD
LOCAL lTRBPos:DWORD
LOCAL lRect:RECT


	mov		eax,uMsg
	
	.if eax==WM_MOUSEMOVE
		
		
	.elseif eax==WM_HSCROLL
		mov eax,wParam
		.if ax==TB_THUMBTRACK
			mov eax,lParam
			.if eax==hTRB3
				jmp WndTRB3
			.elseif eax==hTRB4
				jmp WndTRB4
			.elseif eax==hTRB5
				jmp WndTRB5
			.elseif eax==hTRB6
				jmp WndTRB6
			.endif
		.elseif ax==TB_LINEUP
			mov eax,lParam
			.if eax==hTRB3
				jmp WndTRB3
			.elseif eax==hTRB4
				jmp WndTRB4
			.elseif eax==hTRB5
				jmp WndTRB5
			.elseif eax==hTRB6
				jmp WndTRB6
			.endif
		.elseif ax==TB_LINEDOWN
			mov eax,lParam
			.if eax==hTRB3
				jmp WndTRB3
			.elseif eax==hTRB4
				jmp WndTRB4
			.elseif eax==hTRB5
				jmp WndTRB5
			.elseif eax==hTRB6
				jmp WndTRB6
			.endif
		.elseif ax==TB_ENDTRACK
			mov eax,lParam
			.if eax==hTRB3
				WndTRB3:
				invoke SendDlgItemMessage,hWin,IDC_TRB3,TBM_GETPOS,0,0
				mov lTRBPos,eax
				mov Brightness,eax
				invoke SetVideoOption,ProcAmpControl9_Brightness,eax
				invoke SetVideoSTCText,lTRBPos,hSTC10
			.elseif eax==hTRB4
				WndTRB4:
				invoke SendDlgItemMessage,hWin,IDC_TRB4,TBM_GETPOS,0,0
				mov lTRBPos,eax
				mov Contrast,eax
				invoke SetVideoOption,ProcAmpControl9_Contrast,eax
				invoke SetVideoSTCText,lTRBPos,hSTC11
			.elseif eax==hTRB5
				WndTRB5:
				invoke SendDlgItemMessage,hWin,IDC_TRB5,TBM_GETPOS,0,0
				mov lTRBPos,eax
				mov Hue,eax
				invoke SetVideoOption,ProcAmpControl9_Hue,eax
				invoke SetVideoSTCText,lTRBPos,hSTC12
			.elseif eax==hTRB6
				WndTRB6:
				invoke SendDlgItemMessage,hWin,IDC_TRB6,TBM_GETPOS,0,0
				mov lTRBPos,eax
				mov Saturation,eax
				invoke SetVideoOption,ProcAmpControl9_Saturation,eax
				invoke SetVideoSTCText,lTRBPos,hSTC13
			.endif
		.endif
	.elseif eax==WM_KEYDOWN
		mov eax,wParam
		.if eax==VK_ESCAPE
			jmp Exit
		.endif
	.elseif eax==WM_INITDIALOG
		invoke GetDlgItem, hWin,IDC_TRB3
		mov hTRB3,eax
		invoke GetDlgItem, hWin,IDC_TRB4
		mov hTRB4,eax
		invoke GetDlgItem, hWin,IDC_TRB5
		mov hTRB5,eax
		invoke GetDlgItem, hWin,IDC_TRB6
		mov hTRB6,eax
		invoke GetDlgItem, hWin,IDC_BTN9
		mov hBTN9,eax
		invoke GetDlgItem, hWin,IDC_STC10
		mov hSTC10,eax
		invoke GetDlgItem, hWin,IDC_STC11
		mov hSTC11,eax
		invoke GetDlgItem, hWin,IDC_STC12
		mov hSTC12,eax
		invoke GetDlgItem, hWin,IDC_STC13
		mov hSTC13,eax
		
		invoke SetWindowLong,hTRB3,GWL_WNDPROC,addr WndTRBProc3
		mov OldWndTRBProc3,eax
		invoke SetWindowLong,hTRB4,GWL_WNDPROC,addr WndTRBProc4
		mov OldWndTRBProc4,eax
		invoke SetWindowLong,hTRB5,GWL_WNDPROC,addr WndTRBProc5
		mov OldWndTRBProc5,eax
		invoke SetWindowLong,hTRB6,GWL_WNDPROC,addr WndTRBProc6
		mov OldWndTRBProc6,eax
		invoke SetWindowLong,hBTN9,GWL_WNDPROC,addr WndBTN9Proc2
		mov OldWndBTN9Proc2,eax
		
		invoke SendDlgItemMessage,hWin,IDC_TRB3,TBM_SETRANGEMIN,FALSE,0
		invoke SendDlgItemMessage,hWin,IDC_TRB3,TBM_SETRANGEMAX,FALSE,100
		invoke SendDlgItemMessage,hWin,IDC_TRB3,TBM_SETLINESIZE,FALSE,1
		
		invoke SendDlgItemMessage,hWin,IDC_TRB4,TBM_SETRANGEMIN,FALSE,0
		invoke SendDlgItemMessage,hWin,IDC_TRB4,TBM_SETRANGEMAX,FALSE,100
		invoke SendDlgItemMessage,hWin,IDC_TRB4,TBM_SETLINESIZE,FALSE,1
		
		invoke SendDlgItemMessage,hWin,IDC_TRB5,TBM_SETRANGEMIN,FALSE,0
		invoke SendDlgItemMessage,hWin,IDC_TRB5,TBM_SETRANGEMAX,FALSE,100
		invoke SendDlgItemMessage,hWin,IDC_TRB5,TBM_SETLINESIZE,FALSE,1
		
		invoke SendDlgItemMessage,hWin,IDC_TRB6,TBM_SETRANGEMIN,FALSE,0
		invoke SendDlgItemMessage,hWin,IDC_TRB6,TBM_SETRANGEMAX,FALSE,100
		invoke SendDlgItemMessage,hWin,IDC_TRB6,TBM_SETLINESIZE,FALSE,1
		
		.if fRun==0 || fAudio==1 || fVMR9Created==0
			invoke EnableWindow,hTRB3,0
			invoke EnableWindow,hTRB4,0
			invoke EnableWindow,hTRB5,0
			invoke EnableWindow,hTRB6,0
			;mov fDisableVideoTRBs,1
			jmp Quit
		.endif
		                   ;Get default video adjustments
		mov VMR9ProcAmpControl.dwSize,sizeof _VMR9ProcAmpControl
		mov VMR9ProcAmpControl.dwFlags,0
		vmr_mixercontrol9 GetProcAmpControl,pMControl9,0,addr VMR9ProcAmpControl
		
		                         ;set slider Brightness   
		invoke SetVideoOptionSliderPos,ProcAmpControl9_Brightness,hTRB3
		mov Brightness,eax     
		invoke SetVideoSTCText,eax,hSTC10  
		                        ;set slider Contrast
		invoke SetVideoOptionSliderPos,ProcAmpControl9_Contrast,hTRB4
		mov Contrast,eax 
		invoke SetVideoSTCText,eax,hSTC11 
		                            ;set slider Hue
		invoke SetVideoOptionSliderPos,ProcAmpControl9_Hue,hTRB5
		mov Hue,eax 
		invoke SetVideoSTCText,eax,hSTC12 
		                     ;set slider Saturation
		invoke SetVideoOptionSliderPos,ProcAmpControl9_Saturation,hTRB6
		mov Saturation,eax 
		invoke SetVideoSTCText,eax,hSTC13 
		mov fVideoOptionsSaved,1
		Quit:
		invoke GetWindowRect,hWnd,addr lRect
		invoke MoveWindow,hWin,lRect.right,lRect.top,304,307,TRUE
		
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		.if ax==IDC_BTN9 && fAudio==0
			shr eax,16
			.if ax==BN_CLICKED
				.if fVMR9Created==1
					invoke SetDefaultVideoOptions
					mov VMR9ProcAmpControl.dwSize,sizeof VMR9ProcAmpControl
					mov VMR9ProcAmpControl.dwFlags,0
					vmr_mixercontrol9 GetProcAmpControl,pMControl9,0,addr VMR9ProcAmpControl
					invoke SetVideoOptionSliderPos,ProcAmpControl9_Brightness,hTRB3
					mov Brightness,eax
					invoke SetVideoSTCText,eax,hSTC10 
					invoke SetVideoOptionSliderPos,ProcAmpControl9_Contrast,hTRB4
					mov Contrast,eax
					invoke SetVideoSTCText,eax,hSTC11 
					invoke SetVideoOptionSliderPos,ProcAmpControl9_Hue,hTRB5
					mov Hue,eax
					invoke SetVideoSTCText,eax,hSTC12 
					invoke SetVideoOptionSliderPos,ProcAmpControl9_Saturation,hTRB6
					mov Saturation,eax
					invoke SetVideoSTCText,eax,hSTC13 
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		Exit:
		mov fVideoOptionCreated,0
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

WndVideoOptionProc endp
SetDefaultVideoOptions	proc
	
	.if fVMR9Created==0
		jmp Quit
	.endif
	mov VMR9ProcAmpControlRange.dwSize,sizeof VMR9ProcAmpControlRange
	mov VMR9ProcAmpControlRange.VMR9ProcAmpControlFlags,ProcAmpControl9_Brightness
	vmr_mixercontrol9 GetProcAmpControlRange,pMControl9,0,addr VMR9ProcAmpControlRange

	mov VMR9ProcAmpControl.dwSize,sizeof VMR9ProcAmpControl
	mov VMR9ProcAmpControl.dwFlags,ProcAmpControl9_Brightness
	mov eax,VMR9ProcAmpControlRange.DefaultValue
	mov VMR9ProcAmpControl.Brightness,eax
	vmr_mixercontrol9 SetProcAmpControl,pMControl9,0,addr VMR9ProcAmpControl


	mov VMR9ProcAmpControlRange.dwSize,sizeof VMR9ProcAmpControlRange
	mov VMR9ProcAmpControlRange.VMR9ProcAmpControlFlags,ProcAmpControl9_Contrast
	vmr_mixercontrol9 GetProcAmpControlRange,pMControl9,0,addr VMR9ProcAmpControlRange

	mov VMR9ProcAmpControl.dwSize,sizeof VMR9ProcAmpControl
	mov VMR9ProcAmpControl.dwFlags,ProcAmpControl9_Contrast
	mov eax,VMR9ProcAmpControlRange.DefaultValue
	mov VMR9ProcAmpControl.Contrast,eax
	vmr_mixercontrol9 SetProcAmpControl,pMControl9,0,addr VMR9ProcAmpControl



	mov VMR9ProcAmpControlRange.dwSize,sizeof VMR9ProcAmpControlRange
	mov VMR9ProcAmpControlRange.VMR9ProcAmpControlFlags,ProcAmpControl9_Hue
	vmr_mixercontrol9 GetProcAmpControlRange,pMControl9,0,addr VMR9ProcAmpControlRange

	mov VMR9ProcAmpControl.dwSize,sizeof VMR9ProcAmpControl
	mov VMR9ProcAmpControl.dwFlags,ProcAmpControl9_Hue
	mov eax,VMR9ProcAmpControlRange.DefaultValue
	mov VMR9ProcAmpControl.Hue,eax
	vmr_mixercontrol9 SetProcAmpControl,pMControl9,0,addr VMR9ProcAmpControl



	mov VMR9ProcAmpControlRange.dwSize,sizeof VMR9ProcAmpControlRange
	mov VMR9ProcAmpControlRange.VMR9ProcAmpControlFlags,ProcAmpControl9_Saturation
	vmr_mixercontrol9 GetProcAmpControlRange,pMControl9,0,addr VMR9ProcAmpControlRange

	mov VMR9ProcAmpControl.dwSize,sizeof VMR9ProcAmpControl
	mov VMR9ProcAmpControl.dwFlags,ProcAmpControl9_Saturation
	mov eax,VMR9ProcAmpControlRange.DefaultValue
	mov VMR9ProcAmpControl.Saturation,eax
	vmr_mixercontrol9 SetProcAmpControl,pMControl9,0,addr VMR9ProcAmpControl
	
	Quit:
	ret

SetDefaultVideoOptions endp
SetVideoOption	proc	_ProcAmpControl9:DWORD,_TRBPos:DWORD
LOCAL lsto:DWORD
LOCAL content[108]:BYTE

	.if fVMR9Created==0
		jmp Quit
	.endif
	
	mov VMR9ProcAmpControlRange.dwSize,sizeof VMR9ProcAmpControlRange
	mov eax,_ProcAmpControl9
	mov VMR9ProcAmpControlRange.VMR9ProcAmpControlFlags,eax
	vmr_mixercontrol9 GetProcAmpControlRange,pMControl9,0,addr VMR9ProcAmpControlRange
	fsave content
	fld VMR9ProcAmpControlRange.MaxValue
	fld VMR9ProcAmpControlRange.MinValue
	fsub
	mov lsto,100
	fild lsto
	fdiv
	fild _TRBPos
	fmul
	fld VMR9ProcAmpControlRange.MinValue
	fadd
	.if _ProcAmpControl9==ProcAmpControl9_Brightness
		fstp VMR9ProcAmpControl.Brightness
	.elseif _ProcAmpControl9==ProcAmpControl9_Contrast
		fstp VMR9ProcAmpControl.Contrast
	.elseif _ProcAmpControl9==ProcAmpControl9_Hue
		fstp VMR9ProcAmpControl.Hue
	.elseif _ProcAmpControl9==ProcAmpControl9_Saturation
		fstp VMR9ProcAmpControl.Saturation
	.endif
	frstor  content
	
	mov VMR9ProcAmpControl.dwSize,sizeof VMR9ProcAmpControl
	mov eax,_ProcAmpControl9
	mov VMR9ProcAmpControl.dwFlags,eax
	vmr_mixercontrol9 SetProcAmpControl,pMControl9,0,addr VMR9ProcAmpControl
	
	Quit:
	ret

SetVideoOption endp
SetVideoOptionSliderPos	proc _ProcAmpControl9:DWORD,_hTRB:DWORD
LOCAL lTRBPos:DWORD
LOCAL lsto:DWORD
LOCAL content[108]:BYTE
	
	.if fVMR9Created==0
		jmp Quit
	.endif
	
	mov VMR9ProcAmpControlRange.dwSize,sizeof VMR9ProcAmpControlRange
	mov eax,_ProcAmpControl9
	mov VMR9ProcAmpControlRange.VMR9ProcAmpControlFlags,eax
	vmr_mixercontrol9 GetProcAmpControlRange,pMControl9,0,addr VMR9ProcAmpControlRange
	fsave content
	.if _ProcAmpControl9==ProcAmpControl9_Brightness
		fld VMR9ProcAmpControl.Brightness
	.elseif _ProcAmpControl9==ProcAmpControl9_Contrast
		fld VMR9ProcAmpControl.Contrast
	.elseif _ProcAmpControl9==ProcAmpControl9_Hue
		fld VMR9ProcAmpControl.Hue
	.elseif _ProcAmpControl9==ProcAmpControl9_Saturation
		fld VMR9ProcAmpControl.Saturation
	.endif
	fld VMR9ProcAmpControlRange.MinValue
	fsub
	fld VMR9ProcAmpControlRange.MaxValue
	fld VMR9ProcAmpControlRange.MinValue
	fsub
	fdiv
	mov lsto,100
	fild lsto
	fmul
	frndint
	lea eax,lTRBPos
	fistp dword ptr [eax]
	frstor  content
	invoke SendMessage,_hTRB,TBM_SETPOS,TRUE,lTRBPos
	mov eax,lTRBPos
	
	Quit:
	ret

SetVideoOptionSliderPos endp
WndTRBProc3 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg5,WM_CLOSE,0,0
		.else
			invoke CallWindowProc,OldWndTRBProc3,hWin,uMsg,wParam,lParam
			ret
		.endif
	.elseif uMsg==WM_MOUSEWHEEL
		xor eax,eax
		mov ax,TB_LINEUP
		invoke SendMessage, hDlg5,WM_HSCROLL,eax,hWin
		invoke CallWindowProc,OldWndTRBProc6,hWin,uMsg,wParam,lParam
		ret
	.else
		invoke CallWindowProc,OldWndTRBProc3,hWin,uMsg,wParam,lParam
		ret
	.endif
	
	xor eax,eax
	ret
WndTRBProc3 endp

WndTRBProc4 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg5,WM_CLOSE,0,0
		.else
			invoke CallWindowProc,OldWndTRBProc4,hWin,uMsg,wParam,lParam
			ret
		.endif
	.elseif uMsg==WM_MOUSEWHEEL
		xor eax,eax
		mov ax,TB_LINEUP
		invoke SendMessage, hDlg5,WM_HSCROLL,eax,hWin
		invoke CallWindowProc,OldWndTRBProc6,hWin,uMsg,wParam,lParam
		ret
	.else
		invoke CallWindowProc,OldWndTRBProc4,hWin,uMsg,wParam,lParam
		ret
	.endif
	
	xor eax,eax
	ret
WndTRBProc4 endp

WndTRBProc5 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg5,WM_CLOSE,0,0
		.else
			invoke CallWindowProc,OldWndTRBProc5,hWin,uMsg,wParam,lParam
			ret
		.endif
	.elseif uMsg==WM_MOUSEWHEEL
		xor eax,eax
		mov ax,TB_LINEUP
		invoke SendMessage, hDlg5,WM_HSCROLL,eax,hWin
		invoke CallWindowProc,OldWndTRBProc6,hWin,uMsg,wParam,lParam
		ret
	.else
		invoke CallWindowProc,OldWndTRBProc5,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndTRBProc5 endp
WndTRBProc6 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg5,WM_CLOSE,0,0
		.else
			invoke CallWindowProc,OldWndTRBProc6,hWin,uMsg,wParam,lParam
			ret
		.endif
	.elseif uMsg==WM_MOUSEWHEEL
		xor eax,eax
		mov ax,TB_LINEUP
		invoke SendMessage, hDlg5,WM_HSCROLL,eax,hWin
		invoke CallWindowProc,OldWndTRBProc6,hWin,uMsg,wParam,lParam
		ret
	.else
		invoke CallWindowProc,OldWndTRBProc6,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndTRBProc6 endp

WndBTN9Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg5,WM_CLOSE,0,0
		.endif
	.else
		invoke CallWindowProc,OldWndBTN9Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndBTN9Proc2 endp

CreateVideoOptionDLG	proc Visibility:DWORD

	cmp fVideoOptionCreated,1
	je Quit
	invoke CreateDialogParam,hInstance,IDD_DIALOG5,hWnd,addr WndVideoOptionProc,0;lParam
	mov hDlg5,eax
	mov fVideoOptionCreated,1
	.if Visibility==1
		invoke ShowWindow,hDlg5,SW_SHOW
	.endif
	Quit:
	
	ret
CreateVideoOptionDLG endp

SetVideoSTCText	proc	_TRBPos:DWORD,_hSTC:DWORD
LOCAL lBuffer [64]:BYTE
LOCAL lBuffer2 [128]:BYTE

	mov edx,_TRBPos
	lea edi,lBuffer
	xor al,al
	mov ecx,64
	rep stosb
	invoke dw2a,edx,addr lBuffer
	lea edi,lBuffer
	xor ecx,ecx
	@@:
	add ecx,1
	cmp ecx,64
	je @f
	add edi,1
	mov al,byte ptr [edi]
	cmp al,0
	jne @b
	mov al,'%'
	stosb
	@@:
	invoke GetWindowText,_hSTC,addr lBuffer2,60
	lea edi,lBuffer2
	xor ecx,ecx
	@@:
	add ecx,1
	cmp ecx,128
	je @f
	add edi,1
	mov al,byte ptr [edi]
	cmp al,' '
	jne @b
	add edi,1
	xor al,al
	stosb
	invoke lstrcat,addr lBuffer2,addr lBuffer
	invoke SetWindowText,_hSTC,addr lBuffer2
	@@:
	
	ret
SetVideoSTCText	endp

EnumFilters	proc	_pGraph:DWORD
LOCAL lpEnum:DWORD
LOCAL lpFilter:DWORD
LOCAL lcFetched:DWORD
LOCAL lBuffer [260]:BYTE
LOCAL __FilterInfo:_FilterInfo
	
	.data
		szAVIPlay111	db "EnumFilters:",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay111
	
	mov lpEnum,0
	mov lpFilter,0
	
	gbuilder EnumFilters,_pGraph,addr lpEnum
	
	@@:
	lea edi,lBuffer
	xor eax,eax
	mov ecx,260
	rep stosb
	lea edi,__FilterInfo
	xor eax,eax
	mov ecx,132
	rep stosb
	
	epins Next,lpEnum,1,addr lpFilter,addr lcFetched
	cmp eax,0
	jnz @f
	bfilter QueryFilterInfo,lpFilter,addr __FilterInfo
	
	invoke WideCharToMultiByte,CP_ACP, 0,addr __FilterInfo.achName,-1,addr lBuffer, 256, 0, 0
	invoke WriteLogFile,addr lBuffer
	;invoke MessageBox,0,addr lBuffer,addr AppName,MB_OK
	
	
	gbuilder Release,_pGraph
	bfilter Release,lpFilter
	jmp @b
	
	@@:
	epins Release,lpEnum
	
	.data
		szAVIPlay1	db "EnumFilters end",0
	.code 
  	invoke WriteLogFile,addr szAVIPlay1
  		
    ret
EnumFilters endp

WndWarnTurnOffMonitor proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL lBuffer [64]:BYTE
	
	mov		eax,uMsg

	.if eax==WM_INITDIALOG
		invoke GetDlgItem, hWin,IDC_STC14
		mov hSTC14,eax
		invoke GetDlgItem, hWin,IDC_STC15
		mov hSTC15,eax
		;invoke SetWindowText,hSTC14,addr szWarnTurnOffMonitor
		invoke SetTimer,hWin,IDC_TIMER3,500,NULL
		mov hTimer3,eax
		mov CountForTurnOffMonitor,5
	.elseif eax==WM_SIZE
		mov eax,lParam
		mov edx,eax
		shr edx,16
		and eax,0FFFFh
		invoke MoveWindow,hSTC14,0,0,eax,edx,TRUE
	.elseif eax==WM_TIMER
		.if fTurnOffMonitor==1
			invoke KillTimer,hWin,hTimer3
			;mov hTimer3,0 
			invoke SendMessage,HWND_BROADCAST,WM_SYSCOMMAND, SC_MONITORPOWER,1
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.else
			mov edx,CountForTurnOffMonitor
			invoke dw2a,edx,addr lBuffer
			invoke SetWindowText,hSTC15,addr lBuffer
			sub CountForTurnOffMonitor,1
			jnz @f
			mov fTurnOffMonitor,1
			@@:
		.endif
		
	.elseif eax==WM_CLOSE
		;mov hSTC14,0
		;mov hSTC15,0
		mov fTurnOffMonitor,0
		mov fWndWarnTurnOffMonitorIs,0
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret
WndWarnTurnOffMonitor endp

LoadBitmaps	proc
	
	.if fSilver==0
		invoke LoadBitmap,hInstance,601		
		mov hOpenBtnBmp,eax 
		invoke SendMessage,hBTN1,BM_SETIMAGE,0,hOpenBtnBmp
		invoke LoadBitmap,hInstance,602		
		mov hPlayBtnBmp,eax 
		invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
		invoke LoadBitmap,hInstance,603		
		mov hStopBtnBmp,eax 
		invoke SendMessage,hBTN3,BM_SETIMAGE,0,hStopBtnBmp
		invoke LoadBitmap,hInstance,605	
		mov hPlBtnBmp,eax 
		invoke SendMessage,hBTN4,BM_SETIMAGE,0,hPlBtnBmp
		invoke LoadBitmap,hInstance,606
		mov hNextBtnBmp,eax 
		invoke SendMessage,hBTN5,BM_SETIMAGE,0,hNextBtnBmp
		invoke LoadBitmap,hInstance,604
		mov hPrevBtnBmp,eax 
		invoke SendMessage,hBTN6,BM_SETIMAGE,0,hPrevBtnBmp
		invoke LoadBitmap,hInstance,607
		mov hOpenBtnEmbossBmp,eax 
		invoke LoadBitmap,hInstance,608
		mov hNextBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,609
		mov hPlayBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,610
		mov hPlBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,611
		mov hPrevBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,612
		mov hStopBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,613
		mov hPauseBtnBmp,eax
		invoke LoadBitmap,hInstance,614
		mov hPauseBtnEmbossBmp,eax
	.else
		invoke LoadBitmap,hInstance,615
		mov hOpenBtnBmp,eax
		invoke SendMessage,hBTN1,BM_SETIMAGE,0,hOpenBtnBmp
		invoke LoadBitmap,hInstance,621
		mov hOpenBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,616
		mov hPlayBtnBmp,eax
		invoke SendMessage,hBTN2,BM_SETIMAGE,0,hPlayBtnBmp
		invoke LoadBitmap,hInstance,623
		mov hPlayBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,617
		mov hStopBtnBmp,eax
		invoke SendMessage,hBTN3,BM_SETIMAGE,0,hStopBtnBmp
		invoke LoadBitmap,hInstance,626
		mov hStopBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,618
		mov hPrevBtnBmp,eax
		invoke SendMessage,hBTN6,BM_SETIMAGE,0,hPrevBtnBmp
		invoke LoadBitmap,hInstance,625
		mov hPrevBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,619
		mov hPlBtnBmp,eax
		invoke SendMessage,hBTN4,BM_SETIMAGE,0,hPlBtnBmp
		invoke LoadBitmap,hInstance,624
		mov hPlBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,620
		mov hNextBtnBmp,eax
		invoke SendMessage,hBTN5,BM_SETIMAGE,0,hNextBtnBmp
		invoke LoadBitmap,hInstance,622
		mov hNextBtnEmbossBmp,eax
		invoke LoadBitmap,hInstance,627
		mov hPauseBtnBmp,eax
		invoke LoadBitmap,hInstance,628
		mov hPauseBtnEmbossBmp,eax
	.endif
	ret

LoadBitmaps endp

CreateBrushes	proc
LOCAL lb:LOGBRUSH
	
	mov lb.lbStyle, BS_SOLID
	.if fSilver==1
		mov eax,MainColour2
	.else
		mov eax,MainColour
	.endif
	mov lb.lbColor,eax       
	mov lb.lbHatch, NULL
	invoke CreateBrushIndirect,ADDR lb
	mov hBrushMain,eax
	
	
	
	ret

CreateBrushes endp

WndEDT4Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov eax,uMsg
	.if eax==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			invoke SendMessage,hDlg7,WM_CLOSE,0,0
			xor eax,eax
			ret
		.endif
	.elseif eax==WM_SETFOCUS
		;invoke SendMessage,hEDT4,EM_SETSEL,0,0
	.else
		invoke CallWindowProc,OldWndEDT4Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndEDT4Proc2 endp

WndFindPLProc	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;LOCAL FindRect:RECT
LOCAL lPoint:POINT

	mov eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetCursorPos,addr lPoint
		invoke MoveWindow,hWin,lPoint.x,lPoint.y,400,125,TRUE
		invoke GetDlgItem, hWin,IDC_EDT9
		mov hEDT9,eax
		invoke SetWindowLong,hEDT9,GWL_WNDPROC,addr WndEDT9Proc2
		mov OldWndEDT9Proc2,eax
		mov ContinueFind,0
		
		
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		;and		eax,0FFFFh
		.if ax==IDC_BTN10	;find
			shr eax,16
			.if ax==BN_CLICKED
				;int 3
				.if ContinueFind==1
					mov edi,Findlvi.iItem
					add edi,1
					jmp Repeate
				.endif
				invoke     SendMessage, hList, LVM_GETITEMCOUNT,0,0
				.if eax<2
					jmp Quit
				.endif
				mov FindAmountOfItems,eax
				
				invoke GetWindowText,hEDT9,addr BufferFind1,512
				invoke lstrlen,addr BufferFind1
				.if eax<2
					invoke MessageBox,0,addr szFindFewLetters,addr AppName,MB_OK
					jmp Quit
				.endif
				mov Findcount1,eax
				;int 3
				mov Findlvi.iSubItem, 1
				mov Findlvi.imask, LVIF_TEXT
				lea edx,BufferFind2
				mov Findlvi.pszText, edx
				mov Findlvi.cchTextMax,512
				xor edi,edi
				
				Repeate:
				mov     Findlvi.iItem, edi
				invoke     SendMessage, hList, LVM_GETITEM, 0, addr Findlvi
				;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
				push edi
				invoke lstrlen,addr BufferFind2
				sub eax,Findcount1
				jl NotEqual
				mov Findcount2,eax
				
				lea edi,BufferFind2
				Cikl:
				pushad
				mov esi,edi
				lea edi,BufferFind3	;очистим третий буфер
				mov ecx,Findcount1
				.if ecx<512
					add ecx,1
				.endif
				xor eax,eax
				rep stosb
				lea edi,BufferFind3
				;lea esi,lBufferFind2
				mov ecx,Findcount1
				rep movsb
				popad
				invoke lstrcmpi,addr BufferFind1,addr BufferFind3
				je Equal
				add edi,1
				sub Findcount2,1
				jl NotEqual
				jmp Cikl
				
				NotEqual:
				xor eax,eax
				pop edi
				jmp @f
				Equal:
				mov eax,1
				pop edi
				@@:
				;/////////////////////////////////////////////////////
				.if eax!=1
					jmp @f
				.endif
				push edi;count
				pop PLSelected
				invoke InvalidateRect,hPL,0,TRUE
				invoke SendMessage, hList, LVM_ENSUREVISIBLE,PLSelected,FALSE
				mov ContinueFind,1
				jmp QuitFound
				@@:
				
				cmp FindAmountOfItems,edi
				je QuitNotFound
				inc edi;count 
				jmp Repeate
				Quit:
				mov ContinueFind,0
				jmp QuitFound
				QuitNotFound:
				mov ContinueFind,0
				invoke MessageBox,hWin,addr szFindNotFound,addr AppName,MB_OK
				invoke SetFocus,hWin
				invoke SetFocus,hEDT9
				QuitFound:
			.endif
		.elseif ax==IDC_BTN11	
			shr eax,16
			.if ax==BN_CLICKED
				;invoke SendMessage,hDlg8,WM_CLOSE,0,0
				jmp Quit1_1
			.endif
		.endif
	.elseif eax==WM_KEYDOWN 
		.if wParam==VK_ESCAPE
			;invoke SendMessage,hDlg8,WM_CLOSE,0,0
			jmp Quit1_1
		.endif
	;.elseif eax==WM_SIZE
		;mov eax,lParam
		;mov edx,eax
		;shr edx,16
		;and eax,0FFFFh
		;invoke MoveWindow,hEDT1,0,0,eax,edx,TRUE
		
	.elseif eax==WM_CLOSE
		Quit1_1:
		invoke EndDialog,hWin,0
		mov FindExist,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret
WndFindPLProc	endp

WndEDT9Proc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov eax,uMsg
	.if eax==WM_KEYDOWN 
		mov eax,wParam
		.if eax==VK_ESCAPE
			invoke SendMessage,hDlg8,WM_CLOSE,0,0
		.elseif eax==VK_RETURN
			invoke SendMessage,hDlg8,WM_COMMAND,IDC_BTN10,0
		.endif		
		;mov ContinueFind,0
		invoke CallWindowProc,OldWndEDT9Proc2,hWin,uMsg,wParam,lParam
	.else
		invoke CallWindowProc,OldWndEDT9Proc2,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
WndEDT9Proc2 endp

include Genre.asm

end start
