include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc
include ole32.inc
include masm32.inc
include \masm32\include\winmm.inc
	;include \masm32\include\oleaut32.inc
	;includelib \masm32\lib\oleaut32.lib
	;include \masm32\include\masm32.inc
	;includelib \masm32\lib\masm32.lib
	;include \masm32\macros\macros.asm
   INCLUDE  \masm32\include\DShow.inc
   ;include \masm32\include\dxerr9.inc
includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib
includelib ole32.lib
includelib masm32.lib
includelib \masm32\lib\winmm.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc2			PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc3			PROTO :DWORD,:DWORD,:DWORD,:DWORD
dw2a				PROTO :DWORD,:DWORD
TopXY  				PROTO :DWORD,:DWORD
GlueMain			PROTO :DWORD
CmdLineProc			PROTO :DWORD
LoadPL				PROTO :DWORD,:DWORD,:DWORD
IniProc				PROTO :DWORD
AddStr				PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WndListProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD
AVIPlay2			PROTO :DWORD
FillFirstColumn		PROTO :DWORD
SavePL				PROTO :DWORD
AVIOpenFile			PROTO :DWORD
ForFilterProc		PROTO :DWORD,:DWORD
FilterProc			PROTO :DWORD
FindFiles			PROTO :DWORD
WndTBRProc2			PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndTBR2Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndBTN1Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndBTN2Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndBTN3Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndBTN4Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndBTN5Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndBTN6Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndSearchPLProc		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT1Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT9Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndRenameProc		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT2Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT3Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT5Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT6Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT7Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndEDT8Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndCBO1Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndScreenFhonProc	PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndFileInfoProc		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndToolTipProc		PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetGenre			PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProgressWindow	PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProgressProc		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndVideoOptionProc	PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndTRBProc3			PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndTRBProc4			PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndTRBProc5			PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndTRBProc6			PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndBTN9Proc2		PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndWarnTurnOffMonitor	PROTO	:DWORD,:DWORD,:DWORD,:DWORD
WndHelpProc			PROTO	:DWORD,:DWORD,:DWORD,:DWORD
WndEDT4Proc2		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
WndFindPLProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
SetPosition			PROTO
GetMasterVolume		PROTO
ProgressWindow		PROTO
SetMasterVolume		PROTO :DWORD
CloseMasterVolume	PROTO
_CreateMailSlot		PROTO :DWORD
WaitEvent			PROTO
GetTime				PROTO :DWORD
UpdateSTC2			PROTO :DWORD
FindFilesThread		PROTO 
RotateCaption		PROTO :DWORD
ScrollCaptionThread PROTO
SleepProc			PROTO :DWORD
RandomPlay			PROTO :DWORD
AVIPlay3			PROTO :DWORD
VideoSize			PROTO
GetScreenShot		PROTO :DWORD
OpenFiles			PROTO :DWORD
FrameStep			PROTO
GetPosition			PROTO
ReadTagMp3Proc		PROTO :DWORD,:DWORD
AddStrVPL			PROTO :DWORD,:DWORD
CreateVPL			PROTO
DestroyVPL			PROTO :DWORD
ClearVPL			PROTO :DWORD
RandomVPL			PROTO :DWORD
DeleteCellVPL		PROTO :DWORD,:DWORD
LoadVPL				PROTO :DWORD
HoverPL				PROTO 
WriteLogFile		PROTO :DWORD
WriteTagMp3Proc		PROTO :DWORD,:DWORD
CompareFunc			PROTO :DWORD,:DWORD,:DWORD
FindStringInPl		PROTO :DWORD,:DWORD,:DWORD
HotButtonsProc		PROTO :DWORD,:DWORD
DecrementCellsVPL	PROTO :DWORD,:DWORD
RandomRDTSC			PROTO :DWORD,:DWORD
BlendText			PROTO :DWORD,:DWORD,:DWORD
UpdateText			PROTO :DWORD
CreateVideoOptionDLG PROTO :DWORD
SetVideoOptionSliderPos PROTO :DWORD,:DWORD
SetVideoOption      PROTO :DWORD,:DWORD
SetDefaultVideoOptions	PROTO
SetVideoSTCText			PROTO :DWORD,:DWORD
EnumFilters				PROTO :DWORD
LoadBitmaps			PROTO
DestroyBitmaps		PROTO
CreateBrushes		PROTO


