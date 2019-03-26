[% USE Asset %]


[% IF whole.error %]
    <p>Unbekannter Fehler</p>
[% END %]

[% IF ( whole.stage == "confirmcommit" ) %]
    <h2>Verlustmeldung für Fernleihe-Medium (Bestell-ID: [% request.orderid %])</h2>
    <p>Das Bestätigen dieser Aktion setzt den Status der Fernleihebestellung auf 'Abgeschlossen'.</p>
    <p>Das bedeutet, dass der Besteller das Medium nach der Ausleihe verloren hat, <br>
       oder dass das Medium in der Bibliothek nach Eingangsverbuchung vor der Ausleihe <br>
       oder nach der Rückgabe vor dem Rückversand abhanden gekommen ist.</p>

    [% IF ! ( request.status == 'LOSTBCO' || request.status == 'LOSTACO' ) %]
        <p><strong>
            Der aktuelle Status '[% request.status %]' der Fernleihebestellung steht der Verlustmeldung entgegen.<br>
            Vor der Verlustmeldung muss im Fernleihe-Exemplar ein Verloren-Status gesetzt werden.</strong></p>
    [% END %]

    <form id="SLNP_itemlost" name="SLNP_itemlost" method="POST" action=[% here %]>

        <label for="illitemlostlibraryletterprint">Verlustmeldung an die besitzende Bibliothek erstellen:</label>
        [% IF whole.value.other.illitemlostlibrarylettercode %]
            <input type="checkbox" name="illitemlostlibraryletterprint" id="illitemlostlibraryletterprint" value="1" [% IF whole.value.other.illitemlostlibraryletterprint %]checked="checked"[% END %] />
        [% ELSE %]
            <input type="checkbox" name="illitemlostlibraryletterprint" id="illitemlostlibraryletterprint" value="1" disabled />
        [% END %]
        <br>

        [% IF ( request.status == 'LOSTBCO' ) %]
            <label for="illitemlostborrowerletterprint">Verlustmeldung an den Besteller erstellen:</label>
            [% IF whole.value.other.illitemlostborrowerlettercode %]
                <input type="checkbox" name="illitemlostborrowerletterprint" id="illitemlostborrowerletterprint" value="1" [% IF whole.value.other.illitemlostborrowerletterprint %]checked="checked"[% END %] />
            [% ELSE %]
                <input type="checkbox" name="illitemlostborrowerletterprint" id="illitemlostborrowerletterprint" value="1" disabled />
            [% END %]
            <br>
        [% END %]

        <input name="illrequest_id" id="illrequest_id" value="[% whole.illrequest_id %]" type="hidden" />
        <input name="backend" id="backend" value="ILLSLNPKoha" type="hidden" />
        <input name="method" id="method" value="meldeVerlust" type="hidden" />
        <input name="stage" id="stage" value="[% whole.stage %]" type="hidden" />
        <input name="itemnumber" id="itemnumber" value="[% whole.value.other.itemnumber %]" type="hidden" />
        <input name="sendingIllLibraryBorrowernumber" id="sendingIllLibraryBorrowernumber" value="[% whole.value.other.sendingIllLibraryBorrowernumber %]" type="hidden" />
        <input name="illitemlostlibrarylettercode" id="illitemlostlibrarylettercode" value="[% whole.value.other.illitemlostlibrarylettercode %]" type="hidden" />
        <input name="illitemlostborrowerlettercode" id="illitemlostborrowerlettercode" value="[% whole.value.other.illitemlostborrowerlettercode %]" type="hidden" />
        <br>

        [% IF ( whole.stage == "confirmcommit" ) %]
            <input id="submitbutton" name="submitbutton" type="submit" value="Bestätigen" onclick="stage.value='confirmcommit'" />
        [% ELSE %]
            <input id="submitbutton" name="submitbutton" type="submit" value="Bestätigen" onclick="stage.value='commit'" disabled />
        [% END %]

        <a class="cancel" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>

    </form>

[% ELSE %]
    <p>Unbekannte Stufe '[% whole.stage %]'. Das sollte sich nicht ereignen.</p>
[% END %]



<script type= "text/javascript">

    $(document).ready(function() {
        [% IF ! ( request.status == 'LOSTBCO' || request.status == 'LOSTACO' ) %]
            submitbutton.disabled = true;
        [% END %]

    });

</script>
