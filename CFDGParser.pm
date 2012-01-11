package CFDGParser;
use constant NO_MATCH => -1;
use Regexp::Grammars;
use Data::Dump 'dump';

$\ = "\n";

my $grammar = qr {
    <nocontext:>
    startshape\s+<startshape=shape_name> <[definitions=shape_definition]>*

    <rule: shape_name>
        \w+

    <rule: shape_definition>
        rule <shape_name> \{ <[calls=shape_call]>* \}

    <rule: shape_call>
        <call_name=shape_name> \{ <[transformations=transformation]>* \}

    <nocontext:>
    <rule: transformation>
        <.cmd= (s|size) > <size=(-?\d+|-?\d+ -?\d+)>
      | <.cmd= (x) > <x=(-?\d+)>
      | <.cmd= (y) > <y=(-?\d+)>
      | <.cmd= (hue|h) > <hue=(-?\d)>
      | <.cmd= (sat|saturation) > <saturation=(-?\d)>
      | <.cmd= (b|brightness) > <brightness=(-?\d)>
      | <.cmd= (skew) > <skew=(-?\d+ -?\d+)>
}xms;

sub parse ($){
    my $text = shift;

    if($text =~ $grammar) {
        return \%/;
    } else {
        return NO_MATCH;
    }
}

1;
