Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=1.51
@EndOfDesignText@
#Region Module Attributes
	#StartAtBoot: False
#End Region

'Service module
Sub Process_Globals

	Dim rv As RemoteViews

End Sub

Sub Service_Create

	DateTime.DateFormat="dd/MM/YYYY HH:mm"
	'Set the widget to update every 60 minutes.
	rv = ConfigureHomeWidget("main", "rv", 60, "Your Widget Name")

End Sub

Sub Service_Start (StartingIntent As Intent)
	
	If rv.HandleWidgetEvents(StartingIntent) Then Return
	
End Sub

Sub rv_RequestUpdate

	SetContent
	rv.UpdateWidget

End Sub

Sub rv_Disabled

	StopService("")

End Sub

Sub Service_Destroy

End Sub

Sub SetContent

	Wait For(DownloadCalendario) Complete (calendarioSemplificato As String)
	AggiornaContentutoWidget (calendarioSemplificato)

End Sub

Sub ImageView1_Click

	SetContent
	rv.UpdateWidget

End Sub


Sub AggiornaContentutoWidget (calendario As String)
	
	'Verifico che giorno della settimana è
	Dim giorno As String = getGiornoDellaSettimana
		
	'passo il calendario ad un parser Jason per estrarre i rifiuti che si raccolgono oggi
	Dim messaggio As String = decodeCalendario(calendario, giorno )
	
	Dim  dataOra  As String	
	dataOra = DateTime.Date(DateTime.now)
	
	'imposto il testo sul widget
	rv.SetText("Label1", messaggio ) 
	rv.SetText("Label2", "Clicca sull'icona per aggiornare il widget." & Chr(10) & "Ultimo aggiornamento: " & dataOra)
	
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
	
End Sub


Sub DownloadCalendario As ResumableSub
	
	Dim job As HttpJob
	Dim calendarioJson As String
	
	job.Initialize("", Me)
	job.Download("PATH TO JSON FILE WITH MESSAGES")
	Wait For (job) JobDone(job As HttpJob)
	
	If job.Success Then
		calendarioJson = job.GetString
	End If
	
	job.Release
	
	Return calendarioJson
	
End Sub

Sub getGiornoDellaSettimana As String
	
	'you can change the week days in other languages. If true, you need to change json file too	
	Dim days() As String = Array As String("","Domenica" , "Lunedì" , "Martedì", "Mercoledì" ,"Giovedì" ,"Venerdì"  ,"Sabato" )
	
	Dim oggi As Int = DateTime.GetDayOfWeek(DateTime.Now)
	If oggi < 7 Then
		Dim domani As Int = oggi + 1
	Else
		domani = 1
	End If
	
	Dim giornoDellaSettimana As String = days(domani)
	
	Return giornoDellaSettimana
	
	 
End Sub

Sub decodeCalendario (calendarioSettimanale As String, giornoDellaSettimana As String ) As String
	
	'estraggo l'rsu del giorno dato dal tracciato Json
	Dim parser As JSONParser
	Dim Map1 As Map
	Dim rsuDelGiorno As String
    
	parser.Initialize(calendarioSettimanale)
	Map1 = parser.NextObject
	
	rsuDelGiorno = Map1.Get(giornoDellaSettimana)
	
	Return rsuDelGiorno
	
End Sub


Private Sub Label2_Click
	
End Sub

Private Sub Label1_Click
	
End Sub

Private Sub Panel1_Click
	
End Sub