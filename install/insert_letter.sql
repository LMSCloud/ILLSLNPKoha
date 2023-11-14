INSERT IGNORE INTO letter ( module, code, branchcode, name, is_html, title, content , message_transport_type, lang ) 
VALUES 
('circulation', 'ILLSLNP_DELIVERY_SLIP', '', 'PFL-Laufzettel', 1, 'PFL-Laufzettel', '<div style="max-width:200mm">
<br />
<<branches.branchaddress1>>
<<today>><br />
</div>


<h2>Laufzettel für Fernleihe (PFL: <<illrequests.illrequest_id>>)</h2>
<br />

<h3>Besteller</h3>
Ausweisnummer: <<borrowers.cardnumber>><br />
<h2>Name: <<borrowers.firstname>> <<borrowers.surname>><br /></h2>
<br />
Buchungsnummer: <img src="/cgi-bin/koha/svc/barcode?barcode=*<<items.barcode>>*&type=Code39" /><br />
<br />
<h3>Exemplar</h3>

Titel: <<biblio.title>><br />
Verfasser: <<biblio.author>><br />
Rückgabedatum: <<illreqattr_duedate>><br />
Leihbibliothek: <<account.city>>,  <<account.surname>><br />
</br>
</br>
<h2>Dieser Laufzettel sollte bis zur Rückgabe im Buch verbleiben!</h2>
', 'print', 'default'), 

('circulation', 'ILLSLNP_ITEMLOST_BORROWER', '', 'Fernleihe-Verlustmeldung an Besteller', 0, 'Fernleihe-Verlustmeldung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

Ihre Fernleihebestellung  kann wegen Verlust des Medium leider nicht durchgeführt werden.

Bestell-ID: <<illrequests.orderid>>
Bestell-Datum: <<illrequests.placed>>

Autor: <<illrequestattributes.author>>
Titel: <<illrequestattributes.title>>
Artikel-Autor: <<illrequestattributes.article_author>>
Artikel-Titel: <<illrequestattributes.article_title>>
Bemerkung: <<illrequestattributes.notes>>

Standort: <<branches.branchname>>
<<branches.branchaddress1>>
<<branches.branchaddress2>>
<<branches.branchaddress3>>
<<branches.branchzip>> <<branches.branchcity>>

Mit freundlichen Grüßen,
Ihre <<branches.branchaddress1>>
', 'email', 'default'), 

('circulation', 'ILLSLNP_ITEMLOST_BORROWER', '', 'Fernleihe-Verlustmeldung an Besteller', 1, 'Fernleihe-Verlustmeldung', '<div class="message">
<div class="library_address">
<span class="institution1"><<branches.branchaddress1>><br /></span>
<span class="streetaddress"><<branches.branchaddress2>><br /><<branches.branchzip>> <<branches.branchcity>><br />Tel: <<branches.branchphone>><br />E-Mail: <<branches.branchemail>></span>
</div>
<div class="return_address"><<branches.branchname>> · <<branches.branchaddress2>> · <<branches.branchzip>> <<branches.branchcity>></div>
<div class="address"><<borrowers.title>><br /><<borrowers.firstname>> <<borrowers.surname>><br /><<borrowers.address>> <<borrowers.streetnumber>> <<borrowers.address2>><br /><<borrowers.zipcode>> <<borrowers.city>></div>
<div class="topic">Betreff</div><div class="topictext"><b>Fernleihbestellung</b></div>
<div class="cardnumber">Ausweis-Nummer</div><div class="cardnumbertext"><b><<borrowers.cardnumber>></b></div>
<div class="manager"></div><div class="managertext"></div>
<div class="date">Datum</div><div class="datetext"><b><<today>></b></div>

<div class="salutation">Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,</div>

<div class="content">Ihre Fernleihebestellung kann wegen Verlust des Medium leider nicht durchgeführt werden.<br />
<br />
Bestell-ID: <<illrequests.orderid>><br />
Bestell-Datum: <<illrequests.placed>><br />
<br />
Autor: <<illrequestattributes.author>><br />
Titel: <<illrequestattributes.title>><br />
Artikel-Autor: <<illrequestattributes.article_author>><br />
Artikel-Titel: <<illrequestattributes.article_title>><br />
Bemerkung: <<illrequestattributes.notes>><br />
<br />
Standort: <<branches.branchname>><br />
<<branches.branchaddress1>><br />
<<branches.branchaddress2>><br />
<<branches.branchaddress3>><br />
<<branches.branchzip>> <<branches.branchcity>><br />
<br />
Mit freundlichen Grüßen<br />
<br />
<<branches.branchname>>
</div>

<div class="footer">
<pre class="footertext">
<<branches.opac_info>>
</pre></div>
</div>', 'print', 'default'), 

('circulation', 'ILLSLNP_ITEMLOST_LIBRARY', '', 'Fernleihe-Verlustmeldung an besitzende Bibilothek', 0, 'Fernleihe-Verlustmeldung', 'An <<borrowers.surname>>

Sehr geehrte Damen und Herren,

folgendes Medium einer an uns gelieferten Fernleihebestellung  ist leider abhanden gekommen:

Bestell-ID: <<illrequests.orderid>>
Bestell-Datum: <<illrequests.placed>>
Besteller: <<account.surname>>, <<account.firstname>>

Autor: <<illrequestattributes.author>>
Titel: <<illrequestattributes.title>>
Artikel-Autor: <<illrequestattributes.article_author>>
Artikel-Titel: <<illrequestattributes.article_title>>
Bemerkung: <<illrequestattributes.notes>>

Standort: <<branches.branchname>>
<<branches.branchaddress1>>
<<branches.branchaddress2>>
<<branches.branchaddress3>>
<<branches.branchzip>> <<branches.branchcity>>

Mit freundlichen Grüßen,
Ihre <<branches.branchaddress1>>
', 'email', 'default'), 

('circulation', 'ILLSLNP_ITEMLOST_LIBRARY', '', 'Fernleihe-Verlustmeldung an besitzende Bibilothek', 1, 'Fernleihe-Verlustmeldung', '<div class="message">
<div class="library_address">
<span class="institution1"><<branches.branchaddress1>><br /></span>
<span class="streetaddress"><<branches.branchaddress2>><br /><<branches.branchzip>> <<branches.branchcity>><br />Tel: <<branches.branchphone>><br />E-Mail: <<branches.branchemail>></span>
</div>
<div class="return_address"><<branches.branchname>> · <<branches.branchaddress2>> · <<branches.branchzip>> <<branches.branchcity>></div>
<div class="address"><<borrowers.title>><br /><<borrowers.firstname>> <<borrowers.surname>><br /><<borrowers.address>> <<borrowers.streetnumber>> <<borrowers.address2>><br /><<borrowers.zipcode>> <<borrowers.city>></div>
<div class="topic">Betreff</div><div class="topictext"><b>Fernleihbestellung</b></div>
<div class="cardnumber">Ausweis-Nummer</div><div class="cardnumbertext"><b><<borrowers.cardnumber>></b></div>
<div class="manager"></div><div class="managertext"></div>
<div class="date">Datum</div><div class="datetext"><b><<today>></b></div>

<div class="salutation">Sehr geehrte Damen und Herren,</div>

<div class="content">folgendes Medium einer an uns gelieferten Fernleihebestellung  ist leider abhanden gekommen:<br />
<br />
Bestell-ID: <<illrequests.orderid>><br />
Bestell-Datum: <<illrequests.placed>><br />
Besteller: <<account.surname>>, <<account.firstname>><br />
<br />
Autor: <<illrequestattributes.author>><br />
Titel: <<illrequestattributes.title>><br />
Artikel-Autor: <<illrequestattributes.article_author>><br />
Artikel-Titel: <<illrequestattributes.article_title>><br />
Bemerkung: <<illrequestattributes.notes>><br />
<br />
Standort: <<branches.branchname>><br />
<<branches.branchaddress1>><br />
<<branches.branchaddress2>><br />
<<branches.branchaddress3>><br />
<<branches.branchzip>> <<branches.branchcity>><br />
<br />
Mit freundlichen Grüßen<br />
<br />
<<branches.branchname>>
</div>

<div class="footer">
<pre class="footertext">
<<branches.opac_info>>
</pre></div>
</div>', 'print', 'default'), 

('circulation', 'ILLSLNP_NOT_DELIVERED', '', 'Absage Fernleihebestellung', 0, 'Absage Fernleihebestellung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

Ihre Fernleihebestellung  konnte leider deutschlandweit aus anderen Bibliotheken nicht erfüllt werden.
Der Auftrag wird daher gelöscht.

Bestell-ID: <<illrequests.orderid>>
Bestelldatum: <<illrequests.placed>>

Autor: <<illrequestattributes.author>>
Titel: <<illrequestattributes.title>>
Artikel-Autor: <<illrequestattributes.article_author>>
Artikel-Titel: <<illrequestattributes.article_title>>
Bemerkung: <<illrequestattributes.notes>>

Standort: <<branches.branchname>>
<<branches.branchaddress1>>
<<branches.branchaddress2>>
<<branches.branchaddress3>>
<<branches.branchzip>> <<branches.branchcity>>

Mit freundlichen Grüßen, 
Ihre <<branches.branchaddress1>>
', 'email', 'default'), 

('circulation', 'ILLSLNP_NOT_DELIVERED', '', 'Absage Fernleihebestellung', 1, 'Absage Fernleihebestellung', '<div class="message">
<div class="library_address">
<span class="institution1"><<branches.branchaddress1>><br /></span>
<span class="streetaddress"><<branches.branchaddress2>><br /><<branches.branchzip>> <<branches.branchcity>><br />Tel: <<branches.branchphone>><br />E-Mail: <<branches.branchemail>></span>
</div>
<div class="return_address"><<branches.branchname>> · <<branches.branchaddress2>> · <<branches.branchzip>> <<branches.branchcity>></div>
<div class="address"><<borrowers.title>><br /><<borrowers.firstname>> <<borrowers.surname>><br /><<borrowers.address>> <<borrowers.streetnumber>> <<borrowers.address2>><br /><<borrowers.zipcode>> <<borrowers.city>></div>
<div class="topic">Betreff</div><div class="topictext"><b>Fernleihbestellung</b></div>
<div class="cardnumber">Ausweis-Nummer</div><div class="cardnumbertext"><b><<borrowers.cardnumber>></b></div>
<div class="manager"></div><div class="managertext"></div>
<div class="date">Datum</div><div class="datetext"><b><<today>></b></div>

<div class="salutation">Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,</div>

<div class="content">Ihre Fernleihebestellung  konnte leider deutschlandweit aus anderen Bibliotheken nicht erfüllt werden.<br />
Der Auftrag wird daher gelöscht.<br />
<br />
Bestell-ID: <<illrequests.orderid>><br />
Bestelldatum: <<illrequests.placed>><br />

Autor: <<illrequestattributes.author>><br />
Titel: <<illrequestattributes.title>><br />
Artikel-Autor: <<illrequestattributes.article_author>><br />
Artikel-Titel: <<illrequestattributes.article_title>><br />
Bemerkung: <<illrequestattributes.notes>><br />
<br />
Standort: <<branches.branchname>><br />
<<branches.branchaddress1>><br />
<<branches.branchaddress2>><br />
<<branches.branchaddress3>><br />
<<branches.branchzip>> <<branches.branchcity>><br />
<br />
Mit freundlichen Grüßen<br />
<br />
<<branches.branchname>>
</div>

<div class="footer">
<pre class="footertext">
<<branches.opac_info>>
</pre></div>
</div>', 'print', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_1_CHARGE', '', 'PFL-Eingangsbenachrichtigung 1', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

Für Sie liegt eine Fernleihbestellung zur Abholung bereit:

Bestell-ID: <<illrequests.orderid>>
Bestelldatum: <<illrequests.placed>>

Titel: <<biblio.title>>
Verfasser: <<biblio.author>>
Exemplar: <<items.barcode>>

Autor: <<illrequestattributes.author>>
Titel: <<illrequestattributes.title>>
Artikel-Autor: <<illrequestattributes.article_author>>
Artikel-Titel: <<illrequestattributes.article_title>>
Bemerkung: <<illrequestattributes.notes>>

Leihbibliothek:
Ort: <<account.city>>
Name: <<account.surname>>
Sigel: <<illrequestattributes.sendingIllLibraryIsil>>

Standort: <<branches.branchname>>
<<branches.branchaddress1>>
<<branches.branchaddress2>>
<<branches.branchaddress3>>
<<branches.branchzip>> <<branches.branchcity>>

Mit freundlichen Grüßen, 
Ihre <<branches.branchaddress1>>
', 'email', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_1_CHARGE', '', 'PFL-Eingangsbenachrichtigung 1', 1, 'Fernleihbenachrichtigung', '<div class="message">
<div class="library_address">
<span class="institution1"><<branches.branchaddress1>><br /></span>
<span class="streetaddress"><<branches.branchaddress2>><br /><<branches.branchzip>> <<branches.branchcity>><br />Tel: <<branches.branchphone>><br />E-Mail: <<branches.branchemail>></span>
</div>
<div class="return_address"><<branches.branchname>> · <<branches.branchaddress2>> · <<branches.branchzip>> <<branches.branchcity>></div>
<div class="address"><<borrowers.title>><br /><<borrowers.firstname>> <<borrowers.surname>><br /><<borrowers.address>> <<borrowers.streetnumber>> <<borrowers.address2>><br /><<borrowers.zipcode>> <<borrowers.city>></div>
<div class="topic">Betreff</div><div class="topictext"><b>Fernleihbestellung</b></div>
<div class="cardnumber">Ausweis-Nummer</div><div class="cardnumbertext"><b><<borrowers.cardnumber>></b></div>
<div class="manager"></div><div class="managertext"></div>
<div class="date">Datum</div><div class="datetext"><b><<today>></b></div>

<div class="salutation">Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,</div>

<div class="content">für Sie liegt ein mittels Fernleihe bestelles Medium zur Abholung bereit:<br />
<br />
Bestell-ID: <<illrequests.orderid>><br />
Bestelldatum: <<illrequests.placed>><br />
<br />
Titel: <<biblio.title>><br />
Verfasser: <<biblio.author>><br />
Exemplar: <<items.barcode>><br />
<br />
Autor: <<illrequestattributes.author>><br />
Titel: <<illrequestattributes.title>><br />
Artikel-Autor: <<illrequestattributes.article_author>><br />
Artikel-Titel: <<illrequestattributes.article_title>><br />
Bemerkung: <<illrequestattributes.notes>><br />
<br />
Leihbibliothek:<br />
Ort: <<account.city>><br />
Name: <<account.surname>><br />
Sigel: <<illrequestattributes.sendingIllLibraryIsil>><br />
<br />
Standort: <<branches.branchname>><br />
<<branches.branchaddress1>><br />
<<branches.branchaddress2>><br />
<<branches.branchaddress3>><br />
<<branches.branchzip>> <<branches.branchcity>><br />
<br />
Mit freundlichen Grüßen<br />
<br />
<<branches.branchname>>
</div>

<div class="footer">
<pre class="footertext">
<<branches.opac_info>>
</pre></div>
</div>', 'print', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_2_CHARGE', '', 'PFL-Eingangsbenachrichtigung 2', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

Für Sie liegt eine Fernleihbestellung zur Abholung bereit:

Bestell-ID: <<illrequests.orderid>>
Bestelldatum: <<illrequests.placed>>

Titel: <<biblio.title>>
Verfasser: <<biblio.author>>
Exemplar: <<items.barcode>>

Autor: <<illrequestattributes.author>>
Titel: <<illrequestattributes.title>>
Artikel-Autor: <<illrequestattributes.article_author>>
Artikel-Titel: <<illrequestattributes.article_title>>
Bemerkung: <<illrequestattributes.notes>>

Leihbibliothek:
Ort: <<account.city>>
Name: <<account.surname>>
Sigel: <<illrequestattributes.sendingIllLibraryIsil>>

Standort: <<branches.branchname>>
<<branches.branchaddress1>>
<<branches.branchaddress2>>
<<branches.branchaddress3>>
<<branches.branchzip>> <<branches.branchcity>>

Mit freundlichen Grüßen, 
Ihre <<branches.branchaddress1>>
', 'email', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_2_CHARGE', '', 'PFL-Eingangsbenachrichtigung 2', 1, 'Fernleihbenachrichtigung', '<div class="message">
<div class="library_address">
<span class="institution1"><<branches.branchaddress1>><br /></span>
<span class="streetaddress"><<branches.branchaddress2>><br /><<branches.branchzip>> <<branches.branchcity>><br />Tel: <<branches.branchphone>><br />E-Mail: <<branches.branchemail>></span>
</div>
<div class="return_address"><<branches.branchname>> · <<branches.branchaddress2>> · <<branches.branchzip>> <<branches.branchcity>></div>
<div class="address"><<borrowers.title>><br /><<borrowers.firstname>> <<borrowers.surname>><br /><<borrowers.address>> <<borrowers.streetnumber>> <<borrowers.address2>><br /><<borrowers.zipcode>> <<borrowers.city>></div>
<div class="topic">Betreff</div><div class="topictext"><b>Fernleihbestellung</b></div>
<div class="cardnumber">Ausweis-Nummer</div><div class="cardnumbertext"><b><<borrowers.cardnumber>></b></div>
<div class="manager"></div><div class="managertext"></div>
<div class="date">Datum</div><div class="datetext"><b><<today>></b></div>

<div class="salutation">Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,</div>

<div class="content">für Sie liegt ein mittels Fernleihe bestelles Medium zur Abholung bereit:<br />
<br />
Bestell-ID: <<illrequests.orderid>><br />
Bestelldatum: <<illrequests.placed>><br />
<br />
Titel: <<biblio.title>><br />
Verfasser: <<biblio.author>><br />
Exemplar: <<items.barcode>><br />
<br />
Autor: <<illrequestattributes.author>><br />
Titel: <<illrequestattributes.title>><br />
Artikel-Autor: <<illrequestattributes.article_author>><br />
Artikel-Titel: <<illrequestattributes.article_title>><br />
Bemerkung: <<illrequestattributes.notes>><br />
<br />
Leihbibliothek:<br />
Ort: <<account.city>><br />
Name: <<account.surname>><br />
Sigel: <<illrequestattributes.sendingIllLibraryIsil>><br />
<br />
Standort: <<branches.branchname>><br />
<<branches.branchaddress1>><br />
<<branches.branchaddress2>><br />
<<branches.branchaddress3>><br />
<<branches.branchzip>> <<branches.branchcity>><br />
<br />
Mit freundlichen Grüßen<br />
<br />
<<branches.branchname>>
</div>

<div class="footer">
<pre class="footertext">
<<branches.opac_info>>
</pre></div>
</div>', 'print', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_CHARGE_NOT', '', 'PFL-Eingangsbenachrichtigung gebührenfrei', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

Für Sie liegt eine Fernleihbestellung zur Abholung bereit:

Bestell-ID: <<illrequests.orderid>>
Bestelldatum: <<illrequests.placed>>

Titel: <<biblio.title>>
Verfasser: <<biblio.author>>
Exemplar: <<items.barcode>>

Autor: <<illrequestattributes.author>>
Titel: <<illrequestattributes.title>>
Artikel-Autor: <<illrequestattributes.article_author>>
Artikel-Titel: <<illrequestattributes.article_title>>
Bemerkung: <<illrequestattributes.notes>>

Leihbibliothek:
Ort: <<account.city>>
Name: <<account.surname>>
Sigel: <<illrequestattributes.sendingIllLibraryIsil>>

Standort: <<branches.branchname>>
<<branches.branchaddress1>>
<<branches.branchaddress2>>
<<branches.branchaddress3>>
<<branches.branchzip>> <<branches.branchcity>>

Mit freundlichen Grüßen, 
Ihre <<branches.branchaddress1>>
', 'email', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_CHARGE_NOT', '', 'PFL-Eingangsbenachrichtigung gebührenfrei', 1, 'Fernleihbenachrichtigung', '<div class="message">
<div class="library_address">
<span class="institution1"><<branches.branchaddress1>><br /></span>
<span class="streetaddress"><<branches.branchaddress2>><br /><<branches.branchzip>> <<branches.branchcity>><br />Tel: <<branches.branchphone>><br />E-Mail: <<branches.branchemail>></span>
</div>
<div class="return_address"><<branches.branchname>> · <<branches.branchaddress2>> · <<branches.branchzip>> <<branches.branchcity>></div>
<div class="address"><<borrowers.title>><br /><<borrowers.firstname>> <<borrowers.surname>><br /><<borrowers.address>> <<borrowers.streetnumber>> <<borrowers.address2>><br /><<borrowers.zipcode>> <<borrowers.city>></div>
<div class="topic">Betreff</div><div class="topictext"><b>Fernleihbestellung</b></div>
<div class="cardnumber">Ausweis-Nummer</div><div class="cardnumbertext"><b><<borrowers.cardnumber>></b></div>
<div class="manager"></div><div class="managertext"></div>
<div class="date">Datum</div><div class="datetext"><b><<today>></b></div>

<div class="salutation">Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,</div>

<div class="content">für Sie liegt ein mittels Fernleihe bestelles Medium zur Abholung bereit:<br />
<br />
Bestell-ID: <<illrequests.orderid>><br />
Bestelldatum: <<illrequests.placed>><br />
<br />
Titel: <<biblio.title>><br />
Verfasser: <<biblio.author>><br />
Exemplar: <<items.barcode>><br />
<br />
Autor: <<illrequestattributes.author>><br />
Titel: <<illrequestattributes.title>><br />
Artikel-Autor: <<illrequestattributes.article_author>><br />
Artikel-Titel: <<illrequestattributes.article_title>><br />
Bemerkung: <<illrequestattributes.notes>><br />
<br />
Leihbibliothek:<br />
Ort: <<account.city>><br />
Name: <<account.surname>><br />
Sigel: <<illrequestattributes.sendingIllLibraryIsil>><br />
<br />
Standort: <<branches.branchname>><br />
<<branches.branchaddress1>><br />
<<branches.branchaddress2>><br />
<<branches.branchaddress3>><br />
<<branches.branchzip>> <<branches.branchcity>><br />
<br />
Mit freundlichen Grüßen<br />
<br />
<<branches.branchname>>
</div>

<div class="footer">
<pre class="footertext">
<<branches.opac_info>>
</pre></div>
</div>', 'print', 'default'), 

('circulation', 'ILLSLNP_REQUEST_CONFIRM', '', 'Bestätigung Fernleihebestellung', 0, 'Bestätigung Fernleihebestellung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

Ihre Fernleihebestellung  wurde von einer besitzenden Bibliothek akzeptiert.
Der Zeitpunkt des Liefereingangs hier in unserer Bibliothek steht im Moment noch nicht fest. Hierüber werden wir Sie separat informieren.

Bestell-ID: <<illrequests.orderid>>
Bestelldatum: <<illrequests.placed>>

Autor: <<illrequestattributes.author>>
Titel: <<illrequestattributes.title>>
Artikel-Autor: <<illrequestattributes.article_author>>
Artikel-Titel: <<illrequestattributes.article_title>>
Bemerkung: <<illrequestattributes.notes>>

Mit freundlichen Grüßen,
Ihre <<branches.branchaddress1>>
', 'email', 'default'), 


('circulation', 'ILLSLNP_REQUEST_CONFIRM', '', 'Bestätigung Fernleihebestellung', 1, 'Bestätigung Fernleihebestellung', '<div class="message">
<div class="library_address">
<span class="institution1"><<branches.branchaddress1>><br /></span>
<span class="streetaddress"><<branches.branchaddress2>><br /><<branches.branchzip>> <<branches.branchcity>><br />Tel: <<branches.branchphone>><br />E-Mail: <<branches.branchemail>></span>
</div>
<div class="return_address"><<branches.branchname>> · <<branches.branchaddress2>> · <<branches.branchzip>> <<branches.branchcity>></div>
<div class="address"><<borrowers.title>><br /><<borrowers.firstname>> <<borrowers.surname>><br /><<borrowers.address>> <<borrowers.streetnumber>> <<borrowers.address2>><br /><<borrowers.zipcode>> <<borrowers.city>></div>
<div class="topic">Betreff</div><div class="topictext"><b>Fernleihbestellung</b></div>
<div class="cardnumber">Ausweis-Nummer</div><div class="cardnumbertext"><b><<borrowers.cardnumber>></b></div>
<div class="manager"></div><div class="managertext"></div>
<div class="date">Datum</div><div class="datetext"><b><<today>></b></div>

<div class="salutation">Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,</div>

<div class="content">Ihre Fernleihebestellung  wurde von einer besitzenden Bibliothek akzeptiert.<br />
Der Zeitpunkt des Liefereingangs hier in unserer Bibliothek steht im Moment noch nicht fest. Hierüber werden wir Sie separat informieren.<br />
<br />
Bestell-ID: <<illrequests.orderid>><br />
Bestelldatum: <<illrequests.placed>><br />
<br />
Autor: <<illrequestattributes.author>><br />
Titel: <<illrequestattributes.title>><br />
Artikel-Autor: <<illrequestattributes.article_author>><br />
Artikel-Titel: <<illrequestattributes.article_title>><br />
Bemerkung: <<illrequestattributes.notes>><br />
<br />
Mit freundlichen Grüßen<br />
<br />
<<branches.branchname>>
</div>

<div class="footer">
<pre class="footertext">
<<branches.opac_info>>
</pre></div>
</div>', 'print', 'default'), 

('circulation', 'ILLSLNP_SHIPBACK_SLIP', '', 'PFL-Rückversandzettel', 1, 'PFL-Rückversandzettel', '<div style="max-width:200mm">
<br />
<<branches.branchname>> 
<<branches.branchaddress1>>
<<branches.branchzip>> <<branches.branchcity>> <<today>><br />
<br />
<br />
</div>

<h2>Rückversandzettel für Fernleihe (PFL: <<illrequests.illrequest_id>>)</h2>
<br />

<h3>Bestellung</h3>
Bestell-ID: <<illrequests.orderid>>
Bestelldatum: <<illrequests.placed>>
PFL-Nummer: <<illrequests.illrequest_id>>

<h3>Besteller</h3>
Ausweisnummer: <<borrowers.cardnumber>><br />
Name: <<borrowers.firstname>> <<borrowers.surname>><br />
Telefon: <<borrowers.phone>>

<h3>Exemplar</h3>
Titel: <<illrequestattributes.title>><br />
Verfasser: <<illrequestattributes.author>><br />
Rückgabedatum: <<illreqattr_duedate>><br />
Signatur: <<items.itemcallnumber>><br />
Leihbibliothek: <<account.city>>,  <<account.surname>><br />

', 'print', 'default');
