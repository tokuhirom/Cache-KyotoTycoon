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
__END__

=head1 NAME

TSVRPC::Client - TSV-RPC client library

=head1 SYNOPSIS

    use TSVRPC::Client;

    my $t = TSVRPC::Client->new(
        base    => 'http://localhost:1978/rpc/',
        agent   => "myagent",
        timeout => 1
    );
    $t->call('echo', {a => 'b'});

=head1 DESCRIPTION

The client library for TSV-RPC.

=head1 METHODS

=over 4

=item my $t = TSVRPC::Client->new();

Create new instance.

=over 4

=item base

The base TSV-RPC end point URL.

=item timeout

Timeout value for each request.

I<Default>: 1 second

=item agent

User-Agent value.

=back

=item $t->call($method, \%args);

Call the $method with \%args.

I<Return>: instance of L<TSVRPC::Response>.

=back

=head1 SEE ALSO

L<http://fallabs.com/mikio/tech/promenade.cgi?id=97>

