use strict;
use SVG;

my $svg = SVG->new(width=>600, height=>400);

my $ano=$svg->tag('g',
                    id    => 'group_ano',
                    style => {
                        stroke => 'rgb(100,200,50)',
                        fill   => 'rgb(10,150,100)'
                    }
                );
    $ano->tag('circle', cx=>50, cy=>50, r=>100, id=>'circle_in_group_ano');

my $z=$svg->tag('g',
                    id    => 'group_z',
                    style => {
                        stroke => 'rgb(100,200,50)',
                        fill   => 'rgb(10,100,150)'
                    },
		    transform=>'translate(100, 150)',
                );

    # create and add a circle using the generic 'tag' method
    $z->tag('circle', cx=>50, cy=>50, r=>100, id=>'circle_in_group_z');
    $z->tag('rect', width=>120, height=>50,  id=>'rect_in_group_z',
		transform=>'rotate(-45)');
    
    # create an anchor on a rectangle within a group within the group z
    my $k = $z->anchor(
        id      => 'anchor_k',
        -href   => 'http://google.bg/',
        target => 'new_window_0'
    )->rectangle(
        x     => 20, y      => 50,
        width => 20, height => 30,
        rx    => 10, ry     => 5,
        id    => 'rect_k_in_anchor_k_in_group_z'
    );

    # now render the SVG object, implicitly use svg namespace
    print $svg->xmlify;
    