﻿Function frBVGK_login()
	Dim functionname : functionname = "frBVGK_login"
	frBVGK_login = functionName & "|Error|Unknown Error"
	Dim RetVal 
	Dim DB : DB = "AUTOVBT"
	Dim arrLoginInfo
	Dim strRetVal,SQL,obj
	Call logger.trace(1,functionName & "*****Start*****")
	'SQL = "Execute SPLogin  '" & Paramin("CIT") & "', 'BVGK', '" & ParamIn("PCName") & "'"
	
	If Instr(1, ParamIn("CIT"),"2")  > 0 Then
		ParamIn("CIT") = "SIT2"
	ElseIf Instr(1, ParamIn("CIT"),"4")  > 0 Then
		ParamIn("CIT") = "SIT4"
	Else
		RetVal =  functionName&" |Error|Valid Environment not found in Key ParamIn(CIT)"
		frLoginCRM_Sales = RetVal
		Call logger.trace(1,RetVal )
		Exit function
	End If
	

	RetVal = GetCredentials( Paramin("CIT") , "BVGK", url, uname, password)
'	arrLoginInfo =  frGetMSSQLDataProc (DB, SQL)
	SystemUtil.CloseProcessByName "iexplore.exe" 'Close already open Internet Explorer instances	
	wait(10)
	Paramin("PCName") = pcname
	
	Set ie = Nothing	
	Set ie = CreateObject("InternetExplorer.Application")
	Call logger.trace(1, functionName & " | URL = " & url)	
	ie.Navigate Trim(url) ''Navigate to URL
	ie.Visible = True
	Dim hwnd 
	Window("hwnd:=" & ie.HWND).Maximize
	Set ie = Nothing		
	
	For i = 1 To 5
		If Browser("Anmeldung - SAP Web Applicatio").Page("Zertifikatfehler: Navigation").Link("Laden dieser Website fortsetze").Exist(20) Then
			Browser("Anmeldung - SAP Web Applicatio").Page("Zertifikatfehler: Navigation").Sync
			RetVal= frClick("Laden dieser Website fortsetze",Browser("Anmeldung - SAP Web Applicatio").Page("Zertifikatfehler: Navigation").Link("Laden dieser Website fortsetze"))
'			Browser("Anmeldung - SAP Web Applicatio").Page("Zertifikatfehler: Navigation").Link("Laden dieser Website fortsetze").Click
			Call logger.trace(1,functionName&"| Certification found and handled")
			If Dialog("Sicherheitswarnung").Exist(5) Then
				Dialog("Sicherheitswarnung").WinButton("Ja").Click
			End If
			Exit For
			
		ElseIf Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebEdit("sap-user").Exist Then
			Call logger.trace(1,functionName&"| Login page Found")
			Exit For 
		End If	
		Call logger.trace(1,functionName&"| Certification error not found")
		Wait(3)
	Next
	
	Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Sync
	Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebEdit("sap-user")
	RetVal = frEnterData("UserName", Obj, "Text",uname)
	If RetVal = "True" Then
		Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebEdit("sap-password")
		RetVal = frEnterData("Password", Obj, "Text",password)
		If RetVal = "True" Then	
			Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebEdit("sap-client")
			RetVal = frEnterData("MandatBox",obj,"Text","040")
			If RetVal = "True" Then
				If Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("Anmelden").Exist(2) Then
					Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("Anmelden")
				ElseIf Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Link("Anmelden").Exist(2) Then
					Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Link("Anmelden")
				End If
				RetVal = frclick("Anmelden",obj)
				
				If RetVal = "True" Then
					If Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("Weiter").Exist(10) Then
						Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("Weiter").Click
					End If
					Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Sync
					If Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("KundenLink").Exist(20) Then
						frBVGK_login = "True"
					Else
						frBVGK_login = functionname & "|Error|Kunden list not found after loging in "					
					End If
				End If
			End If
		End if
	End if	
	Set obj = nothing
	If frBVGK_login <> "True" Then
		frBVGK_login = fucntionName & RetVal 
		Call logger.trace(1,frBVGK_login)	
	End If
	Call logger.trace(1,functionName & "*****END***** : Return value : "&frBVGK_login)
End function	


