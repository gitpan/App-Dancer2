package [%APP%];
use strict;
use warnings;
use Dancer2;

get '/' => sub {
    template 'index';
};

1;