IDD_DIALOG			equ 1000
IDD_DIALOG2			equ	999
IDD_DIALOG3			equ 998
IDD_DIALOG4			equ 997
IDD_DIALOG5			equ 996	
IDD_DIALOG6			equ 995
IDD_DIALOG7			equ 994
IDD_DIALOG8			equ 993

IDI_TRAY			equ 100000
WM_SHELLNOTIFY 		equ WM_USER+5


IDM_MENU				equ 10000
IDM_FILE_EXIT			equ 10001
IDM_HELP_ABOUT			equ 10101
IDM_TOPMOST				equ	10002
IDM_SaveVideoRatio		equ 10005
IDM_ChangeWindowSize	equ 10006
IDM_Options				equ 10004
IDM_OpenFile			equ 10007
IDM_AddFileToPL			equ 10008
IDM_AddFolderToPL		equ 10009
IDM_NoScrollCaption		equ 10010
IDM_HideVideo			equ 10011
IDM_FileInfo			equ 10012
IDM_RestoreFromTray		equ 10013
IDM_ExitFromTray		equ 10014
IDM_HideInTray			equ 1100
IDM_TurnOffMonitor		equ 1200

IDC_STC1 			equ 1001
IDC_STC2			equ 1010
IDC_STC3			equ 1011
IDC_STC4			equ 1012
IDC_STC5			equ 1013
IDC_STC6			equ 1014
IDC_STC7			equ 1015
IDC_STC8			equ 1016
IDC_STC9			equ 1017
IDC_STC10			equ 1018
IDC_STC11			equ 1019
IDC_STC12			equ 1020
IDC_STC13			equ 1021
IDC_STC14			equ 1022
IDC_STC15			equ 1023

IDC_BTN1			equ 1002
IDC_BTN2			equ 1003
IDC_TBR1			equ 1004
IDC_TBR2			equ 1005
IDC_BTN3			equ 1007
IDC_BTN4			equ 1006
IDC_BTN5			equ 1008
IDC_BTN6			equ 1009
IDC_BTN7			equ 4000
IDC_BTN8			equ 4001
IDC_TRB3			equ 4002
IDC_TRB4			equ 4003
IDC_TRB5			equ 4004
IDC_TRB6			equ 4005
IDC_BTN9			equ 4006
IDC_BTN10			equ 4007
IDC_BTN11			equ 4008

IDC_EDT1			equ 1111
IDC_EDT2			equ 1110
IDC_EDT3			equ 11109
IDC_EDT4			equ 11104
IDC_EDT5			equ 11108
IDC_EDT6			equ 11107
IDC_EDT7			equ 11106
IDC_EDT8			equ 11105
IDC_EDT9			equ 11103

IDC_CBO1			equ 5000
IDC_PROGRESS		equ 6000


IDM_AddFile		equ 1101
IDM_Del			equ 1102
IDM_AddDir		equ 1103
IDM_Save		equ 1104
IDM_DelAll		equ 1105
IDM_Rand		equ 1106
IDM_NoScrollPL	equ 1107
IDM_SearchPL	equ 1108
IDM_Rename		equ 1109
IDM_Options1		equ 1112
IDM_Priority0	equ	1113
IDM_Priority1	equ	1114
IDM_Priority2	equ	1115
IDM_Priority3	equ	1116
IDM_Priority	equ 1117
IDM_SortList	equ 1118
IDM_SortByTitle	equ 1119
IDM_SortByExten	equ 1120
IDM_SortByPath	equ 1121
IDM_ColourSilver	equ 1203
IDM_ColourStandart	equ 1204
IDM_Help			equ 1205
IDM_FindPL			equ 1206

