#!/usr/bin/perl -w
# Wrapper for Spreadsheet::ParseExcelXLSX.

use strict;
use warnings;

require File::Spec;
require Spreadsheet::ParseXLSX;
require Encode;

use utf8;

my $file = $ARGV[0];

unless ($file) {
  print STDERR "usage: xlsx2txt <file>\n";
  exit 1;
}

unless (-e $file) {
  print STDERR "file not found: $file\n";
  exit 1;
}

# Search path for xlsx2csv
my $binary = '';
for my $check (map {File::Spec->catfile($_, 'xlsx2csv')} File::Spec->path()) {
    if (-f $check && -x $check) {
        $binary = $check;
        last;
    }
}

if ($binary) {
    # Use efficient python implementation.
    my @sargs = ($binary, "-i", "--delimiter=tab", $file);
    system(@sargs);
} else {
    # Fall back to much slower and more inefficient ParseXLSX.
    my $parser = Spreadsheet::ParseXLSX->new;
    my $book = $parser->parse($file);

    return '' unless $book;

    my $text = '';

    foreach my $sheet (@{ $book->{Worksheet} }) {
        last if !defined $sheet->{MaxRow};
        foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
            foreach my $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
               my $cell = $sheet->{Cells}[$row][$col];
               if ($cell) {
                   my $cell_text;
                   if ($cell->{Type} eq "Numeric") {
                       $cell_text = $cell->{Val};
                   } else {
                       $cell_text = $cell->Value;
                   }
                   next if ($cell_text eq "");
                   $text .= $cell_text;
               }
               $text .= " ";
            }
            $text .= "\n";
        }
        $text .= "\n";
    }
    print Encode::encode_utf8($text);
}
