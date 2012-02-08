package Polonaise;
use Dancer ':syntax';

use File::Path 'make_path';
use File::Spec;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/upload/**' => sub {
    ## this will use the filename POST'ed
    my ($path) = splat;
    my $file = upload('filename');
    $file->copy_to(File::Spec->catfile(setting('public'), @$path, $file->basename));
};

true;
