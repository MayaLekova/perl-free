package CFDGParser;
use constant NO_MATCH => -1;
use Regexp::Grammars;
use Data::Dump 'dump';

$\ = "\n";

my $grammar = qr {
    <nocontext:>startshape\s+<startshape=shape_name> <[rules=shape_definition]>* <[paths=path_definition]>*

    <rule: shape_name>
        \w+

    <rule: shape_definition>
        rule <shape_name> \{ <[calls=shape_call]>* \}

    <rule: shape_call>
        <call_name=shape_name> \{ <[transformations=transformation]>* \}

    <rule: transformation>
        <cmd= (s|size) >         <[values=signed_num]>{1,2} % <_sep=( )>
      | <cmd= (x) >              <[values=signed_num]>
      | <cmd= (y) >              <[values=signed_num]>
      | <cmd= (r|rotate)>        <[values=signed_num]>
      | <cmd= (skew) >           <[values=signed_num]>{1,2} % <_sep=( )>
      | <cmd= (h|hue) >          <[values=signed_num]>
      | <cmd= (sat|saturation) > <[values=signed_num]>
      | <cmd= (b|brightness) >   <[values=signed_num]>
    
    <rule: signed_num>
        -?\d+(\.\d+)?

    <rule: num>
        \d+(\.\d+)?

    <rule: path_definition>
        path <path_name=shape_name> \{ <[directives=path_directive]>* \}

    <rule: path_directive>
        <command=(MOVETO|MOVEREL)>   \{ x <x=signed_num> y <y=signed_num> \}
      | <command=(LINETO|LINEREL)>   \{ x <x=signed_num> y <y=signed_num> \}
      | <command=(ARCTO|ARCREL)>     \{ x <x=signed_num> y <y=signed_num> x_radius <x_radius=num> y_radius <y_radius=num> ellipse_angle <ellipse_angle=num>\}
      | <command=(ARCTO|ARCREL)>     \{ x <x=signed_num> y <y=signed_num> (r|radius) <radius=num> \}
      | <command=(CURVETO|CURVEREL)> \{ x <x=signed_num> y <y=signed_num> x1 <x1=signed_num> y1 <y1=signed_num> (x2 <x2=signed_num> y2 <y2=signed_num>)? \}
      | <command=(CLOSEPOLY)>        \{  \}
      | <command=(STROKE)>           \{ (w|width) <width=num> \}

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
