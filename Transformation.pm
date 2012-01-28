package Transformation;
use strict;

my $geometric = {'s' => 1, 'size' => 1, 'x' => 1, 'y' => 1, 'r' => 1, 'rotate' => 1, 'skew' => 1};
my $color = {'h' => 1, 'hue' => 1, 'b' => 1, 'brightness' => 1, 'a' => 1, 'alpha' => 1};

sub new {
    my $class = shift;
    my $self = shift;

    bless $self, $class;
}

sub type {
    my $self = shift;

    if (exists $geometric->{$self->{cmd}} ) {
        return "geometric";
    }
    elsif (exists $color->{$self->{cmd}} ) {
        return "color";
    }
    else {
        die("This is one weird transformation...");
    }
}

1;