Function frBVGK_CustomerSearch()
	Dim functionname : functionname = "frBVGK_CustomerSearch"	
	frBVGK_CustomerSearch = functionName & "|Error|Unknown Error"
	Dim RetVal , obj, strCustomerNumber
	Call logger.trace(1,functionName & "*****Start*****")

	If Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("KundenLink").Exist(20) Then
		Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("KundenLink").highlight
		Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("KundenLink").Click
		Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("anzeigen").highlight
		Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("anzeigen").Click
		RetVal = "True"
	End  If
	
' ---------This code not working, the above code with highlight is now working to navigate to other page	
'	Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("KundenLink")
'	Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("KundenLink").highlight
'	RetVal = frClick("KundenList",obj)
'	Set obj = Nothing
'	
'	If RetVal = "True" Then
'	
'		Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Frame("KundenList").WebElement("anzeigen")
'		Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("anzeigen").highlight
'		RetVal = frclick("anzeigen",Obj)
'		Set obj = Nothing
		
		If RetVal = "True" Then
			Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebEdit("CustomerSearchbox")
'			RetVal = frEnterData("CustomerNumberBox",Obj,"text",Paramin("CustomerNumber"))  ''wrong obj name aprametertized

			RetVal = frEnterData("CustomerSearchbox",Obj,"text",Paramin("CustomerNumber"))
			If RetVal = "True" Then
				RetVal = "False"
				'Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Link("Suchen")   ''object class changed so code commented
				'changes done by Ankita K , as suchen button was not getting clicked
				Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("SuchenButton")
				For i = 1 To 15 Step 1
'					RetVal = frclick("SuchenButton",obj)
'				obj.Click
				obj.DoubleClick
					If Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("Details anzeigen").Exist(3)	Then
							RetVal = "True"
							Exit For
					End If
				Next
			
				If RetVal = "True" Then
					wait 10
					Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Sync
					
					'Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("CustomerNumberWebElement") '' object property updated
					Set obj = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebTable("Status").WebElement("CustomerNumberWebElement")										
					obj.highlight
										
					RetVal = frObjectExist("CustomerNumberWebElement",obj,25)
					If RetVal = "True" Then
						Call logger.trace(1,functionName & "Customer Number found : "& Paramin("CustomerNumber"))
						frBVGK_CustomerSearch = RetVal
'						If Strcomp(strCustomerNumber, Paramin("CustomerNumber")) = 0 Then
'							frBVGK_CustomerSearch = "True"
'							Call logger.trace(1,functionName & "Customer Number found : "&strCustomerNumber)
'						Else
'							Call logger.trace(1,functionName & "|Error|Expected Customer Number is "&Paramin("CustomerNumber")&", Actual Customer Number is "&strCustomerNumber)						
'							frBVGK_CustomerSearch = "False"
'						End If
					End If
'				End If
			End If
		End If
	End If
	Set obj = nothing 
	If frBVGK_CustomerSearch <> "True" Then
		frBVGK_CustomerSearch = functionName & RetVal
		Call logger.trace(1,frBVGK_CustomerSearch)
	End If
	Call logger.trace(1,functionName & "*****END***** : Return value : "&frBVGK_CustomerSearch)
End function	

Function frBVGK_CustomerVerify()
	Dim functionname : functionname = "frBVGK_CustomerVerify"
	frBVGK_CustomerVerify = functionName & "|Error|Unknown Error"
	Dim RetVal,Obj
	Call logger.trace(1,functionName & "*****Start*****")
	Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").Sync
	Call logger.trace(1,functionName & "|checking for Customer number - loop begins")
	
		Paramin("CustomerNumberBVGK") = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebTable("Status").WebElement("CustomerNumberWebElement").GetROProperty("innertext")
		If Paramin("CustomerNumber") = Paramin("CustomerNumberBVGK") Then
			Call logger.trace(1,functionName & "|Customer number matched in BVGK")
			frBVGK_CustomerVerify = "True" 
		Else
			
			frBVGK_CustomerVerify = functionName & "|Error|Customer number not matched in BVGK"
			Call logger.trace(1,frBVGK_CustomerVerify)
		End If

	
	If Test.AutID = "AUT_GK_51" Then
		Dim CustName
		CustName = Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebElement("NewCustomerName").GetROProperty("innertext")
		If CustName = Paramin("NewCustomername") Then
			frBVGK_CustomerVerify = "True"
			Call logger.trace(1,functionName & "|New Customer Name found in AKP  ")
		End If
	End If
	Call logger.trace(1,functionName & "*****END***** : Return value : "&frBVGK_CustomerVerify)
