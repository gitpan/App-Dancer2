#!/usr/bin/env perl
#
# This file is part of App-Dancer2
#
# This software is copyright (c) 2012 by celogeek <me@celogeek.com>.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use strict;
use warnings;
BEGIN {
    use FindBin qw/$Bin/;
    my @vendors = glob($Bin."/../vendors/*/lib");
    push @INC, @vendors;
}
use Dancer2;
use [%APP%];

start;
