package Polonaise;
use Dancer ':syntax';

use File::Path 'make_path';
use File::Spec;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/upload/**/*' => sub {
    ## this will use the filename POST'ed
    my ($path, $name) = splat;
    warning $name;
    my $file = upload('filename');
    my $target = File::Spec->catfile(setting('public'), 'gallery', @$path);
    make_path($target);
    $file->copy_to(File::Spec->catfile($target, $name));
};

true;
