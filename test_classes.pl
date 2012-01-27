use Test::More;

BEGIN { 
    use_ok ( 'Transformation' );
    use_ok ( 'ShapeCall' );
    use_ok ( 'Rule' );
    use_ok ( 'CFDGParser' );
}
require_ok ('Transformation');
require_ok ('ShapeCall');
require_ok ('Rule');
require_ok ('CFDGParser');


subtest "Transformation" => sub {
    my $color_transform = Transformation->new({cmd => 'alpha', values => [0.5]});
    is $color_transform->type, "color", "detects color type transformations";

    my $geometric_transform = Transformation->new({cmd => 'size', values => [3]});
    is $geometric_transform->type, "geometric", "detects geometric type transformations";
};

subtest "ShapeCall" => sub {
    my $shape_call = ShapeCall->new( { call_name => 'CIRCLE', transformations => [ { cmd => 'x', values => [2] } ] } );
    isa_ok($shape_call->{transformations}->[0], Transformation) || diag explain $shape_call;
};


subtest "Rule" => sub {
    my $text = "startshape Baba;\nrule Baba {\n \nCIRCLE { x 2 y 3 }\nSQUARE { s 0.7 }\n}\n";
    my $syntax_tree = CFDGParser->parse($text);
    my $baba = Rule->new($syntax_tree->{definitions}->[0]);
    isa_ok($baba, Rule) || diag explain $baba;
};

done_testing();
