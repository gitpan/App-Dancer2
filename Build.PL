
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "App to use dancer2 in your project",
  "dist_author" => [
    "celogeek <me\@celogeek.com>"
  ],
  "dist_name" => "App-Dancer2",
  "dist_version" => "0.09",
  "license" => "perl",
  "module_name" => "App::Dancer2",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Archive::Extract" => 0,
    "Archive::Zip" => 0,
    "Carp" => 0,
    "DateTime" => 0,
    "File::ShareDir" => 0,
    "Git::Repository" => 0,
    "LWP::Protocol::https" => 0,
    "LWP::Simple" => 0,
    "Moo" => 0,
    "MooX::Options" => "3.76",
    "Path::Class" => 0,
    "feature" => 0,
    "perl" => "5.010",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [
    "bin/dancer2"
  ],
  "share_dir" => {
    "dist" => "share"
  },
  "test_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Scalar::Util" => 0,
    "Test::More" => "0.94",
    "perl" => "5.004"
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
