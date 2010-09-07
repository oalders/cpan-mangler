#!/usr/bin/env perl

# start this script via:
# plackup
# OR
# plackup -r -s Twiggy app.psgi

use strict;
use warnings;

use Plack::App::Proxy;
use Plack::Builder;

my $highlight = q[
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shCore.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushPerl.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushJScript.js"></script>
<link href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shCore.css" rel="stylesheet" type="text/css" />
<link href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shThemeEmacs.css" rel="stylesheet" type="text/css" />

<script type="text/javascript">
$(document).ready(function() {
    $("pre").wrap('<div style="padding: 1px 5px; background-color: #000;" />').addClass("brush: pl");
    SyntaxHighlighter.defaults['gutter'] = false;
    SyntaxHighlighter.all();
});
</script>

];

builder {
    enable 'SimpleContentFilter', filter => sub {
        s{</head>}{$highlight</head>}gi;
    };
    
    #enable "Debug", panels => [qw(Environment Memory Timer Response)];

    Plack::App::Proxy->new( remote => 'http://search.cpan.org/' )->to_app;

};
