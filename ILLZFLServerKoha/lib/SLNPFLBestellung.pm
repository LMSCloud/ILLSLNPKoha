package lib::SLNPFLBestellung;

# Copyright 2018-2019 (C) LMSCLoud GmbH
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
use warnings;

use utf8;
use Try::Tiny;
use CGI::Carp;
use Data::Dumper;

use C4::Context;
use Koha::Illrequest;



sub doSLNPFLBestellung {
    my $cmd = shift;
    my ($params) = @_;

    my $schema = Koha::Database->new->schema;
    try {
    $schema->storage->txn_begin;


    # create an illrequests record and some illrequestattributes records from the sent title data using the Illbackend's methods

    if ( $cmd->{'req_valid'} == 1 ) {
        my $illrequest = Koha::Illrequest->new();
        my $slnp_illbackend = $illrequest->load_backend( "ILLSLNPKoha" ); # this is still $illrequest

        my $args;
        $args->{stage} = 'commit';

        # fields for table illrequests
        my @illDefaultBranch =split( /\|/, C4::Context->preference("ILLDefaultBranch") );
        $args->{'branchcode'} = $illDefaultBranch[0];
        if ( ( defined $params->{AufsatzAutor} && length($params->{AufsatzAutor}) ) ||
             ( defined $params->{AufsatzTitel} && length($params->{AufsatzTitel}) )    ) {
            $args->{'medium'} = "Article";
        } else {
            $args->{'medium'} = "Book";
        }
        $args->{'orderid'} = $params->{BestellId};

        # fields for table illrequestattributes
        $args->{attributes} = {
            'zflorderid' => $params->{BestellId},
            'cardnumber' => $params->{BenutzerNummer}, # backend->create() will search for borrowers.borrowernumber via cardnumber or userid
            'author' => $params->{Verfasser},
            'title' => $params->{Titel},
            'isbn' => $params->{Isbn},
            'issn' => $params->{Issn},
            'publisher' => $params->{Verlag},
            'publyear' => $params->{EJahr},
            'issue' => $params->{Auflage},
            'shelfmark' => $params->{Signatur},
            'info' => $params->{Info},
            'notes' => $params->{Bemerkung}
        };
        if ( defined $params->{AufsatzAutor} && length($params->{AufsatzAutor}) ) {
            $args->{attributes}->{article_author} = $params->{AufsatzAutor};
        };
        if ( defined $params->{AufsatzTitel} && length($params->{AufsatzTitel}) ) {
            $args->{attributes}->{article_title} = $params->{AufsatzTitel};
        };
        if ( defined $params->{Heft} && length($params->{Heft}) ) {
            $args->{attributes}->{issue} = $params->{Heft};
        };
        if ( defined $params->{Seitenangabe} && length($params->{Seitenangabe}) ) {
            $args->{attributes}->{article_pages} = $params->{Seitenangabe};
        };
        if ( defined $params->{AusgabeOrt} && length($params->{AusgabeOrt}) ) {
            $args->{attributes}->{pickUpLocation} = $params->{AusgabeOrt};
        };

        my $backend_result = $slnp_illbackend->backend_create($args);

        if ( $backend_result->{error} ne '0' || 
             !defined $backend_result->{value} || 
             !defined $backend_result->{value}->{request} || 
             !$backend_result->{value}->{request}->illrequest_id() || 
             !$backend_result->{value}->{request}->biblio_id() ) {
            $schema->storage->txn_rollback;
	        $cmd->{'req_valid'} = 0;
            if ( $backend_result->{status} eq "invalid_borrower" ) {
		        $cmd->{'err_type'} = 'PATRON_NOT_FOUND';
		        $cmd->{'err_text'} = "No patron found having cardnumber or userid '" . scalar $params->{BenutzerNummer} . "'.";
            } else {
	            $cmd->{'err_type'} = 'ILLREQUEST_NOT_CREATED';
	            $cmd->{'err_text'} = "The Koha illrequest for the title '" . scalar $params->{Titel} . "' could not be created. (" . scalar $backend_result->{status} . ' ' . scalar $backend_result->{message} . ")";
            }
        } else {
            $cmd->{'rsp_para'}->[0] = {
                'resp_pnam' => 'PFLNummer',
                'resp_pval' => $backend_result->{value}->{request}->illrequest_id()
            };
            $cmd->{'rsp_para'}->[1] = {
                'resp_pnam' => 'OKMsg',
                'resp_pval' => 'ILL request successfully inserted.'
            };

            $schema->storage->txn_commit;

            my $biblionumber = $backend_result->{value}->{request}->biblio_id();
            my @biblionumbers = ( $biblionumber );
            my $indexer = Koha::SearchEngine::Indexer->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
            printf STDERR ("doSLNPFLBestellung() is calling indexer->update_index() with biblionumbers:%s:\n", Dumper(@biblionumbers));
            try {
                $indexer->update_index( \@biblionumbers, undef );
            } catch {
                my $mess = sprintf("doSLNPFLBestellung(): Exception thrown by update_index:%s:, so the index has to be rebuilt manually!!!", $_[0]);
                printf STDERR ("%s:\n", $mess);
                carp "ILLSLNPKoha::ILLZFLServerKoha::lib::" . $mess . "\n";
            };
        }
    }
    } catch {
        my $exceptionThrown = $_;

        my $mess = sprintf("doSLNPFLBestellung(): Exception thrown:%s:, so the transaction has to be rolled back!!!", $_[0]);
        printf STDERR ("%s:\n", $mess);
        carp "ILLSLNPKoha::ILLZFLServerKoha::lib::" . $mess . "\n";
        printf STDERR ("doSLNPFLBestellung(): Exception thrown:%s:\n", Dumper($exceptionThrown) );

        $schema->storage->txn_rollback;
	    $cmd->{'req_valid'} = 0;
        $cmd->{'err_type'} = 'ILLREQUEST_NOT_CREATED';
        $cmd->{'err_text'} = "Exception thrown:" . $_[0] . ":";
    };

	return $cmd;
}

1;
