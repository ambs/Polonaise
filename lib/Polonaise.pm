package Polonaise;
use Dancer ':syntax';

use File::Path 'make_path';
use File::Spec::Functions 'catfile';
use Data::Dumper;
use Dancer::Plugin::Database;

our $VERSION = '0.1';

get '/' => sub {
    redirect '/gallery/'
};

post '/upload/**/*' => sub {
    my ($path, $name) = splat;
    my $file = upload('filename');
    my $folder = catfile(setting('public'), 'gallery', @$path);
    make_path($folder) unless -d $folder;
    $file->copy_to(catfile($folder, $name));
    return "OK";
};

get qr{/gallery/(.*)} => sub {
    my ($path) = splat;
    my $systempath = catfile(setting('public'), 'gallery', $path);
    chdir $systempath;
    my (@galleries, @photos);
    for my $file (glob("*")) {
        if (-d $file) {
            push @galleries, $file
        } else {
            push @photos, $file
        }
    }
    template 'gallery/index', { current => $path,
                                galleries => \@galleries,
                                photos => \@photos };
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

any ['get','post'] => '/view/**/*' => sub {
    my ($path,$name) = splat;
    my $fullpath = catfile('/gallery', @$path, $name);
    my $new = params->{comment};

    if ($new) {
        database->quick_insert('comments', {path=>$fullpath,comment=>$new});
    }
    my $comments = [database->quick_select('comments', { path=>$fullpath }, {order_by => 'timestamp'})];

    template 'gallery/image', { comments=>$comments, name=>$name, fullpath=>$fullpath};
};

get '/service/:op' => sub {
    my $op = params->{op};

    my $data;
    $data = __list_galleries() if $op eq 'list_galleries';

    content_type 'application/json';
    return to_xml $data;
};

sub __list_galleries {
    chdir(setting('public') . '/gallery');
    my $galleries;
    foreach (<*>) {
       $galleries->{$_} = [<$_/*>];
    }
    return $galleries;
}

true;
