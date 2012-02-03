package Grammar;
use strict;
use Rule;

sub new {
    my $class = shift;
    my $self = {};

    my $params = shift;
    $self->{axiom} = $params->{startshape};
    $self->{rules} = { map { $_->{shape_name} , Rule->new($_) } @{$params->{rules}} };

    bless $self, $class;
    return $self;
}

sub to_svg {
    my ($self, $svg) = @_;
    $self->{rules}->{$self->{axiom}}->to_svg($svg);
}

1;
