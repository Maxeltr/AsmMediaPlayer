GetGenre	proc	GenreNumber:DWORD, GenreName:DWORD, hCBO:DWORD, IDC_CBO:DWORD
;1) invoke GetGenre,0,0,hWin,IDC_CBO1
;hCBO-handle of parent window, IDC_CBO-identifier, in order to fill combobox
;2)invoke GetGenre,edx,addr GenreName,0,0
;GenreNumber-must be nonzero, in order to get Name of genre
;GenreName-pointer to buffer,which receive name of genre
;3)invoke GetGenre,0,addr GenreName,0,0
;GenreName- zero-terminated string with name of genre
;GenreNumber-must be zero (number of genre retun in eax)
.data
szProbel				db " ",0						;0
szA_Cappella			db "A Cappella",0				;1
szAcid					db "Acid",0						;2
szAcid_Jazz				db "Acid Jazz",0				;3
szAcid_Punk				db "Acid Punk",0				;4
szAcoustic				db "Acoustic",0					;5
szAltRock				db "Alt. Rock",0				;6
szAlternative			db "Alternative",0				;7
szAmbient				db "Ambient",0					;8
szAnime					db "Anime",0					;9
szAvantgarde			db "Avantgarde",0				;10
szBallad				db "Ballad",0					;11
szBass					db "Bass",0						;12
szBeat					db "Beat",0						;13
szBebob					db "Bebob",0					;14
szBig_Band				db "Big Band",0					;15
szBlack_Metal			db "Black Metal",0				;16
szBluegrass				db "Bluegrass",0				;17
szBlues					db "Blues",0					;18
szBooty_Bass			db "Booty Bass",0				;19
szBritPop				db "BritPop",0					;20
szCabaret				db "Cabaret",0					;21
szCeltic				db "Celtic",0					;22
szChamber_Music 		db "Chamber Music",0			;23
szChanson				db "Chanson",0					;24
szChorus				db "Chorus",0					;25
szChristian_Gangsta_Rap	db "Christian Gangsta Rap",0	;26
szChristian_Rap			db "Christian Rap",0			;27
szChristian_Rock		db "Christian Rock",0			;28
szClassic_Rock			db "Classic Rock",0				;29
szClassical				db "Classical",0				;30
szClub					db "Club",0						;31
szClub_House			db "Club-House",0				;32
szComedy				db "Comedy",0					;33
szContemporary_Christ	db "Contemporary Christ",0		;34
szCountry				db "Country",0					;35
szCrossover				db "Crossover",0				;36
szCult					db "Cult",0						;37
szDance					db "Dance",0					;38
szDance_Hall			db "Dance Hall",0				;39
szDarkwave				db "Darkwave",0					;40
szDeath_Metal			db "Death Metal",0				;41
szDisco					db "Disco",0					;42
szDream					db "Dream",0					;43
szDrumBass				db "Drum&Bass",0				;44
szDrum_Solo				db "Drum Solo",0				;45
szDuet					db "Duet",0						;46
szEasy_Listening		db "Easy Listening",0			;47
szElectronic			db "Electronic",0				;48
szEthnic				db "Ethnic",0					;49
szEurodance				db "Eurodance",0				;50
szEuro_House			db "Euro-House",0				;51
szEuro_Techno			db "Euro-Techno",0				;52
szFast_Fusion			db "Fast-Fusion",0				;53
szFolk					db "Folk",0						;54
szFolkRock				db "Folk/Rock",0				;55
szFolklore				db "Folklore",0					;56
szFreestyle				db "Freestyle",0				;57
szFunk					db "Funk",0						;58
szFusion				db "Fusion",0					;59
szGame					db "Game",0						;60
szGangsta_Rap			db "Gangsta Rap",0				;61
szGoa					db "Goa",0						;62
szGospel				db "Gospel",0					;63
szGothic				db "Gothic",0					;64
szGothic_Rock			db "Gothic Rock",0				;65
szGrunge				db "Grunge",0					;66
szHard_Rock				db "Hard Rock",0				;67
szHardcore				db "Hardcore",0					;68
szHeavy_Metal			db "Heavy Metal",0				;69
szHip_Hop				db "Hip-Hop",0					;70
szHouse					db "House",0					;71
szHumor					db "Humor",0					;72
szIndie					db "Indie",0					;73
szIndustrial			db "Industrial",0				;74
szInstrumental			db "Instrumental",0				;75
szInstrumental_Pop		db "Instrumental Pop",0			;76
szInstrumental_Rock		db "Instrumental Rock",0		;77
szJazz					db "Jazz",0						;78
szJazzFunk				db "Jazz+Funk",0				;79
szJPop					db "JPop",0						;80
szJungle				db "Jungle",0					;81
szLatin					db "Latin",0					;82
szLo_Fi					db "Lo-Fi",0					;83
szMeditative			db "Meditative",0				;84
szMerengue				db "Merengue",0					;85
szMetal					db "Metal",0					;86
szMusical				db "Musical",0					;87
szNational_Folk			db "National Folk",0			;88
szNative_American		db "Native American",0			;89
szNegerpunk				db "Negerpunk",0				;90
szNew_Age				db "New Age",0					;91
szNew_Wave				db "New Wave",0					;92
szNoise					db "Noise",0					;93
szOldies				db "Oldies",0					;94
szOpera					db "Opera",0					;95
szOther					db "Other",0					;96
szPolka					db "Polka",0					;97
szPolsk_Punk			db "Polsk Punk",0				;98
szPop					db "Pop",0						;99
szPopFunk				db "Pop/Funk",0					;100
szPop_Folk				db "Pop-Folk",0					;101
szPorn_Groove			db "Porn Groove",0				;102
szPower_Ballad			db "Power Ballad",0				;103
szPranks				db "Pranks",0					;104
szPrimus				db "Primus",0					;105
szProgressive_Rock		db "Progressive Rock",0			;106
szPsychedelic			db "Psychedelic",0				;107
szPsychedelic_Rock		db "Psychedelic Rock",0			;108
szPunk					db "Punk",0						;109
szPunk_Rock				db "Punk Rock",0				;110
szRB					db "R&B",0						;111
szRap					db "Rap",0						;112
szRave					db "Rave",0						;113
szReggae				db "Reggae",0					;114
szRetro					db "Retro",0					;115
szRevival				db "Revival",0					;116
szRhythmic_Soul			db "Rhythmic Soul",0			;117
szRock					db "Rock",0						;118
szRockRoll				db "Rock&Roll",0				;119
szSalsa					db "Salsa",0					;120
szSamba					db "Samba",0					;121
szSatire				db "Satire",0					;122
szShowtunes				db "Showtunes",0				;123
szSka					db "Ska",0						;124
szSlow_Jam				db "Slow Jam",0					;125
szSlow_Rock				db "Slow Rock",0				;126
szSonata				db "Sonata",0					;127
szSoul					db "Soul",0						;128
szSound_Clip			db "Sound Clip",0				;129
szSoundtrack			db "Soundtrack",0				;130
szSouthern_Rock			db "Southern Rock",0			;131
szSpace					db "Space",0					;132
szSpeech				db "Speech",0					;133
szSwing					db "Swing",0					;134
szSymphonic_Rock		db "Symphonic Rock",0			;135
szSymphony				db "Symphony",0					;136
szSynthpop				db "Synthpop",0					;137
szTango					db "Tango",0					;138
szTechno				db "Techno",0					;139
szTechno_Industrial		db "Techno-Industrial",0		;140
szTerror				db "Terror",0					;141
szTrash_Metal			db "Trash Metal",0				;142
szTop40					db "Top 40",0					;143
szTrailer				db "Trailer",0					;144
szTrance				db "Trance",0					;145
szTribal				db "Tribal",0					;146
szTrip_Hop				db "Trip-Hop",0					;147
szVocal					db "Vocal",0					;148

