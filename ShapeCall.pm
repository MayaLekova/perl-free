package ShapeCall;
use strict;
use Transformation;

use constant SCALE => 10;

sub new {
    my $class = shift;
    my $self = shift;

    $self->{transformations} = [ map { Transformation->new($_) } @{$self->{transformations}} ];
    bless $self, $class;
}

sub to_svg {
    my ($self, $parent) = @_;
    my $transform_str = "", my $color_str = ""; #TODO: HSV
    foreach my $tr (@{$self->{transformations}})
    {
	if($tr->type() =~ 'geometric')
	{
	    $transform_str = $transform_str.$tr->to_svg().", ";
	}
	elsif($tr->type() =~ 'color')
	{
	    $color_str = $color_str.$tr->to_svg().", ";
	}
    }
    if(length($transform_str) > 0)
    {
	$transform_str = substr($transform_str, 0, -2);
    }
    if(length($color_str) > 0)
    {
	$color_str = substr($color_str, 0, -2);
    }

    my $group = $parent->tag('g', 
		style => {fill   => $color_str, stroke => $color_str },
		transform => $transform_str);
    
    if($self->{call_name} =~ 'TRIANGLE')
    {
	print "CALL: ".$self->{call_name}."\n";
	my $xv = [-0.5 * SCALE, 0.5 * SCALE, 0];
	my $yv = [-0.5 * SCALE, -0.5 * SCALE, 0.5];
		
	my $points = $parent->get_path(
            x=>$xv, y=>$yv,
            -type=>'polygon',
            -closed=>'true'
        );

	$group->polygon(%$points, 
		style => {fill   => $color_str, stroke => $color_str },
		transform => $transform_str);
    }
    elsif($self->{call_name} =~ 'SQUARE')
    {
	$group->rect(width => SCALE, height => SCALE);
    }
    elsif ($self->{call_name} =~ 'CIRCLE')
    {
	$group->circle(cx=>0, cy=>0, r => SCALE);
    }
    #TODO: find recursive shape call
}

1;
