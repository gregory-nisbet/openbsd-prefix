#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';

use URI;
use SelectMirror qw(select_mirror);
use Data::Dumper;

sub join_url {
    my $base_path = shift;
    my $args = shift;

    ref $base_path eq '' or die sprintf('join_url expects a string: %s', Dumper($base_path));
    
    my $u = URI->new($base_path);
    for my $arg (@$args) {
	$u = URI->new($args)->abs($u);
    }
    $u;
}

sub gen_package_url {
    my $base_path = shift;
    my $openbsd_version = `uname -a | awk 'END {print \$3}'`;
    my $arch = `machine -a`;
    join_url($base_path, [$openbsd_version, 'packages', $arch]);
}

sub config {
    my $vimrc = <<'VIMRC';
" enable syntax highlighting
syntax enable
" remove legacy vi-compatibility behavior
" like handling arrow keys
set nocompatible
" file-type specific behavior and indentation
filetype plugin indent on
" default color scheme that is visible with
" this terminal emulator
colorscheme desert
set backspace=eol,start,indent
VIMRC

    my $pkgconf = <<'PKGCONF';
installpath = ftp://ftp5.usa.openbsd.org/pub/OpenBSD/5.7/packages/amd64/
PKGCONF

    # copy vimrc to ~/vimrc and /root/vimrc
    print $vimrc '/home/g/vimrc';
    print $vimrc '/root/vimrc';

    # copy pkgconf to /etc/pkg.conf
    print $pkgconf '/etc/pkg.conf';
    return;
}

sub main {
    # host component of fastest item
    my $mirror = select_mirror;
    print "main-mirror %s\n", Dumper $mirror;
    my $base_url = $mirror->[0][0];
    printf "base-url: %s\n", Dumper $base_url;
    printf "gen-package: %s\n", Dumper gen_package_url($base_url)->as_string;
}

main();