.code
	
	
	
	.if hCBO!=0 && IDC_CBO!=0
		lea edi,szProbel
		mov ecx,148
		@@:
		push edi
		push ecx
		invoke SendDlgItemMessage,hCBO,IDC_CBO,CB_ADDSTRING,0,edi
		pop ecx
		pop edi
		
		xor al,al
		Cikl:
		inc edi
		cmp al,byte ptr [edi]
		jnz Cikl
		inc edi
		dec ecx
		js @f
		jmp @b
		@@:
		mov eax,1
		ret
	.endif
	
	.if GenreNumber==0 && hCBO==0
		mov esi,GenreName			;0
		lea edi,szProbel
		call Compare
		.if eax==1
			mov eax,0FFh
			ret
		.endif
		
		mov esi,GenreName			;1
		lea edi,szA_Cappella
		call Compare
		.if eax==1
			mov eax,7Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAcid				;2
		call Compare
		.if eax==1
			mov eax,22h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAcid_Jazz				;3
		call Compare
		.if eax==1
			mov eax,4Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAcid_Punk				;4
		call Compare
		.if eax==1
			mov eax,49h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAcoustic				;5
		call Compare
		.if eax==1
			mov eax,63h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAltRock				;6
		call Compare
		.if eax==1
			mov eax,28h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAlternative				;7
		call Compare
		.if eax==1
			mov eax,14h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAmbient				;8
		call Compare
		.if eax==1
			mov eax,1Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAnime				;9
		call Compare
		.if eax==1
			mov eax,91h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szAvantgarde				;10
		call Compare
		.if eax==1
			mov eax,5Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBallad				;11
		call Compare
		.if eax==1
			mov eax,74h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBass				;12
		call Compare
		.if eax==1
			mov eax,29h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBeat				;13
		call Compare
		.if eax==1
			mov eax,87h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBebob				;14
		call Compare
		.if eax==1
			mov eax,55h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBig_Band				;15
		call Compare
		.if eax==1
			mov eax,60h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBlack_Metal				;16
		call Compare
		.if eax==1
			mov eax,8Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBluegrass				;17
		call Compare
		.if eax==1
			mov eax,59h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBlues				;18
		call Compare
		.if eax==1
			mov eax,00h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBooty_Bass				;19
		call Compare
		.if eax==1
			mov eax,6Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szBritPop				;20
		call Compare
		.if eax==1
			mov eax,84h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szCabaret				;21
		call Compare
		.if eax==1
			mov eax,41h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szCeltic				;22
		call Compare
		.if eax==1
			mov eax,58h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szChamber_Music				;23
		call Compare
		.if eax==1
			mov eax,68h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szChanson				;24
		call Compare
		.if eax==1
			mov eax,66h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szChorus				;25
		call Compare
		.if eax==1
			mov eax,61h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szChristian_Gangsta_Rap				;26
		call Compare
		.if eax==1
			mov eax,88h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szChristian_Rap				;27
		call Compare
		.if eax==1
			mov eax,3Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szChristian_Rock				;28
		call Compare
		.if eax==1
			mov eax,8Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szClassic_Rock				;29
		call Compare
		.if eax==1
			mov eax,01h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szClassical				;30
		call Compare
		.if eax==1
			mov eax,20h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szClub				;31
		call Compare
		.if eax==1
			mov eax,70h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szClub_House				;32
		call Compare
		.if eax==1
			mov eax,80h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szComedy				;33
		call Compare
		.if eax==1
			mov eax,39h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szContemporary_Christ				;34
		call Compare
		.if eax==1
			mov eax,8Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szCountry				;35
		call Compare
		.if eax==1
			mov eax,02h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szCrossover				;36
		call Compare
		.if eax==1
			mov eax,8Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szCult				;37
		call Compare
		.if eax==1
			mov eax,3Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDance				;38
		call Compare
		.if eax==1
			mov eax,03h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDance_Hall				;39
		call Compare
		.if eax==1
			mov eax,7Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDarkwave				;40
		call Compare
		.if eax==1
			mov eax,32h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDeath_Metal				;41
		call Compare
		.if eax==1
			mov eax,16h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDisco				;42
		call Compare
		.if eax==1
			mov eax,04h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDream				;43
		call Compare
		.if eax==1
			mov eax,37h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDrumBass				;44
		call Compare
		.if eax==1
			mov eax,7Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDrum_Solo				;45
		call Compare
		.if eax==1
			mov eax,7Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szDuet				;46
		call Compare
		.if eax==1
			mov eax,78h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szEasy_Listening				;47
		call Compare
		.if eax==1
			mov eax,62h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szElectronic				;48
		call Compare
		.if eax==1
			mov eax,34h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szEthnic				;49
		call Compare
		.if eax==1
			mov eax,30h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szEurodance				;50
		call Compare
		.if eax==1
			mov eax,36h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szEuro_House				;51
		call Compare
		.if eax==1
			mov eax,7Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szEuro_Techno				;52
		call Compare
		.if eax==1
			mov eax,19h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szFast_Fusion				;53
		call Compare
		.if eax==1
			mov eax,54h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szFolk				;54
		call Compare
		.if eax==1
			mov eax,50h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szFolkRock				;55
		call Compare
		.if eax==1
			mov eax,51h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szFolklore				;56
		call Compare
		.if eax==1
			mov eax,73h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szFreestyle				;57
		call Compare
		.if eax==1
			mov eax,77h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szFunk				;58
		call Compare
		.if eax==1
			mov eax,05h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szFusion				;59
		call Compare
		.if eax==1
			mov eax,1Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szGame				;60
		call Compare
		.if eax==1
			mov eax,24h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szGangsta_Rap				;61
		call Compare
		.if eax==1
			mov eax,3Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szGoa				;62
		call Compare
		.if eax==1
			mov eax,7Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szGospel				;63
		call Compare
		.if eax==1
			mov eax,26h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szGothic				;64
		call Compare
		.if eax==1
			mov eax,31h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szGothic_Rock				;65
		call Compare
		.if eax==1
			mov eax,5Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szGrunge				;66
		call Compare
		.if eax==1
			mov eax,06h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szHard_Rock				;67
		call Compare
		.if eax==1
			mov eax,4Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szHardcore				;68
		call Compare
		.if eax==1
			mov eax,81h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szHeavy_Metal				;69
		call Compare
		.if eax==1
			mov eax,89h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szHip_Hop				;70
		call Compare
		.if eax==1
			mov eax,07h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szHouse				;71
		call Compare
		.if eax==1
			mov eax,23h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szHumor				;72
		call Compare
		.if eax==1
			mov eax,64h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szIndie				;73
		call Compare
		.if eax==1
			mov eax,83h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szIndustrial				;74
		call Compare
		.if eax==1
			mov eax,13h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szInstrumental				;75
		call Compare
		.if eax==1
			mov eax,21h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szInstrumental_Pop				;76
		call Compare
		.if eax==1
			mov eax,2Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szInstrumental_Rock				;77
		call Compare
		.if eax==1
			mov eax,2Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szJazz				;78
		call Compare
		.if eax==1
			mov eax,08h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szJazzFunk				;79
		call Compare
		.if eax==1
			mov eax,1Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szJPop				;80
		call Compare
		.if eax==1
			mov eax,92h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szJungle				;81
		call Compare
		.if eax==1
			mov eax,3Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szLatin				;82
		call Compare
		.if eax==1
			mov eax,56h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szLo_Fi				;83
		call Compare
		.if eax==1
			mov eax,47h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szMeditative				;84
		call Compare
		.if eax==1
			mov eax,2Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szMerengue				;85
		call Compare
		.if eax==1
			mov eax,8Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szMetal				;86
		call Compare
		.if eax==1
			mov eax,09h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szMusical				;87
		call Compare
		.if eax==1
			mov eax,4Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szNational_Folk				;88
		call Compare
		.if eax==1
			mov eax,52h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szNative_American				;89
		call Compare
		.if eax==1
			mov eax,40h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szNegerpunk				;90
		call Compare
		.if eax==1
			mov eax,85h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szNew_Age				;91
		call Compare
		.if eax==1
			mov eax,0Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szNew_Wave				;92
		call Compare
		.if eax==1
			mov eax,42h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szNoise				;93
		call Compare
		.if eax==1
			mov eax,27h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szOldies				;94
		call Compare
		.if eax==1
			mov eax,0Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szOpera				;95
		call Compare
		.if eax==1
			mov eax,67h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szOther				;96
		call Compare
		.if eax==1
			mov eax,0Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPolka				;97
		call Compare
		.if eax==1
			mov eax,4Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPolsk_Punk				;98
		call Compare
		.if eax==1
			mov eax,86h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPop				;99
		call Compare
		.if eax==1
			mov eax,0Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPopFunk				;100
		call Compare
		.if eax==1
			mov eax,3Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPop_Folk				;101
		call Compare
		.if eax==1
			mov eax,35h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPorn_Groove				;102
		call Compare
		.if eax==1
			mov eax,6Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPower_Ballad				;103
		call Compare
		.if eax==1
			mov eax,75h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPranks				;104
		call Compare
		.if eax==1
			mov eax,17h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPrimus				;105
		call Compare
		.if eax==1
			mov eax,6Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szProgressive_Rock				;106
		call Compare
		.if eax==1
			mov eax,5Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPsychedelic				;107
		call Compare
		.if eax==1
			mov eax,43h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPsychedelic_Rock				;108
		call Compare
		.if eax==1
			mov eax,5Dh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPunk				;109
		call Compare
		.if eax==1
			mov eax,2Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szPunk_Rock				;110
		call Compare
		.if eax==1
			mov eax,79h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRB				;111
		call Compare
		.if eax==1
			mov eax,0Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRap				;112
		call Compare
		.if eax==1
			mov eax,0Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRave				;113
		call Compare
		.if eax==1
			mov eax,44h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szReggae				;114
		call Compare
		.if eax==1
			mov eax,10h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRetro				;115
		call Compare
		.if eax==1
			mov eax,4Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRevival				;116
		call Compare
		.if eax==1
			mov eax,57h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRhythmic_Soul				;117
		call Compare
		.if eax==1
			mov eax,76h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRock				;118
		call Compare
		.if eax==1
			mov eax,11h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szRockRoll				;119
		call Compare
		.if eax==1
			mov eax,4Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSalsa				;120
		call Compare
		.if eax==1
			mov eax,8Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSamba				;121
		call Compare
		.if eax==1
			mov eax,72h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSatire				;122
		call Compare
		.if eax==1
			mov eax,6Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szShowtunes				;123
		call Compare
		.if eax==1
			mov eax,45h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSka				;124
		call Compare
		.if eax==1
			mov eax,15h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSlow_Jam				;125
		call Compare
		.if eax==1
			mov eax,6Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSlow_Rock				;126
		call Compare
		.if eax==1
			mov eax,5Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSonata				;127
		call Compare
		.if eax==1
			mov eax,69h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSoul				;128
		call Compare
		.if eax==1
			mov eax,2Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSound_Clip				;129
		call Compare
		.if eax==1
			mov eax,25h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSoundtrack				;130
		call Compare
		.if eax==1
			mov eax,18h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSouthern_Rock				;131
		call Compare
		.if eax==1
			mov eax,38h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSpace				;132
		call Compare
		.if eax==1
			mov eax,2Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSpeech				;133
		call Compare
		.if eax==1
			mov eax,65h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSwing				;134
		call Compare
		.if eax==1
			mov eax,53h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSymphonic_Rock				;135
		call Compare
		.if eax==1
			mov eax,5Eh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSymphony				;136
		call Compare
		.if eax==1
			mov eax,6Ah
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szSynthpop				;137
		call Compare
		.if eax==1
			mov eax,93h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTango				;138
		call Compare
		.if eax==1
			mov eax,71h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTechno				;139
		call Compare
		.if eax==1
			mov eax,12h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTechno_Industrial				;140
		call Compare
		.if eax==1
			mov eax,33h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTerror				;141
		call Compare
		.if eax==1
			mov eax,82h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTrash_Metal				;142
		call Compare
		.if eax==1
			mov eax,90h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTop40				;143
		call Compare
		.if eax==1
			mov eax,3Ch
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTrailer				;144
		call Compare
		.if eax==1
			mov eax,46h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTrance				;145
		call Compare
		.if eax==1
			mov eax,1Fh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTribal				;146
		call Compare
		.if eax==1
			mov eax,48h
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szTrip_Hop				;147
		call Compare
		.if eax==1
			mov eax,1Bh
			ret
		.endif
		
		mov esi,GenreName
		lea edi,szVocal				;148
		call Compare
		.if eax==1
			mov eax,1Ch
			ret
		.endif
		
		mov eax,0FFh
		ret
		
		Compare:
		invoke lstrcmpi,esi,edi
		je Equal
		xor eax,eax
		pop edx
		jmp edx
		Equal:
		mov eax,1
		pop edx
		jmp edx
	.endif
	
	
	mov eax,GenreNumber
	.if eax==0FFh
		lea esi,szProbel			;0-FFh	
		mov ecx,1
		call MovsNameToBuf
	.elseif eax==7Bh
		lea esi,szA_Cappella		;1-7Bh	
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==22h
		lea esi,szAcid		;2-22h     
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==4Ah
		lea esi,szAcid_Jazz		;3-4Ah      
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==49h
		lea esi,szAcid_Punk		;4-49h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==63h
		lea esi,szAcoustic		;5-63h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==28h
		lea esi,szAltRock		;6-28h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==14h
		lea esi,szAlternative	;7-14h
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==1Ah
		lea esi,szAmbient		;8-1Ah
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==91h
		lea esi,szAnime		;9-91h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==5Ah
		lea esi,szAvantgarde	;10-5Ah
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==74h
		lea esi,szBallad		;11-74h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==29h
		lea esi,szBass		;12-29h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==87h
		lea esi,szBeat		;13-87h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==55h
		lea esi,szBebob		;14-55h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==60h
		lea esi,szBig_Band		;15-60h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==8Ah
		lea esi,szBlack_Metal	;16-8Ah
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==59h
		lea esi,szBluegrass		;17-59h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==00h
		lea esi,szBlues		;18-00h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==6Bh
		lea esi,szBooty_Bass	;19-6Bh
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==84h
		lea esi,szBritPop		;20-84h
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==41h
		lea esi,szCabaret		;21-41h
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==58h
		lea esi,szCeltic		;22-58h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==68h
		lea esi,szChamber_Music	;23-68h
		mov ecx,13
		call MovsNameToBuf
	.elseif eax==66h
		lea esi,szChanson		;24-66h
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==61h
		lea esi,szChorus		;25-61h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==88h
		lea esi,szChristian_Gangsta_Rap;26-88h
		mov ecx,21
		call MovsNameToBuf
	.elseif eax==3Dh
		lea esi,szChristian_Rap		;27-3D
		mov ecx,13
		call MovsNameToBuf
	.elseif eax==8Dh	
		lea esi,szChristian_Rock	;28-8Dh
		mov ecx,14
		call MovsNameToBuf
	.elseif eax==01h
		lea esi,szClassic_Rock	;29-01h
		mov ecx,12
		call MovsNameToBuf
	.elseif eax==20h
		lea esi,szClassical		;30-20h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==70h
		lea esi,szClub		;31-70h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==80h
		lea esi,szClub_House	;32-80h
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==39h
		lea esi,szComedy		;33-39h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==8Ch
		lea esi,szContemporary_Christ	;34-8Ch
		mov ecx,18
		call MovsNameToBuf
	.elseif eax==02h
		lea esi,szCountry		;35-02h
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==8Bh
		lea esi,szCrossover		;36-8Bh
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==3Ah
		lea esi,szCult		;37-3Ah
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==03h
		lea esi,szDance		;38-03h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==7Dh
		lea esi,szDance_Hall	;39-7Dh
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==32h
		lea esi,szDarkwave		;40-32h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==16h
		lea esi,szDeath_Metal	;41-16h
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==04h
		lea esi,szDisco		;42-04h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==37h
		lea esi,szDream		;43-37h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==7Fh
		lea esi,szDrumBass		;44-7Fh
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==7Ah
		lea esi,szDrum_Solo		;45-7Ah
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==78h
		lea esi,szDuet		;46-78h
		mov ecx,4
		call MovsNameToBuf	
	.elseif eax==62h
		lea esi,szEasy_Listening	;47-62h
		mov ecx,14
		call MovsNameToBuf
	.elseif eax==34h
		lea esi,szElectronic	;48-34h
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==30h
		lea esi,szEthnic		;49-30h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==36h
		lea esi,szEurodance		;50-36h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==7Ch
		lea esi,szEuro_House	;51-7Ch
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==19h
		lea esi,szEuro_Techno	;52-19h
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==54h
		lea esi,szFast_Fusion	;53-54h
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==50h
		lea esi,szFolk		;54-50h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==51h
		lea esi,szFolkRock		;55-51h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==73h
		lea esi,szFolklore		;56-73h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==77h
		lea esi,szFreestyle		;57-77h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==05h
		lea esi,szFunk		;58=05h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==1Eh
		lea esi,szFusion		;59-1Eh
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==24h
		lea esi,szGame		;60-24h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==3Bh
		lea esi,szGangsta_Rap	;61-3Bh
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==7Eh
		lea esi,szGoa		;62-7Eh
		mov ecx,3
		call MovsNameToBuf
	.elseif eax==26h
		lea esi,szGospel		;63-26h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==31h
		lea esi,szGothic		;64-31h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==5Bh
		lea esi,szGothic_Rock	;65-5Bh
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==06h
		lea esi,szGrunge		;66-06h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==4Fh
		lea esi,szHard_Rock		;67-4Fh
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==81h
		lea esi,szHardcore		;68-81h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==89h
		lea esi,szHeavy_Metal	;69-89h
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==07h
		lea esi,szHip_Hop		;70-07h
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==23h
		lea esi,szHouse		;71-23h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==64h
		lea esi,szHumor		;72-64h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==83h
		lea esi,szIndie		;73-83h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==13h
		lea esi,szIndustrial	;74-13h
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==21h
		lea esi,szInstrumental	;75-21h
		mov ecx,12
		call MovsNameToBuf
	.elseif eax==2Eh
		lea esi,szInstrumental_Pop	;76-2Eh
		mov ecx,16
		call MovsNameToBuf
	.elseif eax==2Fh
		lea esi,szInstrumental_Rock	;77-2Fh
		mov ecx,17
		call MovsNameToBuf
	.elseif eax==08h
		lea esi,szJazz		;78-08h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==1Dh
		lea esi,szJazzFunk		;79-1Dh
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==92h
		lea esi,szJPop		;80-92h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==3Fh
		lea esi,szJungle		;81-3Fh
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==56h
		lea esi,szLatin		;82-56h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==47h
		lea esi,szLo_Fi		;83-47h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==2Dh
		lea esi,szMeditative	;84-2Dh
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==8Eh
		lea esi,szMerengue		;85-8Eh
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==09h
		lea esi,szMetal		;86-09h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==4Dh
		lea esi,szMusical		;87-4Dh
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==52h
		lea esi,szNational_Folk	;88-52h
		mov ecx,13
		call MovsNameToBuf
	.elseif eax==40h
		lea esi,szNative_American	;89-40h
		mov ecx,15
		call MovsNameToBuf
	.elseif eax==85h
		lea esi,szNegerpunk		;90-85h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==0Ah
		lea esi,szNew_Age		;91-0Ah
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==42h
		lea esi,szNew_Wave		;92-42h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==27h
		lea esi,szNoise		;93-27h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==0Bh
		lea esi,szOldies		;94-0Bh
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==67h
		lea esi,szOpera		;95-67h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==0Ch
		lea esi,szOther		;96-0Ch
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==4Bh
		lea esi,szPolka		;97-4Bh
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==86h
		lea esi,szPolsk_Punk	;98-86h
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==0Dh
		lea esi,szPop		;99-0Dh
		mov ecx,3
		call MovsNameToBuf
	.elseif eax==3Eh
		lea esi,szPopFunk		;100-3Eh
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==35h
		lea esi,szPop_Folk		;101-35h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==6Dh
		lea esi,szPorn_Groove		;102-6Dh
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==75h
		lea esi,szPower_Ballad	;103-75h
		mov ecx,12
		call MovsNameToBuf
	.elseif eax==17h
		lea esi,szPranks		;104-17h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==6Ch
		lea esi,szPrimus		;105-6Ch
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==5Ch
		lea esi,szProgressive_Rock	;106-5Ch
		mov ecx,16
		call MovsNameToBuf
	.elseif eax==43h
		lea esi,szPsychedelic	;107-43h
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==5Dh
		lea esi,szPsychedelic_Rock	;108-5Dh
		mov ecx,16
		call MovsNameToBuf
	.elseif eax==2Bh
		lea esi,szPunk		;109-2Bh
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==79h
		lea esi,szPunk_Rock		;110-79h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==0Eh
		lea esi,szRB		;111-0Eh
		mov ecx,3
		call MovsNameToBuf
	.elseif eax==0Fh
		lea esi,szRap		;112-0Fh
		mov ecx,3
		call MovsNameToBuf
	.elseif eax==44h
		lea esi,szRave		;113-44h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==10h
		lea esi,szReggae		;114-10h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==4Ch
		lea esi,szRetro		;115-4Ch
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==57h
		lea esi,szRevival		;116-57h
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==76h
		lea esi,szRhythmic_Soul	;117-76h
		mov ecx,13
		call MovsNameToBuf
	.elseif eax==11h
		lea esi,szRock		;118-11h
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==4Eh
		lea esi,szRockRoll		;119-4Eh
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==8Fh
		lea esi,szSalsa		;120-8Fh
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==72h
		lea esi,szSamba		;121-72h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==6Eh
		lea esi,szSatire		;122-6Eh
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==45h
		lea esi,szShowtunes		;123-45h
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==15h
		lea esi,szSka		;124-15h
		mov ecx,3
		call MovsNameToBuf
	.elseif eax==6Fh
		lea esi,szSlow_Jam		;125-6Fh
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==5Fh
		lea esi,szSlow_Rock		;126-5Fh
		mov ecx,9
		call MovsNameToBuf
	.elseif eax==69h
		lea esi,szSonata		;127-69h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==2Ah
		lea esi,szSoul		;128-2Ah
		mov ecx,4
		call MovsNameToBuf
	.elseif eax==25h
		lea esi,szSound_Clip	;129-25h
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==18h
		lea esi,szSoundtrack	;130-18h
		mov ecx,10
		call MovsNameToBuf
	.elseif eax==38h
		lea esi,szSouthern_Rock	;131-38h
		mov ecx,13
		call MovsNameToBuf
	.elseif eax==2Ch
		lea esi,szSpace		;132-2Ch
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==65h
		lea esi,szSpeech		;133-65h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==53h
		lea esi,szSwing		;134-53h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==5Eh
		lea esi,szSymphonic_Rock	;135-5Eh
		mov ecx,14
		call MovsNameToBuf
	.elseif eax==6Ah
		lea esi,szSymphony		;136-6Ah
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==93h
		lea esi,szSynthpop 		;137-93h
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==71h
		lea esi,szTango		;138-71h
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==12h
		lea esi,szTechno		;139-12h
		mov ecx,6
		call MovsNameToBuf	
	.elseif eax==33h
		lea esi,szTechno_Industrial	;140-33h
		mov ecx,17
		call MovsNameToBuf
	.elseif eax==82h
		lea esi,szTerror		;141-82h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==90h
		lea esi,szTrash_Metal	;142-90h
		mov ecx,11
		call MovsNameToBuf
	.elseif eax==3Ch
		lea esi,szTop40		;143-3Ch
		mov ecx,5
		call MovsNameToBuf
	.elseif eax==46h
		lea esi,szTrailer		;144-46h
		mov ecx,7
		call MovsNameToBuf
	.elseif eax==1Fh
		lea esi,szTrance		;145-1Fh
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==48h
		lea esi,szTribal		;146-48h
		mov ecx,6
		call MovsNameToBuf
	.elseif eax==1Bh
		lea esi,szTrip_Hop		;147-1Bh
		mov ecx,8
		call MovsNameToBuf
	.elseif eax==1Ch
		lea esi,szVocal		;148-1Ch
		mov ecx,5
		call MovsNameToBuf
	.else
		mov eax,-1
		ret
	.endif
	inc eax
	ret
	
	
	MovsNameToBuf:
	;int 3
	mov edi,GenreName
	rep movsb
	xor eax,eax
	stosb
	pop edx
	jmp edx
	
	
GetGenre	endp