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
', 'print', 'default'), 

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
', 'print', 'default'), 

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
', 'print', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_CHARGE_1', '', 'PFL-Eingangsbenachrichtigung', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

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

('circulation', 'ILLSLNP_DELIVERY_NOTICE_CHARGE_1', '', 'PFL-Eingangsbenachrichtigung ', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

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
', 'print', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_CHARGE_2', '', 'PFL-Eingangsbenachrichtigung', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

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

('circulation', 'ILLSLNP_DELIVERY_NOTICE_CHARGE_2', '', 'PFL-Eingangsbenachrichtigung ', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

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
', 'print', 'default'), 

('circulation', 'ILLSLNP_DELIVERY_NOTICE_NO_CHARGE', '', 'PFL-Eingangsbenachrichtigung', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

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

('circulation', 'ILLSLNP_DELIVERY_NOTICE_NO_CHARGE', '', 'PFL-Eingangsbenachrichtigung ', 0, 'Fernleihbenachrichtigung', 'Sehr geehrte/r <<borrowers.title>> <<borrowers.surname>>,

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
', 'print', 'default'), 

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
', 'print', 'default'), 

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
