package Rule;
use strict;
use ShapeCall;

sub new {
    my $class = shift;
    my $self = shift;

    $self->{calls} = [ map { ShapeCall->new($_) } @{$self->{calls}} ];
    bless $self, $class;
}

sub to_svg {
    my ($self, $parent, $grammar, $max_depth) = @_;
    
    foreach my $call (@{$self->{calls}}) {
        $call->to_svg($parent, $grammar, $max_depth - 1);
    }
}

1;
