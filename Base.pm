package Koha::Illbackends::ILLSLNPKoha::Base;

# Copyright 2018-2021 (C) LMSCLoud GmbH
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Carp;
use File::Basename qw( dirname );
use Data::Dumper;

use Koha::Libraries;
use Clone qw( clone );
use Locale::Country;
use XML::LibXML;
use MARC::Record;
use C4::Context;
use C4::Biblio qw( AddBiblio );
use Koha::Illrequest::Config;
use Try::Tiny;
use URI::Escape;
use YAML;
use JSON qw( to_json );
use Koha::Patron::Attributes;
use Koha::Patron::Categories;
use C4::Letters;
use C4::Biblio;
use Koha::DateUtils qw(dt_from_string output_pref);


=head1 NAME

Koha::Illbackends::ILLSLNPKoha::Base - Koha ILL Backend: ILLSLNPKoha


=head1 SYNOPSIS
Koha ILL implementation for the "ILLSLNPKoha" backend. 
Some library consortia in Germany run ILL servers that use SLNP (Simple Library Network Protocol) 
for communication with the integrated library management systems.
ZFL is the abbreviation for 'Zentrale Fernleihe' (central interlibrary loan).


=head1 DESCRIPTION
SLNP (TM) (Simple Library Network Protocol) is a TCP network socket based protocol 
designed and introduced by the company Sisis Informationssysteme GmbH (later a part of OCLC) 
for their library management system SISIS-SunRise (TM).
This protocol supports the bussiness processes of libraries.
A subset of SLNP that enables the communication required for regional an national ILL (Inter Library Loan) processes
has been published by Sisis Informationssysteme GmbH as basis for 
connection of library management systems to ILL servers that use SLNP.
Sisis Informationssysteme GmbH / OCLC owns all rights to SLNP.
SLNP is a registered trademark of Sisis Informationssysteme GmbH / OCLC.

This ILL backend provides a simple method to handle Interlibrary Loan requests that are initiated by an regional ILL server using the SLNP protocol.
The additional service 'ILLZFLServerKoha' manages the communication with the regional ILL server and will insert records in tables illrequests and illrequestattributes by calling the 'create' method of ILLSLNPKoha. 
The remaining features of this ILL backend are accessible via the standard ILL framework in the Koha staff interface.

=head1 API

=head2 Class Methods

=cut

=head3 new

=cut

sub new {
    # -> instantiate the backend
    my ( $class ) = @_;
    my $self = {framework => 'FA'};
    bless( $self, $class );
    return $self;
}

=head3 _config

    my $config = $slnp_backend->_config($config);
    my $config = $slnp_backend->_config;

Getter/Setter for our config object.

=cut

sub _config {
  my ($self, $config) = @_;
  $self->{config} = $config if ($config);
  return $self->{config};


}

=head3 status_graph

=cut

sub status_graph {
  return {
    # status 'Received' (This action is used when the ordered ILL item is received in the library of the ordering borrower.)
    RECVD => {
      prev_actions   => ['REQ',],
      id             => 'RECVD',
      name           => 'Eingangsverbucht',
      ui_method_name => 'Eingang verbuchen',
      method         => 'verbucheEingang',
      next_actions   => [],    # in reality: ['CHKDOUT', 'LOSTBCO']
      ui_method_icon => 'fa-check',
    },
    # Pseudo status, not stored in illrequests. Sole purpose: displaying 'Eingang bearbeiten' dialog for update (status stays unchanged)
    RECVDUPD => {
      prev_actions   => ['RECVD', 'CHKDOUT', 'CHKDIN'],
      id             => 'RECVDUPD',
      name           => 'Eingangsverbucht',
      ui_method_name => 'Eingang bearbeiten',
      method         => 'verbucheEingang',
      next_actions   => [],    # in reality: status stays unchanged
      ui_method_icon => 'fa-check',
    },
    # status 'Checkedout' (not for GUI, now internally handled by itemCheckedOut(), called by C4::Circulation::AddIssue() )
    CHKDOUT => {
      prev_actions   => [], # Officially empty, so not used in GUI. in reality: ['RECVD']
      id             => 'CHKDOUT',
      name           => 'Ausgeliehen',
      ui_method_name => 'Aufruf_durch_Koha_Ausleihe',    # not used in GUI
      method         => 'leiheAus',
      next_actions   => [],    # in reality: ['CHKDIN', 'LOSTACO']
      ui_method_icon => 'fa-check',
    },
    # status 'Checkedin' (not for GUI, now internally handled by itemCheckedIn(), called by C4::Circulation::AddReturn() )
    CHKDIN => {
      prev_actions   => [], # Officially empty, so not used in GUI. in reality: ['CHKDOUT']
      id             => 'CHKDIN',
      name           => "R\N{U+fc}ckgegeben",
      ui_method_name => 'Aufruf_durch_Koha_Rueckgabe',    # not used in GUI
      method         => 'gebeRueck',
      next_actions   => [],    # in reality: ['COMP', 'LOSTACO']
      ui_method_icon => 'fa-check',
    },
    # Pseudo status, not stored in illrequests. Sole purpose: displaying "Rueckversenden" dialog (status becomes 'COMP')
    SNTBCK => { # medium is sent back, mark this ILL request as COMP
        prev_actions   => ['RECVD', 'CNCLDFU', 'CHKDIN'],
        id             => 'SNTBCK',
        name           => "Zur\N{U+fc}ckversandt",
        ui_method_name => "R\N{U+fc}ckversenden",
        method         => 'sendeZurueck',
        next_actions   => [],    # in reality: ['COMP']
        ui_method_icon => 'fa-check',
    },
    # Pseudo status, not stored in illrequests. Sole purpose: displaying 'Verlust buchen' dialog (status stays unchanged)
    LOSTHOWTO => {
      prev_actions   => ['RECVD', 'CHKDOUT', 'CHKDIN'],
      id             => 'LOSTHOWTO',
      name           => 'Verlust HowTo',
      ui_method_name => 'Verlust buchen',
      method         => 'bucheVerlust',
      next_actions   => [],    # in reality: status stays unchanged
      ui_method_icon => 'fa-times',
    },
    # status 'LostBeforeCheckOut' (not for GUI, now internally handled by itemLost(), called by cataloguing::additem.pl and catalogue::updateitem.pl )
    LOSTBCO => { # lost by library Before CheckOut
      prev_actions   => [], # Officially empty, so not used in GUI. in reality: ['RECVD']
      id             => 'LOSTBCO',
      name           => 'Verlust vor Ausleihe',
      ui_method_name => 'Aufruf_durch_Koha_Verlust-Buchung',    # not used in GUI
      method         => 'itemLost',
      next_actions   => [],    # in reality: ['COMP']
      ui_method_icon => 'fa-times',
    },
    # status 'LostAfterCheckOut' (not for GUI, now internally handled by itemLost(), called by cataloguing::additem.pl and catalogue::updateitem.pl )
    LOSTACO => { # lost by user After CheckOut or by library after CheckIn
      prev_actions   => [], # Officially empty, so not used in GUI. in reality: ['CHKDOUT', 'CHKDIN']
      id             => 'LOSTACO',
      name           => 'Verlust',
      ui_method_name => 'Aufruf_durch_Koha_Verlust-Buchung',    # not used in GUI
      method         => 'itemLost',
      next_actions   => [],    # in reality: ['COMP']
      ui_method_icon => 'fa-times',
    },
    # Pseudo status, not stored in illrequests. Sole purpose: displaying 'Verlust melden' dialog (status becomes 'COMP')
    LOST => {
      prev_actions   => ['LOSTBCO', 'LOSTACO'],
      id             => 'LOST',
      name           => 'Verlustgebucht',
      ui_method_name => 'Verlust melden',
      method         => 'meldeVerlust',
      next_actions   => ['COMP'],
      ui_method_icon => 'fa-times',
    },
    # status 'CancelledForUser'
    CNCLDFU => {
      prev_actions   => ['REQ'],
      id             => 'CNCLDFU',
      name           => 'Storniert',
      ui_method_name => 'Bestellung stornieren',
      method         => 'storniereFuerBenutzer',
      next_actions   => [],    # in reality: ['COMP']
      ui_method_icon => 'fa-times',
    },
    # Pseudo status, not stored in illrequests. Sole purpose: displaying 'Negativ-Kennzeichen' dialog (status becomes 'COMP')
    NEGFLAG => {
        prev_actions   => ['REQ', 'CNCLDFU'],
        id             => 'NEGFLAG',
        name           => "Negativ/gel\N{U+f6}scht",
        #ui_method_name => "Negativ-Kennzeichen / l\N{U+f6}schen",
        ui_method_name => 'Negativ-Kennzeichen',
        method         => 'kennzeichneNegativ',
        next_actions   => [],    # in reality: ['COMP']
        ui_method_icon => 'fa-times',
    },

    # status of core graph used in this ill backend:
    REQ => {
        prev_actions   => [ 'QUEUED' ],
        id             => 'REQ',
        name           => 'Requested',
        ui_method_name => 'Confirm request',
        method         => 'confirm',
        #next_actions   => [ 'RECVD' ],
        next_actions   => [ ],
        ui_method_icon => 'fa-check',
    },
    REQREV => {
        prev_actions   => [  ],
        id             => 'REQREV',
        name           => 'Request reverted',
        ui_method_name => 'Revert Request',
        method         => 'cancel',
        next_actions   => [  ],
        ui_method_icon => 'fa-times',
    },
    # this leads to the frameworks confirm_delete and delete actions, that are too crude for ILLSLNPKoha, so it is not activated.
    #    KILL => {
    #        prev_actions   => [ 'REQ', 'CNCLDFU' ],
    #        id             => 'KILL',
    #        name           => 'Negativ-Kennzeichen',
    #        ui_method_name => "L\N{U+f6}schung / Negativ-Kennzeichen",
    #        method         => 'delete',
    #        next_actions   => [  ],
    #        ui_method_icon => 'fa-times',
    #    },
    };
}

