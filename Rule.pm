package Rule;
use ShapeCall;
use Data::Dump qw[dump];

sub new {
    my $class = shift;
    my $self = shift;

    $self->{calls} = [ map { ShapeCall->new($_) } @{$self->{calls}} ];
    bless $self, $class;
}

1;
