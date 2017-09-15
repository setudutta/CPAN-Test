#!/ust/bin/perl -w
use strict;
use Test::More tests => 2;
use lib ".";
use Data::Dumper;
use SearchFiles;
use Test::More;
my $obj = new SearchFiles();

$obj->search('/home/vagrant/TEST/CPAN/Filess');

#print Dumper($obj);
ok( Dumper($obj), "*No such file*" );

$obj = new SearchFiles();
$obj->search('/tmp');

#print Dumper($obj);
ok( Dumper($obj), "*End*" );

