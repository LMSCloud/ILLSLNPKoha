[% IF whole.error %]
  [% IF whole.status == 'missing_sendingIllLibraryInfo' %]
    <p><em>Hinweis:</em> Pflichtfeld 'Lieferbibliothek' hat keinen Eintrag.</p>
  [% ELSE %]
    <p>Unbekannter Fehler</p>
  [% END %]
[% END %]

[% IF whole.stage == "deliveryInsert" || whole.stage == "deliveryUpdate" %]
  [% IF whole.stage == "deliveryInsert" %]
    <h2>Eingangsverbuchung (Bestell-ID: [% whole.value.request.orderid %])</h2>
  [% ELSE %]
    <h2>Eingang bearbeiten (Bestell-ID: [% whole.value.request.orderid %])</h2>
  [% END %]

  <form id="SLNP_delivery" name="SLNP_delivery" method="POST" action=[% here %]>

    <fieldset class="rows">
      <legend>Mediendaten</legend>
      <ol id="general-slnp_delivery-fields">

        <li>
          <label class="required" for="type">Bestelltyp:</label>
            <select name="type" id="type" required="required">
            [% IF !whole.error %]
              <option value=""/>
            [% END %]
            [% IF whole.value.other.type == "Book" %]
              <option value="Book" selected="selected">Book</option>
            [% ELSE %]
              <option value="Book">Book</option>
            [% END %]
            [% IF whole.value.other.type == "Article" %]
              <option value="Article" selected="selected">Article</option>
            [% ELSE %]
              <option value="Article">Article</option>
            [% END %]
            [% IF whole.value.other.type == "Journal" %]
              <option value="Journal" selected="selected">Journal</option>
            [% ELSE %]
              <option value="Journal">Journal</option>
            [% END %]
            [% IF whole.value.other.type == "Other" %]
              <option value="Other" selected="selected">Other</option>
            [% ELSE %]
              <option value="Other">Other</option>
            [% END %]
          </select>
        </li>

        <li>
          <label for="noncirccollection">Präsenzbestand:</label>
          [% IF whole.value.other.noncirccollection %]
            <input type="checkbox" name="noncirccollection" id="noncirccollection" value="1" checked="checked" />
          [% ELSE %]
            <input type="checkbox" name="noncirccollection" id="noncirccollection" value="1" />
          [% END %]
        </li>

        <li>
          <label class="required" for="kohaitemtype">Medientyp:</label>
          <select id="kohaitemtype" name="kohaitemtype" required="required" >
            [% IF !whole.error %]
              <option value="" />
            [% END %]
            [% FOREACH kohaillitemtype IN whole.value.other.kohaIllItemtypes %]
              [% IF whole.value.other.kohaitemtype == kohaillitemtype.itemtype %]
                <option value="[% kohaillitemtype.itemtype %]" selected="selected">
              [% ELSE %]
                <option value="[% kohaillitemtype.itemtype %]">
              [% END %]
                [% kohaillitemtype.translated_description %]
              </option>
            [% END %]
          </select>
        </li>

        <li>
          <label for="volumescount">Anzahl Bände:</label>
         <input type="number" name="volumescount" id="volumescount" min="0" size="10" maxlength="10" value="[% whole.value.other.volumescount %]" />
        </li>

      </ol>
    </fieldset>

    <fieldset class="rows">
      <legend>Lieferung</legend>
      <ol id="details-delivery-fields">

        <li>
          <label class="required" for="deliverydate">Exemplar/Dokument erhalten am:</label>
          <input type="text" class="flatpickr" data-flatpickr-futuredate="false" name="deliverydate" id="deliverydate" size="10" maxlength="10" value="[% whole.value.other.deliverydate %]" required="required" />
          <span class="hint">[% INCLUDE 'date-format.inc' %]</span>
        </li>

        <li id="sendingIllLibrary">
          <label class="required" for="sendingIllLibraryInfo">Lieferbibliothek:</label>

          [% IF whole.value.other.sendingIllLibraryBorrowernumber %]
            [% SET selSigel = whole.value.other.sendingIllLibraryIsil %]
            [% SET sendingIllLibraryInfo = 'Sigel: ' _ whole.value.other.sendingIllLibraryIsil _ ' / ' _ whole.value.other.sendingIllLibrarySurname _ ' / Ort: ' _ whole.value.other.sendingIllLibraryCity %]
            <span></span><a target="blank" href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% whole.value.other.sendingIllLibraryBorrowernumber %]"><input disabled type="text" name="sendingIllLibraryInfo" id="sendingIllLibraryInfo" size="80" value="[% sendingIllLibraryInfo | html %]" required="required" /></a>
          [% ELSE %]
            [% SET selSigel = '' %]
            [% SET sendingIllLibraryInfo = 'Sigel' _ '' _ ' / ' _ 'Bibliotheksname' _ ' / ' _ 'Ort' _ '  (noch nicht zugeordnet)' %]
            <span></span><a><input readonly required="required" type="text" name="sendingIllLibraryInfo" id="sendingIllLibraryInfo" size="80" value="[% sendingIllLibraryInfo | html %]" /></a>
          [% END %]
          <input type="hidden" id="sendingIllLibraryBorrowernumber" name="sendingIllLibraryBorrowernumber" value="[% whole.value.other.sendingIllLibraryBorrowernumber %]" />
          <input type="hidden" id="sendingIllLibraryIsil" name="sendingIllLibraryIsil" value="[% whole.value.other.sendingIllLibraryIsil %]" />
          <input type="hidden" id="sendingIllLibrarySurname" name="sendingIllLibrarySurname" value="[% whole.value.other.sendingIllLibrarySurname %]" />
          <input type="hidden" id="sendingIllLibraryCity" name="sendingIllLibraryCity" value="[% whole.value.other.sendingIllLibraryCity %]" />
          [% SET illcategs = '' %]
          [% FOREACH category IN whole.value.other.kohaIllPatronCategories %]
            [% SET illcategs = illcategs _ category.categorycode _ ',' %]
          [% END %]
           <input id="illlibrarysearch" type="button" [% IF whole.value.other.sendingIllLibraryBorrowernumber %]value="Ändern"[% ELSE %]value="Suchen"[% END %] onclick="DoPopIllLibrarySearch('illLibrary_search.pl?illcategories=[% illcategs %]&searchmember=[% selSigel %]');" />
        </li>

        <li>
          <label for="billedillrequestcosts">Kosten:</label>
          <input type="text" size="10" name="billedillrequestcosts" id="billedillrequestcosts" value="[% whole.value.other.billedillrequestcosts | $Price %]"  oninput="floatInput(document.SLNP_delivery.billedillrequestcosts,2)"  onchange="moneyFormat(document.SLNP_delivery.billedillrequestcosts)" />
        </li>

        <li>
          <label class="required" for="duedate">Rückgabedatum:</label>
          <input type="text" class="flatpickr" data-flatpickr-futuredate="true" name="duedate" id="duedate" size="10" maxlength="10" value="[% whole.value.other.duedate %]" required="required" />
         <span class="hint">[% INCLUDE 'date-format.inc' %]</span>
        </li>

      </ol>
    </fieldset>

    <fieldset class="rows">
      <legend>Benachrichtigung / Laufzettel</legend>
      <ol>
        <li>
          <label for="borrowerinfo">Besteller:</label>
          [% SET borrowerInfo = whole.value.other.borrowerFirstname _ ' ' _ whole.value.other.borrowerSurname _ ' (' _ whole.value.other.borrowerCardnumber _ ')'  %]
          <a target="blank" href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% whole.value.other.borrowerBorrowernumber %]"><input disabled type="text" name="borrowerinfo" id="borrowerinfo" size="80" value="[% borrowerInfo %]" /></a>
          <input type="hidden" id="borrowerBorrowernumber" name="borrowerBorrowernumber" value="[% whole.value.other.borrowerBorrowernumber %]" />
          <input type="hidden" id="borrowerFirstname" name="borrowerFirstname" value="[% whole.value.other.borrowerFirstname %]" />
          <input type="hidden" id="borrowerSurname" name="borrowerSurname" value="[% whole.value.other.borrowerSurname %]" />
          <input type="hidden" id="borrowerCardnumber" name="borrowerCardnumber" value="[% whole.value.other.borrowerCardnumber %]" />
        </li>

        <li>
          <label [% IF ( whole.stage == "deliveryInsert" ) %]class="required"[% END %] for="illdeliverylettercode">Benachrichtigung:</label>
          <select id="illdeliverylettercode" name="illdeliverylettercode" [% IF ( whole.stage == "deliveryInsert" ) %]required="required"[% END %] [% IF ( whole.stage == "deliveryUpdate" ) %]onchange="actualizePrintButton(document.SLNP_delivery.printButton)"[% END %] >
          [% IF ( whole.stage != "deliveryInsert" ) %]
            <option value="" />
          [% END %]
          [% FOREACH letter IN whole.value.other.kohaIllPatronLetters %]
            [% IF ( ( whole.stage == "deliveryInsert" || whole.error) && whole.value.other.illdeliverylettercode == letter.code ) %]
              <option value="[% letter.code %]" selected="selected">[% letter.name %]</option>
            [% ELSE %]
              <option value="[% letter.code %]">[% letter.name %]</option>
            [% END %]
          [% END %]
          </select>
        </li>

        <li>
          <label for="illdeliveryslipprint">Laufzettel drucken:</label>
          [% IF ( whole.stage == "deliveryUpdate" && ! whole.error ) %]
            <input type="checkbox" name="illdeliveryslipprint" id="illdeliveryslipprint" value="1" [% IF ( whole.stage == "deliveryUpdate" ) %]oninput="actualizePrintButton(document.SLNP_delivery.printButton)"[% END %] />
          [% ELSE %]
            [% IF whole.value.other.illdeliveryslipprint %]
              <input type="checkbox" name="illdeliveryslipprint" id="illdeliveryslipprint" value="1" checked="checked" [% IF ( whole.stage == "deliveryUpdate" ) %]oninput="actualizePrintButton(document.SLNP_delivery.printButton)"[% END %] />
            [% ELSE %]
              <input type="checkbox" name="illdeliveryslipprint" id="illdeliveryslipprint" value="1" [% IF ( whole.stage == "deliveryUpdate" ) %]oninput="actualizePrintButton(document.SLNP_delivery.printButton)"[% END %] />
            [% END %]
          [% END %]
        </li>

      </ol>
    </fieldset>

    <fieldset class="action">
      <input type="hidden" name="illrequest_id" id="illrequest_id" value="[% whole.illrequest_id %]" />
      <input type="hidden" name="backend" id="backend" value="[% request.backend %]" />
      <input type="hidden" name="method" id="method" value="[% whole.method %]" />
      <input type="hidden" name="stage" id="stage" value="[% whole.stage %]" />
      <input type="hidden" name="itemnumber" id="itemnumber" value="[% whole.value.other.itemnumber %]" />

      [% IF ( whole.stage == "deliveryInsert" ) %]
        <input type="submit" id="submitbutton" name="submitbutton" value="Speichern" onclick="stage.value='InsertAndPrint';" />
      [% ELSE %]    <!-- whole.stage == "deliveryUpdate" -->
        <input type="submit" id="submitbutton" name="submitbutton" value="Änderungen speichern" onclick="stage.value='UpdateAndMaybePrint';" />
        <input type="submit" id="printButton"  name="printButton"  value="Drucken" disabled onclick="stage.value='PrintOnly';" />
      [% END %]

      <a class="cancel" id="cancelbutton" name="cancelbutton" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>
    </fieldset>
  </form>

