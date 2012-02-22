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
    template 'gallery', { current => $path,
                          galleries => \@galleries,
                          photos => \@photos };
};

any ['get','post'] => '/view/**/*' => sub {
    my ($path, $pic) = splat;
    my $fullpath = catfile('/gallery', @$path, $pic);

    if (param('comment')) {
        database->quick_insert('comments',
                               { path => $fullpath,
                                 comment => param('comment')});
    }

    my @comments = database->quick_select('comments',
                                          { path => $fullpath },
                                          { order_by => 'timestamp'});

    template 'image', { comments => \@comments,
                        name => $pic,
                        fullpath => $fullpath};
};

true;