IDM_GetScreenShot	equ	1201
IDM_UseAsFhon		equ	1202

IDC_TIMER 		equ 3000
IDC_TIMER2		equ 3001
IDC_TIMER3		equ 3002

IDC_HOT1		equ 7000
IDC_HOT2		equ 7001
IDC_HOT3		equ 7002
IDC_HOT4		equ 7003
IDC_HOT5		equ 7004

toWrite	equ 1
toRead	equ	2

NOT_MEDIA_TYPE	equ	0
MEDIA_TYPE		equ	1
MPL_TYPE		equ	3
AUDIO_TYPE		equ 2

wheelFrameStep	equ 0
wheelVolume		equ 1


MIXER_ERROR equ 0FFFFFFFFh 
SPEAKEROUTLINEID equ 0FFFF0000h


RGB macro red,green,blue
     xor eax,eax
     mov ah,blue
     shl eax,8
     mov ah,green
     mov al,red
   endm

.data
;	b_hwndOwner				dd 0
;    b_pidlRoot				dd 0
;    b_pszDisplayName		dd OFFSET szFolderName			
;    b_lpszTitle				dd OFFSET szSelectDir
;    b_ulFlags				dd BIF_NEWDIALOGSTYLE or BIF_EDITBOX
;    b_lpfn					dd 0
;    b_lParam				dd 0
;    b_iImage				dd 0


     Filter	          db "Media Files",0,"*.asf;*.avi;*.divx;*.m1v;*.m2v;*.mkv;*.mov;*.mp4;*.mpe;*.mpeg;*.mpg;*.mpv;*.ogm;*.qt;*.ram;*.rm;*.rv;*.vob;*.wm;*.wmv;*.mpl;*.mp3;*.wav;*.wma;*.ac3;*.midi;*.kar;*.3gp;",0,0;

	lStructSize       dd sizeof(OPENFILENAME)
    hwndOwner         dd 0
    hinstance         dd 400000h
    lpstrFilter       dd OFFSET Filter
    lpstrCustomFilter dd 0
    nMaxCustFilter    dd 0
    nFilterIndex      dd 0
    lpstrFile         dd OFFSET szFileName
    nMaxFile          dd 4096
    lpstrFileTitle    dd OFFSET szfilename
    nMaxFileTitle     dd 4096
    lpstrInitialDir   dd 0
    lpstrTitle        dd OFFSET Title_
    Flags             dd OFN_EXPLORER or OFN_LONGNAMES or OFN_OVERWRITEPROMPT or OFN_ALLOWMULTISELECT
    nFileOffset       dw 0
    nFileExtension    dw 0
    lpstrDefExt       dd 0
    lCustData         dd 0
    lpfnHook          dd 0
    lpTemplateName    dd 0
    
	fFileLoad 		    dd 0
    fRun				dd 0                
    fPause				dd 0
    fFullScreen			dd 0
    fNoPause			dd 0
    fGlue				dd 0
    fGlueR				dd 0
    fGlueL				dd 0
    fGlueB				dd 0
    fCreatePL			dd 0
    fTopmost			dd 0
	fMaximized			dd 0
	fMinimized			dd 0
	fFirstLoad			dd 0
	fNotRememberPos		dd 0
    fExit				dd 0
    fSaveVideoRatio		dd 0
    fChangeWindowSize 	dd 0
    fAudio				dd 0
    fExitScrollThread	dd 0
    fNoScrollCaption	dd 0
    fTerminateFindFiles	dd 0
    fExitFindFiles		dd 0
    fRandomPlay			dd 0
    fNoScrollPL			dd 0
    fError				dd 0
    fHideVideo			dd 0
    fAudioWasPrev		dd 0
    fFhonNotFound		dd 0
    fCreateScreenFhon	dd 0
    fKillAll			dd 0
    fCurHidden			dd 0
    fPlayOfPlComplete	dd 0
    fCreateToolTip		dd 0
    fToolTipVisible		dd 0
    fHoverBusy			dd 0
    fNoLog				dd 0
    fCreateProgressWindow	dd	0
    fProgressWindowHidden	dd	0
    fHoverProgWin		dd	0
    fBlendText			dd  0
    fDisableVideoTRBs	dd  0
    fVideoOptionCreated dd  0
    fVideoOptionsSaved  dd  0
    fVMR9Created		dd	0
    fBlendTextShowTime	dd  0
    fWaitEventActive	dd  0
    fCallCmdProcFromWaitEvent	dd  0
    fTray				dd  0
    fHideInTray			dd  0
    fTurnOffMonitor		dd  0
    fMonitorIsTurnedOff	dd	0
    fWndWarnTurnOffMonitorIs	dd	0
    fMute				dd	0
    fSilver				dd  0
    
    CountForMouse		dd 0
    CountForProgressWindow	dd 0
    CountForBlendText		dd 0
    CountForCompleting		dd 0
    CountForTurnOffMonitor	dd 0
    
    
    Title_	          db "Открыть файл",0
    _Title	          db "Сохранить файл",0
    Dir 	          db 0

    szWarning         db "Внимание!",0
    szAVIOpenError    db "Не удалось открыть файл",0
	
   ID_IBasicAudio		GUID	IID_IBasicAudio
   ID_IGraphBuilder     GUID    IID_IGraphBuilder
   ID_IMediaControl     GUID    IID_IMediaControl
   ID_IMediaEventEx     GUID    IID_IMediaEventEx
   ID_IBasicVideo       GUID    IID_IBasicVideo
   ID_IVideoWindow      GUID    IID_IVideoWindow
   ID_IMediaSeeking	    GUID    IID_IMediaSeeking
   ID_IVideoFrameStep	GUID	IID_IVideoFrameStep
   
   ID_IVMRFilterConfig9			GUID	IID_IVMRFilterConfig9
   ID_IVMRWindowlessControl9	GUID	IID_IVMRWindowlessControl9
   ID_IVMRMixerControl9 		GUID 	IID_IVMRMixerControl9
   ID_IVMRMixerBitmap9			GUID	IID_IVMRMixerBitmap9
   ID_IBaseFilter	 			GUID	IID_IBaseFilter
   
	_TIME_FORMAT_NONE       GUID TIME_FORMAT_NONE 
	_TIME_FORMAT_FRAME      GUID TIME_FORMAT_FRAME 
	_TIME_FORMAT_BYTE       GUID TIME_FORMAT_BYTE 
	_TIME_FORMAT_SAMPLE     GUID TIME_FORMAT_SAMPLE
	_TIME_FORMAT_FIELD      GUID TIME_FORMAT_FIELD
	_TIME_FORMAT_MEDIA_TIME GUID TIME_FORMAT_MEDIA_TIME
	
   ;INFINITE equ 0FFFFFFFFh
   ;CLSCTX_INPROC_SERVER  EQU  1
   CLSID_FilterGraph  dd 0E436EBB3h, 11CE524Fh, 2000539Fh, 70A70BAFh, 3031424Eh
	CLSID_SampleGrabber		   dd 0C1F400A0h, 3F0811D3h, 9F0B0060h,  08039E37h
	CLSID_VideoMixingRenderer9 dd 51B4ABF3h,  4E3B748Fh, 28C876A2h, 6A920E33h

	;CLSID_SampleGrabberCB		dd 0579154Ah, 49942B53h, 73E7D0B0h, 85FF8E14h
	                               ;0579154A-2B53-4994- B0 D0-E7 73 14 8E FF 85 


