<h2>Verlustbuchung für Fernleihe-Medium (Bestell-ID: [% request.orderid %])</h2>
<p>Die Verlustbuchung des Mediums der Fernleihebestellung wird durchgeführt, <br>
   indem man im entsprechenden Exemplar-Datensatz den zutreffenden Verloren-Status auswählt. <br>
   Dadurch wird der Status der Fernleihebestellung auf 'Verlust vor Ausgabe' bzw. 'Verlust' gesetzt. <br>
   Fernleihebestellung mit diesem Status können mittels der Aktion 'Verlustmeldung' abgeschlossen werden. <br>
   Erst durch die Aktion 'Verlustmeldung' erfolgt die Benachrichtigung an die besitzende Bibliothek und ggfs. an den Besteller</p>

<a class="text" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% request.biblio_id %]" target="_blank" >Verloren-Status setzen</a>
&nbsp;&nbsp;&nbsp;
<a class="cancel" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>
