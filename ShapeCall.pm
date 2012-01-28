package ShapeCall;
use strict;
use Transformation;

sub new {
    my $class = shift;
    my $self = shift;

    $self->{transformations} = [ map { Transformation->new($_) } @{$self->{transformations}} ];
    bless $self, $class;
}

1;
