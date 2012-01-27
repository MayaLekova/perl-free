use Test::More;

BEGIN { 
    use_ok ( 'Transformation' );
    use_ok ( 'ShapeCall' )
}
require_ok ('Transformation');
require_ok ('ShapeCall');


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

done_testing();
