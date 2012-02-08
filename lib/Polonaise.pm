package Polonaise;
use Dancer ':syntax';

use File::Path 'make_path';
use File::Spec;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/upload/**/*' => sub {
    my ($path, $name) = splat;
    my $file = upload('filename');
    my $folder = File::Spec->catfile(setting('public'), 'gallery', @$path);
    make_path($folder) unless -d $folder;
    $file->copy_to(File::Spec->catfile($folder, $name));
    return "OK";
};

true;
