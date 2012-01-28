package Grammar;
use strict;

sub new {
    my $class = shift;
    my $self = {};

    $params = shift;
    $self->{axiom} = $params->{startshape};
    $self->{rules} = [ map { Rule->new($_) } @{$params->{definitions}} ];
}

1;