sub name {
    return "ILLSLNPKoha";
}

=head3 capabilities

    $capability = $backend->capabilities($name);

Return the sub implementing a capability selected by NAME, or 0 if that
capability is not implemented.

=cut

sub capabilities {
    my ($self, $name) = @_;
    my ($query) = @_;
    my $capabilities = {

        # experimental, general access, not used yet (usage: my $duedate = $illrequest->_backend_capability( "getIllrequestattributes", [$illrequest,["duedate"]] );)
        getIllrequestattributes => sub { $self->getIllrequestattributes(@_); },    

        # used capabilities:
        getIllrequestDateDue => sub { $self->getIllrequestDateDue(@_); },
        isShippingBackRequired => sub { $self->isShippingBackRequired(@_); },
        itemCheckedOut => sub { $self->itemCheckedOut(@_); },
        itemCheckedIn => sub { $self->itemCheckedIn(@_); },
        itemLost => sub { $self->itemLost(@_); },
        isReserveFeeAcceptable => sub { $self->isReserveFeeAcceptable(@_); },
        sortAction => sub { $self->sortAction(@_); }
    };
    return $capabilities->{$name};
}

=head3 metadata

Return a hashref containing canonical values from the key/value
illrequestattributes table.
Theese canonical values are used in the table view and record view of the ILL framework
und so can not be renamed without adaptions.

=cut

sub metadata {
    my ( $self, $request ) = @_;

    my %map = (
        'Article_author' => 'article_author',    # used alternatively to 'Author'
        'Article_title' => 'article_title',    # used alternatively to 'Title'
        'Author' => 'author',
        'ISBN' => 'isbn',
        'Order ID' => 'zflorderid',
        'Title' => 'title',
    );

    my %attr;
    for my $k (keys %map) {
        my $v = $request->illrequestattributes->find({ type => $map{$k} });
        $attr{$k} = $v->value if defined $v;
    }
    if ( $attr{Article_author} ) {
        if ( length($attr{Article_author}) ) {
            $attr{Author} = $attr{Article_author};
        }
        delete $attr{Article_author};
    }
    if ( $attr{Article_title} ) {
        if ( length($attr{Article_title}) ) {
            $attr{Title} = $attr{Article_title};
        }
        delete $attr{Article_title};
    }

    return \%attr;
}

=head3 create

    my $response = $slnp_backend->create( $params );

Checks values in $params and inserts an illrequests record.
The values in $params normally are filled by SLNPFLBestellung.pm based on the request parameters of the received SLNP command 'SLNPFLBestellung'.
Returns an ILL backend standard response for the create method call.

=cut

sub create {
    my ( $self, $params ) = @_;
    my $stage = $params->{other}->{stage};

    my $backend_result = {
        backend    => $self->name,
        method     => 'create',
        stage      => $stage,
        error      => 0,
        status     => '',
        message    => '',
        value      => {}
    };

    # Initiate process stage is dummy for ILLSLNPKoha
    if ( !$stage || $stage eq 'init' ) {
        ;    # Ill request is created by the external ILLSLNLKoha server calling SLNPFLBestellung, so no manual handling at this stage
    }

    # Validate SLNP request parameter values and insert new ILL request in DB
    elsif ( $stage eq 'commit' ) {

        # Check for borrower by sent cardnumber
        my ( $brw_count, $brw ) = _validate_borrower($params->{other}->{attributes}->{'cardnumber'});

        if ( !$params->{other}->{'attributes'}->{'title'} ) {
            $backend_result->{error}  = 1;
            $backend_result->{status} = "missing_title";
            $backend_result->{value} = $params;
        } elsif ( !$params->{other}->{'medium'} ) {
            $backend_result->{error}  = 1;
            $backend_result->{status} = "missing_ILLtype";
            $backend_result->{value} = $params;
       } elsif ( !$params->{other}->{'branchcode'} ) {
            $backend_result->{error}  = 1;
            $backend_result->{status} = "missing_branch";
            $backend_result->{value} = $params;
        } elsif ( !Koha::Libraries->find($params->{other}->{'branchcode'}) ) {
            $backend_result->{error}  = 1;
            $backend_result->{status} = "invalid_branch";
            $backend_result->{value} = $params;
        } elsif ( $brw_count != 1 ) {
            $backend_result->{error}  = 1;
            $backend_result->{status} = "invalid_borrower";
            $backend_result->{value}  = $params;
        } else {
            $params->{other}->{borrowernumber} = $brw->borrowernumber;
            $backend_result->{borrowernumber} = $params->{other}->{borrowernumber};
        }

        my $biblionumber = $self->slnp2biblio($params->{other});
        my $itemnumber = 0;

        if ( ! $biblionumber ) {
            $backend_result->{error}  = 1;
            $backend_result->{status} = "error_creating_biblio";
            $backend_result->{value}  = $params;
        } else {
            $itemnumber = $self->slnp2items($params,$biblionumber,{});
            if ( ! $itemnumber ) {
                $backend_result->{error}  = 1;
                $backend_result->{status} = "error_creating_items";
                $backend_result->{value}  = $params;
            }
        }

        if ( $backend_result->{error} == 0 ) {
            my $now = DateTime->now( time_zone => C4::Context->tz() );

            # populate Illrequest

            # illrequest_id is set automatically if 0
            $params->{request}->borrowernumber($brw->borrowernumber);
            $params->{request}->biblio_id($biblionumber) unless !$biblionumber;
            $params->{request}->branchcode($params->{other}->{branchcode});
            $params->{request}->status('REQ');
            $params->{request}->placed($now);
            # replied is NULL
            $params->{request}->updated($now);
            # completed is NULL
            $params->{request}->medium($params->{other}->{medium});
            # accessurl is NULL
            # cost is NULL
            # notesopac is NULL
            # notesstaff is NULL
            $params->{request}->orderid($params->{other}->{orderid});
            $params->{request}->backend($self->name);

            $params->{request}->store;

            # Consortium HBZ has two ways of calling SLNPFLBestellung:
            # A) directly by ZFL-Server: BestellID is correct and of form yyyyiiiiiii with yyyy: current year and iiiiiii: serial number, e.g. 19990000123
            # B) by a perl script from the end user portal: BestellID is always dummy 999999999
            # In case B) we replace the not unique '999999999' by unique yyyyiiiiiiiF with yyyy: current year and iiiiiii: illrequests.illrequest_id and F: text 'F'
            if ( $params->{request}->orderid() eq '999999999' ) {
                my $newOrderId = sprintf("%04d%07dF", $now->year(), $params->{request}->illrequest_id() % 10000000);
                $params->{other}->{attributes}->{zflorderid} = $newOrderId;    # content for items.barcode
                $params->{request}->orderid($newOrderId);    # content for hit list table column 'Order ID' (en) / 'Bestell-ID' (de)
                $params->{request}->store;
            }

            # populate table illrequestattributes
            $params->{other}->{attributes}->{itemnumber} = $itemnumber;
            while (my ($type, $value) = each %{$params->{other}->{attributes}}) {

                try {
                    Koha::Illrequestattribute->new({
                        illrequest_id => $params->{request}->illrequest_id,
                        type          => $type,
                        value         => $value,
                    })->store;
                };
            }
            # update items record: store (maybe modified) zflorderid in items.barcode, illrequest.illrequest_id in items.stocknumber, etc.
            $self->slnp2items($params,$biblionumber,{   barcode => scalar $params->{other}->{attributes}->{zflorderid},
                                                        homebranch => $params->{request}->branchcode(),,
                                                        holdingbranch => $params->{request}->branchcode(),
                                                        stocknumber => $params->{request}->illrequest_id()
                                                    } );

            # send ILL request confirmation notice (e.g. with letter.code ILLSLNP_REQUEST_CONFIRM) to ordering borrower if configured (syspref ILLRequestConfirm)
            my $illrequestconfirmLetterCode = C4::Context->preference("ILLRequestConfirm");
            if ( $illrequestconfirmLetterCode && length($illrequestconfirmLetterCode) ) {
                &printIllNoticeSlnp($params->{request}->branchcode(), $params->{request}->borrowernumber(), undef, undef, $params->{request}->illrequest_id(), $params->{other}->{attributes}, 0, $illrequestconfirmLetterCode );
            }

            $backend_result->{stage} = "commit";
            $backend_result->{value} = $params;
        };
    }

    # Invalid stage, return error.
    else {
        $backend_result->{stage} = $params->{stage};
        $backend_result->{error} = 1;
        $backend_result->{status} = 'unknown_stage';
    }

    return $backend_result;
}

