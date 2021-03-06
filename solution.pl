#!/usr/bin/perl
use Cwd;

sub print_contents {
    &filler;
    my @contents;
    open( FILE, $_[0] );
    @contents = <FILE>;
    close(FILE);
    print STDOUT "@contents";
}

sub filler {
    print "\n\n";
    print "#?" x 80;
    print "\n\n";
    print "#?" x 80;
    print "\n\n";

}
my $dir = getcwd;
my $reply;
print "$dir \n";

print "Question 1: \n";
&print_contents("$dir/question1.txt");

print "Do you want to execute the solution to 1st problem? (y/n): ";

$reply = <>;

if ( $reply =~ m/^y/i ) {
    system
      "chmod 755 $dir/search.pl && $dir/search.pl -d '$dir/Sample_Files, /tmp'";
}

print "Question 2: \n";
&print_contents("$dir/question2.txt");
print "Do you want to execute the solution to 2nd problem? (y/n): ";

$reply = <>;

if ( $reply =~ m/^y/i ) {
    system
"chmod 755 $dir/search.pl && $dir/search.pl -d '$dir/Sample_Files, /tmp' --verbose 1";
}

print "Question 3: \n";
&print_contents("$dir/question3.txt");
print "Do you want to execute the solution to 3rd problem? (y/n): ";

$reply = <>;

do "$dir/test.pl" if ( $reply =~ m/^y/i );

print "Question 4: \n";
&print_contents("$dir/question4.txt");

print "Do you want to execute the solution to 4th problem? (y/n): ";

$reply = <>;

system "chmod 755 $dir/search.pl && $dir/search.pl -d '/home/, /tmp' -u 1000"
  if ( $reply =~ m/^y/i );