note						NOTIFYICONDATA <>
clientwindow  				RECT <>
;rs 						RECT <>
Rct_MainWindow				RECT <>
Rct1  						RECT <>
;newTime	REFERENCE_TIME <>
 curPos		POINT <>

FontSizeStruct	Struct
	w	dd ?
	h	dd ?
FontSizeStruct ends

FSSize FontSizeStruct <>

TagStruct Struct
Tag db 4 dup (0)
Tit db 31 dup (0)
Art db 31 dup (0)
Alb db 31 dup (0)
Year db 5 dup (0)
Com db 31 dup (0)
Gen db 2 dup (0)
TagStruct ends

_NORMALIZEDRECT_180 struct 
     left	dd 1.0
     top	dd 1.0
     right	dd 0.0
     bottom	dd 0.0
_NORMALIZEDRECT_180 ends
NORMALIZEDRECT_180 _NORMALIZEDRECT_180 <>
_NORMALIZEDRECT struct 
     left	dd 0.0
     top	dd 0.0
     right	dd 1.0
     bottom	dd 1.0
_NORMALIZEDRECT ends
NORMALIZEDRECT _NORMALIZEDRECT <>
_NORMALIZEDRECT_ZER struct 
     left	dd 1.0
     top	dd 0.0
     right	dd 0.0
     bottom	dd 1.0