# stages if status=='REQ':   init -> deliveryInsert -> InsertAndPrint-> commit
# stages if status=='RCVD':  init -> deliveryUpdate -> UpdateAndMaybePrint-> commit  or  init -> deliveryUpdate -> PrintOnly-> commit
sub verbucheEingang {
    my ($self, $params) = @_;

    my $stage = $params->{other}->{stage};    # empty at the beginning; only filled if HTML page has been submitted
    my $backend_result = {
        backend => $self->name,
        method  => "verbucheEingang",
        stage   => $stage,    # default for testing the template
        error   => 0,
        status  => "",
        message => "",
        value   => {},
        next    => "illview",
    };

    if ( ( $stage eq 'InsertAndPrint' || $stage eq 'UpdateAndMaybePrint' || $stage eq 'PrintOnly' || $stage eq 'commit' ) && !$params->{other}->{'sendingIllLibraryBorrowernumber'} ) {
        $stage = 'errorNoSendingIllLibraryInfo';
    }
    $backend_result->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{other}->{illdeliveryslipcode} = C4::Context->preference("ILLDeliverySlipCode");
    $backend_result->{value}->{request}->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{orderid} = $params->{request}->orderid();
    $backend_result->{value}->{request}->{biblio_id} = $params->{request}->biblio_id();
    $backend_result->{value}->{request}->{borrowernumber} = $params->{request}->borrowernumber();
    if (!$stage || $stage eq 'init' ) {
        $backend_result->{value}->{other}->{type} = $params->{request}->medium();
    } else {
        $backend_result->{value}->{other}->{type} = $params->{other}->{type};
    }

    # illItemtypes (not destroying original sequence of syspref IllItemtypes)
    my @illItemtypes = split( /\|/, C4::Context->preference("IllItemtypes") );
    my $kohaIllItemtypes = [];
    foreach my $it (@illItemtypes) {
        my $rs = Koha::ItemTypes->search({itemtype => $it});
        if ( my $itres = $rs->next ) {
            push @$kohaIllItemtypes, { itemtype => $itres->itemtype, description => $itres->description, translated_description => $itres->translated_description };
        }
    }
    $backend_result->{value}->{other}->{kohaIllItemtypes} = $kohaIllItemtypes;

    # illPatronCategories (using categories for pop up window that enables search for sending library):
    my @illPatronCategories = split( /\|/, C4::Context->preference("IllPatronCategories") );
    my $kohaIllPatronCategories = [];
    foreach my $catcode (@illPatronCategories) {
        my $rs = Koha::Patron::Categories->search({categorycode => $catcode});
        if ( my $categoryres = $rs->next ) {
            push @$kohaIllPatronCategories, { categorycode => $categoryres->categorycode, description => $categoryres->description };
        }
    }
    $backend_result->{value}->{other}->{kohaIllPatronCategories} = $kohaIllPatronCategories;

    # letter code of Notices for ordering borrower (not destroying original sequence of syspref ILLNoticesLetterCodes)
    my @illNoticesLetterCodes = split( /\|/, C4::Context->preference("ILLNoticesLetterCodes") );
    my $kohaILLNoticesLetters = [];
    foreach my $code (@illNoticesLetterCodes) {
        my $letterhits = C4::Letters::GetLetters({code => $code});
        foreach my $letterhit (@$letterhits) {
            push @$kohaILLNoticesLetters, $letterhit;    # { code => $letterres->code, module => $letterres->module, name => $letterres->name };
        }
    }
    $backend_result->{value}->{other}->{kohaIllPatronLetters} = $kohaILLNoticesLetters;

    if (!$stage || $stage eq 'init' || $stage eq 'errorNoSendingIllLibraryInfo') {
        if ( $params->{request}->status eq 'REQ' ) {
            $backend_result->{stage}  = 'deliveryInsert';
        } else {
            $backend_result->{stage}  = 'deliveryUpdate';
        }

        # data of ordering patron
        $backend_result->{value}->{other}->{borrowerBorrowernumber} = $params->{request}->borrowernumber();
        my $rs = Koha::Patrons->search( { 'borrowernumber' => $params->{request}->borrowernumber() } );
        if ( my $borrower = $rs->next ) {
            $backend_result->{value}->{other}->{borrowerCardnumber} = $borrower->cardnumber();
            $backend_result->{value}->{other}->{borrowerFirstname} = $borrower->firstname();
            $backend_result->{value}->{other}->{borrowerSurname} = $borrower->surname();
        }

        if ($stage eq 'errorNoSendingIllLibraryInfo') {
            $backend_result->{error} = 1;
            $backend_result->{status} = "missing_sendingIllLibraryInfo";

            $backend_result->{value}->{other}->{itemnumber} = $params->{other}->{itemnumber};
            $backend_result->{value}->{other}->{noncirccollection} = $params->{other}->{noncirccollection};
            $backend_result->{value}->{other}->{kohaitemtype} = $params->{other}->{kohaitemtype};
            $backend_result->{value}->{other}->{deliverydate} = output_pref( { str => $params->{other}->{deliverydate}, dateonly => 1, dateformat => 'sql' } );
            $backend_result->{value}->{other}->{volumescount} = $params->{other}->{volumescount};
            $backend_result->{value}->{other}->{billedillrequestcosts} = format_to_dbmoneyfloat($params->{other}->{billedillrequestcosts});
            $backend_result->{value}->{other}->{duedate} = output_pref( { str => $params->{other}->{duedate}, dateonly => 1, dateformat => 'sql' } );
            $backend_result->{value}->{other}->{illdeliverylettercode} = $params->{other}->{illdeliverylettercode};
            $backend_result->{value}->{other}->{illdeliveryslipprint} = $params->{other}->{illdeliveryslipprint};

        } else {
            $backend_result->{value}->{other}->{volumescount} = 1;
            $backend_result->{value}->{other}->{billedillrequestcosts} = $params->{request}->cost();
            $backend_result->{value}->{other}->{illdeliveryslipprint} = 1;

            $backend_result->{value}->{other}->{sendingIllLibraryBorrowernumber} = '';
            $backend_result->{value}->{other}->{sendingIllLibraryIsil} = '';
            $backend_result->{value}->{other}->{sendingIllLibrarySurname} = '';
            $backend_result->{value}->{other}->{sendingIllLibraryCity} = '';

            my @interesting_fields = ();
            # search interesting illrequestattributes and store in hash of $backend_result
            if ($params->{request}->status eq 'REQ') {
                @interesting_fields = (
                    'isbn',
                    'issn',
                    'itemnumber',
                    'shelfmark',
                    'author',
                    'title',
                    'zflorderid'
                );
            } else {    # status eq 'RECVD' / 'CHKDOUT' / 'CHKDIN' / ...
                @interesting_fields = (
                    'deliverydate',
                    'duedate',
                    'illdeliverylettercode',
                    'illdeliveryslipprint',
                    'isbn',
                    'issn',
                    'itemnumber',
                    'kohaitemtype',
                    'noncirccollection',
                    'sendingIllLibraryBorrowernumber',
                    'sendingIllLibraryIsil',
                    'shelfmark',
                    'author',
                    'title',
                    'volumescount',
                    'zflorderid'
                );
            }

            my $fieldResults = $params->{request}->illrequestattributes->search(
                { type => {'-in' => \@interesting_fields}});
            my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
            foreach my $type (keys %{$illreqattr}) {
                $backend_result->{value}->{other}->{$type} = $illreqattr->{$type};
            }

            if ($params->{request}->status ne 'REQ') {
                # read record of sending library
                my $borrowers_rs = Koha::Patrons->search( { borrowernumber => $backend_result->{value}->{other}->{sendingIllLibraryBorrowernumber} } );
                if ( my $sendinglib = $borrowers_rs->next ) {
                    $backend_result->{value}->{other}->{sendingIllLibraryBorrowernumber} = $sendinglib->borrowernumber();
                    $backend_result->{value}->{other}->{sendingIllLibrarySurname} = $sendinglib->surname();
                    $backend_result->{value}->{other}->{sendingIllLibraryCity} = $sendinglib->city();

                    my $borrower_attributes_rs = Koha::Patron::Attributes->search({ borrowernumber => $sendinglib->borrowernumber(),
                                                                                    code => 'SIGEL' });
                    if ( my $borrower_attribute_res = $borrower_attributes_rs->next ) {
                        $backend_result->{value}->{other}->{sendingIllLibraryIsil} = $borrower_attribute_res->attribute();
                    }
                }
            }
        }

    } elsif ($stage eq 'InsertAndPrint' || $stage eq 'UpdateAndMaybePrint' || $stage eq 'PrintOnly' || $stage eq 'commit') {
        # 'InsertAndPrint': we insert illrequestattributes records, update the illrequest record, print a letter (the delivery slip is printed in a separate tab, if checked) and return.
        # 'UpdateAndMaybePrint': we update illrequestattributes records, update the illrequest record, maybe print a letter (the delivery slip is printed in a separate tab, if checked) and return.
        # 'PrintOnly': we do not update illrequestattributes records or the illrequest record, but print a letter and return.

        if ( $stage eq 'InsertAndPrint' || $stage eq 'UpdateAndMaybePrint' ) {    # 'InsertAndPrint'/'UpdateAndMaybePrint' precede 'commit'; $stage eq 'commit' is used only for closing the dialog
            my $illreq_attributes = {};

            # volume count of the received medium is stored in illattributes and in analog form in items.materials
            my $itemrs = Koha::Items->find({ itemnumber => $params->{other}->{itemnumber} });
            my $materials = "Anzahl B\N{U+e4}nde " . $params->{other}->{volumescount};

            # selected koha item type of the received medium is stored in illattributes and items.itype
            my $itype = $params->{other}->{kohaitemtype};

            # non-circulation collection of the received medium is stored in illattributes and in analog form in items.notforloan
            my $notforloan = $itemrs->notforloan();
            if ( !defined($params->{other}->{noncirccollection}) || $params->{other}->{noncirccollection} + 0 == 0 ) {
                $notforloan = -1;     # 'ordered'
            } else {
                $notforloan = -127;    # defined authorised value for ILL non circulation collection
            }
            if ( $itemrs->materials() ne $materials || $itemrs->itype() ne $itype || $itemrs->notforloan() ne $notforloan ) {
                $itemrs->update({ materials => $materials,
                                  itype => $itype,
                                  notforloan => $notforloan
                                });
            }

            # ill type is stored in illrequests record (field 'medium')
            my $oldmedium = $params->{request}->medium();
            my $newmedium = $params->{other}->{type};
            if ( $newmedium ne $oldmedium ) {
                $params->{request}->update({ medium => $newmedium });
            }

            # costs billed by the sending library is stored in illrequests record
            my $oldcosts = $params->{request}->cost();
            my $newcosts = format_to_dbmoneyfloat($params->{other}->{billedillrequestcosts});
            if ( $newcosts ne $oldcosts ) {
                $params->{request}->update({ cost => $newcosts });
            }


            # and these fields are stored in illrequestattributes

            # non-circulation collection
            if ( !defined($params->{other}->{noncirccollection}) || $params->{other}->{noncirccollection} + 0 == 0 ) {
                $illreq_attributes->{noncirccollection} = '0';
            } else {
                $illreq_attributes->{noncirccollection} = '1';
            }

            # selected koha item type
            $illreq_attributes->{kohaitemtype} = $params->{other}->{kohaitemtype};

            # date the ILL medium was received in this library
            $illreq_attributes->{deliverydate} = output_pref( { str => $params->{other}->{deliverydate}, dateonly => 1, dateformat => 'sql' } );

            # borrowernumber of the sending library
            $illreq_attributes->{sendingIllLibraryBorrowernumber} = $params->{other}->{sendingIllLibraryBorrowernumber};

            # isil of the sending library
            $illreq_attributes->{sendingIllLibraryIsil} = $params->{other}->{sendingIllLibraryIsil};

            # date the ordering patron has to return the medium
            $illreq_attributes->{duedate} = output_pref( { str => $params->{other}->{duedate}, dateonly => 1, dateformat => 'sql' } );

            # type of letter choosen for informing the ordering patron on the medium receipt
            $illreq_attributes->{illdeliverylettercode} = $params->{other}->{illdeliverylettercode};

            # flag for printing the Ill delivery slip
            if ( !defined($params->{other}->{illdeliveryslipprint}) || $params->{other}->{illdeliveryslipprint} + 0 == 0 ) {
                $illreq_attributes->{illdeliveryslipprint} = '0';
            } else {
                $illreq_attributes->{illdeliveryslipprint} = '1';
            }
            # volume count of the received medium
            $illreq_attributes->{volumescount} = $params->{other}->{volumescount};


            if ( $params->{request}->status eq 'REQ' ) {
                while (my ($type, $value) = each %{$illreq_attributes}) {
                    try {
                        Koha::Illrequestattribute->new({
                            illrequest_id => $params->{request}->id,
                            type          => $type,
                            value         => $value,
                        })->store;
                    }
                }

                $params->{request}->status('RECVD')->store;

                # additionally create a standard Koha reserve
                my $reserve_id = C4::Reserves::AddReserve(
                    $params->{request}->branchcode(),
                    $params->{request}->borrowernumber(),
                    $params->{request}->biblio_id(),
                    [$params->{request}->biblio_id()],
                    0,                              # priority
                    '',                             # reservedate today
                    $illreq_attributes->{duedate},  # expirationdate
                    '',                             # notes
                    '',                             # biblio title for fee
                    $params->{other}->{itemnumber}, # itemnumber
                    'W',                            # field 'found'
                    undef                           # itemtype
                );
 
            } else {
                while (my ($type, $value) = each %{$illreq_attributes}) {
                    my $res = Koha::Illrequestattributes->find_or_create({
                        illrequest_id => $params->{request}->id,
                        type          => $type
                    });
                    if ( $res->value() ne $value ) {
                        $res->update({
                                      value => $value,
                                     });
                    }
                }
            }
        }

        # the fields are already stored, so check only if to generate a new borrower notice
        if ( $params->{other}->{illdeliverylettercode} ) {    # either (Deliveryinsert->InsertAndPrint submit) or (DeliveryUpdate->UpdateAndMaybePrint submit) or (DeliveryUpdate->PrintOnly submit for letter (not slip))

            my $fieldResults = $params->{request}->illrequestattributes->search();
            my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
            &printIllNoticeSlnp($params->{request}->branchcode(), $params->{request}->borrowernumber(), $params->{request}->biblio_id(), $params->{other}->{itemnumber}, $params->{request}->illrequest_id(), $illreqattr, $params->{other}->{sendingIllLibraryBorrowernumber}, $params->{other}->{illdeliverylettercode} );

            $backend_result->{value}->{other}->{illdeliverylettercode} = $params->{other}->{illdeliverylettercode}
        }

        $backend_result->{stage} = $stage;

        $backend_result->{value}->{other}->{billedillrequestcosts} = format_to_dbmoneyfloat($params->{other}->{billedillrequestcosts});
        $backend_result->{value}->{other}->{borrowerBorrowernumber} = $params->{other}->{borrowerBorrowernumber};
        $backend_result->{value}->{other}->{borrowerCardnumber} = $params->{other}->{borrowerCardnumber};
        $backend_result->{value}->{other}->{borrowerFirstname} = $params->{other}->{borrowerFirstname};
        $backend_result->{value}->{other}->{borrowerSurname} = $params->{other}->{borrowerSurname};
        $backend_result->{value}->{other}->{deliverydate} = output_pref( { str => $params->{other}->{deliverydate}, dateonly => 1, dateformat => 'sql' } );
        $backend_result->{value}->{other}->{duedate} = output_pref( { str => $params->{other}->{duedate}, dateonly => 1, dateformat => 'sql' } );
        $backend_result->{value}->{other}->{illdeliverylettercode} = $params->{other}->{illdeliverylettercode};
        $backend_result->{value}->{other}->{illdeliveryslipprint} = $params->{other}->{illdeliveryslipprint};
        $backend_result->{value}->{other}->{itemnumber} = $params->{other}->{itemnumber};
        $backend_result->{value}->{other}->{kohaitemtype} = $params->{other}->{kohaitemtype};
        $backend_result->{value}->{other}->{noncirccollection} = $params->{other}->{noncirccollection};
        $backend_result->{value}->{other}->{sendingIllLibraryBorrowernumber} = $params->{other}->{sendingIllLibraryBorrowernumber};
        $backend_result->{value}->{other}->{sendingIllLibraryIsil} = $params->{other}->{sendingIllLibraryIsil};
        $backend_result->{value}->{other}->{sendingIllLibrarySurname} = $params->{other}->{sendingIllLibrarySurname};
        $backend_result->{value}->{other}->{sendingIllLibraryCity} = $params->{other}->{sendingIllLibraryCity};
        $backend_result->{value}->{other}->{type} = $params->{other}->{type};
        $backend_result->{value}->{other}->{volumescount} = $params->{other}->{volumescount};
        $backend_result->{value}->{other}->{zflorderid} = $params->{other}->{zflorderid};
    } else {
        # in case of faulty or testing stage, we just return the standard $backend_result with original stage
        $backend_result->{stage} = $stage;
    }

    return $backend_result;
}

