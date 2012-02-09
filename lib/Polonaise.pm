package Polonaise;
use Dancer ':syntax';

use File::Path 'make_path';
use File::Spec;
use Data::Dumper;

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

get '/gallery' => sub {
    chdir(setting('public') . '/gallery');

    my $galleries;
    foreach (<*>) {
       $galleries->{$_} = [<$_/*>];
    }

    template 'gallery/index', { galleries => $galleries};
};

get '/gallery/:gallery/:name' => sub {
    my $gallery = params->{gallery};
    my $name = params->{name};
    chdir(setting('public') . "/gallery/$gallery/$name");

    my $photos;
    foreach (<*>) {
        $photos->{$_} = "/gallery/$gallery/$name/$_"; # XXX create thumb
    }

    template 'gallery/view', { photos => $photos, name => "$gallery/$name" };
};

true;
