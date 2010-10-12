package Cache::KyotoTycoon;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.06';
use Cache::KyotoTycoon::Cursor;
use TSVRPC::Client;

my %STATUS_CODE = (
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',                      # RFC 2518 (WebDAV)
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-Status',                    # RFC 2518 (WebDAV)
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    307 => 'Temporary Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Large',
    415 => 'Unsupported Media Type',
    416 => 'Request Range Not Satisfiable',
    417 => 'Expectation Failed',
    422 => 'Unprocessable Entity',            # RFC 2518 (WebDAV)
    423 => 'Locked',                          # RFC 2518 (WebDAV)
    424 => 'Failed Dependency',               # RFC 2518 (WebDAV)
    425 => 'No code',                         # WebDAV Advanced Collections
    426 => 'Upgrade Required',                # RFC 2817
    449 => 'Retry with',                      # unofficial Microsoft
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
    506 => 'Variant Also Negotiates',         # RFC 2295
    507 => 'Insufficient Storage',            # RFC 2518 (WebDAV)
    509 => 'Bandwidth Limit Exceeded',        # unofficial
    510 => 'Not Extended',                    # RFC 2774
);

sub _errmsg {
    my $code = shift;
    my $msg = $STATUS_CODE{$code} || 'Unknown';
    return "Cache::KyotoTycoon unexpected response code: $code $msg";
}

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    my $host = $args{host} || '127.0.0.1';
    my $port = $args{port} || 1978;
    my $base = "http://${host}:${port}/rpc/";
    my $client = TSVRPC::Client->new(
        timeout    => exists( $args{timeout} ) ? $args{timeout} : 1,
        base       => $base,
    );
    my $self = bless {
        db        => 0,
        client    => $client,
    }, $class;
    return $self;
}

sub db {
    my $self = shift;
    $self->{db} = shift if @_;
    $self->{db};
}

sub make_cursor {
    my ($self, $cursor_id) = @_;
    return Cache::KyotoTycoon::Cursor->new($cursor_id, $self->{db}, $self->{client});
}

sub echo {
    my ($self, $args) = @_;
    my ($code, $body) = $self->{client}->call('echo', $args);
    die _errmsg($code) if $code ne 200;
    return $body;
}

sub report {
    my ($self, ) = @_;
    my ($code, $body) = $self->{client}->call('report');
    die _errmsg($code) if $code ne 200;
    return $body;
}

sub play_script { die "play_script: not implemented yet" }

sub status {
    my ($self, ) = @_;
    my ($code, $body) = $self->{client}->call('status', {DB => $self->db});
    die _errmsg($code) unless $code eq 200;
    return $body;
}

sub clear {
    my ($self, ) = @_;
    my %args = (DB => $self->db);
    my ($code, $body) = $self->{client}->call('clear', \%args);
    die _errmsg($code) unless $code eq 200;
    return;
}

sub synchronize {
    my ($self, $hard, $command) = @_;
    my %args = (DB => $self->db);
    $args{hard} = $hard if $hard;
    $args{command} = $command if defined $command;
    my ($code, $body) = $self->{client}->call('synchronize', \%args);
    return 1 if $code eq 200;
    return 0 if $code eq 450;
    die _errmsg($code);
}

sub set {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('set', \%args);
    die _errmsg($code) unless $code eq 200;
    return;
}

sub add {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('add', \%args);
    return 1 if $code eq '200';
    return 0 if $code eq '450';
    die _errmsg($code);
}

sub replace {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('replace', \%args);
    return 1 if $code eq '200';
    return 0 if $code eq '450';
    die _errmsg($code);
}

sub append {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('append', \%args);
    die _errmsg($code) unless $code eq '200';
    return;
}

sub increment {
    my ($self, $key, $num, $xt) = @_;
    my %args = (DB => $self->db, key => $key, num => $num);
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('increment', \%args);
    die _errmsg($code) unless $code eq '200';
    return $body->{num};
}

sub increment_double {
    my ($self, $key, $num, $xt) = @_;
    my %args = (DB => $self->db, key => $key, num => $num);
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('increment_double', \%args);
    die _errmsg($code) unless $code eq '200';
    return $body->{num};
}

sub cas {
    my ($self, $key, $oval, $nval, $xt) = @_;
    my %args = (DB => $self->db, key => $key);
    $args{oval} = $oval if defined $oval;
    $args{nval} = $nval if defined $nval;
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('cas', \%args);
    return 1 if $code eq '200';
    return 0 if $code eq '450';
    die _errmsg($code);
}

sub remove {
    my ($self, $key) = @_;
    my %args = (DB => $self->db, key => $key);
    my ($code, $body) = $self->{client}->call('remove', \%args);
    return 1 if $code eq '200';
    return 0 if $code eq '450';
    die _errmsg($code);
}

sub get {
    my ($self, $key) = @_;
    my %args = (DB => $self->db, key => $key);
    my ($code, $body) = $self->{client}->call('get', \%args);
    if ($code eq 450) {
        return undef; # no value for key
    } elsif ($code eq 200) {
        return $body->{value};
    } else {
        die _errmsg($code);
    }
}

sub set_bulk {
    my ($self, $vals, $xt) = @_;
    my %args = (DB => $self->db);
    while (my ($k, $v) = each %$vals) {
        $args{"_$k"} = $v;
    }
    $args{xt} = $xt if defined $xt;
    my ($code, $body) = $self->{client}->call('set_bulk', \%args);
    die _errmsg($code) unless $code eq '200';
    return $body->{num};
}

