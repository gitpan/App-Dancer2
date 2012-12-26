package [%APP%];
# ABSTRACT: [%APP%] dancer apps
use strict;
use warnings;
# VERSION
use Dancer;

get '/' => sub {
    template 'index';
};

1;
