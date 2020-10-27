INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES 
('ILLDefaultBranch', 'HST', NULL, 'Branchcode of the branch that is used as default with ILL requests.', 'Free'), 
('ILLItemTypes', 'FERNLEIHE|FERNLEIHE-KOPIEN', NULL, 'item types used for ILL media', 'Free'), 
('ILLPatronCategories', 'FERNLEIHE_TYP_1|FERNLEIHE_TYP_2', NULL, 'list of categorycodes of ILL libraries', 'Free'), 
('ILLPortalURL', '<p>Neue Fernleihbestellung im Portal <a href="https://fernleihe.boss.bsz-bw.de/Bsz/saveIsil/DE-833" target="_blank" >https://fernleihe.boss.bsz-bw.de/Bsz/saveIsil/DE-833</a> anlegen.</p>', NULL, 'HTML that is used if borrower clicks on the button \'create a new ILL request\' in the Koha OPAC.', 'Htmlarea'), 
('ILLDeliverySlipCode', 'ILLSLNP_DELIVERY_SLIP', NULL, 'Code of letter layout used for ILL delivery processing slips.', 'Free'), 
('ILLItemLostBorrowerLettercode', 'ILLSLNP_ITEMLOST_BORROWER', NULL, 'code of letter that will be sent to ordering borrower if item is lost before check out', 'Free'), 
('ILLItemLostLibraryLettercode', 'ILLSLNP_ITEMLOST_LIBRARY', NULL, 'code of letter that will be sent to owning library if item is lost after receipt', 'Free'), 
('ILLNotDeliveredLettercode', 'ILLSLNP_NOT_DELIVERED', NULL, 'letter code of notice to borrower informing that the ILL order will not be delivered by the owning library', 'Free'), 
('ILLNoticesLetterCodes', 'ILLSLNP_DELIVERY_NOTICE_1_CHARGE|ILLSLNP_DELIVERY_NOTICE_2_CHARGE|ILLSLNP_DELIVERY_NOTICE_CHARGE_NOT', NULL, 'Provide a list of letter codes (separate multiple codes with |) which can be used to send notices on ILL receipts.', 'Free'), 
('ILLRequestConfirm', 'ILLSLNP_REQUEST_CONFIRM', NULL, 'letter code of notice to borrower that his ILL request has been confirmed by a owning library', 'Free'), 
('ILLShipBackLettercode', 'ILLSLNP_SHIPBACK_SLIP', NULL, 'letter code of slip used when sending back medium to owning ILL library', 'Free');

