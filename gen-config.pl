#!/usr/bin/env perl

use strict;

use FindBin;
use Data::Dumper;

use YAML;
use Template;

my $golpe = YAML::LoadFile('./golpe.yaml');

my $config = $golpe->{config} || [];

foreach my $c (@$config) {
    die "invalid name: $c->{name}" if $c->{name} =~ /^_/;
    $c->{nameCpp} = $c->{name};
    $c->{nameCpp} =~ s{[.]}{__}g;

    $c->{path} = [ split(/[.]/, $c->{name}) ];

    if ($c->{type} eq 'uint64') {
        $c->{typeCpp} = 'uint64_t';
        $c->{defaultCpp} = $c->{default} . 'ULL';
    } elsif ($c->{type} eq 'string') {
        $c->{typeCpp} = 'std::string';
        $c->{defaultCpp} = $c->{default};
        $c->{defaultCpp} =~ s/"/\\"/g;
        $c->{defaultCpp} = '"' . $c->{defaultCpp} . '"';
    } elsif ($c->{type} eq 'bool') {
        $c->{typeCpp} = 'bool';
        $c->{defaultCpp} = lc($c->default);
    } else {
        die "unknown type: $c->{type}";
    }
}

my $ctx = {
    config => $config,
};


my $tt = Template->new({
    ABSOLUTE => 1,
    INCLUDE_PATH => ".",
}) || die "$Template::ERROR\n";

$tt->process("golpe/config.h.tt", $ctx, "build/config.h") || die $tt->error(), "\n";
$tt->process("golpe/config.cpp.tt", $ctx, "build/config.cpp") || die $tt->error(), "\n";
