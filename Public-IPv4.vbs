Dim fso
Set fso = WScript.CreateObject("Scripting.Filesystemobject")
Set f = FSO.CreateTextFile(".\Public-IP.txt", TRUE)
f.Close
Set f = fso.OpenTextFile(".\Public-IP.txt", 2)

Set oIP = CreateObject("MSXML2.XMLhttp")
oIP.Open "GET", "http://v4.members.feste-ip.net", False
oIP.Send
f.WriteLine oIP.ResponseText
Set oIP = Nothing

WScript.Quit 


f.Close
'End of Script
' https://stackoverflow.com/questions/17194375/i-need-to-write-vbs-wscript-echo-output-to-text-or-cvs
' https://administrator.de/forum/vbs-scripten-textdateien-erstellen-147551.html
' https://www.feste-ip.net/ddns-service/einrichtung/ipv4-ipv6/
' oIP.Open "GET", "http://show-my-ip-address.de/iponly.php", False

