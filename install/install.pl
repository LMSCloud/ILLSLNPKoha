#!/usr/bin/perl

# Copyright 2020 (C) LMSCLoud GmbH
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


# include the default Koha lib directory
use lib '/usr/share/koha/lib/';

BEGIN {
	if (!
            ( exists($ENV{"KOHA_CONF"})
              && $ENV{"KOHA_CONF"} ne ''
              && -e $ENV{"KOHA_CONF"}
              && -f $ENV{"KOHA_CONF"}
              && -r $ENV{"KOHA_CONF"} ) )
    {
            die "Environment variable KOHA_CONF '" . $ENV{"KOHA_CONF"} . "' not set appropriately. Please set the the variable before running this script.";
    }
#    if ( exists($ENV{"MEMCACHED_NAMESPACE"}) ) {
#            delete $ENV{"MEMCACHED_NAMESPACE"};
#    }
#    if ( exists($ENV{"MEMCACHED_SERVERS"}) ) {
#            delete $ENV{"MEMCACHED_SERVERS"};
#    }
#    $|++;
}

use strict;
use warnings;

use C4::Context;
use utf8;
use Unicode::Normalize;



sub execute_sql_statement {
    my ($filename_in) = @_;
	my $dbh = C4::Context->dbh;

    printf("install.pl::execute_sql_statement(filename_in:%s:)\n", $filename_in );

    open(my $fh_in, "<", $filename_in)
	or die "Can't open $filename_in: $!";

    my $sql_stmnt = '';
    while ( <$fh_in> ) {
        my $line = $_;
        $sql_stmnt .= $line;
    }
    close($fh_in);

	my $sth = $dbh->prepare($sql_stmnt);

	my $res = $sth->execute;
	$sth->finish;
}

sub update_koha_conf {
    my ($filename_in, $backendname, $interlibrary_loans_block) = @_;
    my $filename_out = $filename_in;

    printf("install.pl::update_koha_conf(filename_in:%s: backendname:%s:)\n", $filename_in, $backendname );

    open(my $fh_in, "<", $filename_in)
	or die "Can't open for read: $filename_in: $!";

    my $inputtext = '';
    my $outputtext = '';
    while ( <$fh_in> ) {
        my $line = $_;
        $inputtext .= $line;
    }
    close($fh_in);

    if ( $inputtext =~ /(.*?<backends_available>)(.*?)(<\/backends_available>.*)/s ) {
        my $ba_pre = $1;
        my $ba = $2;
        my $ba_post = $3;
        my $backendnameAlreadyContained = 0;
        my @backendsAvail = split(/,/,$ba);
        foreach my $backendAvail (@backendsAvail) {
            if ( $backendname eq $backendAvail ) {
                $backendnameAlreadyContained = 1;
                last;
            }
        }
        if ( $backendnameAlreadyContained == 0 ) {
            if ( $ba ) {
                $ba .= ',' . $backendname;
            } else {
                $ba = $backendname;
            }
            $outputtext = $ba_pre . $ba . $ba_post;
        }
    } else {
        if ( $inputtext =~ /(.*?<backend_directory>.*?<\/backend_directory>\s*\n)(.*)/s ) {
            my $ba_pre = $1;
            my $ba_post = $2;
            my $ba = "     <backends_available>" . $backendname . "</backends_available>\n";
            $outputtext = $ba_pre . $ba . $ba_post;
        } else {
            if ( $inputtext =~ /(.*?<interlibrary_loans>\s*\n)(.*)/s ) {
                die "install.pl ERROR: could not insert the <backends_available> line into $filename_in. (Could not locate <backend_directory> line.)\n";
            } else {
                if ( $interlibrary_loans_block && $inputtext =~ /(.*?)(\n<\/config>\s*\n.*)/s ) {
                    my $interlibrary_loans_pre = $1;
                    my $interlibrary_loans_post = $2;
                    $outputtext = $interlibrary_loans_pre . $interlibrary_loans_block . $interlibrary_loans_post;
                } else {
                    die "install.pl ERROR: did not insert the <interlibrary_loans> block into $filename_in. (Could not locate </config> line. Or default value for <interlibrary_loans> block is not set.)\n";
                }
            }
        }
    }

    if ( $outputtext ) {
        # modification of KOHA_CONF file required
        printf("install.pl::update_koha_conf() is trying to modify %s.\n", $filename_out );
        open(my $fh_out, ">", $filename_out)
	        or die "Can't open for write: $filename_out: $!";
        printf $fh_out ("%s", $outputtext);
        close($fh_out);
    } else {
        printf("install.pl::update_koha_conf() does not need to modify %s.\n", $filename_out );
    }
}

