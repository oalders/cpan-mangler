#!/usr/bin/env perl

# start this script via:
# plackup
# OR
# plackup -r -s Twiggy app.psgi

use strict;
use warnings;

use Data::Dumper;
use Plack::App::Proxy;
use Plack::Builder;

my $pod_highlight = q[
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shCore.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushPerl.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushJScript.js"></script>
<link href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shCore.css" rel="stylesheet" type="text/css" />
<link href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shThemeDefault.css" rel="stylesheet" type="text/css" />

<script type="text/javascript">
$(document).ready(function() {
    $("pre").wrap('<div style="padding: 1px 10px; background-color: #fff; border: 1px solid #999;" />').addClass("brush: pl");
    SyntaxHighlighter.defaults['gutter'] = false;
    SyntaxHighlighter.defaults['toolbar'] = false;
    SyntaxHighlighter.all();
});
</script>

];

my $source_highlight = q[
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shCore.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushPerl.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushJScript.js"></script>
<link href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shCore.css" rel="stylesheet" type="text/css" />
<link href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shThemeDefault.css" rel="stylesheet" type="text/css" />

<script type="text/javascript">
$(document).ready(function() {
    SyntaxHighlighter.defaults['toolbar'] = false;
    SyntaxHighlighter.all();
});
</script>

];

my $app = builder {
    #enable "Debug", panels => [qw(Environment Memory Timer Response)];
    mount "/source" => builder {
        enable 'Header', set => [ 'Content-Type' => 'text/html' ];
        #enable 'SimpleContentFilter', filter => sub {
        #    s{package(.*)}{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n<html lang="en">\n<head>$source_highlight</head>\n<body>\n<pre class="brush: pl">\n$1}gi;
        #    s{(.*);1}{\n$1</pre>\n</body>\n</html>}gi;
        #};
        enable 'HTMLify',
            set_start => qq[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n<html lang="en">\n<head>$source_highlight</head>\n<body>\n<pre class="brush: pl">],
            set_end   => qq[</pre>\n</body>\n</html>];
        Plack::App::Proxy->new( remote => 'http://cpansearch.perl.org/src/' )->to_app;
    };
    mount "/"    => builder {
        enable 'SimpleContentFilter', filter => sub {
            s{</head>}{$pod_highlight</head>}i;
            s{/src/}{/source/}gi;
        };
        Plack::App::Proxy->new( remote => 'http://search.cpan.org/' )->to_app;
    };
};

$app;