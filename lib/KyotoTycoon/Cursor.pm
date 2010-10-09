package KyotoTycoon::Cursor;
use strict;
use warnings;

sub new {
    my ($class, $cursor_id, $db) = @_;
    bless { db => $db, cursor => $cursor_id }, $class;
}

sub jump {
    my ($self, $key) = @_;
    ...
}

sub jump_back {
    my ($self, $key) = @_;
    ...
}

sub step {
    my ($self, ) = @_;
    ...
}

sub step_back {
    my ($self, ) = @_;
    ...
}

sub set_value {
    my ($self, ) = @_;
    ...
}

sub remove {
    my ($self, $key) = @_;
    ...
}

sub get_key {
    my ($self, $step) = @_;
    ...
}

sub get_value {
    my ($self, $step) = @_;
    ...
}

sub get {
    my ($self, $step) = @_;
    ...
}

sub delete {
    my ($self, ) = @_;
    ...
}

1;
