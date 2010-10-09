use strict;
use warnings;
use Test::More;
use KyotoTycoon;
use t::Util;

test_kt(
    sub {
        my $port = shift;
        my $kt = KyotoTycoon->new(port => $port);
        my $input = {foo => 'bar', 'hoge' => 'fuga'};
        my $got = $kt->echo($input);
        is_deeply($got, $input);
        done_testing;
    },
);

