package TSVRPC::Response;
use strict;
use warnings;
use parent qw/Class::Accessor::Fast/;
use TSVRPC::Util;
use TSVRPC::Parser;

__PACKAGE__->mk_ro_accessors(qw/method response_encoding response body/);

sub new {
    my ($class, $method, $res) = @_;
    my $res_encoding = TSVRPC::Util::parse_content_type( $res->content_type );
    my $body = defined($res_encoding) ? TSVRPC::Parser::decode_tsvrpc( $res->content, $res_encoding ) : undef;
    bless {
        body              => $body,
        response          => $res,
        response_encoding => $res_encoding,
    }, $class;
}

sub code { $_[0]->response->code }
sub content { $_[0]->response->content }
sub status_line { $_[0]->response->status_line }

1;
