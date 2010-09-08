package Plack::Middleware::HTMLify;
use strict;
use warnings;
use parent qw( Plack::Middleware );

use Plack::Util;
use Plack::Util::Accessor
    qw( set_doctype set_head set_body_start set_body_end );

__PACKAGE__->{'count'} = 0;

sub call {
    my ( $self, $env ) = @_;

    my $res = $self->app->($env);
    $self->response_cb(
        $res,
        sub {
            my $res     = shift;
            my $headers = $res->[1];
            Plack::Util::header_set( $headers, 'Content-Type', 'text/html' );

            return sub {
                my $chunk = shift;
                if ( !defined $chunk ) {
                    __PACKAGE__->{'count'} = 0;
                    $chunk = qq[\n</body>\n</html>];
                    $chunk = $self->set_body_end . $chunk
                        if $self->set_body_end;
                    return $chunk;
                }
                else {
                    if ( __PACKAGE__->{'count'} == 0 ) {
                        my $start_chunk = "";
                        if ( $self->set_doctype ) {
                            $start_chunk = $self->set_doctype . "\n";
                        }
                        else {
                            $start_chunk =
                                q[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n];
                        }
                        if ( $start_chunk =~ /xhtml/i ) {
                            $start_chunk .=
                                qq[<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">\n];
                        }
                        else {
                            $start_chunk .= qq[<html lang="en">\n];
                        }
                        $start_chunk .=
                            qq[<head>\n] . $self->set_head . "\n</head>\n"
                            if $self->set_head;
                        $start_chunk .= qq[<body>\n];
                        $start_chunk .= $self->set_body_start . "\n"
                            if $self->set_body_start;
                        $chunk = $start_chunk . $chunk;
                    }
                    __PACKAGE__->{'count'}++;
                    return $chunk;
                }
            }
        }
    );
}

1;

__END__

=head1 NAME

Plack::Middleware::HTMLify - Transforms a non-html document into html.

=head1 SYNOPSIS

    use Plack::Builder;

    my $app = sub {
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Hello Foo' ] ];
    };

    builder {
        enable "HTMLify",
            set_doctype    => "...", # html for the doctype
            set_head       => "...", # html to include in <head>
            set_body_start => "...", # html for the beginning of the <body>
            set_body_end   => "..."; # html for the end of the <body>
        $app;
    };

=head1 DESCRIPTION

Used for transforming a non-html document into html.

=head1 AUTHOR

Mark Jubenville

=cut