End function


function frBVGKCheck_Main()
	Dim functionname : functionname = "frBVGKCheck_Main"
	frBVGKCheck_Main = functionName & "|Error|Unknown Error"
	Dim RetVal,Obj
	Call logger.trace(1,functionName & "*****Start*****")
	RetVal = frBVGK_Login()
	If RetVal = "True" Then
		RetVal = frBVGK_CustomerSearch()
	End If
	If RetVal = "True" Then
		RetVal = frBVGK_CustomerVerify() 
	End If
	If RetVal = "True" Then
		frBVGKCheck_Main = "True"
	End If
	Browser("Anmeldung - SAP Web Applicatio").Close
	Call logger.trace(1,functionName & "*****END***** : Return value : "&frBVGKCheck_Main)
End function


'******************************************************************************************************************
'Function Name: frBVGK_inaktiv_customerVerification
'Description: This function is used to verify the customer in Inaktiv
'Input Parameter(s): 
'Output Parameter(s): 
'Return Value: Boolean Value or Error message
'Call Examples: AUT_GK_118
'Container (Designed In): 19.2
'Author: Ankita Kumari
'Created On: 11-Jun-2019
'Used In TCCs: AUT_GK_118
'**************************************MODIFICATION LOG*************************************************************
'Last Updated By : <Author name :  add a new entry for each modification>
'Container (Modified In): <Container #>
'Modified for TCC: <Automation_ID>
'Last Updated On: <Date>
'********************************************************************************************************************   
Function frBVGK_inaktiv_customerVerification()
	
	Dim functionName : functionName = "frBVGK_inaktiv_customerVerification"
	Dim strRetVal,stat
	Dim Proceed : Proceed = False
	frBVGK_inaktiv_customerVerification = functionName&"|Error|Unknown Error."
	Call logger.trace(1, "============================== Function Begin : "&functionName& " =========================")
	strRetval=frBVGK_login
	
	If Instr(1, Lcase(strRetval), "true")  > 0 Then
		strRetval=frBVGK_CustomerSearch()	
	End If
	
	If Instr(1, Lcase(strRetval), "true")  > 0 Then
		If Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebEdit("Edit_Status").Exist(30) Then
			
			stat=Browser("Anmeldung - SAP Web Applicatio").Page("Anmeldung - SAP Web Applicatio").WebEdit("Edit_Status").GetROProperty("value")
			If Lcase(stat)="inaktiv" Then
				call logger.addcheckpoint(1,4, "Customer is Inaktiv in BVGK","INFO","Successful","Y")
				Call logger.trace(1,functionName & "| Customer is Inactiv in BVGK ")
				strRetVal = "True"
				Browser("Anmeldung - SAP Web Applicatio").Close
			End If
		Else
        	strRetval = functionName&" | Error | status object not found"
			Call logger.trace(1, strRetval)		
		End If
	End If
	
	If Instr(1, Lcase(strRetval), "true")  > 0 Then
		frBVGK_inaktiv_customerVerification = "True"
	Else
		frBVGK_inaktiv_customerVerification = UpdateFunctionName(strRetVal, functionName)	
		Call logger.addScreenshot(functionName&" | "&strRetval)
	End If
	SystemUtil.CloseProcessByName "iexplore.exe" 'Close already open Internet Explorer instances.
	SystemUtil.CloseProcessByName "firefox.exe" 'Close already open firefox instances.


	Set objVal = Nothing
	Call logger.trace(1, "============================== "&functionName& " Return Value : "&frBVGK_inaktiv_customerVerification&" =========================")
	Call logger.trace(1, "============================== Function End : "&functionName& " =========================")

	
End Function

'********************************************************************************************************************   
'End of Function: frBVGK_inaktiv_customerVerification
'********************************************************************************************************************   

