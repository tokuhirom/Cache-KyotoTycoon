package KyotoTycoon;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use Class::Accessor::Lite;
use KyotoTycoon::Cursor;
use LWP::UserAgent;
use TSVRPC::Client;

Class::Accessor::Lite->mk_accessors(qw/cursor db base ua/);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    my $host = $args{host} || '127.0.0.1';
    my $port = $args{port} || 1978;
    my $base = "http://${host}:${port}/rpc/";
    my $client = TSVRPC::Client->new(
        timeout    => defined( $args{timeout} ) ? $args{timeout} : 1,
        base       => $base,
    );
    my $self = bless {
        db        => 0,
        client    => $client,
    }, $class;
    return $self;
}

sub make_cursor {
    my ($self, $cursor_id) = @_;
    return KyotoTycoon::Cursor->new($cursor_id, $self->{db}, $self->{client});
}

sub echo {
    my ($self, $args) = @_;
    my $res = $self->{client}->call('echo', $args);
    die $res->status_line if $res->code ne 200;
    return $res->body;
}

sub report {
    my ($self, ) = @_;
    my $res = $self->{client}->call('report');
    die $res->status_line if $res->code ne 200;
    return $res->body;
}

sub play_script { die "play_script: not implemented yet" }

sub status {
    my ($self, ) = @_;
    my $res = $self->{client}->call('status', {DB => $self->db});
    die $res->status_line unless $res->code eq 200;
    return $res->body;
}

sub clear {
    my ($self, ) = @_;
    my %args = (DB => $self->db);
    my $res = $self->{client}->call('clear', \%args);
    die $res->status_line unless $res->code eq 200;
    return;
}

sub synchronize {
    my ($self, $hard, $command) = @_;
    my %args = (DB => $self->db);
    $args{hard} = $hard if defined $hard;
    $args{command} = $command if defined $command;
    my $res = $self->{client}->call('synchronize', \%args);
    die $res->status_line unless $res->code eq 200 || $res->code eq 450;
    return $res->body;
}

sub set {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('set', \%args);
    die $res->status_line unless $res->code eq 200;
    return;
}

sub add {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('add', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub replace {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('replace', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub append {
    my ($self, $key, $value, $xt) = @_;
    my %args = (DB => $self->db, key => $key, value => $value);
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('append', \%args);
    die $res->status_line unless $res->code eq '200';
    return;
}

sub increment {
    my ($self, $key, $num, $xt) = @_;
    my %args = (DB => $self->db, key => $key, num => $num);
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('increment', \%args);
    die $res->status_line unless $res->code eq '200';
    return $res->body->{num};
}

sub increment_double {
    my ($self, $key, $num, $xt) = @_;
    my %args = (DB => $self->db, key => $key, num => $num);
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('increment_double', \%args);
    die $res->status_line unless $res->code eq '200';
    return $res->body->{num};
}

sub cas {
    my ($self, $key, $oval, $nval, $xt) = @_;
    my %args = (DB => $self->db, key => $key);
    $args{oval} = $oval if defined $oval;
    $args{nval} = $nval if defined $nval;
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('cas', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub remove {
    my ($self, $key) = @_;
    my %args = (DB => $self->db, key => $key);
    my $res = $self->{client}->call('remove', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub get {
    my ($self, $key) = @_;
    my %args = (DB => $self->db, key => $key);
    my $res = $self->{client}->call('get', \%args);
    if ($res->code eq 450) {
        return undef; # no value for key
    } elsif ($res->code eq 200) {
        return $res->body->{value};
    } else {
        die $res->status_line;
    }
}

sub set_bulk {
    my ($self, $vals, $xt) = @_;
    my %args = (DB => $self->db);
    while (my ($k, $v) = each %$vals) {
        $args{"_$k"} = $v;
    }
    $args{xt} = $xt if defined $xt;
    my $res = $self->{client}->call('set_bulk', \%args);
    die $res->status_line unless $res->code eq '200';
    return $res->body->{num};
}

sub remove_bulk {
    my ($self, $keys) = @_;
    my %args = (DB => $self->db);
    for my $k (@$keys) {
        $args{"_$k"} = '';
    }
    my $res = $self->{client}->call('remove_bulk', \%args);
    die $res->status_line unless $res->code eq '200';
    return $res->body->{num};
}

sub get_bulk {
    my ($self, $keys) = @_;
    my %args = (DB => $self->db);
    for my $k (@$keys) {
        $args{"_$k"} = '';
    }
    my $res = $self->{client}->call('get_bulk', \%args);
    die $res->status_line unless $res->code eq '200';
    my $body = $res->body;
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

KyotoTycoon - KyotoTycoon client library

=head1 SYNOPSIS

    use KyotoTycoon;

    my $kt = KyotoTycoon->new(host => '127.0.0.1', port => 1978);
    $kt->set('foo' => bar');
    $kt->get('foo'); # => 'bar'

=head1 DESCRIPTION

KyotoTycoon is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