sub update_log4perlconf {
    my ($filename_in, $backendname, $kohaInstanceName) = @_;
    my $filename_out = $filename_in;

    printf("install.pl::update_log4perlconf(filename_in:%s: backendname:%s: kohaInstanceName:%s:)\n", $filename_in, $backendname, $kohaInstanceName );

    open(my $fh_in, "<", $filename_in)
	or die "Can't open for read: $filename_in: $!";

    my $inputtext = '';
    my $outputtext = '';
    while ( <$fh_in> ) {
        my $line = $_;
        $inputtext .= $line;
    }
    close($fh_in);

    if ( ! ( $inputtext =~ /log4perl.logger.Koha.Illbackends.$backendname=/s ||
             $inputtext =~ /log4perl.logger.Koha.Illbackends.$backendname =/s  ) ) {
        $outputtext = $inputtext;
        $outputtext .= "\n";
        $outputtext .= "log4perl.logger.Koha.Illbackends.$backendname = INFO, $backendname\n";
        $outputtext .= "log4perl.appender.$backendname=Log::Log4perl::Appender::File\n";
        $outputtext .= "log4perl.appender.$backendname.filename=/var/log/koha/$kohaInstanceName/$backendname-error.log\n";
        $outputtext .= "log4perl.appender.$backendname.mode=append\n";
        $outputtext .= "log4perl.appender.$backendname.layout=PatternLayout\n";
        $outputtext .= "log4perl.appender.$backendname.layout.ConversionPattern=" . '[%d] [%p] %C::%m (line %L)%n' . "\n";
    }

    if ( $outputtext ) {
        # modification of log4perl configuration file required
        printf("install.pl::update_log4perlconf() is trying to modify %s.\n", $filename_out );
        open(my $fh_out, ">", $filename_out)
	        or die "Can't open for write: $filename_out: $!";
        printf $fh_out ("%s", $outputtext);
        close($fh_out);
    } else {
        printf("install.pl::update_log4perlconf() does not need to modify %s.\n", $filename_out );
    }
}

my $THIS_BACKEND_NAME = 'ILLSLNPKoha';
my $interlibrary_loans_block = "
 <interlibrary_loans>
     <!-- Path to where Illbackends are located on the system
          - This setting should normally not be touched -->
     <backend_directory>/usr/share/koha/lib/Koha/Illbackends</backend_directory>
     <backends_available>$THIS_BACKEND_NAME</backends_available>
     <!-- How should we treat staff comments?
          - hide: don't show in OPAC
          - show: show in OPAC -->
     <staff_request_comments>hide</staff_request_comments>
     <!-- How should we treat the reply_date field?
          - hide: don't show this field in the UI
          - any other string: show, with this label -->
     <reply_date>hide</reply_date>
     <!-- Where should digital ILLs be sent?
          - borrower: send it straight to the borrower email
          - branch: send the ILL to the branch email -->
     <digital_recipient>branch</digital_recipient>
     <!-- What patron category should we use for p2p ILL requests?
          - By default this is set to 'ILLLIBS' -->
     <partner_code>ILLLIBS</partner_code>
 </interlibrary_loans>
";

printf("install.pl for backend %s Start (KOHA_CONF:%s:)\n", $THIS_BACKEND_NAME, $ENV{"KOHA_CONF"});

&execute_sql_statement( 'insert_systempreferences.sql' );
&execute_sql_statement( 'insert_letter.sql' );
&update_koha_conf( $ENV{"KOHA_CONF"}, $THIS_BACKEND_NAME, $interlibrary_loans_block );

# TODO: The logging using log4perl is not yet implemented in ILLSLNPKoha (may be done as in ILLZKSHA, ILLZKSHP, ILLALV)
#my $kohaconfPath = join('/',(split(/\//,$ENV{"KOHA_CONF"}))[0..4]);
#my $kohaInstanceName = (split(/\//,$ENV{"KOHA_CONF"}))[4];
#&update_log4perlconf( $kohaconfPath . '/log4perl.conf', $THIS_BACKEND_NAME, $kohaInstanceName );

printf("install.pl End\n");