sub remove_bulk {
    my ($self, $keys) = @_;
    my %args = (DB => $self->db);
    for my $k (@$keys) {
        $args{"_$k"} = '';
    }
    my ($code, $body) = $self->{client}->call('remove_bulk', \%args);
    die _errmsg($code) unless $code eq '200';
    return $body->{num};
}

sub get_bulk {
    my ($self, $keys) = @_;
    my %args = (DB => $self->db);
    for my $k (@$keys) {
        $args{"_$k"} = '';
    }
    my ($code, $body) = $self->{client}->call('get_bulk', \%args);
    die _errmsg($code) unless $code eq '200';
    my %ret;
    while (my ($k, $v) = each %$body) {
        if ($k =~ /^_(.+)$/) {
            $ret{$1} = $v;
        }
    }
    die "fatal error" unless keys(%ret) == $body->{num};
    return wantarray ? %ret : \%ret;
}

1;
__END__

=encoding utf8

=head1 NAME

Cache::KyotoTycoon - KyotoTycoon client library

=head1 SYNOPSIS

    use KyotoTycoon;

    my $kt = KyotoTycoon->new(host => '127.0.0.1', port => 1978);
    $kt->set('foo' => bar');
    $kt->get('foo'); # => 'bar'

=head1 DESCRIPTION

KyotoTycoon.pm is L<KyotoTycoon|http://fallabs.com/kyototycoon/> client library for Perl5.

B<THIS MODULE IS IN ITS BETA QUALITY. THE API MAY CHANGE IN THE FUTURE>.

=head1 ERROR HANDLING POLICY

This module throws exception if got B<Server Error>.

=head1 CONSTRUCTOR OPTIONS

=over 4

=item timeout

Timeout value for each request in seconds.

I<Default>: 1 second

=item host

Host name of server machine.

I<Default>: '127.0.0.1'

=item port

Port number of server process. 

I<Default>: 1978 

=item db

DB name or id.

I<Default>: 0

=back

=head1 METHODS

=over 4

=item $kt->db()

Getter/Setter of DB name/id.

=item my $cursor: KyotoTycoon::Cursor = $kt->make_cursor($cursor_number: Int);

Create new cursor object. This method returns instance of L<KyotoTycoon::Cursor>.

=item my $res = $kt->echo($args)

The server returns $args. This method is useful for testing server.

$args is hashref.

I<Return>: the copy of $args.

=item $kt->report()

Get server report.

I<Return>: server status information in hashref.

=item $kt->play_script

I<Not Implemented Yet>.

=item my $info = $kt->status()

Get database status information.

I<Return>: database status information in hashref.

=item $kt->clear()

Remove all elements for the storage.

I<Return>: Not a useful value.

=item $kt->synchronize($hard:Bool, $command);

Synchronize database with file system.

I<$hard>: call fsync() or not.

I<$command>: call $command in synchronization state.

I<Return>: 1 if succeeded, 0 if $command returns false.

=item $kt->set($key, $value, $xt);

Store I<$value> to I<$key>.

I<$xt>: expiration time. If $xt>0, expiration time in seconds from now. If $xt<0, the epoch time. It is never remove if missing $xt.

I<Return>: not a useful value.

=item my $ret = $kt->add($key, $value, $xt);

Store record. This method is not store if the I<$key> is already in the database.

I<$xt>: expiration time. If $xt>0, expiration time in seconds from now. If $xt<0, the epoch time. It is never remove if missing $xt.

I<Return>: 1 if succeeded. 0 if $key is already in the db.

=item my $ret = $kt->replace($key, $value, $xt);

Store the record, ignore if the record is not exists in the database.

I<$xt>: expiration time. If $xt>0, expiration time in seconds from now. If $xt<0, the epoch time. It is never remove if missing $xt.

I<Return>: 1 if succeeded. 0 if $key is not exists in the database.

=item my $ret = $kt->append($key, $value, $xt);

Store the record, append the $value to existent record if already exists entry.

I<$xt>: expiration time. If $xt>0, expiration time in seconds from now. If $xt<0, the epoch time. It is never remove if missing $xt.

I<Return>: not useful value. 

=item my $ret = $kt->increment($key, $num, $xt);

I<$num>: incremental

I<Return>: value after increment. 

=item my $ret = $kt->increment_double($key, $num, $xt);

I<$num>: incremental

I<Return>: value after increment. 

=item my $ret = $kt->cas($key, $oval, $nval, $xt);

compare and swap.

I<Return>: 1 if succeeded, 0 if failed.

=item $kt->remove($key);

Remove I<$key> from database.

I<Return> 1 if removed, 0 if record does not exists.

=item my $val = $kt->get($key);

Get I<$key> from database.

I<Return>: the value from database. I<undef> if not exists in database.

=item $kt->set_bulk(\%values);

Store multiple values in one time.

I<Return>: not useful value.

=item $kt->remove_bulk(\@keys);

Remove multiple keys in one time.

I<Return>: not useful value.

=item my $hashref = $kt->get_bulk(\@keys);

Get multiple values in one time.

I<Return>: records in hashref.

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=over 4

=item L<KyotoTycoon|http://fallabs.com/kyototycoon/>

=item http://fallabs.com/mikio/tech/promenade.cgi?id=99

=back

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
