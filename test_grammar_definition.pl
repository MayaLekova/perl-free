use Test::More;

BEGIN { use_ok ( 'CFDGParser' ); }

require_ok ('CFDGParser');

{
#Startshape recognition
my $text = "startshape Baba";
my $parsed_hash = CFDGParser::parse($text);
is $parsed_hash->{startshape}, 'Baba', "startshape detection";
}

{
#Simple shape definitions
my $text = <<CFDGTEXT
startshape Baba

rule Baba {
    CIRCLE {}
    SQUARE {}
}
CFDGTEXT
;

my $parsed_hash = CFDGParser::parse($text);
is_deeply $parsed_hash->{definitions},  [
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
}

{
#Shape definition with transformations
my $text = <<CFDGTEXT
startshape Dyado

rule Dyado {
    CIRCLE {}
    TRIANGLE { x 5 y 10 size 7 2 }
}
CFDGTEXT
;

my $parsed_hash = CFDGParser::parse($text);
is_deeply $parsed_hash->{definitions}, [
                                        {
                                         shape_name => 'Dyado',
                                         calls => [
                                                   {
                                                    call_name => 'CIRCLE',
                                                   },
                                                   {
                                                    call_name => 'TRIANGLE',
                                                    transformations => [{ x => 5 },
                                                                        { y => 10 },
                                                                        { size => '7 2' }
                                                                       ]
                                                   }
                                                  ]
                                        }
                                       ]
}

done_testing();
