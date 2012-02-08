#!/usr/bin/perl

use LWP::UserAgent;
use HTTP::Request::Common;
my $ua = LWP::UserAgent->new;

my $file = shift;

my $res = $ua->request(POST "http://localhost:3000/upload/foo/bar/$file",
                       Content_Type => 'multipart/form-data',
                       Content => [filename => [ $file ]]);