[% ELSIF whole.stage == "InsertAndPrint" || whole.stage == "UpdateAndMaybePrint" || whole.stage == "PrintOnly" %]

  <p>Rückkehr zur Fernleihbestellung</p>

  <form id="SLNP_delivery" name="SLNP_delivery" method="POST" action=[% here %]>
    <input style="display:none" type="checkbox" name="illdeliveryslipprint" id="illdeliveryslipprint" value="1" [% IF ( whole.value.other.illdeliveryslipprint ) %]checked="checked"[% END %] />
    <a style="display:none" class="cancel" id="cancelbutton" name="cancelbutton" href="/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=[% request.illrequest_id %]">Abbrechen</a>
  </form>

[% ELSE %]
  <p>Unbekannte Stufe '[% whole.stage %]'. Das sollte sich nicht ereignen.</p>
[% END %]



[% BLOCK backend_jsinclude %]
    <style id="antiClickjack">body{display:none !important;}</style>
    [% INCLUDE 'js_includes.inc' %]

    <script type= "text/javascript">
        $(document).ready(function() {
            [% IF whole.stage == "InsertAndPrint" || whole.stage == "UpdateAndMaybePrint" || whole.stage == "PrintOnly" %]
                var slipchecked = $("#illdeliveryslipprint").prop('checked');
                if ( slipchecked ) {
                    var ret = printIllProcessingSlip();
                } else {
                    document.getElementById("cancelbutton").click();
                }
            [% ELSIF whole.stage == "deliveryUpdate" %]
                actualizePrintButton(document.SLNP_delivery.printButton);
            [% END %]

            $("#printButton").on('click', function(e){
                e.preventDefault();
                var ret = false;
                var deliverylettercode = $("#illdeliverylettercode").val();
                var slipchecked = $("#illdeliveryslipprint").prop('checked');
                if ( !(deliverylettercode || slipchecked) ) {
                    alert( _("You have not selected any letter or slip!") );
                    return false;
                }
                if ( slipchecked > 0 || deliverylettercode ) {
                    $('#SLNP_delivery').submit();
                }
                return ret;
            });

        });    // $(document).ready(function() END

        function actualizePrintButton (buttonObj) {
            if ( $("#illdeliverylettercode").val() || $("#illdeliveryslipprint").prop('checked') )
                buttonObj.disabled = false;
            else
                buttonObj.disabled = true;
        }

        function printIllProcessingSlip () {
            var slipcount = 0;
            if ( $("#illdeliveryslipprint").prop('checked') ) {
              slipcount = 2;
            }
            var borrowernumbers = [];
            borrowernumbers.push("[% whole.value.other.sendingIllLibraryBorrowernumber %]");
            borrowernumbers.push("[% whole.value.request.borrowernumber %]");
            var data = {
                use_letter: "[% whole.value.other.illdeliveryslipcode %]",
                use_email: '',
                slipcount: slipcount,
                illrequestid: "[% whole.illrequest_id %]",
                biblionumber: "[% whole.value.request.biblio_id %]",
                itemnumber: "[% whole.value.other.itemnumber %]",
                duedate: "[% whole.value.other.duedate %]",
                borrowernumbers: borrowernumbers
            };

            $.ajax({
                data: data,
                type: 'POST',
                url: '/cgi-bin/koha/svc/ill/genIllDeliverySlip',
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


        function floatInput(floatAsText,decimalplaces) {
            // Not accepting more than 1 decimal separator ("." or ",") and 2 ciphers after the integer part of the input in money amount field.
            var len = floatAsText.value.length;
            var decSepPos = floatAsText.value.indexOf(".");
            var decSepPos2 = floatAsText.value.indexOf(",");
            if ( decSepPos2 >= 0 && (decSepPos2 < decSepPos || decSepPos < 0) ) {  
                decSepPos = decSepPos2;
            }
            if ( decSepPos >= 0 && len > decSepPos + 1 + decimalplaces ) {
                floatAsText.value = floatAsText.value.substr(0, decSepPos + 1 + decimalplaces);
            }
        }

        function moneyNormalize(textObj) {
            var amountNew = parseFloat(textObj.value.replace(",","."));
            if ( isNaN(amountNew) ) {
                amountNew = 0.0;
            }
            textObj.value = parseFloat(amountNew);
        }

        function moneyFormat(textObj) {
            var newValue = textObj.value.replace(",",".");
            var decAmount = "";
            var dolAmount = "";
            var decFlag   = false;
            var aChar     = "";

            for(i=0; i < newValue.length; i++) {
                aChar = newValue.substring(i, i+1);
                if (aChar >= "0" && aChar <= "9") {
                    if(decFlag) {
                        decAmount = "" + decAmount + aChar;
                    }
                    else {
                        dolAmount = "" + dolAmount + aChar;
                    }
                }
                if (aChar == ".") {
                    if (decFlag) {
                        break;
                    }
                    decFlag = true;
                }
            }

            if (dolAmount == "") {
                dolAmount = "0";
            }
            // Strip leading 0s
            if (dolAmount.length > 1) {
                while(dolAmount.length > 1 && dolAmount.substring(0,1) == "0") {
                    dolAmount = dolAmount.substring(1,dolAmount.length);
                }
            }
            if (decAmount.length > 2) {
                decAmount = decAmount.substring(0,2);
            }
            // Pad right side
            if (decAmount.length == 1) {
                decAmount = decAmount + "0";
            }
            if (decAmount.length == 0) {
            decAmount = decAmount + "00";
            }

            textObj.value = parseFloat(parseFloat(dolAmount + "." + decAmount).toFixed(2)).format_price();
        }


        function DoPopIllLibrarySearch(link) {
            var newWin = window.open(link,'popup','width=800,height=500,resizable=no,toolbar=false,scrollbars=yes,top');
        }


        function select_user(borrowernumber, borrowersData) {
            var form = $('#SLNP_delivery').get(0);
            var borrowersDataBorrowernumber = borrowersData.patron_id;
            var borrowersDataSurname = borrowersData.surname ? borrowersData.surname : '';
            var borrowersDataCity = borrowersData.city ? borrowersData.city : '';
            let isil = "";
            let extended_attributes = borrowersData.extended_attributes;
            if ( extended_attributes ) {
                for ( let i = 0, len = extended_attributes.length; i < len; i += 1 ) {
                    if ( extended_attributes[i].type.toUpperCase() === 'SIGEL' ) {
                        isil = extended_attributes[i].value;
                        break;
                    }
                }
            }

            var sendingIllLibraryInfo = 'Sigel: ' + isil + ' / ' + borrowersDataSurname + ' / Ort: ' + borrowersDataCity;
            $('#sendingIllLibrary')
                .show()
                .find('a')
                .attr("href","/cgi-bin/koha/members/moremember.pl?borrowernumber=" + borrowersDataBorrowernumber);

            var illlibrarysearch = $('#illlibrarysearch');
            illlibrarysearch.attr("onclick","DoPopIllLibrarySearch('illLibrary_search.pl?illcategories=[% illcategs %]&searchmember=" + isil + "');");
            form.illlibrarysearch.value = 'Ändern';

            form.sendingIllLibraryBorrowernumber.value = borrowersDataBorrowernumber;
            form.sendingIllLibraryIsil.value = isil;
            form.sendingIllLibrarySurname.value = borrowersDataSurname;
            form.sendingIllLibraryCity.value = borrowersDataCity;
            form.sendingIllLibraryInfo.value = sendingIllLibraryInfo;

            return 0;
        }

    </script>
[% END %]
