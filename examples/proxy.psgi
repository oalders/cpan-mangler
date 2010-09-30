#!/usr/bin/env perl

# start this script via:
# plackup examples/proxy.psgi

# this script only sets up the proxy 

use strict;
use warnings;

use Plack::App::Proxy;
use Plack::Builder;

my $app = builder {
    mount "/"    => builder {
        Plack::App::Proxy->new( remote => 'http://search.cpan.org/' )->to_app;
    };
};

$app;