_NORMALIZEDRECT_ZER ends
NORMALIZEDRECT_ZER _NORMALIZEDRECT_ZER <>

_NORMALIZEDRECT_BMP struct 
     left	dd 0.4
     top	dd 0.03
     right	dd 0.6
     bottom	dd 0.1
_NORMALIZEDRECT_BMP ends
_VMRALPHABITMAP struct
	VMRdwFlags		dd 0
	VMRhdc			dd 0
	VMRpDDS			dd 0
	VMRrSrc			RECT <> 
	VMRrDest		_NORMALIZEDRECT_BMP <>
	VMRfAlpha		dd 0.3
	VMRclrSrcKey	dd 0
_VMRALPHABITMAP ends
VMRALPHABITMAP _VMRALPHABITMAP <>
FontSizeStruct1	struct
	x	dd 0
	y	dd 0
FontSizeStruct1 ends

_FontSizeStruct	FontSizeStruct1	<>

_FilterInfo struct 
    achName db 128 dup (0)
    _pGraph dd 0
_FilterInfo ends



VMRfAlpha_05	dd	0.3


VMR9ProcAmpControl  _VMR9ProcAmpControl <>

VMR9ProcAmpControlRange  _VMR9ProcAmpControlRange <>

MENUINFOA struct
	cbSize			dd	0
    fMask			dd	0
    dwStyle			dd	0
    cyMax			dd	0
    hbrBack			dd	0
    dwContextHelpID	dd	0
    dwMenuData		dd	0
MENUINFOA ends
;MENUINFO	MENUINFOA	<>


lbMenu LOGBRUSH <>

