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
    is_deeply $parsed_hash2->{rules},  [
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
    is_deeply $parsed_hash3->{rules}, [
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
    is_deeply $parsed_hash4->{rules}, [
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

    is_deeply $parsed_hash5->{rules}, [
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

subtest "Paths", sub {
    my $text6 = <<CFDGTEXT
startshape Baba

rule Baba {
    Strinka {}
}

path Strinka {
    MOVETO { x 5 y 10 }
}

CFDGTEXT
;

    my $parsed_hash6 = CFDGParser::parse($text6);

    is_deeply($parsed_hash6->{paths}, [
                                          {
                                           path_name => 'Strinka',
                                           directives => [
                                                          {
                                                           command => 'MOVETO',
                                                           x => 5,
                                                           y => 10,
                                                          }
                                                         ]
                                          }
                                      ],
                                      "minimalistic path") || diag explain $parsed_hash6->{paths};


    my $test7 = <<CFDGTEXT
startshape Baba

rule Baba {
    Strinka{}
}

path Strinka {
    MOVETO  { x 5 y 10 }
    CURVETO { x 5 y 12 x1 3 y1 4 }
    LINEREL { x 7 y 7 }
}
CFDGTEXT
;

    my $parsed_hash7 = CFDGParser::parse($test7);
    is_deeply($parsed_hash7->{paths}, [
                                       {
                                        path_name => 'Strinka',
                                        directives => [
                                                       {
                                                        command => 'MOVETO',
                                                        x  => 5,
                                                        y => 10,
                                                       },
                                                       {
                                                        command => 'CURVETO',
                                                        x  => 5,
                                                        y => 12,
                                                        x1 => 3,
                                                        y1 => 4,
                                                       },
                                                       {
                                                        command => 'LINEREL',
                                                        x  => 7,
                                                        y => 7,
                                                       },
                                                      ]
                                       },
                                      ],
                                      "parse multiple directives per path") || diag explain $parse->{paths};

};

done_testing();
