#!/usr/bin/perl

# tex-2col-tab.pl
#
# Double up a table in tex so that the bottom half is to the right of the top
# half, making a 'two-column' table. (Or rather a 2N column table where N is
# the number of columns it currently has.)

use strict;

if(scalar(@ARGV) == 0 || $ARGV[0] eq "--help") {
  print STDERR "Usage: $0 <tex file>\n";
  exit(0);
}
my $tex = shift(@ARGV);

open(FP, "<", $tex) or die "Cannot open tex file $tex: $!\n";

while(my $line = <FP>) {
  print $line;
  if($line =~ /\\begin\{table\}/) {
    &table_start(*FP);
  }
}

close(FP);

exit(0);

sub table_start {
  my ($fp) = @_;

  while(my $line = <$fp>) {
    if($line =~ /\\begin\{tabular\}/) {
      &double_up($fp, $line);
    }
    else {
      print $line;
      if($line =~ /\\end\{table\}/) {
        return;
      }
    }
  }
}

sub double_up {
  my ($fp, $start) = @_;

  if($start =~ /^(.*)\\begin\{tabular\}\{(.*)\}(.*)$/) {
    my ($pre, $cols, $post) = ($1, $2, $3);
    my $dcols = $cols;
    my @colchr = split(//, $cols);
    if($colchr[$#colchr] ne '|') {
      $dcols .= '|';
    }
    $dcols .= 'c';
    if($colchr[0] ne '|') {
      $dcols .= '|';
    }
    $dcols .= $cols;
    print "$pre\\begin{tabular}{$dcols}$post\n";
  }
  else {
    $start =~ s/\s+$//;
    die "Unexpected tabular environment line format: \"$start\"\n";
  }

  my @rows;
  my $end;
  while(my $line = <$fp>) {
    if($line =~ /\\end\{tabular\}/) {
      $end = $line;
      last;
    }
    else {
      $line =~ s/\s+$//;
      push(@rows, $line);
    }
  }
  if(!defined($end)) {
    die "Did not detect or reach end of tabular environment\n";
  }
  # Skip over \hlines at the beginning of the table
  while($rows[0] !~ /\\\\\s*$/ && scalar(@rows) > 0) {
    print shift @rows, "\n";
  }
  # Assume the next row ending \\ is the header row and print it twice
  my $header = shift(@rows);
  $header =~ s/\s*\\\\\s*$//;
  print "$header & ~ & ";
  $header =~ s/^\s+//;
  print "$header \\\\\n";
  # Count the number of rows ending \\ (assumed rows to double up)
  my $n = 0;
  foreach my $row (@rows) {
    $n++ if $row =~ /\\\\\s*$/;
  }
  # Find the first row ending \\ that's half way through
  my $dn = 0;
  foreach my $row (@rows) {
    $dn++ if($row =~ /\\\\\s*$/ && $dn <= int($n / 2));
  }
  # Set $j to the first row to print in the second column -- we'll jump over
  # any \hlines $j happens to have hit on later if $n % 2 isn't 0
  my $j = $dn + ($n % 2);
  for(my $i = 0; $i < $dn; $i++) {
    if($rows[$i] !~ /\\\\\s*$/) {
      # Could be \hline or similar, so print it. These instructions will be
      # obeyed for the first half of the table, so a complicated table
      # is likely to get messed up.
      print "$rows[$i]\n";
    }
    else {
      while($rows[$j] !~ /\\\\\s*$/ && $j <= $#rows) {
        $j++;
      }
      $rows[$i] =~ s/\s*\\\\\s*$//;
      $rows[$j] =~ s/^\s+//;

      print "$rows[$i] & ~ & $rows[$j]\n";

      $j++;
    }
  }
  # If there were an odd number of rows containing data (i.e. ending \\),
  # then print that row and empty columns in the 'doubled up' area. Hope
  # that people format their table nicely using & with spaces either side!
  if($n % 2 == 1) {
    $rows[$dn] =~ s/\s*\\\\\s*$//;
    my $namp = scalar(split(/\s&\s/, $rows[$dn]));
    print "$rows[$dn] & ~".(" & ~" x $namp)." \\\\\n";
  }
  # There may be \hlines at the end of the table, so print those
  for(; $j <= $#rows; $j++) {
    print "$rows[$j]\n";
  }
  print $end;
}