;.const
szTIME_FORMAT_MEDIA_TIME	db	"TIME_FORMAT_MEDIA_TIME",0
szTIME_FORMAT_FIELD		db	"TIME_FORMAT_FIELD",0
szTIME_FORMAT_SAMPLE	db	"TIME_FORMAT_SAMPLE",0
szTIME_FORMAT_BYTE	db	"TIME_FORMAT_BYTE",0
szTIME_FORMAT_FRAME	db	"TIME_FORMAT_FRAME",0
szTIME_FORMAT_NONE	db "TIME_FORMAT_NONE",0
ButtonClassName		db "Button",0
ClassName			db "DLGCLASS",0
WinClassName		db "SimpleWinClass",0
WinClassName2		db "Template_Class",0
WinClassName3		db "ToolTipClass",0
WinClassName4		db "Progress_Window",0
ListClassName		db "SysListView32",0
StaticClassName		db "Static",0
progressClass  		db "msctls_progress32",0
AppName				db "MaxPlayer",0
AboutMsg			db 'MASM32 RadASM MaxPlayer beta',13,10,'Copyright © MAX Birusinsk@mail.ru 2006',0
szNotEnoughMemory	db "Памяти не хватает...",0
Picture				db "Fhon.bmp",0
szPause				db "Pause",0
szPlay				db "Play",0
szPicNotFound		db "Файл Fhon.bmp не найден",0
szAddFile			db "Add file",0
szAddDir			db "Add folder",0
szDel				db "Delete         Del",0
szSave				db "Save playlist",0
;PLName				db "c:\masm32\RadASM\Projects\WinForVid\PL.mpl",0
PLName2				db "Playlist",0
IniFileName			db "MaxPlayer.ini",0
NotOpenIni			db "Couldn't open ini-file",0
InvalidPL			db "Invalid playlist",0
szMpl				db ".mpl",0
szDelAll			db "Delete All",0
szInvalidFile		db "Invalid File",0
szSelectDir			db "Select folder:",0
szErrorSearching	db "Error searching",0
szCannotSave		db "Error saving",0
szFileMask			db "*.*",0
szPoint				db ".",0
sz2Point			db "..",0
szMailSlotName		db "\\.\mailslot\$MaxPlayerMailSlot$",0
szEventName			db "MaxPlayerOpenFile",0
szSTC2				db "0:00:00-->0:00:00",0
szFFThreadActive	db "Некорректное завершение программы.",13,10,"Не рекомендуется закрывать программу во время поиска файлов",0
szRand				db "Random Play",0
szNoScrollPL		db "Don't scroll Pl",0
szSearchPL			db "Jump to file    J",0
dlgname   			db "POPUPINFO",0
szRenameFile		db "Rename file    R",0
szErrorRename		db "Не удалось переименовать файл. Возможно у Вас нет необходимых прав.",0
szBitmapName		db "1.bmp",0
szBmpExtension		db ".bmp",0
szGetScreenShot		db "Сохранить кадр",0
szERROR_FILE_EXISTS	db "Файл уже существует",0
szError				db	"ERROR",0
szERROR_ACCESS_DENIED db "Доступ запрещен. Возможно у Вас нет необходимых прав.",0 
szERROR_FILE_NOT_FOUND db "Файл с таким именем не найден. Возможно он уже был переименован или удален.",0
szERROR_SHARING_VIOLATION	db	"Файл проигрывается или занят другим приложением",0
szUseAsFhon			db "Установить в качестве фонового рисунка",0
szFileInfo			db "File Info          I",0
szOptions			db	"Options",0
szPriority0			db	"Low        0",0
szPriority1			db	"Normal    1",0
szPriority2			db	"Medium   2",0
szPriority3			db	"High        3",0
szPriority			db	"Priority",0
szSortList			db	"Sort Pl by",0
szSortByTitle		db	"Filename",0
szSortByExten		db	"Extension",0
szSortByPath		db	"Pathname",0
FontName 			db "script",0
szHelpFontName		db "system",0
szVMR9				db "VideoMixingRenderer9",0
szWheelVolume		db "Volume",0
szWheelFrameStep	db "FrameStep",0
szFontName			db	"Times New Roman",0
szArtist			db 	"Artist",0
szExit				db  "Выход",0
szRestore			db  "Восстановить",0
szErrorHelp			db	"Файл справки не найден",0
szFileHelp			db	"mpleer.txt",0
szFindPL			db  "Найти            F",0
szFindFewLetters	db  "Введите больше букаф, пожалуйста :-)",0
szFindNotFound		db  "По вашему запросу ничего не найдено.",0

dva	dd 2
sto	dd 300
endStr	dw 0A0Dh
try dd 30

MaxStream	dd 2	;amount video streams

BackdropColour	dd 00FF0000h ;Backdrop Colour
MainColour		dd 00D8E9ECh ;-default colour
MainColour2		dd 00F0EBE8h ;-silver colour

	



.data?