sub format_to_dbmoneyfloat  {
    my ( $floatstr ) = @_;
    my $ret = $floatstr;
    # The float value in $floatstr has been formatted by javascript for display in the HTML page, but we need it in database form again (i.e without thousands separator, with decimal separator '.').
    my $thousands_sep = ' ';    # default, correct if Koha.Preference("CurrencyFormat") == 'FR'  (i.e. european format like "1 234 567,89")
    if ( substr($floatstr,-3,1) eq '.' ) {    # american format, like "1,234,567.89"
        $thousands_sep = ',';
    }
    $ret =~ s/$thousands_sep//g;    # get rid of the thousands separator
    $ret =~ tr/,/./;      # decimal separator in DB is '.'
    return $ret;
}

sub printIllNoticeSlnp {
    my ( $branchcode, $borrowernumber, $biblionumber, $itemnumber, $illrequest_id, $illreqattr_hashptr, $accountBorrowernumber, $letter_code ) = @_;
    my $noticeFees = C4::NoticeFees->new();
    my $patron = Koha::Patrons->find( $borrowernumber );
    my $library = Koha::Libraries->find( $branchcode )->unblessed;
    my $admin_email_address = $library->{branchemail} || C4::Context->preference('KohaAdminEmailAddress');

    # Try to get the borrower's email address
    my $to_address = $patron->notice_email_address;

    my %letter_params = (
        module => 'circulation',
        branchcode => $branchcode,
        lang => $patron->lang,
        tables => {
            'branches'       => $library,
            'borrowers'      => $patron->unblessed,
            'biblio'         => $biblionumber,
            'biblioitems'    => $biblionumber,
            'items'          => $itemnumber,
            'account'        => $accountBorrowernumber,    # if $borrowernumber marks sending library, this marks the orderer, and vice versa (or 0)
            'illrequests'    => $illrequest_id,
            'illrequestattributes' => $illreqattr_hashptr,
        },
    );


    my $send_notification = sub {
        my ( $mtt, $borrowernumber,   $letter_code ) = (@_);
        return unless defined $letter_code;
        $letter_params{letter_code} = $letter_code;
        $letter_params{message_transport_type} = $mtt;
        my $letter =  C4::Letters::GetPreparedLetter ( %letter_params );
        unless ($letter) {
            warn "Could not find a letter called '$letter_params{'letter_code'}' for $mtt in the '$letter_params{'module'}' module";
            return;
        }

        C4::Letters::EnqueueLetter( {
            letter => $letter,
            borrowernumber => $borrowernumber,
            from_address => $admin_email_address,
            message_transport_type => $mtt,
            branchcode => $branchcode
        } );

        # check whether there are notice fee rules defined
        if ( $noticeFees->checkForNoticeFeeRules() == 1 ) {
            #check whether there is a matching notice fee rule
            my $noticeFeeRule = $noticeFees->getNoticeFeeRule($letter_params{branchcode}, $patron->categorycode, $mtt, $letter_code);

            if ( $noticeFeeRule ) {
                my $fee = $noticeFeeRule->notice_fee();
                
                if ( $fee && $fee > 0.0 ) {
                    # Bad for the patron, staff has assigned a notice fee for sending the notification
                     $noticeFees->AddNoticeFee( 
                        {
                            borrowernumber => $borrowernumber,
                            amount         => $fee,
                            letter_code    => $letter_code,
                            letter_date    => output_pref( { dt => dt_from_string, dateonly => 1 } ),
                            
                            # these are parameters that we need for fancy message printing
                            branchcode     => $letter_params{branchcode},
                            substitute     => { bib     => $library->{branchname}, 
                                                'count' => 1,
                                              },
                            tables        =>  $letter_params{tables}
                            
                         }
                     );
                }
            }
        }
    };

    if ( $to_address ) {
        &$send_notification('email', $borrowernumber, $letter_code);
    } else {
        &$send_notification('print', $borrowernumber, $letter_code);
    }
}

