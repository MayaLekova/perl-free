use Test::More;
use strict;

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

    isa_ok $geometric_transform->{values}, 'ARRAY';
    is_deeply $geometric_transform->{values}, [3], "preserve values";
    isa_ok $color_transform->{values}, 'ARRAY';
    is_deeply $color_transform->{values}, [0.5], "preserve values";

    subtest "translation matrices" => sub {
        my $translate_x_by_2 = Transformation->new( {cmd => 'x', values => [2]} );
        my $matrix = $translate_x_by_2->matrix();
        is_deeply $matrix, [
                            [1, 0, 2],
                            [0, 1, 0],
                            [0, 0, 1],
                           ];
    };
};

subtest "ShapeCall" => sub {
    my $shape_call = ShapeCall->new( { call_name => 'CIRCLE', transformations => [ { cmd => 'x', values => [2] } ] } );
    isa_ok($shape_call->{transformations}->[0], 'Transformation');
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

    my $baba = Rule->new($syntax_tree->{rules}->[0]);
    isa_ok($baba, 'Rule') || diag explain $baba;
    is ($baba->{shape_name}, 'Baba', 'the rule has the name given');
    isa_ok($baba->{calls}->[0], 'ShapeCall');
    is_deeply $baba->{calls}->[0]->{transformations}->[0], { cmd => 'x', values => [2], type => 'geometric' }, "transformations are kept in the right places";
};

done_testing();
