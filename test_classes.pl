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

print "\n\n\n";

subtest "Transformation" => sub {
    my $color_transform = Transformation->new({cmd => 'alpha', values => [0.5]});
    is $color_transform->type, "color", "detects color type transformations";

    my $geometric_transform = Transformation->new({cmd => 'size', values => [3]});
    is $geometric_transform->type, "geometric", "detects geometric type transformations";
};

print "\n\n";

subtest "ShapeCall" => sub {
    my $shape_call = ShapeCall->new( { call_name => 'CIRCLE', transformations => [ { cmd => 'x', values => [2] } ] } );
    isa_ok($shape_call->{transformations}->[0], Transformation);
};

print "\n\n";

subtest "Rule" => sub {
    my $text = <<TEXT
    startshape Baba
    rule Baba {
        CIRCLE { x 2 y 3 }
        SQUARE { s 7 }
    }
TEXT
;
    my $syntax_tree = CFDGParser::parse($text);

    my $baba = Rule->new($syntax_tree->{definitions}->[0]);
    isa_ok($baba, Rule) || diag explain $baba;
    is ($baba->{shape_name}, 'Baba', 'the rule has the name given');
    isa_ok($baba->{calls}->[0], ShapeCall);
    is_deeply $baba->{calls}->[0]->{transformations}->[0], { cmd => 'x', values => [2] }, "transformations are kept in the right places";
};

done_testing();
