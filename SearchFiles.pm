package SearchFiles;

use strict;
use warnings;
use lib ".";

use constant DEFAULT_PATH => '/home';
use constant DEFAULT_DAYS => 10;

use File::Find;
use File::stat;
use Fcntl "S_IWOTH";
use File::chmod;
use Data::Dumper;

our $Effective_Uid;

my $files  = [];
my $errors = [];

my @properties = qw(name perm dirpath error verbose);
my $self       = {
    'verbose' => 0,
    'dirpath' => DEFAULT_PATH,
    'error'   => []
};

sub wanted {
    my $st        = stat("$File::Find::dir/$_");
    my $match_uid = -1;
    if ($Effective_Uid) {
        $match_uid =
          &check_effective_uid( "$File::Find::dir/$_", $Effective_Uid );
    }
    if ( $st->cando( S_IWOTH, 1 ) && $match_uid ) {
        print STDOUT "File: $File::Find::dir/$_ had write permission\n";
        print STDOUT "Changing  permission to o-w\n\n" if $self->verbose;
        eval { chmod( "o-w", "$File::Find::dir/$_" ); };
        unless ($@) {
            push( @$files, "$File::Find::dir/$_" );
        }
        else {
            push( @$errors, "$File::Find::dir/$_" );
        }
    }
    print "Searching in $File::Find::dir/$_\n" if $self->verbose;
}

sub new {
    my $package = shift;
    my $verbose = shift || "";
    $self->{verbose} = 1 if $verbose;
    bless $self, $package;
    return $self;
}

sub files_changed {
    my $self  = shift;
    my $files = $self->name;
    return join "\n", @$files;
}

sub error {
    my $self    = shift;
    my @message = @_;
    push( @$errors, "@message" );
    $self->set_error($errors);
}

sub search {
    my $obj = shift;
    my $dir = shift || DEFAULT_PATH;
    $self->set_dirpath($dir);
    my @result;
    print "About to search in $dir \n" if $self->verbose();
    eval { find( \&wanted, $dir ); };
    $self->set_error( "Error Occured: " . $@ ) if ($@);
    $obj->set_name($files);
    $obj->set_error($errors);
    print "Finished searching in $dir\n" if $self->verbose();

    #print Dumper($obj);
}

sub check_effective_uid {
    my $file = shift || die "$!";
    my $euid = shift || return 1;
    my $f_uid = stat($file)->uid;
    print "File UID: $f_uid, Effective UID: $euid ... \n" if $self->verbose();
    if ( $f_uid == $euid ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub AUTOLOAD {

    our $AUTOLOAD;
    if ( $AUTOLOAD =~ /::(\w+)$/ and grep $1 eq $_, @properties ) {
        my $field = $1;
        {
            no strict 'refs';
            *{$AUTOLOAD} = sub { $_[0]->{$field} };
        }
        goto &{$AUTOLOAD};
    }

    if ( $AUTOLOAD =~ /::set_(\w+)$/ and grep $1 eq $_, @properties ) {
        my $field = $1;
        {
            no strict 'refs';
            *{$AUTOLOAD} = sub { $_[0]->{$field} = $_[1] };
        }
        goto &{$AUTOLOAD};
    }

    die "$_[0] does not understand $AUTOLOAD\n";
}
1;
