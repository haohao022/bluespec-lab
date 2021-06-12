#!/usr/bin/perl -w
#==========================================================================
# objdump2vmh.pl
#
# Author : Christopher Batten
# Date   : March 7, 2005
#
# Edited by Myron King to make it Bluespec safe.  This means
# removing all comments and addressing

(our $usageMsg = <<'ENDMSG') =~ s/^\#/ /gm;
#
# This script converts the output of objdump into a verlog memory 
# dump format. It assumes that objdump was run with the following
# options:
#
#  --disassemble-all     (to dissasemble all sections)
#  --disassemble-zeroes  (fully dissassemble sequences of zeros)
#
# The --hostreq command line argument can be use to dump a vmh file
# in a format suitable for use with the mkGetFromFile and 
# mkGetFromCmdLineFile bluespec files and the MemRequest type ...
# 
ENDMSG

use strict "vars";
use warnings;
no  warnings("once");
use Getopt::Long;

#--------------------------------------------------------------------------
# Command line processing
#--------------------------------------------------------------------------

our %opts;

sub usage()
{

  print "\n";
  print " Usage: objdump2vmh.pl [options] <input-file> <output-file>\n";
  print "\n";
  print " Options:\n";
  print "  --hostreq           use host memory request vmh format\n";
  print "  --help              print this message\n";
  print "  --verbose           enable verbose output\n";
  print "  --bluespec          no comments or addressing";
  print "$usageMsg";

  exit();
}

sub processCommandLine()
{

  $opts{"help"}        = 0;
  $opts{"verbose"}     = 0;
  $opts{"hostreq"}     = 0;
  $opts{"bluespec"}     = 0;

  Getopt::Long::GetOptions( \%opts, 'help|?', 'verbose', 'hostreq', 'bluespec' ) or usage();

  $opts{"fname-in"}  = shift(@ARGV) or usage();
  $opts{"fname-out"} = shift(@ARGV) or usage();

  $opts{"help"} and usage();

}

#--------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------

sub main()
{

  #------------------------------------------------------------
  # Initialize and setup

  processCommandLine();

  open( FIN,  "<".$opts{"fname-in"} ) 
    or die("Could not open file ".$opts{"fname-in"}." for input!");

  open( FOUT, ">".$opts{"fname-out"} )
    or die("Could not open file ".$opts{"fname-in"}." for output!");

  my $skippedHeader = 0;
  my $currentAddr = 0;
  while ( <FIN> ) {

    # Translate instructions
    if ( $skippedHeader && /^\s*\w+:\s*(\w+)\s*(.*)$/ ) {
      if ( $opts{"hostreq"} ) {
        print FOUT "1_".sprintf("%08x",$currentAddr)."_$1  // $2\n";
    } elsif ($opts{"bluespec"}){
        print FOUT "$1"."\n";
    } else {
        print FOUT "$1  // ".sprintf("%08x",$currentAddr)." $2\n";
      }
      $currentAddr += 4;
    }

    # Translate sections and labels
    if ( $skippedHeader && /^\s*(\w+) (<.*>):$/ ) {
      my $old_currentAddr = $currentAddr;
      $currentAddr = hex($1);
      if ( $opts{"hostreq"} ) {        
	  print FOUT "\n".(" "x19)."  // $2\n" ;
      } elsif ($opts{"bluespec"}) {
	  for(my $i = $old_currentAddr; $i < $currentAddr; $i=$i+4){
	      print FOUT "00000000\n";
	  }
      } else {
	  my $wordAddrStr = sprintf("%-8x",$currentAddr/4);
	  print FOUT "\n\@$wordAddrStr // $2\n" ;
      }
    }
    
    # Skip over initial couple lines
    if ( /Disassembly of section .text:/ ) {
	$skippedHeader = 1;
    }
    
  }
  
  close( FIN );
  close( FOUT );
  
}

main();
