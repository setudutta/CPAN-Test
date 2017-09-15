#!/usr/bin/perl
use strict;
use File::Find;

#use File::stat;
#use DateTime;
my $dir1    = '/home';
my $daysago = 1;
my @files;

find( \&wanted, $dir1 );

sub _wanted {

#my $filesecs = (stat("$File::Find::dir/$_"))[9]; #GETS THE 9TH ELEMENT OF file STAT - THE MODIFIED TIME
    my $filesecs = ( stat("$File::Find::dir/$_") )[9]
      ;    #GETS THE 9TH ELEMENT OF file STAT - THE MODIFIED TIME
           #my $filesecs2=localtime($filesecs);
    my $filesecs2 = time() * $daysago;
    if ( $filesecs < $filesecs2 && -f )
    {      #-f=regular files, eliminates DIR p.367
        push( @files, "$File::Find::dir/$_" );
        push( @files, "$filesecs2" );
    }

#print "filesecs = $filesecs and localtime = $filesecs2 for file: $File::Find::dir/$_\n";

}

#print "@files\n...";

sub wanted {

#my $filesecs = (stat("$File::Find::dir/$_"))[9]; #GETS THE 9TH ELEMENT OF file STAT - THE MODIFIED TIME
    my $filesecs = ( stat("$File::Find::dir/$_") )[9]
      ;    #GETS THE 9TH ELEMENT OF file STAT - THE MODIFIED TIME
           #my $filesecs2=localtime($filesecs);
    my $filesecs2 = time() * $daysago;
    if ( $filesecs < $filesecs2 && -f )
    {      #-f=regular files, eliminates DIR p.367
        push( @files, "$File::Find::dir/$_" );
        push( @files, "$filesecs2" );
    }

#print "filesecs = $filesecs and localtime = $filesecs2 for file: $File::Find::dir/$_\n";
}
print "@files\n...";
