use Test::More;

BEGIN { use_ok ( 'CFDGParser' ); }

require_ok ('CFDGParser');

subtest "No transformations", sub {
    #Startshape recognition
    my $text1 = "startshape Baba";
    my $parsed_hash1 = CFDGParser::parse($text1);
    is $parsed_hash1->{startshape}, 'Baba', "startshape detection";

    #Simple shape definitions
    my $text2 = <<CFDGTEXT
    startshape Baba

    rule Baba {
        CIRCLE {}
        SQUARE {}
    }
CFDGTEXT
    ;

    my $parsed_hash2 = CFDGParser::parse($text2);
    is_deeply $parsed_hash2->{definitions},  [
                                             {
                                              shape_name => 'Baba',
                                              calls => [{
                                                         call_name => 'CIRCLE',
                                                       },

                                                       {
                                                         call_name => 'SQUARE',
                                                       }]
                                            }
                                            ],
                                            "parse a simple rule with one call";
};

subtest "With transformations", sub {
    #Shape definition with transformations
    my $text3 = <<CFDGTEXT
    startshape Dyado

    rule Dyado {
        CIRCLE {}
        TRIANGLE { x 5 y -10 size 7 2 }
    }
CFDGTEXT
    ;

    my $parsed_hash3 = CFDGParser::parse($text3);
    is_deeply $parsed_hash3->{definitions}, [
                                            {
                                             shape_name => 'Dyado',
                                             calls => [
                                                       {
                                                        call_name => 'CIRCLE',
                                                       },
                                                       {
                                                        call_name => 'TRIANGLE',
                                                        transformations => [
                                                                            { cmd => 'x',    values => [5] },
                                                                            { cmd => 'y',    values => [-10] },
                                                                            { cmd => 'size', values => [7, 2] }
                                                                           ]
                                                       }
                                                      ]
                                            }
                                           ],
                                           "parse rule with transformations";

    #Transformations with non-integers
    my $text4 = <<CFDGTEXT
    startshape Dyado

    rule Dyado {
        CIRCLE {}
        TRIANGLE { x 5 y 10 size 7.5 2 r 12.32 }
    }
CFDGTEXT
    ;

    my $parsed_hash4 = CFDGParser::parse($text4);
    is_deeply $parsed_hash4->{definitions}, [
                                            {
                                             shape_name => 'Dyado',
                                             calls => [
                                                       {
                                                        call_name => 'CIRCLE',
                                                       },
                                                       {
                                                        call_name => 'TRIANGLE',
                                                        transformations => [
                                                                            { cmd => 'x',    values => [5] },
                                                                            { cmd => 'y',    values => [10] },
                                                                            { cmd => 'size', values => [7.5, 2] },
                                                                            { cmd => 'r',    values => [12.32] }
                                                                           ]
                                                       }
                                                      ]
                                            }
                                           ],
                                           "parse rule with transformations with noninteger arguments";

    #Something a bit longer
    my $text5 = <<CFDGTEXT
    startshape Dyado

    rule Dyado {
        CIRCLE { x 2 y 0.1 }
        SQUARE { size 1.1 }
    }

    rule STOP {}

    rule Dyado {
        STOP{}
    }

    rule Dyado {
        SQUARE {}
        Dyado { s 0.8 x 1.2 }
    }

CFDGTEXT
;
    my $parsed_hash5 = CFDGParser::parse($text5);

    is_deeply $parsed_hash5->{definitions}, [
                                             {
                                              shape_name => 'Dyado',
                                              calls => [
                                                        {
                                                         call_name => 'CIRCLE',
                                                         transformations => [
                                                                             { cmd => 'x', values => [2] },
                                                                             { cmd => 'y', values => [0.1] },
                                                                            ]
                                                        },
                                                        {
                                                         call_name => 'SQUARE',
                                                         transformations => [
                                                                             { cmd => 'size', values => [1.1] },
                                                                            ]
                                                        }
                                                       ]
                                             },
                                             {
                                              shape_name => 'STOP',
                                             },
                                             {
                                              shape_name => 'Dyado',
                                              calls => [
                                                        {
                                                         call_name => 'STOP',
                                                        },
                                                       ],
                                             },
                                             {
                                              shape_name => 'Dyado',
                                              calls => [
                                                        {
                                                         call_name => 'SQUARE',
                                                        },
                                                        {
                                                         call_name => 'Dyado',
                                                         transformations => [
                                                                             { cmd => 's', values => [0.8] },
                                                                             { cmd => 'x' , values => [1.2] },
                                                                            ],
                                                        },
                                                       ],
                                             },
                                            ],
                                            "parse a richer grammar";
};

done_testing();
