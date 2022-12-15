# Windows server II
 **Naam: Ube Uyttendaele**

 **Klas: G3.B**
## Inhoudstabel

- [Windows server II](#windows-server-ii)
	- [Inhoudstabel](#inhoudstabel)
	- [Vereisten](#vereisten)
	- [Documentatie](#documentatie)
		- [Resource toekenning](#resource-toekenning)
		- [Netwerk diagram](#netwerk-diagram)
		- [DC](#dc)
			- [Active Directory](#active-directory)
			- [DNS](#dns)
			- [NAT](#nat)
			- [Certificate authority](#certificate-authority)
		- [Web](#web)
			- [DHCP](#dhcp)
			- [IIS](#iis)
			- [DNS(web)](#dnsweb)
		- [Mail](#mail)
		- [SQL](#sql)
	- [Zoals bij de exchange heb je voor de sql server ook een iso nodig waarvan je de software installeert, om later op deze database te geraken via de clients.](#zoals-bij-de-exchange-heb-je-voor-de-sql-server-ook-een-iso-nodig-waarvan-je-de-software-installeert-om-later-op-deze-database-te-geraken-via-de-clients)
		- [Workstations](#workstations)

## Vereisten
* Virtualbox + extension
* Virtualbox guestadditions ISO
* Windows server 2019 en 10/11 ISO
* Microsoft exchange ISO
* Microsoft SQL ISO
* Powershell scripts die voorzien zijn

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

## Documentatie
### Resource toekenning

__De resource toekenning kan nog mogelijks veranderen indien de huidige toekenning niet voldoende is__


| Device    	|   Cores   |  Ram  	|  Opslag	  	|
|---------------|-----------|-----------|---------------|
|   dc 	    	|   2       |   2GiB	|  25GB	        |
|   web 		|   2	    |   1GiB	|  25GB	        |
|   mail    	| 	2       |   6GiB 	|  50GB         |
| 	SQL			|	1		|	1GiB	|  25GB			|
|   ws 	    	|   1	    |   1GiB	|  25GB 	    |
| **Totaal**  	|	8		|	11GiB	|  150GB		|

_Opmerking, ik probeer deze opstelleing te draaien op een laptop mat 14GB RAM te beschikking (16GB maar integrated graphics en os nemen deel in beslag) indien dit niet voldoende is kan ik overschakelen naar een computer met 32GB ram en zal het aantal ram aangepast worden_

Hierboven vindt je een tabel met alle benodigdheden om deze opstelling te kunnen draaien op jouw host systeem en de ip addressen die aan de virtuele machines worden toegekend aan de hand van een powershell script of de DHCP server die draait op een van de servers. Met uizondering van de NAT adapter die op de domeincontroller "dc" staat. Deze krijgt een ip toegekend van een virtuele router die virtualbox aanmaakt op jouw host systeem om aan het internet aan te kunnen.

Storage wordt dynamisch gealloceerd, dus de vm neemt evenveel opslagruimte in beslag op het host hostsysteem als op de vm. Bv je vm gebruikt 8GB van de 30GB die hij gealloceerd krijgt, dan zal de vm ook maar 8GB innemen op de host.

-------

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

### Netwerk diagram

__Het netwerk diagram kan nog logelijks veranderen indien de rollen verplaatst worden naar een andere server__

![Netwerk diagram][netwerkDiagram]
__Netwerkdiagram moet nog aangepast worden(sql server is nog niet toegevoegd)__

| Device    	|   Type   	|  IP  					|  Gateway	  	| DNS						|
|---------------|-----------|-----------------------|---------------|---------------------------|
|   dc 	    	|   dhcp    | 10.0.2.15         	| 10.0.2.2		| 10.0.2.2					|
|    	    	|   static  | 192.168.22.1     		| /				| 192.168.22.1, 192.168.22.2|
|   web 		|   static	| 192.168.22.2  		| 192.168.22.1	| 192.168.22.1, 192.168.22.2|
|   mail    	| 	static  | 192.168.22.3  		| 192.168.22.1	| 192.168.22.1, 192.168.22.2|
| 	SQL			|	static	| 192.168.22.4 			| 192.168.22.1	| 192.168.22.1, 192.168.22.2|
|   ws 	    	|   dhcp	| 192.168.22.101-150	| 192.168.22.1	| 192.168.22.1, 192.168.22.2|

--------
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

### DC
De dc is het hart van ons lan, deze is verantwoordelijk voor het beheren van het domein en toegang te geven tot het internat aan andere toestellen.


| Rollen 	| AD 	| DNS	| NAT 	| CA 	| DHCP 	| IIS 	| SQL 	| EX 	|
|-----------|-------|-------|-------|-------|-------|-------|-------|-------|
|			|	X	|	X	|	X	|	X	|		|		|		|		|

Zoals reeds vermeld is in de tabel onder "Resource toekenning" zal deze server **2 cores, 2GiB ram en 25gb opslag** krijgen. Vervolgens heeft de DC heeft 2 interfaces een NAT adapter die een ip krijgt via dhcp (internet) en een internal adapter met een static ip die het interne netwerk "intnet" (lan) in virtualbox gebruikt. De **NAT adapter** krijgt het ip address **10.0.2.15**, dit het default ip adres dat virtualbox toekent via dhcp. Vervolgens krijgt de **internal adapter** het static ip adres **192.168.22.1**.

#### Active Directory
Deze server wordt voorzien om het domein te beheren, hiervoor hebben we de rol `Active Directory Domain Services` nodig, deze rol is cruciaal zodat we als users kunnen inlogen met een account die is verbonden met het domein en zo alle services die hierbij behoren kunnen gebruiken. Het domein zal de naam **"ws2-2223-ube.hogent"** krijgen, vervolgens zullen er ook **2 test gebruikers** worden voorzien die geen speciale rechten hebben om administrative taken uit te voeren.

Gebruiker 1:

* gebruikersnaam: bob
* wachtwoord: Admin2021

Gebruiker 2:

* gebruikersnaam: sofie
* wachtwoord: Admin2021


**Opmerking** Gebruik deze wachtwoorden nooit in een omgeving of service dat geen testomgeving is. Deze wachtwoorden zijn gekozen om het simpel te houden, ze voldoen niet aan veiligheidsnormen en kunnen zeer makkelijk geraden/gekraakt worden.

#### DNS
Bij het installeren van Active Directory wordt er ook gevraagd of je een DNS server wilt installeren omdat deze nodig is om een domein op te zetten. Dit verzoek accepteren we waardoor alle benodigheden voor active directory voldoen worden. Deze DNS server zal de **primairy DNS** server zijn in deze omgeving.

#### NAT
Omdat de dc het enigste toestel is dat een verbinding heeft met het internet zullen we hier NAT op moeten draaien zodat we andere toestellen dan ook toegang kunnen geven indien hun default-gateway als de dc is ingesteld. Dit kunnen we doen door de rol `Remote Access` te installeren. 

<br>

#### Certificate authority

De CA dient om certificaten aan te maken voor het domein, voor onze use case zullen we deze roll gebruiken om een certificaat aan te maken voor de webserver zodat deze beschikbaar is via https. Dit gaan we doen door een enterprise CA aan te maken aangezien deze nodig is om certificaten te beheren voor een domein.


---------

### Web
De "web" server zal de rollen draaien gerelateerd met het internet. 
Rollen:


| Rollen 	| AD 	| DNS	| NAT 	| CA 	| DHCP 	| IIS 	| SQL 	| EX 	|
|-----------|-------|-------|-------|-------|-------|-------|-------|-------|
|			|		|	X	|		|		|	X	|	X	|		|		|

Deze server heeft **2 cores, 2GiB ram en 25GB opslag**, ten slotte krijgt deze server het static ip adres **192.168.22.2**

#### DHCP
Deze server zal de dhcp server zijn voor dit netwerk. Dit is mogelijk door de rol `DHCP` te installeren, na het installeren van deze rol wordt er een scope aangemaakt met het ip range 192.168.22.101 tot 192.168.22.150. Dit zijn de ip adressen die worden toegekend aan clients die zich in het lan bevinden.

#### IIS
IIS is de naam dat Microsoft hun webservice geef. Deze rol kunnen we installeren met `Web-Server`.
De service zal een website draaien die we zelf bepalen (komt later aan bod). Deze draait op poort 443, de standaard https poort waarbij het certificaat zal gegeneerd worden door de rol CA.
De website zal beschikbaar zijn op https://ws2-2223-ube.hogent.


#### DNS(web)
Dit is onze secundairy DNS server dat we installeren met de rol `dns`. Deze zal alle records overnemen die zich bevinden op de dc.

--------

### Mail
Deze server met de naam "mail" zal microsoft exchange draaien, hierdoor zullen de domein gebruikers emails naar elkaar kunnen sturen aan de hand van hun email adressen die worden toegekend via het domein. 

| Rollen 	| AD 	| DNS	| NAT 	| CA 	| DHCP 	| IIS 	| SQL 	| EX 	|
|-----------|-------|-------|-------|-------|-------|-------|-------|-------|
|			|		|		|		|		|		|		|		|	X	|

Deze server krijgt 2 cores, 6GiB ram en 50GB opslag en het statisch ip adress 192.168.22.3 toegewezen.

Dit gaan we doen door aan de hand van de microsoft exchange 2019 iso, vervolgens zullen we de software installeren en zal de installer alle benodigheden installeren op de dc.


--------

### SQL
De sql server met de naam "SQL" zijn enigste taak is om een database ter beschikking te zetten voor het lan netwerk. Op deze server zal dan ook geen andere rollen worden geinstalleerd.

| Rollen 	| AD 	| DNS	| NAT 	| CA 	| DHCP 	| IIS 	| SQL 	| EX 	|
|-----------|-------|-------|-------|-------|-------|-------|-------|-------|
|			|		|		|		|		|		|		|	X	|		|

Deze server krijgt 1 cores, 1GiB ram en 25GB opslag en het statisch ip adress 192.168.22.4 toegewezen waarop de clients verbinding zullen maken om aan de databse te kunnen.

Zoals bij de exchange heb je voor de sql server ook een iso nodig waarvan je de software installeert, om later op deze database te geraken via de clients.
--------

### Workstations

Vervolgens heb je de groep workstations, deze zullen een ip adres toegekend krijgen van de DHCP server die op "web" draait. Net zoals de rest van de toestellen zullen deze aangesloten zijn met een internal adapter op het netwerk "intnet". Deze computers krijgen 1 core, 1GiB ram en 25GB opslag.

Op deze computers zal er enkele software geinstalleerd worden. Deze zijn onderandere:

* Firefox
* Microsoft sql client
* Remote management tool voor servers