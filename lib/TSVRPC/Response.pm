package TSVRPC::Response;
use strict;
use warnings;
use parent qw/Class::Accessor::Fast/;
use TSVRPC::Util;
use TSVRPC::Parser;

__PACKAGE__->mk_ro_accessors(qw/method response_encoding body code status_line/);

# do not call this method manually.
sub new {
    my ($class, $method, $code, $content_type, $content) = @_;
    my $res_encoding = TSVRPC::Util::parse_content_type( $content_type );
    my $body = defined($res_encoding) ? TSVRPC::Parser::decode_tsvrpc( $content, $res_encoding ) : undef;
    bless {
        body              => $body,
        response_encoding => $res_encoding,
        code              => $code,
        status_line       => $code,
    }, $class;
}

1;
__END__

=head1 NAME

TSVRPC::Response - response object of TSV-RPC

=head1 DESCRIPTION

TSV-RPC response object.

=head1 METHODS

=over 4

=item $res->method()

Get method name for TSV-RPC.

=item $res->response_encoding()

Get response encoding for TSV-RPC.

=item $res->body()

Response body in hashref.

=item $res->code()

HTTP Status code.

=item $res->status_line()

Get HTTP status line.

=back

