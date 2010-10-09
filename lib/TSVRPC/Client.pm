package TSVRPC::Client;
use strict;
use warnings;
use 5.008001;
use LWP::UserAgent;
our $VERSION = '0.01';
use TSVRPC::Parser;
use TSVRPC::Util;
use TSVRPC::Response;

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    my $base = $args{base} or Carp::croak("missing argument named 'base' for rpc base url");
    $base .= '/' unless $base =~ m{/$};
    my $ua = LWP::UserAgent->new(
        timeout => exists( $args{timeout} ) ? $args{timeout} : 1,
        agent => $args{agent} || "$class/$VERSION",
        parse_head   => 0,
        keep_alive   => 1,
        max_redirect => 0,
    );
    return bless {ua => $ua, base => $base}, $class;
}

sub call {
    my ( $self, $method, $args ) = @_;
    my $content      = TSVRPC::Parser::encode_tsvrpc($args);
    my $req_encoding = 'U';
    my $req          = HTTP::Request->new(
        POST => $self->{base} . $method,
        [ 'Content-Type' => "text/tab-separated-values; colenc=$req_encoding" ],
        $content
    );
    my $res = $self->{ua}->request($req);
    return TSVRPC::Response->new($method, $res);
}

1;
