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
        my $got = $kt->status();
        note Dumper($got);
        ok exists($got->{count});
        ok exists($got->{size});
        done_testing;
    },
);