# shipping back the ILL item to the owning library
sub sendeZurueck {
    my ($self, $params) = @_;
    my $stage = $params->{other}->{stage};
    my $backend_result = {
        backend    => $self->name,
        method  => "sendeZurueck",
        stage   => $stage,    # default for testing the template
        error   => 0,
        status  => "",
        message => "",
        value   => {},
        next    => "illview",
    };
    $backend_result->{value}->{other}->{illshipbacklettercode} = C4::Context->preference("illShipBackLettercode");
    if ( $backend_result->{value}->{other}->{illshipbacklettercode} ) {
        $backend_result->{value}->{other}->{illshipbackslipprint} = 1;
    } else {
        $backend_result->{value}->{other}->{illshipbackslipprint} = 0;
    }

    $backend_result->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{biblio_id} = $params->{request}->biblio_id();
    $backend_result->{value}->{request}->{borrowernumber} = $params->{request}->borrowernumber();
    $backend_result->{value}->{other}->{type} = $params->{request}->medium();

    if (!$stage || $stage eq 'init') {
        $backend_result->{stage}  = "confirmcommit";
    } elsif ($stage eq 'storeandprint' || $stage eq 'commit') {

        # read relevant data from illrequestatributes
        my @interesting_fields = (
            'isbn',
            'issn',
            'itemnumber',
            'sendingIllLibraryBorrowernumber',
            'sendingIllLibraryIsil',
            'shelfmark',
            'title',
            'zflorderid'
        );

        my $fieldResults = $params->{request}->illrequestattributes->search(
            { type => {'-in' => \@interesting_fields}});
        my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
        foreach my $type (keys %{$illreqattr}) {
            $backend_result->{value}->{other}->{$type} = $illreqattr->{$type};
        }

        # finally delete biblio and items data
        #XXXWH delBiblioAndItem(scalar $params->{request}->biblio_id(), $backend_result->{value}->{other}->{itemnumber});

        # set illrequest.completed date to today
        $params->{request}->completed(output_pref( { dt => dt_from_string, dateformat => 'iso' } ));
        $params->{request}->status('COMP')->store;

        $backend_result->{value}->{request} = $params->{request};
        $backend_result->{value}->{other}->{illshipbackslipprint} = $params->{other}->{illshipbackslipprint};

    } else {
        # in case of faulty or testing stage, we just return the standard $backend_result with original stage
        $backend_result->{stage} = $stage;
    }

    return $backend_result;
}

