package KyotoTycoon::Cursor;
use strict;
use warnings;

# Do not call this method manually.
sub new {
    my ($class, $cursor_id, $db, $client) = @_;
    bless { db => $db, client => $client, cursor => $cursor_id }, $class;
}

sub jump {
    my ($self, $key) = @_;
    my %args = (DB => $self->{db}, CUR => $self->{cursor});
    $args{key} = $key if defined $key;
    my $res = $self->{client}->call('cur_jump', \%args);
    return 1 if $res->code eq 200;
    return 0 if $res->code eq 450;
    die $res->status_line;
}

sub jump_back {
    my ($self, $key) = @_;
    ...
}

sub step {
    my ($self, ) = @_;
    my %args = (CUR => $self->{cursor});
    my $res = $self->{client}->call('cur_step', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub step_back {
    my ($self, ) = @_;
    my %args = (CUR => $self->{cursor});
    my $res = $self->{client}->call('cur_step_back', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub set_value {
    my ($self, $value, $xt, $step) = @_;
    my %args = (CUR => $self->{cursor}, value => $value);
    $args{xt} = $xt if defined $xt;
    $args{step} = '' if defined $step;
    my $res = $self->{client}->call('cur_set_value', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub remove {
    my ($self,) = @_;
    my %args = (CUR => $self->{cursor});
    my $res = $self->{client}->call('cur_remove', \%args);
    return 1 if $res->code eq '200';
    return 0 if $res->code eq '450';
    die $res->status_line;
}

sub get_key {
    my ($self, $step) = @_;
    my %args = (CUR => $self->{cursor});
    $args{step} = '' if defined $step;
    my $res = $self->{client}->call('cur_get_key', \%args);
    return $res->body->{key} if $res->code eq '200';
    return if $res->code eq '450';
    die $res->status_line;
}

sub get_value {
    my ($self, $step) = @_;
    my %args = (CUR => $self->{cursor});
    $args{step} = '' if defined $step;
    my $res = $self->{client}->call('cur_get_value', \%args);
    return $res->body->{value} if $res->code eq '200';
    return if $res->code eq '450';
    die $res->status_line;
}

sub get {
    my ($self, $step) = @_;
    my %args = (CUR => $self->{cursor});
    $args{step} = '' if defined $step;
    my $res = $self->{client}->call('cur_get', \%args);
    return ($res->body->{key}, $res->body->{value}) if $res->code eq '200';
    return if $res->code eq '450';
    die $res->status_line;
}

sub delete {
    my ($self, ) = @_;
    my %args = (CUR => $self->{cursor});
    my $res = $self->{client}->call('cur_delete', \%args);
    return if $res->code eq '200';
    die $res->status_line;
}

1;
