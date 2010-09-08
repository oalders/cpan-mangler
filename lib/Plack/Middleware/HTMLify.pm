package Plack::Middleware::HTMLify;
use strict;
use warnings;
use parent qw( Plack::Middleware );

use Plack::Util;
use Plack::Util::Accessor qw( set_start set_end );

__PACKAGE__->{'count'} = 0;

sub call {
    my ($self, $env) = @_;

    my $res = $self->app->($env);
    $self->response_cb(
        $res,
        sub {
            my $res = shift;
            return sub {
                my $chunk = shift;
                if (!defined $chunk) {
                    return unless $self->set_end;
                    return $self->set_end;
                }
                return $self->set_start . $chunk if $self->set_start && __PACKAGE__->{'count'} == 0;
                return $chunk;
                __PACKAGE__->{'count'}++;
            }
        }
        
    );
}

1;

__END__

=head1 NAME

Plack::Middleware::HTMLify - Modifies the entire body.

=head1 SYNOPSIS

    use Plack::Builder;

    my $app = sub {
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Hello Foo' ] ];
    };

    builder {
        enable "HTMLify",
            set_start => "HTML HERE";
            set_end   => "HTML HERE";
        $app;
    };

=head1 DESCRIPTION

No description.

=head1 AUTHOR

Mark Jubenville

=cut
