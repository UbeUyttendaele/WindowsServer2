# Windows server II: Instalatie handleiding
 **Naam: Ube Uyttendaele**

 **Klas: G3.B**
## Inhoudstabel
	
- [Windows server II: Instalatie handleiding](#windows-server-ii-instalatie-handleiding)
	- [Inhoudstabel](#inhoudstabel)
	- [Opstellen](#opstellen)
	- [Uitvoering](#uitvoering)
	- [Setup](#setup)
	- [VM configuratie](#vm-configuratie)
		- [DC](#dc)
		- [Web, SQL en mail](#web-sql-en-mail)
		- [Workstations](#workstations)
		- [Testen](#testen)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>




## Opstellen
Voorzie de volgende structuur:

![bestandStructuur][bestandStructuur]

Een groot deel van dit zit al verpakt in het zip bestand. Maar plaats o.a. je iso bestanden in de iso folden.
Vervolgens ga je in het script VMSetup.ps1 en pas je de variabelen aan zodat de namen van de iso bestanden matchen.

Een andere mogelijkheid is om het pad van de iso in het script te veranderen naar het pad waar bestanden momenteel staan. **Let op je indien je isos niet in de map "iso" zet is de map nog steeds nodig.**



Bestand locaties:

- SSMS-Setup-ENU.exe -> ./scripts/provisioning/ws/

----
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Uitvoering

## Setup
Open vervolgens een powershell window ga naar de locatie waar je de opstelling hebt geplaatst en voor het VMSetup.ps1 bestand uit.

Indien alles goed gaat zouden er 5 virtuele machines opstarten. De uitvoer zou er als volgend moeten uitzien:

![VMSetup.ps1][VMSetup.ps1]

----


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## VM configuratie
Nu je vms opstaat zullen deze normaal een script oproepen.
DC zou uit zichzelf gestart moeten worden terwijl de andere wachten op een input.
Dit is intentioneel omdat alle andere vms moeten wachten tot de DC klaar is met configureren.

![dcstart][dcstart]

![webstart][webstart]
### DC
Dus als eerste volg je alle stappen die op je scherm komen op de dc vm, bij het uitvoeren van de scripts zal deze enkele keren herstarten en het script heropnemen. De volledige installatie van deze server kan een tijdje duren.

Bij de laatste stap zal je 1x op enter moeten duwen zodat de optie Y wordt gekozen

**Het script is ten einde indien je de melding "Script complete" te zien krijg.**

---- 

<br>
<br>
<br>
<br>
<br>
<br>

### Web, SQL en mail
Nu de DC klaar is kunnen we de rest van de servers configureren.
Voer nu de stappen uit die op je scherm komen tijdens de installatie van web, sql en mail.
Run deze in de volgende volgorde om fouten te vermijden:
1. WEB
2. SQL
3. Mail

Indien web klaar is kan je ook beginnen aan de configuratie van de workstations.

**Let op, bij enkele van deze servers moet je manueel dingen selecteren.**

----

### Workstations
Vervolgens starten we met het configureren van de workstations.
Het scherm zou al moeten openstaan bij eerste startup. Voer het script uit en de computer zal herstarten uitzichzelf en zou in het domein moeten zitten.

----

### Testen
Om deze omgeving te testen probeer het volgende:
* surf naar https://www.ws2-2223-ube.hogent
* Kijk of je van user kan veranderen
	* Username: bob of sofie
	* Wachtwoord: Admin2021
* Probeer te connecteren naar de database: sql.ws2-2223-ube.hogent, hier zou een database moeten bestaan met de naam temp. Doe dit als de user **Administrator@ws2-2223-ube.hogent**, andere users hebben geen toegang tot deze sql server.
* Surf naar https://mail.ws2-2223-ube.hogent/owa en probeer in te loggen met het email van een user. Bv bob@ws2-2223-ube.hogent of sofie@ws2-2223-ube.hogent
* Probeer een mail te versturen naar de andere user.
* Probeer te connecteren via de email client van windows, deze kan wat moeilijk doen om te connecteren. Indien dit niet lukt ga in advanced mode en vul alle velden in met het volgende:

- Email: email van de user
- paswoord: paswoord van de user
- domainname: ws2-2223-ube.hogent
- server: mail.ws2-2223-ube.hogent

* Open een terminal en probeer nslookup te doen van servers.

<style>
img{
	display: block;
	margin-left: auto;
	margin-right: auto;
	width: 50%;
}
</style>
[bestandStructuur]: ./Deployment/Structuur.png
[VMSetup.ps1]: ./Deployment/VMsetup.png
[dcstart]: ./Deployment/dcstart.png
[webstart]: ./Deployment/webstart.png