hInstance				dd ?
CommandLine				dd ?
OldWndProc				dd ?
WndListOldProc			dd ?
OldWndTBRProc2			dd ?
OldWndTBR2Proc2			dd ?
OldWndBTN1Proc2			dd ?
OldWndBTN2Proc2			dd ?
OldWndBTN3Proc2			dd ?
OldWndBTN4Proc2			dd ?
OldWndBTN5Proc2			dd ?
OldWndBTN6Proc2			dd ?
OldWndEDT1Proc2			dd ?
OldWndEDT9Proc2			dd ?
OldWndEDT2Proc2			dd ?
OldWndEDT3Proc2			dd ?
OldWndEDT5Proc2			dd ?
OldWndEDT6Proc2			dd ?
OldWndEDT7Proc2			dd ?
OldWndEDT8Proc2			dd ?
OldWndCBO1Proc2			dd ?
OldWndProgressProc		dd ?
OldWndTRBProc3			dd ?
OldWndTRBProc4			dd ?
OldWndTRBProc5			dd ?
OldWndTRBProc6			dd ?
OldWndBTN9Proc2			dd ?
OldWndEDT4Proc2			dd ?
hDlg					dd ?
hDlg7					dd ?
hEDT1					dd ?
hDlg3					dd ?
hDlg4					dd ?
hDlg5					dd ?
hDlg6					dd ?
hDlg8					dd ?
hEDT2					dd ?
hEDT3					dd ?
hEDT4					dd ?
hEDT5					dd ?
hEDT6					dd ?
hEDT7					dd ?
hEDT8					dd ?
hEDT9					dd ?
hWnd					dd ?
hSTC1					dd ?
hPic					dd ?
hBTN1					dd ?
hBTN2					dd ?
hTBR1					dd ?
hSTC2					dd ?
hSTC9					dd ?
hSTC14					dd ?
hSTC15					dd ?
hTBR2					dd ?
hBTN3					dd ?
hBTN4					dd ?
hBTN5					dd ?
hBTN6					dd ?
hBTN9					dd ?
hCBO1					dd ?
hTimer					dd ?
hTimer2					dd ?
hTimer3					dd ?
hPL						dd ?
hList					dd ?
hMenu					dd ?
hSysMenu				dd ?
BytesWritten			dd ?
hInPL					dd ?
hPopMenu				dd ?
hPopMenu2				dd ?
hPopMenu3				dd ?
hPopupMenu				dd ?
hSearch					dd ?
hServerMailslotHandle	dd ?
hCommandEvent			dd ?
hWaitEventThread		dd ?
hScreenFhon				dd ?
hVPL					dd ?
hVPL2					dd ?
hVPL3					dd ?
pVPL					dd ?
hToolTip				dd ?
hSTCToolTip				dd ?
hPopMenu4				dd ?
hWndProgress			dd ?
hProgressWindow			dd ?
hFont					dd ?
hSysMenuMainWin			dd ?
hBrushMain				dd ?
hOpenBtnBmp				dd ?
hPlayBtnBmp				dd ?
hStopBtnBmp				dd ?
hPrevBtnBmp				dd ?
hPlBtnBmp				dd ?
hNextBtnBmp				dd ?
hOpenBtnEmbossBmp		dd ?
hNextBtnEmbossBmp		dd ?
hPlayBtnEmbossBmp		dd ?
hStopBtnEmbossBmp		dd ?
hPlBtnEmbossBmp			dd ?
hPrevBtnEmbossBmp		dd ?
hPauseBtnBmp			dd ?
hPauseBtnEmbossBmp		dd ?
;hOpenBtnSilverBmp		dd ?
;hOpenBtnEmbossSilverBmp	dd ?
;hPlayBtnSilverBmp		dd ?
;hPlayBtnEmbossSilverBmp	dd ?
;hStopBtnSilverBmp		dd ?
;hStopBtnEmbossSilverBmp	dd ?
;hPrevBtnSilverBmp		dd ?
;hPrevBtnEmbossSilverBmp	dd ?
;hPlBtnSilverBmp			dd ?
;hPlBtnEmbossSilverBmp	dd ?
;hNextBtnSilverBmp		dd ?
;hNextBtnEmbossSilverBmp	dd ?
;hPauseBtnSilverBmp		dd ?
;hPauseBtnEmbossSilverBmp dd ?
hTRB3					dd ?
hTRB4					dd ?
hTRB5					dd ?
hTRB6					dd ?
hSTC10					dd ?
hSTC11					dd ?
hSTC12					dd ?
hSTC13					dd ?
hPopupMenuTray			dd ?
hMainIcon				dd ?


