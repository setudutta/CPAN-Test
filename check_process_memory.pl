#!/usr/bin/perl
use strict;

#use warnings;

my $process_name       = shift || 'transformer';
my $show_memory        = shift || 'Virtual Memory';
my $warn_threshold     = shift || 15000;
my $critical_threshold = shift || 20000;
my $per_process_monitor = 0;

my $w = &get_mem_unit($warn_threshold);
my $c = &get_mem_unit($critical_threshold);

my @pids =
`ps -ef | egrep "$process_name" | fgrep -v "$0" | fgrep -v ' grep ' | tr -s ' ' ' ' | cut -d' ' -f2`;

my @msg;

my $critical_alert = 0;
my $warning_alert  = 0;
my $tvmem          = 0;
my $trmem          = 0;
my $tsmem          = 0;
my $ttmem          = 0;
my ( $vmem, $rmem, $smem ) = 0;
foreach (@pids) {
    my $pid = $_;
    chomp($pid);

#my $mem = `top -n 1 -p $pid | tail -2 | head -1 | tr -s ' ' ' ' | cut -d' ' -f6,7,8`;
    my $mem = `top -n 1 -p $pid | tail -2 | head -1 | fgrep "$pid "`;
    chomp($mem);
    next unless $mem;
    next unless $mem =~ m/[0-9]+/;
    $mem =~ s/.*($pid .*)/$1/;
    $mem = join ' ', ( split /\s+/, $mem )[ 4 .. 6 ];

    #print "mem=$mem"; exit;
    my $tmem = 0;
    ( $vmem, $rmem, $smem ) = split /\s+/, $mem;
    $tvmem += &get_mem_unit($vmem);
    $trmem += &get_mem_unit($rmem);
    $tsmem += &get_mem_unit($smem);
    if ( $show_memory =~ m/Virtual/io ) {
        $tmem = &get_mem_unit($vmem);
        $ttmem += $tmem;

    }
    elsif ( $show_memory =~ m/Res/io ) {
        $tmem = &get_mem_unit($rmem);
        $ttmem += $tmem;
    }
    elsif ( $show_memory =~ m/Share/io ) {
        $tmem = &get_mem_unit($smem);
        $ttmem += $tmem;
    }
    else {
        $tmem =
          &get_mem_unit($vmem) + &get_mem_unit($rmem) + &get_mem_unit($smem);
        $ttmem += $tmem;
    }

    $mem =~ tr/\n/ /s;
    $mem =~ tr/\|/ /s;

    if ($per_process_monitor) {

        #&evaluate($tmem, $w, $c, $vmem, $rmem, $smem, $process_name, $pid);
        if ( $tmem < $w ) {
            push @msg,
"Ok: MEMORY Virtual = $vmem, Res = $rmem, Shared = $smem for process: $process_name pid: $pid";

        }
        elsif ( $tmem >= $c ) {
            push @msg,
"CRITICAL: MEMORY Virtual = $vmem, Res = $rmem, Shared = $smem for processs: $process_name pid: $pid";
            $critical_alert++;
        }
        else {
            push @msg,
"WARNING: MEMORY Virtual = $vmem, Res = $rmem, Shared = $smem for processs: $process_name pid:$pid";
            $warning_alert++;
        }
    }
}

unless ($per_process_monitor) {
    $tvmem = &bytes_to_GMKB($tvmem);
    $trmem = &bytes_to_GMKB($trmem);
    $tsmem = &bytes_to_GMKB($tsmem);
    if ( $ttmem < $w ) {
        push @msg,
"MEMORY Virtual = $tvmem, Res = $trmem, Shared = $tsmem for process: $process_name";

    }
    elsif ( $ttmem >= $c ) {
        push @msg,
"MEMORY Virtual = $tvmem, Res = $trmem, Shared = $tsmem for processs: $process_name";
        $critical_alert++;
    }
    else {
        push @msg,
"MEMORY Virtual = $tvmem, Res = $trmem, Shared = $tsmem for processs: $process_name";
        $warning_alert++;
    }

}

END {
    if ( $critical_alert == 0 && $warning_alert == 0 ) {
        print STDOUT "OK: @msg";
        exit 0;
    }
    if ($critical_alert) {
        print STDOUT "CRITICAL: @msg";
        exit 2;
    }
    else {
        print STDOUT "WARNING: @msg";
        exit 1;
    }
}

sub get_mem_unit {
    my $mem = shift;
    $mem =~ m/(\d+)(m|M|g|G|k|K)/i;
    my $unit = $2 || return $mem;
    $mem = $1;

    if ( $unit && $unit =~ /g/i ) {
        $mem = $mem . '000000000';
    }
    elsif ( $unit && $unit =~ /m/i ) {
        $mem = $mem . '000000';
    }
    elsif ( $unit && $unit =~ /k/i ) {
        $mem = $mem . '000';
    }
    return ( ( int($mem) ) );
}

sub bytes_to_GMKB {
    my $mem = shift;
    length($mem) > 9 && return int( $mem / 1000000000 ) . 'GB';

    length($mem) > 6 && return int( $mem / 1000000 ) . 'MB';

    length($mem) > 3 && return int( $mem / 1000 ) . 'KB';

    return int($mem) . 'B';
}
