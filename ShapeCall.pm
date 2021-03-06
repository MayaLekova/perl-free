package ShapeCall;
use strict;
use Transformation;

use constant SCALE => 10;

sub new {
    my $class = shift;
    my $self = shift;

    $self->{transformations} = [ map { Transformation->new($_) } @{$self->{transformations}} ];

    if ($self->{loop_cnt}) {
        $self->{loop_transformations} = [ map { Transformation->new($_) } @{$self->{loop_transformations}} ];
    }

    bless $self, $class;
}

sub transform_to_str {
    my $transformations = shift;
    
    my $transform_str = "";
    my $h = 0, my $s = 0, my $v = 0, my $opacity = 1;
    foreach my $tr (@{$transformations}) {
        if($tr->type() eq 'geometric') {
            $transform_str = $transform_str.$tr->to_svg().", ";
        }
        elsif($tr->type() eq 'color') {
            ($h, $s, $v) = $tr->to_hsv($h, $s, $v);
        }
        elsif($tr->{cmd} eq 'alpha') {
            $opacity *= $tr->{values}->[0];
        }
    }

    if(length($transform_str) > 0) {
        $transform_str = substr($transform_str, 0, -2);
    }
    my $color_str = Transformation::to_rgb($h, $s, $v);
    
    return ($transform_str, $color_str, $opacity);
}

sub single_call {
    my ($self, $parent, $grammar, $max_depth) = @_;
    
    my ($transform_str, $color_str, $opacity) = ShapeCall::transform_to_str($self->{transformations});

    my $group = $parent->tag('g', 
        style => {fill => $color_str, stroke => $color_str, 'fill-opacity' => "$opacity", 'stroke-opacity' => "$opacity" },
        transform => $transform_str);
    
    if($self->{call_name} eq 'TRIANGLE') {
        my $xv = [-0.5 * SCALE, 0.5 * SCALE, 0];
        my $yv = [-0.5 * SCALE, -0.5 * SCALE, 0.366 * SCALE];
            
        my $points = $parent->get_path(
                x=>$xv, y=>$yv,
                -type=>'polygon',
                -closed=>'true'
            );

        $group->polygon(%$points);
    }
    elsif($self->{call_name} eq 'SQUARE') {
        $group->rect(width => SCALE, height => SCALE);
    }
    elsif($self->{call_name} eq 'CIRCLE') {
        $group->circle(cx=>0, cy=>0, r => SCALE);
    }
    else {
	my $successor = $grammar->{rules}->{$self->{call_name}};
	if($successor) {
	    $successor->to_svg($group, $grammar, $max_depth);
	}
    }
}

sub iteration {
    my ($self, $parent, $grammar, $max_depth, $count) = @_;
    if ($count <= 0) { return; }
    
    my ($transform_str, $color_str, $opacity) = ShapeCall::transform_to_str($self->{loop_transformations});

    my $group = $parent->tag('g', 
	style => {fill => $color_str, stroke => $color_str, 'fill-opacity' => "$opacity", 'stroke-opacity' => "$opacity" },
	transform => $transform_str);

    $self->single_call($group, $grammar, $max_depth);
	    
    $count--;
    $self->iteration($group, $grammar, $max_depth, $count);
}

sub to_svg {
    my ($self, $parent, $grammar, $max_depth) = @_;
    if ($max_depth <= 0) { return; }
    if ($self->{loop_cnt}) {
	$self->iteration($parent, $grammar, $max_depth, $self->{loop_cnt});
    } else {
        $self->single_call($parent, $grammar, $max_depth);
    }
    
}

1;
