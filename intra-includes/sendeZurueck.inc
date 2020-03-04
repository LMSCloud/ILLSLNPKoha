[% USE Asset %]


[% IF whole.error %]
    <p>Unbekannter Fehler</p>
[% END %]

[% IF whole.stage == "confirmcommit" %]
    <h2>Rückversand des Fernleihe-Mediums an die besitzende Bibliothek (Bestell-ID: [% request.orderid %])</h2>
    <p>Das Bestätigen dieser Aktion setzt den Status der Fernleihebestellung auf 'Abgeschlossen'.</p>
    <p>Das bedeutet, dass der Besteller das Medium zurückgegeben oder die Fernleihebestellung vor der Ausleihe storniert hat,<br>
       und dass der Rückversand des Fernleihe-Mediums an die besitzende Bibliothek in die Wege geleitet wird.</p>

    [% IF ( request.status == 'RECVD' ) %]
        <p><strong>
            Das Fernleihe-Medium wurde noch nicht an den Besteller ausgeliehen bzw. ausgehändigt.<br>
            Bestätigen Sie den Rückversand also nur dann, wenn Sie eine Stornierung dieser Fernleihebestellung durchführen wollen.</strong></p>
    [% ELSE %]
        [% IF ! ( request.status == 'CHKDIN' || request.status == 'CNCLDFU' ) %]
            <p><strong>
                Der aktuelle Status '[% request.status %]' der Fernleihebestellung steht dem Rückversand entgegen.<br>
                Vor dem Rückversand muss die Fernleihebestellung storniert werden oder das Fernleihe-Medium nach der Ausleihe erst Rückgabe-verbucht werden.</strong></p>
        [% END %]
    [% END %]

    <form id="SLNP_shipback" name="SLNP_shipback" method="POST" action=[% here %]>

        <label for="illshipbackslipprint">Brief für den Rückversand erstellen:</label>
        [% IF whole.value.other.illshipbacklettercode %]
            <input type="checkbox" name="illshipbackslipprint" id="illshipbackslipprint" value="1" [% IF whole.value.other.illshipbackslipprint %]checked="checked"[% END %] />
        [% ELSE %]
            <input type="checkbox" name="illshipbackslipprint" id="illshipbackslipprint" value="1" disabled />
        [% END %]
        <br>

        <input type="hidden" name="illrequest_id" id="illrequest_id" value="[% whole.illrequest_id %]" />
        <input type="hidden" name="backend" id="backend" value="[% request.backend %]" />
        <input type="hidden" name="method" id="method" value="[% whole.method %]" />
        <input type="hidden" name="stage" id="stage" value="[% whole.stage %]" />
        <input type="hidden" name="itemnumber" id="itemnumber" value="[% whole.value.other.itemnumber %]" />
        <br>

        <input id="submitbutton" name="submitbutton" type="submit" value="Bestätigen" onclick="stage.value='storeandprint';" />

        <a class="cancel" id="cancelbutton" name="cancelbutton" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>

    </form>

[% ELSIF whole.stage == "storeandprint" %]

  <p>Rückkehr zur Fernleihbestellung</p>

  <form id="SLNP_shipback" name="SLNP_shipback" method="POST" action=[% here %]>
    <input style="display:none" type="checkbox" name="illshipbackslipprint" id="illshipbackslipprint" value="1" [% IF ( whole.value.other.illshipbackslipprint ) %]checked="checked"[% END %] />
    <input style="display:none" id="submitbutton" name="submitbutton" type="submit" value="Bestätigen" onclick="stage.value='storeandprint';" />
    <a style="display:none" class="cancel" id="cancelbutton" name="cancelbutton" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>
  </form>

[% ELSE %]
    <p>Unbekannte Stufe '[% whole.stage %]'. Das sollte sich nicht ereignen.</p>
[% END %]



<script type= "text/javascript">

    $(document).ready(function() {
        [% IF ! ( request.status == 'RECVD' || request.status == 'CHKDIN' || request.status == 'CNCLDFU' ) %]
            submitbutton.disabled = true;
        [% END %]

        [% IF whole.stage == 'storeandprint' %]
            var slipchecked = $("#illshipbackslipprint").prop('checked');
            if ( slipchecked ) {
                var ret = printIllShipbackSlip();
            } else {
                document.getElementById("cancelbutton").click();
            }
        [% END %]
    });    // $(document).ready(function() END

    function printIllShipbackSlip () {
        var borrowernumbers = [];
        borrowernumbers.push("[% whole.value.other.sendingIllLibraryBorrowernumber %]");
        borrowernumbers.push("[% whole.value.request.borrowernumber %]");

        var data = {
            use_letter: "[% whole.value.other.illshipbacklettercode %]",
            use_email: '',
            slipcount: '1',
            illrequestid: "[% whole.illrequest_id %]",
            biblionumber: "[% request.biblio_id %]",
            itemnumber: "[% whole.value.other.itemnumber %]",
            duedate: "[% whole.value.other.duedate %]",
            borrowernumbers: borrowernumbers
        };

        $.ajax({
            data: data,
            type: 'POST',

            url: '/cgi-bin/koha/svc/members/genIllDeliverySlip',
            success: function(data) {

                var processingslipwin = window.open("/cgi-bin/koha/tools/download-files.pl?filename=" + data.printedfile + "&op=download");

                processingslipwin.onload = function()
                {
                    document.getElementById("cancelbutton").click();
                    processingslipwin.print();
                    processingslipwin.close();
                };

            },
            error: function() {
                alert( _("A server error occured processing the processing slip print request.") );

                document.getElementById("cancelbutton").click();
            }
        });
    }

</script>
