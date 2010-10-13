#!/usr/bin/env perl

# start this script via:
# plackup
# OR
# plackup -r -s Twiggy app.psgi

use strict;
use warnings;

use HTML::Entities;
use HTML::Highlighter;
use Plack::App::Proxy;
use Plack::Builder;

my $pod_highlight = q[
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shCore.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushPerl.js"></script>
<script type="text/javascript" src="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/scripts/shBrushJScript.js"></script>
<script type="text/javascript" src="http://github.com/oalders/cpan-mangler/raw/master/js/deps.js"></script>
<link type="text/css" href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shCore.css" rel="stylesheet" />
<link type="text/css" href="http://alexgorbatchev.com.s3.amazonaws.com/pub/sh/3.0.83/styles/shThemeDefault.css" rel="stylesheet" />

<style type="text/css">.highlight {background:yellow}</style>
<script type="text/javascript">
$(document).ready(function() {
    $("pre").wrap('<div style="padding: 1px 10px; background-color: #fff; border: 1px solid #999;" />').addClass("brush: pl");
    SyntaxHighlighter.defaults['gutter'] = false;
    SyntaxHighlighter.defaults['toolbar'] = false;
    SyntaxHighlighter.all();
    
    for each ( sr in document.getElementsByTagName( 'h2' ) ) {
    
        // parse the page to get the list of modules
        module = sr.childNodes[0].childNodes[0].innerHTML;
    
        // keep a reference to the line that shows information about the module
        infoblock = find_sibling_by_tagname(sr, "SMALL", "P", 1);
        if ( ! infoblock ) {
            // edge case - there is no description for this module
            infoblock = find_sibling_by_tagname(sr, "SMALL", "P", 0);
        }
    
        // keep track of the module distribution 
        if ( infoblock && infoblock.childNodes[1] ) {
            dist = infoblock.childNodes[1].href;
        }
        if ( dist ) {
            dist = dist.replace(/\/$/, '');
            dist = dist.replace(/^.*\//, '');
    
            dists_by_module[module] = dist;
            infoblocks_by_module[module] = infoblock;
            dists[dist] = 1;
        }
    }
    
    // loop through the dists to get the number cpan dependents
    // a callback will update the page with the number of dependents for each module
    for ( var dist in dists ) {
        num_dists++;
    }
    for ( var dist in dists ) {
        gather_cpan_dependents(dist);
    }

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
    mount '/source' => builder {
        enable 'HTMLify',
            set_head       => $source_highlight,
            set_body_start => '<pre class="brush: pl">',
            set_body_end   => '</pre>';
            ;
        enable 'SimpleContentFilter', filter => sub {
            encode_entities($_);
        };
        Plack::App::Proxy->new( remote => 'http://cpansearch.perl.org/src/' )->to_app;
    };
    mount '/'    => builder {
        enable 'SimpleContentFilter', filter => sub {
            s{</head>}{$pod_highlight</head>}i;
            s{/src/}{/source/}gi;
        };
        enable '+HTML::Highlighter', param => 'query';
        Plack::App::Proxy->new( remote => 'http://search.cpan.org/' )->to_app;
    };
};

$app;
