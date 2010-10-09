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
        my $got = $kt->report();
        note Dumper($got);
        ok(keys(%$got) > 0);
        done_testing;
    },
);

