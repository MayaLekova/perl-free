package Transformation;
use Math::Trig;
use Test::More;
use Graphics::ColorObject;
use strict;

use constant GEOMETRIC => {'s' => 1, 'size' => 1, 'x' => 1, 'y' => 1, 'r' => 1, 'rotate' => 1, 'skew' => 1};
use constant COLOR => {'h' => 1, 'hue' => 1, 'sat' => 1,  'saturation' => 1, 'b' => 1, 'brightness' => 1};
use constant ALPHA => {'a' => 1, 'alpha' => 1};
use constant SHORT_COMMANDS => {'h' => 'hue', 'sat' => 'saturation', 'b' => 'brightness', 's' => 'size', 'a' => 'alpha', 'r' => 'rotate'};
use constant GEOMETRIC_MATRIX_CONSTRUCTORS => {
    x => sub {
        my $x = shift;
        return [
                [ 1, 0,$x],
                [ 0, 1, 0],
                [ 0, 0, 1],
               ];
    },

    y => sub {
        my $y = shift;
        return [
                [1, 0, 0],
                [0, 1,$y],
                [0, 0, 1],
               ];
    },

    size => sub {
        my ($x, $y) = (shift, shift);
        return [
                [$x, 0, 0],
                [ 0,$y, 0],
                [ 0, 0, 1],
               ];
    },
    skew => sub {
        my ($x, $y) = (shift, shift);
        return [
                [1, tan($x), 0],
                [tan($y), 1, 0],
                [0, 0, 1],
               ]
    }
};

sub new {
    my $class = shift;
    my $self = shift;

    if (exists SHORT_COMMANDS->{$self->{cmd}}) {	#store command internally as FULL NAME command
        $self->{cmd} = SHORT_COMMANDS->{$self->{cmd}};
    }

    bless $self, $class;
    $self->{type} = $self->type();
    return $self;
}

sub type {
    my $self = shift;

    if (defined $self->{type}) {
        return $self->{type};
    }
    elsif (exists GEOMETRIC->{$self->{cmd}} ) {
        return "geometric";
    }
    elsif (exists COLOR->{$self->{cmd}} ) {
        return "color";
    }
    elsif (exists ALPHA->{$self->{cmd}} ) {
        return "alpha";
    }
    else {
        die("This is one weird transformation...");
    }
}

sub matrix {
    my $self = shift;
    my $rslt;
    if (exists GEOMETRIC->{$self->{cmd}}) {
        $rslt = GEOMETRIC_MATRIX_CONSTRUCTORS->{$self->{cmd}}->(@{$self->{values}});
    }
    return $rslt;
}

sub to_svg {
    my $self = shift;

    if($self->{cmd} eq "size") {
	if(!@{$self->{values}}[1]) {
	    @{$self->{values}}[1] = @{$self->{values}}[0];
        }
        return "scale(".@{$self->{values}}[0].", ".@{$self->{values}}[1].")";
    }
   elsif($self->{cmd} eq "x") {
        return "translate(".@{$self->{values}}[0].", 0)";
    }
    elsif($self->{cmd} eq "y") {
        return "translate(0, ".@{$self->{values}}[0].")";
    }
    elsif($self->{cmd} eq "rotate") {
        return "rotate(".@{$self->{values}}[0].")";
    }
    elsif($self->{cmd} eq "skew") {
	if(!@{$self->{values}}[1]) {
	    @{$self->{values}}[1] = @{$self->{values}}[0];
        }
        return "skewX(".@{$self->{values}}[0]."), skewY(".@{$self->{values}}[1].")";
    }
    elsif($self->{cmd} eq "alpha") {
        # alpha?
    }
    return "";
}

sub to_hsv {
    my $self = shift;
    my ($h, $s, $v) = @_;
    
    if($self->{cmd} eq "hue") {
	$h += @{$self->{values}}[0];
    }
    elsif($self->{cmd} eq "saturation") {
	$s += @{$self->{values}}[0];
    }
    elsif($self->{cmd} eq "brightness") {
	$v += @{$self->{values}}[0];
    }
    
    return ($h, $s, $v);
}

sub to_rgb {
    my ($h, $s, $v) = @_;
        
    my $color = Graphics::ColorObject->new_HSV([$h, $s, $v]);
    my ($r, $g, $b) = @{ $color->as_RGB255() };
    return "rgb(".$r.", ".$g.", ".$b.")\n";
}

1;
