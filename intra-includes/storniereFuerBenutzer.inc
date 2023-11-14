[% IF whole.error %]
    <p>Unbekannter Fehler</p>
[% END %]

[% IF ( whole.stage == "confirmcommit" ) %]
    <h2>Bestellung stornieren (Bestell-ID: [% request.orderid %])</h2>
    <p>Das Bestätigen dieser Aktion setzt den Status der Fernleihebestellung auf  'Abgeschlossen' oder 'Storniert'.</p>
    <p>Das bedeutet, dass mit der besitzenden Bibliothek abgeklärt worden ist, ob der Versand des bestellten Mediums noch unterbunden werden kann<br>
    oder ob das bestellte Medium bereits hierher versandt worden ist.</p>
    <p>Im ersten Fall geht die Bestellung in den Status 'Abgeschlossen' und die dafür temporär angelegten Titel- und Exemplardaten werden gelöscht.<br>
    Im zweiten Fall wird der Status auf 'Storniert' gesetzt und nach Eintreffen in der Bibliothek kann das Medium ohne Eingangsverbuchung und ohne Ausleihe sofort zurück versandt werden.</p>

    [% IF ( request.status != 'REQ' ) %]
        <hr>
        <p>Der aktuelle Status '[% request.status %]' der Fernleihebestellung steht der Stornierung entgegen.</p>
        <p>Diese Aktion ist nur vor der Eingangsverbuchung möglich.</p>
        <p>Bei Verzicht des Benutzers nach der Eingangsverbuchung kann das Medium sofort zurück versandt werden.</p>

        <a class="cancel" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>

    [% ELSE %]

        <form id="SLNP_cancelled" name="SLNP_cancelled" method="POST" action=[% here %]>

            <input name="illrequest_id" id="illrequest_id" value="[% whole.illrequest_id %]" type="hidden" />
            <input name="backend" id="backend" value="ILLSLNPKoha" type="hidden" />
            <input name="method" id="method" value="storniereFuerBenutzer" type="hidden" />
            <input name="stage" id="stage" value="[% whole.stage %]" type="hidden" />
            <input name="itemnumber" id="itemnumber" value="[% whole.value.other.itemnumber %]" type="hidden" />

            <div>
                <input type="radio" id="alreadyShippedNo" name="alreadyShipped" value="alreadyShippedNo"> 
                <label for="alreadyShippedNo">Das bestellte Medium wird von der besitzenden Bibliothek nicht versandt.</label>
            </div>
            <div>
                <input type="radio" id="alreadyShippedYes" name="alreadyShipped" value="alreadyShippedYes" checked>
                <label for="alreadyShippedYes">Das bestellte Medium befindet sich bereits im Versand an die nehmende Bibliothek.</label>
            </div>
            <br>

            [% IF ( whole.stage == "confirmcommit" ) %]
                <input id="submitbutton" name="submitbutton" type="submit" value="Bestätigen" onclick="stage.value='commit'" />
            [% ELSE %]
                <input id="submitbutton" name="submitbutton" type="submit" value="Bestätigen" onclick="stage.value='commit'" disabled />
            [% END %]

            <a class="cancel" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>

        </form>
    [% END %]

[% ELSE %]
    <p>Unbekannte Stufe '[% whole.stage %]'. Das sollte sich nicht ereignen.</p>
[% END %]



[% BLOCK backend_jsinclude %]
    [% IF ! ( request.status == 'REQ' ) %]
        <style id="antiClickjack">body{display:none !important;}</style>
        [% INCLUDE 'js_includes.inc' %]

        <script type= "text/javascript">

            $(document).ready(function() {
                submitbutton.disabled = true;
            })

        </script>
    [% END %]
[% END %]