# display a dialog that explains how to mark an ILL item as lost
sub bucheVerlust {
    my ($self, $params) = @_;
    my $stage = $params->{other}->{stage};
    my $backend_result = {
        backend    => $self->name,
        method  => "bucheVerlust",
        stage   => $stage,    # default for testing the template
        error   => 0,
        status  => "",
        message => "",
        value   => {},
        next    => "illview",
    };

    $backend_result->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{biblio_id} = $params->{request}->biblio_id();
    $backend_result->{value}->{request}->{borrowernumber} = $params->{request}->borrowernumber();
    $backend_result->{value}->{other}->{type} = $params->{request}->medium();

    return $backend_result;
}

# if the ILL item is lost, display a dialog that enables a message to the owning library (and the orderer) that the item can not be shipped back
sub meldeVerlust {
    my ($self, $params) = @_;
    my $stage = $params->{other}->{stage};
    my $backend_result = {
        backend    => $self->name,
        method  => "meldeVerlust",
        stage   => $stage,    # default for testing the template
        error   => 0,
        status  => "",
        message => "",
        value   => {},
        next    => "illview",
    };

    $backend_result->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{biblio_id} = $params->{request}->biblio_id();
    $backend_result->{value}->{request}->{borrowernumber} = $params->{request}->borrowernumber();
    $backend_result->{value}->{other}->{type} = $params->{request}->medium();

    if (!$stage || $stage eq 'init') {
        $backend_result->{stage}  = "confirmcommit";

        # information for the owning library that the ordered ILL medium has been lost (e.g. with letter.code ILLSLNP_LOSTITEM_LIBRARY) if configured (syspref ILLItemLostLibraryLettercode)
        $backend_result->{value}->{other}->{illitemlostlibrarylettercode} = C4::Context->preference("illItemLostLibraryLettercode");
        if ( $backend_result->{value}->{other}->{illitemlostlibrarylettercode} ) {
            $backend_result->{value}->{other}->{illitemlostlibraryletterprint} = 1;
        } else {
            $backend_result->{value}->{other}->{illitemlostlibraryletterprint} = 0;
        }

        # information for the borrower that the ordered ILL medium has been lost before check out (e.g. with letter.code ILLSLNP_LOSTITEM_BORROWER) if configured (syspref ILLItemLostBorrowerLettercode)
        $backend_result->{value}->{other}->{illitemlostborrowerlettercode} = C4::Context->preference("illItemLostBorrowerLettercode");
        if ( $backend_result->{value}->{other}->{illitemlostborrowerlettercode} ) {
            $backend_result->{value}->{other}->{illitemlostborrowerletterprint} = 1;
        } else {
            $backend_result->{value}->{other}->{illitemlostborrowerletterprint} = 0;
        }

        # read relevant data from illrequestatributes
        my @interesting_fields = (
            'itemnumber',
            'sendingIllLibraryBorrowernumber'
        );

        my $fieldResults = $params->{request}->illrequestattributes->search(
            { type => {'-in' => \@interesting_fields}});
        my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
        foreach my $type (keys %{$illreqattr}) {
            $backend_result->{value}->{other}->{$type} = $illreqattr->{$type};
        }

    } elsif ($stage eq 'confirmcommit') {
        $backend_result->{value}->{other}->{illitemlostlibrarylettercode} = $params->{other}->{illitemlostlibrarylettercode};
        $backend_result->{value}->{other}->{illitemlostlibraryletterprint} = $params->{other}->{illitemlostlibraryletterprint};
        $backend_result->{value}->{other}->{illitemlostborrowerlettercode} = $params->{other}->{illitemlostborrowerlettercode};
        $backend_result->{value}->{other}->{illitemlostborrowerletterprint} = $params->{other}->{illitemlostborrowerletterprint};
        $backend_result->{value}->{other}->{itemnumber} = $params->{other}->{itemnumber};
        $backend_result->{value}->{other}->{sendingIllLibraryBorrowernumber} = $params->{other}->{sendingIllLibraryBorrowernumber};

        # send information to the owning library that the ordered ILL medium has been lost (after delivery, before shipping back)
        if ( $params->{other}->{illitemlostlibraryletterprint} &&
             $params->{other}->{illitemlostlibrarylettercode} && length($params->{other}->{illitemlostlibrarylettercode}) ) {
            my $fieldResults = $params->{request}->illrequestattributes->search();
            my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
            &printIllNoticeSlnp($params->{request}->branchcode(), $params->{other}->{sendingIllLibraryBorrowernumber}, undef, undef, $params->{request}->illrequest_id(), $illreqattr, $params->{request}->borrowernumber(), $params->{other}->{illitemlostlibrarylettercode} );
        }

        if ( $params->{request}->status() eq 'LOSTBCO' ) {
            # send information to the borrower about the denied delivery of the ordered ILL medium (because it has been lost before check out)
            if ( $params->{other}->{illitemlostborrowerletterprint} &&
                 $params->{other}->{illitemlostborrowerlettercode} && length($params->{other}->{illitemlostborrowerlettercode}) ) {
                my $fieldResults = $params->{request}->illrequestattributes->search();
                my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
                &printIllNoticeSlnp($params->{request}->branchcode(), $params->{request}->borrowernumber(), undef, undef, $params->{request}->illrequest_id(), $illreqattr, $params->{other}->{sendingIllLibraryBorrowernumber}, $params->{other}->{illitemlostborrowerlettercode} );
            }
        }
        
        # Finally delete biblio and items data, but only if not stored in DB table issues any more.
        # try to etrieve the issue
        my $issue = Koha::Checkouts->find( { itemnumber => $params->{other}->{itemnumber} } );
        if ( ! $issue ) {
            delBiblioAndItem($params->{request}->biblio_id(), $params->{other}->{itemnumber});
        }

        # set illrequest.completed date to today
        $params->{request}->completed(output_pref( { dt => dt_from_string, dateformat => 'iso' } ));
        $params->{request}->status('COMP')->store;

        $backend_result->{value}->{request} = $params->{request};
        $backend_result->{stage} = 'commit';

    } else {
        # in case of faulty or testing stage, we just return the standard $backend_result with original stage
        $backend_result->{stage} = $stage;
    }

    return $backend_result;
}

