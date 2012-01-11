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
                                         {shape_name => 'Baba',
                                          calls => [{
                                                     call_name => 'CIRCLE',
                                                     transformations => ['']
                                                   },

                                                   {
                                                     call_name => 'SQUARE',
                                                     transformations => ['']
                                                   }]
                                        }
                                        ], "parse a simple rule with one call";
}

done_testing();
