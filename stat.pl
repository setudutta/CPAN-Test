#!/usr/bin/perl
#use File::chmod;
use lib "/home/vagrant/TEST/CPAN/";

#push(@INC, "/home/vagrant/TEST/CPAN/");
use Data::Dumper;
use File::stat;
use Fcntl "S_IWOTH";
use File::chmod;

#use subs qw(chmod);

#sub chmod {
#    print @_;
#}

my $file = "/home/vagrant/TEST/CPAN/tp.txt";
my $mode = 0776;
chmod( 0666, $file );

#my $perm = (stat ($file))[2];
my $st   = stat($file);
my $perm = ( stat($file) );
print "perm=$perm\n";
if ( $st->cando( S_IWOTH, 1 ) ) {

    print "Others can write\n";
    eval { chmod( "o-w", $file ); };

    #eval { chmod("ln''", $file); };
    print "error " if $@;
}