# Handles the cancellation of the ordering borrower before the ILL item is received.
# If the borrower cancels his order after receipt of the ILL item in the library (before checkout), the sendeZurueck() method is used
sub storniereFuerBenutzer {
    my ($self, $params) = @_;
    my $stage = $params->{other}->{stage};
    my $backend_result = {
        backend    => $self->name,
        method  => "storniereFuerBenutzer",
        stage   => $stage,    # default for testing the template
        error   => 0,
        status  => "",
        message => "",
        value   => {},
        next    => "illview",
    };
    $backend_result->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{biblio_id} = $params->{request}->biblio_id();
    $backend_result->{value}->{request}->{borrowernumber} = $params->{request}->borrowernumber();
    $backend_result->{value}->{other}->{type} = $params->{request}->medium();

    if (!$stage || $stage eq 'init') {
        $backend_result->{stage}  = "confirmcommit";

    } elsif ($stage eq 'commit' || $stage eq 'confirmcommit') {
        
        # read relevant data from illrequestatributes
        my @interesting_fields = (
            'itemnumber',
            'author',
            'title'
        );

        my $fieldResults = $params->{request}->illrequestattributes->search(
            { type => {'-in' => \@interesting_fields}});
        my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
        foreach my $type (keys %{$illreqattr}) {
            $backend_result->{value}->{other}->{$type} = $illreqattr->{$type};
        }

        if ( $params->{other}->{alreadyShipped} eq 'alreadyShippedYes' ) {
            $params->{request}->status('CNCLDFU')->store;
        } else {
            # finally delete biblio and items data
            delBiblioAndItem(scalar $params->{request}->biblio_id(), $backend_result->{value}->{other}->{itemnumber});

            # set illrequest.completed date to today
            $params->{request}->completed(output_pref( { dt => dt_from_string, dateformat => 'iso' } ));
            $params->{request}->status('COMP')->store;
        }
        $backend_result->{value}->{request} = $params->{request};

    } else {
        # in case of faulty or testing stage, we just return the standard $backend_result with original stage
        $backend_result->{stage} = $stage;
    }

    return $backend_result;
}

# This method is used when the owning library denies the delivery of the ILL item
sub kennzeichneNegativ {
    my ($self, $params) = @_;
    my $stage = $params->{other}->{stage};
    my $backend_result = {
        backend    => $self->name,
        method  => "kennzeichneNegativ",
        stage   => $stage,    # default for testing the template
        error   => 0,
        status  => "",
        message => "",
        value   => {},
        next    => "illview",
    };

    my $illNotDeliveredLetterCode = C4::Context->preference("ILLNotDeliveredLettercode");
    $backend_result->{value}->{other}->{illnotdeliveredlettercode} = $illNotDeliveredLetterCode;
    if ( $backend_result->{value}->{other}->{illnotdeliveredlettercode} && $params->{request}->status() ne 'CNCLDFU' ) {
        $backend_result->{value}->{other}->{illnotdeliveredletterprint} = 1;
    } else {
        $backend_result->{value}->{other}->{illnotdeliveredletterprint} = 0;
    }

    $backend_result->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{illrequest_id} = $params->{request}->illrequest_id;
    $backend_result->{value}->{request}->{biblio_id} = $params->{request}->biblio_id();
    $backend_result->{value}->{request}->{borrowernumber} = $params->{request}->borrowernumber();
    $backend_result->{value}->{other}->{type} = $params->{request}->medium();

    if (!$stage || $stage eq 'init') {
        $backend_result->{stage}  = "confirmcommit";

    } elsif ($stage eq 'commit' || $stage eq 'confirmcommit') {
        $backend_result->{value}->{other}->{illnotdeliveredletterprint} = $params->{other}->{illnotdeliveredletterprint};

        # read relevant data from illrequestatributes
        my @interesting_fields = (
            'itemnumber',
            'author',
            'title'
        );

        my $fieldResults = $params->{request}->illrequestattributes->search(
            { type => {'-in' => \@interesting_fields}});
        my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
        foreach my $type (keys %{$illreqattr}) {
            $backend_result->{value}->{other}->{$type} = $illreqattr->{$type};
        }

        if ( $params->{request}->borrowernumber() && $params->{other}->{illnotdeliveredletterprint} eq '1' ) {
            # send information to the borrower about the denied delivery of the ordered ILL medium (e.g. with letter.code ILLSLNP_NOT_DELIVERED) if configured (syspref ILLNotDeliveredLettercode)
            if ( $illNotDeliveredLetterCode && length($illNotDeliveredLetterCode) ) {
                my $fieldResults = $params->{request}->illrequestattributes->search();
                my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
                &printIllNoticeSlnp($params->{request}->branchcode(), $params->{request}->borrowernumber(), undef, undef, $params->{request}->illrequest_id(), $illreqattr, 0, $illNotDeliveredLetterCode );
            }
        }


        # finally delete biblio and items data
        delBiblioAndItem(scalar $params->{request}->biblio_id(), $backend_result->{value}->{other}->{itemnumber});

        # set illrequest.completed date to today
        $params->{request}->completed(output_pref( { dt => dt_from_string, dateformat => 'iso' } ));
        $params->{request}->status('COMP')->store;

        $backend_result->{value}->{request} = $params->{request};

    } else {
        # in case of faulty or testing stage, we just return the standard $backend_result with original stage
        $backend_result->{stage} = $stage;
    }

    return $backend_result;
}

# deletes biblio and item data of the ILL item from the database, normally if illrequests.status is set to 'COMP'
sub delBiblioAndItem {
    my ($biblionumber, $itemnumber) = @_;
    my $holds = Koha::Holds->search({ itemnumber => $itemnumber });
    if ( $holds ) {
        $holds->delete();
    }
    my $res = C4::Items::DelItemCheck( $biblionumber, $itemnumber );
    my $error;
    if ( $res eq '1' ) {
        $error = &DelBiblio($biblionumber);
    }
    if ( $res ne '1' || $error) {
        warn "ERROR when deleting ILL title $biblionumber ($error) or ILL item $itemnumber ($res)";
        print "Content-Type: text/html\n\n<html><body><h4>ERROR when deleting ILL title $biblionumber (error:$error) <br />or when deleting ILL item $itemnumber (res:$res)</h4></body></html>";
        exit;
    }
}

=head3 slnp2biblio

    my $biblionumber = $slnp_backend->slnp2biblio($params->{other});

Create a basic biblio record for the passed SLNP API request

=cut

sub slnp2biblio {
    my ($self, $other) = @_;

    # We're going to try and populate author, title, etc.
    my $author = $other->{attributes}->{author};
    my $title  = $other->{attributes}->{title};
    my $isbn   = $other->{attributes}->{isbn};
    my $issn   = $other->{attributes}->{issn};

    # Create the MARC::Record object and populate it
    my $marcrecord = MARC::Record->new();
    $marcrecord->MARC::Record::encoding( 'UTF-8' );

    if ( $isbn && length($isbn) > 0 ) {
        my $marc_isbn = MARC::Field->new('020',' ',' ','a' => $isbn);
        $marcrecord->insert_fields_ordered($marc_isbn);
    }
    if ( $issn && length($issn) > 0 ) {
        my $marc_issn = MARC::Field->new('022',' ',' ','a' => $issn);
        $marcrecord->insert_fields_ordered($marc_issn);
    }
    if ($author) {
        my $marc_author = MARC::Field->new('100', '1', '', 'a' => $author);
        $marcrecord->insert_fields_ordered($marc_author);
    }
    my $marc_field245;
    if ( defined($title) && length($title) > 0 ) {
        $marc_field245 = MARC::Field->new('245','0','0','a' => $title);
    }
    if ( defined($author) && length($author) > 0 ) {
        if ( !defined($marc_field245) ) {
            $marc_field245 = MARC::Field->new('245','0','0','c' => $author);
        } else {
            $marc_field245->add_subfields('c' => $author);
        }
    }
    if ( defined($marc_field245) ) {
        $marcrecord->insert_fields_ordered($marc_field245);
    }

    # set opac display suppression flag of the record
    my $marc_field942 = MARC::Field->new('942', '', '', n => '1');
    $marcrecord->append_fields($marc_field942);

    # We use a minimal framework named 'ILLSLNP', which needs to be created beforehand.
    my $biblionumber = AddBiblio($marcrecord, $self->{framework});

    return $biblionumber;
}

