#!/usr/bin/perl

use File::Basename;
use Cwd;
###################################################################
# Script convert wave to sph in batch
#
# Vikramjit Mitra
# go_wav2sph.pl,
# V1.0 2011/05/10
# V1.1 2011/05/19
# V1.2 2011/07/25

# UPDATES: 
# V1.2: customized to perform wav to sphere conversion
#
###################################################################
#USEAGE go_wav2sph.pl <input_file_list> <dest_dir> <temp_dir> <log_dir>
# **NOTE
# The input file list must contain the full path
#
#---------------------------------------------------------------------------
# Check input arguments
#---------------------------------------------------------------------------

$numArgs = $#ARGV + 1;

if ($numArgs == 4)
{
    ( -e $ARGV[0] ) || die("ERROR: $0 : ERROR with $ARGV[0] : $!\n");
    #USEAGE goPripAudio.pl <input_file_list> <dest_dir> <temp_dir> <log_dir>
    $INPUT_FILES_LIST=$ARGV[0];
    $DEST_DIR=$ARGV[1];
    $TEMP_DIR=$ARGV[2];
    $LOG_DIR=$ARGV[3];
}
else
{
    die("ERROR: You must provide an input file list to process and a Destimation directory !! \n");
}

#---------------------------------------------------------------------------
# Read the input file list with the following three fields per line:
#---------------------------------------------------------------------------

open(FILE_LIST,$INPUT_FILES_LIST)
    || die("ERROR: $0: Could not open $INPUT_FILES_LIST: $!\n");
@trials_list=<FILE_LIST>;
close(FILE_LIST);
#
my $soxcode;
my $FNAME;
my $INPUT_DIR;
my $EXT;

foreach $file(@trials_list)
{
    chomp($file);
    ($FNAME,$INPUT_DIR,$EXT) = fileparse($file,qr/\.[^.]*/);

    $ofile = "$DEST_DIR/$FNAME.sph";
     if (-e $ofile) {
	    print "$ofile exists\n";
     } 
     else {           
           $soxcode = system("sox -t wav $file -r 16000 -t sph $ofile");
          # $soxcode = system("sox -t wav $file -r 16000 -t sph $ofile remix 1-2");

           if ($soxcode != 0) {
            $File2 = $LOG_DIR . '/SOX_ERR.LOG';
	      if (-e $File2) {
              open FH2, ">>", $File2 or die "Can't open ${File2} for input: $!";
              printf FH2 "SOX returned error code $soxcode for file: $FNAME$EXT\n\n";
              close (FH2);
             } 
             else {
              open FH2, ">>", $File2 or die "Can't open ${File2} for input: $!";
              printf FH2 "SOX returned error code $soxcode for file: $FNAME$EXT\n\n";       
              close (FH2);
             }
           }
     }
}


