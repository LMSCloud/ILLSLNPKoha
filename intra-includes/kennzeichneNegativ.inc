[% IF whole.error %]
    <p>Unbekannter Fehler</p>
[% END %]

[% IF ( whole.stage == "confirmcommit" ) %]
    <h2>Negativ-Kennzeichen (Bestell-ID: [% request.orderid %])</h2>
    <p>Das Bestätigen dieser Aktion setzt den Status der Fernleihebestellung auf 'Abgeschlossen'.</p>
    <p>Das bedeutet, dass die besitzende Bibliothek das bestellte Medium nicht liefern kann, <br>
       dass diese Fernleihebestellung beendet wird, <br>
       und dass die dafür temporär angelegten Titel- und Exemplardaten gelöscht werden.</p>

    [% IF ! ( request.status == 'REQ' || request.status == 'CNCLDFU' ) %]
        <p>Der aktuelle Status '[% request.status %]' der Fernleihebestellung steht der Negativ-Kennzeichnung entgegen.</p>
        <p>Diese Aktion ist nur vor der Eingangsverbuchung möglich.</p>

        <a class="cancel" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>

    [% ELSE %]

        <form id="SLNP_notdelivered" name="SLNP_notdelivered" method="POST" action=[% here %]>

            <label for="illnotdeliveredletterprint">Absage-Benachrichtigung an den Besteller:</label>
            [% IF whole.value.other.illnotdeliveredlettercode %]
                <input type="checkbox" name="illnotdeliveredletterprint" id="illnotdeliveredletterprint" value="1" [% IF whole.value.other.illnotdeliveredletterprint %]checked="checked"[% END %] />
            [% ELSE %]
                <input type="checkbox" name="illnotdeliveredletterprint" id="illnotdeliveredletterprint" value="1" disabled />
            [% END %]
            <br>

            <input name="illrequest_id" id="illrequest_id" value="[% whole.illrequest_id %]" type="hidden" />
            <input name="backend" id="backend" value="ILLSLNPKoha" type="hidden" />
            <input name="method" id="method" value="kennzeichneNegativ" type="hidden" />
            <input name="stage" id="stage" value="[% whole.stage %]" type="hidden" />
            <input name="itemnumber" id="itemnumber" value="[% whole.value.other.itemnumber %]" type="hidden" />
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
    [% IF ! ( request.status == 'REQ' || request.status == 'CNCLDFU' ) %]
        <style id="antiClickjack">body{display:none !important;}</style>
        [% INCLUDE 'js_includes.inc' %]

        <script type= "text/javascript">

            $(document).ready(function() {
                submitbutton.disabled = true;
            })

        </script>
    [% END %]
[% END %]