=head3 slnp2items

    my $itemnumber = $slnp_backend->slnp2items($params->{other}, $biblionumber, {});

Create or update a basic items record from the sent SLNPFLCommand data

=cut

sub slnp2items {
    my ($self, $params, $biblionumber, $itemfieldsvals) = @_;
    my ($biblionumberItem, $biblioitemnumberItem, $itemnumberItem) = (undef,undef,undef);
    if ( ! keys %{$itemfieldsvals} )    # create items record
    {
        my $item_hash;
        $item_hash->{homebranch} = $params->{request}->branchcode();
        $item_hash->{notforloan} = -1;     # 'ordered'
        my $itemcallnumber = 'Fernleihe ' . $params->{other}->{attributes}->{shelfmark};
        $item_hash->{itemcallnumber} = $itemcallnumber;
        $item_hash->{itemnotes} = scalar $params->{other}->{attributes}->{info};
        $item_hash->{itemnotes_nonpublic} = scalar $params->{other}->{attributes}->{notes};
        $item_hash->{holdingbranch} = $params->{request}->branchcode();
        $item_hash->{itype} = 'Fernleihe';    # dummy initialisation
        my @illItemtypes = split( /\|/, C4::Context->preference("IllItemtypes") );
        foreach my $it (@illItemtypes) {
            my $rs = Koha::ItemTypes->search({itemtype => $it});
            if ( my $itres = $rs->next ) {
                $item_hash->{itype} = $itres->itemtype;
                last;
            }
        }
            
        # finally add the next items record
        ( $biblionumberItem, $biblioitemnumberItem, $itemnumberItem ) = C4::Items::AddItem($item_hash, $biblionumber);
    } else {    # update items record
            $itemnumberItem = scalar $params->{other}->{attributes}->{itemnumber};
            my $itemrs = Koha::Items->find({ itemnumber => $itemnumberItem });
            $itemrs->update($itemfieldsvals);
    }

    return $itemnumberItem;
}

=head3 _validate_borrower
    my ( $brw_count, $brw ) = _validate_borrower($params->{other}->{attributes}->{'cardnumber'});

Try to read the borrowers record using the cardnumber field.
=cut

sub _validate_borrower {
    # Perform cardnumber search.
    # Return ( 0, undef ), ( 1, $brw ) or ( n, $brws )
    my ( $sel_cardnumber ) = @_;
    my $patrons = Koha::Patrons->new;
    my ( $count, $brw );
    my $query = { cardnumber => $sel_cardnumber };

    my $brws = $patrons->search( $query );
    $count = $brws->count;
    if ( $count == 1 ) {
        $brw = $brws->next;
    } else {
        $brw = $brws;           # found multiple results, should never happen
    }
    return ( $count, $brw );
}


# methods that are called by the Koha application via the ILL framework, but not exclusively by the framework

sub isShippingBackRequired {
    my ($self, $request) = @_;
    my $shippingBackRequired = 1;

    if ( $request->medium() eq 'Article' ) {
        $shippingBackRequired = 0;
    }
    return $shippingBackRequired;
}

# e.g. my $$illreqattr = $illrequest->_backend_capability( "getIllrequestattributes", [ $illrequest, ["", ""]] );
sub getIllrequestattributes {    # does work
    my ($self, $args) = @_;
    my $result;
    my ($request, $interesting_fields) = ($args->[0], $args->[1]);

    my $fieldResults = $request->illrequestattributes->search(
        { type => {'-in' => $interesting_fields}});
    my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
    foreach my $type (keys %{$illreqattr}) {
        $result->{$type} = $illreqattr->{$type};
    }
    return $result;
}

sub getIllrequestDateDue {
    my ($self, $request) = @_;
    my $result;

    my $fieldResults = $request->illrequestattributes->search(
        { type => "duedate" } );
    my $illreqattr = { map { ( $_->type => $_->value ) } ($fieldResults->as_list) };
    foreach my $type (keys %{$illreqattr}) {
        $result->{$type} = $illreqattr->{$type};
    }
    return $result->{duedate};
}

sub itemCheckedOut {
    my ($self, $request) = @_;
    $request->status('CHKDOUT')->store;
}

sub itemCheckedIn {
    my ($self, $request) = @_;
    $request->status('CHKDIN')->store;

    # if it is an article, then use this action to transfer the status to completed
    if ( $request->medium() eq 'Article' ) {
        my $params = {};
        $params->{request} = $request;
        $params->{other} = {};
        $params->{other}->{stage} = 'commit';
        $self->sendeZurueck($params);
    }
}

sub itemLost {
    my ($self, $request) = @_;
    if ( $request->status() eq 'REQ' ) {    # ILL receipt booking required before item can be set to lost
        my $illrequest_id = $request->illrequest_id();
        my $orderid = $request->orderid();
        warn "ERROR when setting lost status of an ILL item. The receipt of the ILL request having order ID:$orderid has to be executed by you before this can be done.";
        print "Content-Type: text/html\n\n<html><body><h4>ERROR when setting lost status of an ILL item. Please execute the receipt of the ILL request having order ID <a href=\"/cgi-bin/koha/ill/ill-requests.pl?method=illview&amp;illrequest_id=$illrequest_id\" target=\"_blank\" >$orderid</a> prior to this item update.</h4></body></html>";
        exit;
    } elsif ( $request->status() eq 'RECVD' || $request->status() eq 'RECVDUPD' ) {
        $request->status('LOSTBCO')->store;    # item lost after receipt but before checkout
    } else {
        $request->status('LOSTACO')->store;    # item lost after checkout
    }
}

sub isReserveFeeAcceptable {
    my ($self, $request) = @_;
    my $ret = 0;    # an additional hold fee is not acceptable for the ILLSLNPKoha backend (maybe configurable in the future)

    return $ret
}

# function that defines for the backend the sequence of action buttons in the GUI
# e.g. my $sortActionIsImplemented = $illrequest->_backend_capability( "sortAction", ["", ""] );
# e.g. foreach my $actionId (sort { $illrequest->_backend_capability( "sortAction", [$a, $b] )} keys %available_actions_hash) { ...
sub sortAction {
    my ($self, $statusId_A_B) = @_;
    my $ret = 0;

    my $statusPrio = {
        'REQ' => 1,
        'RECVD' => 2,
        'RECVDUPD' => 3,
        'CHKDOUT' => 4,
        'CHKDIN' => 5,
        'SNTBCK' => 6,
        'NEGFLAG' => 7,
        'CNCLDFU' => 8,
        'LOSTHOWTO' => 9,
        'LOSTBCO' => 10,
        'LOSTACO' => 11,
        'LOST' => 12,
        'COMP' => 13,
    };

    if ( defined $statusId_A_B && defined $statusId_A_B->[0] && defined $statusId_A_B->[1] ) {
        # pseudo arguments '' for checking if this backend function is implemented
        if ( $statusId_A_B->[0] eq '' && $statusId_A_B->[1] eq '' ) {
            $ret = 1;
        } else {
            my $statusPrioA = defined $statusPrio->{$statusId_A_B->[0]} ? $statusPrio->{$statusId_A_B->[0]} : 0;
            my $statusPrioB = defined $statusPrio->{$statusId_A_B->[1]} ? $statusPrio->{$statusId_A_B->[1]} : 0;
            $ret = ($statusPrioA == $statusPrioB ? 0 : ($statusPrioA+0 < $statusPrioB+0 ? -1 : 1));
        }
    }

    return $ret;
}

1;
