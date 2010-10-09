use strict;
use warnings;
use Test::More;
use KyotoTycoon;
use t::Util;
use Data::Dumper;

test_kt(
    sub {
        my $port = shift;
        my $kt = KyotoTycoon->new(port => $port);
        $kt->clear();
        ok 1;
        done_testing;
    },
);

