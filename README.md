# NAME

Catmandu::Fix::cmd - pipe data to be fixed through an external process

# DESCRIPTION

This [Catmandu::Fix](https://metacpan.org/pod/Catmandu::Fix) passes data as a JSON object to an external process over
stdin and reads a JSON object from it's stdout.

# SYNOPSIS

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

# CONTRIBUTORS

Nicolas Steenlant, `<nicolas.steenlant at ugent.be>`

Jakob Voss `jakob.voss at gbv.de`

# LICENSE

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.
