package Rule;
use ShapeCall;

sub new {
    my $class = shift;
    my $self = shift;

    $self->{calls} = [ map { ShapeCall->new($_) } $self->{calls} ];
    bless $self, $class;
}

1;
