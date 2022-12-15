## Instalatie handleiding
### Mappenstructuur
Voorzie een map met de volgende submappen.

![Mappenstructuur][mapStructuur]

Unzip je het bestand met alle scripts, plaats de folder scripts in provisioning. Vervolgens plaats je de scripts functions.ps1 en vmSetup.ps1 in de root hoofdfolder.

Indien je alles goed hebt uitgevoerd zal je structuur er moeten uitzien zoals in de figuur hieronder.
![Mappenstructuur][bestandStructuur]
### Opstellen
Voor de volgende stap kan je op twee manieren op te werk te gaan, de eerste manier is om de iso bestanden in de map "iso" te plaatsen, deze zijn onder de isos van windows server 2019, windows 10/11, mincrosoft exchange en microsoft sql, verander het pad met de namen in het script naar wat voor jouw toepasselijk is (bv. van .\iso\server.iso naar .\iso\win2019.iso).

De andere mogelijkheid is om het pad van de iso in het script te veranderen naar het pad waar bestanden momenteel staan. **Let op je indien je isos niet in de map "iso" zet is de map nog steeds nodig.**

<style>
img{
	display: block;
	margin-left: auto;
	margin-right: auto;
}
</style>
[bestandStructuur]: ./screenschotsDocumentatie/bestandStructuur.png
[netwerkDiagram]: ./screenschotsDocumentatie/netwerkdiagram.png
[mapStructuur]: ./screenschotsDocumentatie/mapStructuur.png