package CFDGParser;
use constant NO_MATCH => -1;
use Regexp::Grammars;
use Data::Dump 'dump';

$\ = "\n";

my $grammar = qr {
    <nocontext:>startshape\s+<startshape=shape_name> <[definitions=shape_definition]>*

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
