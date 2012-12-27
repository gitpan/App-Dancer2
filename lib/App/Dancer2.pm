#
# This file is part of App-Dancer2
#
# This software is copyright (c) 2012 by celogeek <me@celogeek.com>.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package App::Dancer2;

# ABSTRACT: App to use dancer2 in your project

use strict;
use warnings;
our $VERSION = '0.03';    # VERSION
use Carp;
use feature 'say';
use Moo;
use MooX::Options;
use File::ShareDir ':ALL';
use Path::Class;
use Git::Repository;
use LWP::Curl;
use Archive::Extract;
use DateTime;

option 'app' => (
    is     => 'ro',
    doc    => 'Create a new apps',
    format => 's',
    isa    => sub {
        croak "not a valid app name: [a-zA-Z0-9]+"
            unless $_[0] =~ /^[a-zA-Z0-9]+$/x;
    }
);

option 'app_mode' => (
    is      => 'ro',
    doc     => 'Use mode: basic, distzilla',
    format  => 's',
    default => sub {'basic'},
    trigger => sub {
        my ( $self, $val ) = @_;
        if ( $val eq 'distzilla' ) {
            $self->app_with_git(1);
        }
        return;
    }
);

option 'app_with_git' => (
    is  => 'rw',
    doc => 'Use a pure git repository for your apps',
);

option 'install_head' => (
    is  => 'rw',
    doc => 'Install Dancer2 head with cpanm',
);

sub create_app {
    my $self = shift;

    my $path = dir( $ENV{PWD}, $self->app );
    croak "$path already exist !" if -e $path;

    say "Creating app : ", $self->app;

    my $dist_dir = $self->_dist_dir('App-Dancer2')->subdir('app')
        ->subdir( $self->app_mode );
    croak "This mode doesn't exist" if !-e $dist_dir;

    $self->_copy_dist( $dist_dir, $path );
    if ( $self->app_with_git ) {
        $self->_init_git($path);
    }
    else {
        $self->_fetch_latest_dancer2( $path->subdir('vendors') );
    }

    return;
}

sub install_head_with_cpanm {
    my $self = shift;
    my $dest = dir('/tmp/dancer2-head');
    if ( -d $dest ) {
        $dest->rmtree();
    }
    $self->_fetch_latest_dancer2($dest);
    my $install = $dest->file('install.sh');
    carp $install;
    my $fh = $install->open('w');
    print $fh <<'__EOF__'
#!/usr/bin/env bash
set -e -x
cd /tmp/dancer2-head/Dancer2-master/
cpanm -v Dist::Zilla
dzil authordeps | cpanm -v
dzil listdeps | cpanm
dzil install --install-command="cpanm -v ."
__EOF__
        ;
    close($fh);
    chmod 0755, $install;
    system($install);
    return;
}

# PRIVATE METHODS

sub _dist_dir {
    if ($App::Dancer2::VERSION) {
        return dir( dist_dir('App-Dancer2') );
    }
    else {
        return file(__FILE__)->dir->parent->parent->subdir('share');
    }
}

sub _copy_dist {
    my ( $self, $from, $to ) = @_;
    my $app          = $self->app;
    my $now          = DateTime->now();
    my $current_year = $now->year;
    $from->recurse(
        callback => sub {
            my $child = shift;
            my $dest = dir( $to, substr( $child, length($from) ) );
            $dest =~ s/\Q[%APP%]\E/$app/gx;
            if ( -d $child ) {
                $dest = dir($dest);
                say "Creating $dest ...";
                $dest->mkpath(0);
            }
            else {
                $dest = substr( $dest, 0, -4 );
                $dest = file($dest);
                say "Copying to $dest ...";
                my $content = $child->slurp;
                $content =~ s/\Q[%APP%]\E/$app/gx;
                $content =~ s/\Q[%CURRENT_YEAR%]\E/$current_year/gx;
                $dest->spew($content);
                if ( substr( $dest, -3 ) eq '.sh' ) {
                    chmod 0755, $dest;
                }
            }
        }
    );
    return;
}

sub _init_git {
    my ( $self, $dest ) = @_;
    say "Init git repository $dest ...";
    Git::Repository->run( init => { cwd => $dest } );
    my $r = Git::Repository->new( work_tree => $dest );
    $r->run( add => '.' );
    $r->run( commit => '-m', 'init dancer2 project' );
    say "Fetching vendors/Dancer2";
    $r->run(
        submodule => 'add',
        'git://github.com/PerlDancer/Dancer2.git', 'vendors/Dancer2'
    );
    $r->run( commit => '-m', 'plug git dancer2 head' );
    return;
}

sub _fetch_latest_dancer2 {
    my ( $self, $dest ) = @_;
    $dest->mkpath(0);
    say "Fetching latest dancer2 archive ...";
    my $lwpc    = LWP::Curl->new();
    my $content = $lwpc->get(
        'https://github.com/PerlDancer/Dancer2/archive/master.zip');
    say "Extract archive ...";
    my $tmp = file('/tmp/dancer2.zip');
    $tmp->spew($content);
    my $ae = Archive::Extract->new( archive => $tmp );
    $ae->extract( to => $dest );
    return;
}

1;

__END__

=pod

=head1 NAME

App::Dancer2 - App to use dancer2 in your project

=head1 VERSION

version 0.03

=head1 ATTRIBUTES

=head2 app

The app params will create a new dancer2 apps with basic configuration.

dancer2 --app myApps

=head2 app_mode

You can select between multiple mode.

Mode 'basic' : simple configuration without database

Mode 'distzilla' : same as basic, with a default distzilla project. It will allow to deploy your apps with dzil --release command.

=head2 app_with_git

Initialize git apps. It will use the submodule mode to fetch dancer2 instead of fetching the zip file

=head2 install_head

Install Dancer2 head with cpanm

=head1 METHODS

=head2 create_app

    Initialize an new apps. Used inside the binary apps dancer2.

=head2 install_head_with_cpanm

    Install Dancer2 head with cpanm

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
http://tasks.celogeek.com/projects/perl-dancer2-app-dancer2

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

celogeek <me@celogeek.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by celogeek <me@celogeek.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
