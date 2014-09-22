package Catmandu::Fix::cmd;

use namespace::clean;
use Catmandu::Sane;
use IO::Pty::Easy;
use JSON::XS;
use Moo;

our $VERSION = 0.03;

has cmd  => (is => 'ro');
has pty  => (is => 'ro', lazy => 1, builder => 1, predicate => 1);
has json => (is => 'ro', lazy => 1, builder => 1);

around BUILDARGS => sub {
    my ($orig, $class, @cmd) = @_;
    $orig->($class,
        cmd => [@cmd],
    );
};

sub _build_json {
    JSON::XS->new->utf8(1);
}

sub _build_pty {
    my ($self) = @_;
    my $cmd = $self->cmd;
    my $pty = IO::Pty::Easy->new;
    $pty->spawn(@$cmd);
    $pty;
}

sub fix {
    my ($self, $data) = @_;
    my $json = $self->json;
    my $line = $json->encode($data)."\n";
    $self->pty->write($line);
    for (;;) {
         if ($data = $json->incr_parse) {
            last;
         }
         $line = $self->pty->read;
         chomp $line;
         $json->incr_parse($line);
    }
    $data;
}

1;
__END__

=head1 NAME

Catmandu::Fix::cmd - pipe data to be fixed through an external process

=head1 DESCRIPTION

This L<Catmandu::Fix> passes data as a JSON object to an external process over
stdin and reads a JSON object from it's stdout.

=head1 SYNOPSIS

    my $fixer = Catmandu::Fix->new(fixes => [
        # pipe data through the jq command-line json processor
        # keeping only the title field
        'cmd("jq -c -M {title}")', 
        # ...
    ]);

    # a canonical external program in perl
    use JSON;
    while (<STDIN>) {
        my $data = decode_json($_);
        # ...
        print encode_json($data);
    }

=head1 CONTRIBUTORS

Nicolas Steenlant, C<< <nicolas.steenlant at ugent.be> >>

Jakob Voss C<< jakob.voss at gbv.de >>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