;options for ini-file
Wwd_MainWindow		dd ?
Wht_MainWindow		dd ?
Wtx_MainWindow		dd ?
Wty_MainWindow		dd ?
Wtx					dd ?
Wty					dd ?
Wwd					dd ?
Wht					dd ?
StartGlue			dd ?
IsPLVisible			dd ?
WheelFunc			dd ?

LastPL				db 512 dup (?)
;options for ini-file



MixerHandle    dd ?
VolCtlIDMtr    dd ?

mxc MIXERCONTROL <?>
mxcd MIXERCONTROLDETAILS <?>
mxcdVol MIXERCONTROLDETAILS_UNSIGNED <?>
mxlc MIXERLINECONTROLS <?>
icex INITCOMMONCONTROLSEX <?>
       
_CmdLine		db 1024 dup (?)
szCurrentDir	db 512 dup (?)
szFileName	    db 4096 DUP  (?)
szfilename	    db 4096 DUP  (?)
_szFileName 	db 512 DUP  (?)
_szfilename 	db 512 DUP  (?)
buf               db 4096 dup (?) 
buffer			db 256 dup (?)
BufferTimaFormat	db	256 (?)
szFolderName		db  512 (?)
duration 		 dq ? 
position		dq ? 
position1		dq ?
currentTBRpos	dd ?
Value			dq ?
PrevFile		dd ?
BitmapSize		dd ?

BufferFind1 db 512 dup (?)
BufferFind2 db 512 dup (?)
BufferFind3 db 512 dup (?)
Findlvi LV_ITEM <?>
FindAmountOfItems	dd ?
Findcount1			dd ?
Findcount2			dd ?
ContinueFind	dd ?
FindExist		dd ?

	;pEventH          dd ?
    evCode           dd ?
    param1           dd ?
    param2           dd ?
   	drain            dd ?
 	mode             dd ?
 	pGraph           dd ?
 	pControl         dd ?
  	pEvent           dd ?   
 	pVideo           dd ?
	pWindow          dd ?
	pSeeking		 dd ?
	pAudio			 dd ?
	pStep			 dd ?
	pVMR9			 dd ?
	pConfig9		 dd ?
	;pWControl9		 dd ?
	pMControl9		 dd ?
	pMBitmap9		 dd ?
	
 
	trb_position		dd ?
	NativeVideoWidth	dd ?
	NativeVideoHeight	dd ?
	Coefficient_n		dd ?
	VideoHeight			dd ?
	VideoWidth			dd ?
	VideoTop			dd ?
	VideoLeft			dd ?
	Coefficient_s		dd ?
	PLFocus			 	dd ?
	PLSelected		 	dd ?
	PLFocusSaved	 	dd ?
	Hours			 	dw ?
	Minutes			 	dw ?
	Seconds				dw ?
	AllHours			dw ?
	AllMinutes			dw ?
	AllSeconds			dw ?
	Rand				dd ?
	HavePlayed			dd ?
	Wht_MainWindowSaved	dd ?
	CountOfScreenShots	dd ?
	Brightness			dd ?
	Contrast			dd ?
	Hue					dd ?
	Saturation			dd ?
	volumeForMute		dd ?
	
