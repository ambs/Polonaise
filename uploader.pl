#!/usr/bin/perl -s

use LWP::UserAgent;
use HTTP::Request::Common;

our $gallery;

if ($gallery) {
    $gallery =~ s{/?$}{/};
    $gallery =~ s{^/?}{};
} else {
    $gallery = "";
}

my $ua = LWP::UserAgent->new;

for my $file (@ARGV) {
    print STDERR "Uploading $file\n";
    my $res = $ua->request(POST "http://localhost:3000/upload/$gallery$file",
                           Content_Type => 'multipart/form-data',
                           Content => [filename => [ $file ]]);
}
