#!/usr/bin/perl -s

use LWP::UserAgent;
use HTTP::Request::Common;

my $gallery = shift;
my $photo = shift;

my $ua = LWP::UserAgent->new;
my $res = $ua->request(POST "http://localhost:3000/upload/$gallery/$photo",
                       Content_Type => 'multipart/form-data',
                       Content => [filename => [ $photo ]]);
