#!/usr/bin/perl

# Copyright 2018-2019 (C) LMSCloud GmbH

use strict;
use warnings;
use utf8;

# get the local directory
use FindBin '$Bin';

# include the lib subdirectory
use lib "$Bin/../lib";

use lib::ILLZFLServerKoha;

print STDERR "runILLZFLServerKoha: Start; ARGV[0]:$ARGV[0]: INC:@INC:\n";

lib::ILLZFLServerKoha->run(

    conf_file    => $ARGV[0]

#    port       => 9001,
#    ipv        => '*',
#    host       => "127.0.0.1",
#    user       => "wallenheim-koha",
#    group      => "wallenheim-koha",
#    log_file   => "/var/log/koha/wallenheim/ILLZFLServerKoha.log",
#    log_level  => 3,
#    pid_file   => "/var/run/koha/wallenheim/ILLZFLServerKoha.pid"
);

1;
