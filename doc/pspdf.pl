#!/usr/bin/perl
#
# Wrapper around a variety of programs that can do PS -> PDF conversion
#

use strict;

my $compress = 1;

while ($ARGV[0] =~ /^-(.*)$/) {
    my $opt = $1;
    shift @ARGV;

    if ($opt eq '-nocompress') {
	$compress = 0;
    }
}

my ($in, $out) = @ARGV;

if (!defined($out)) {
	die "Usage: $0 [-nocompress] infile outfile\n";
}

# Remove output file
unlink($out);

# 1. Acrobat distiller
my $r = system('acrodist', '-n', '-q', '--nosecurity', '-o', $out, $in);
exit 0 if ( !$r && -f $out );

# 2. ps2pdf (from Ghostscript)
my $r = system('ps2pdf', '-dOptimize=true', '-dEmbedAllFonts=true',
	       '-dCompressPages=' . ($compress ? 'true' : 'false'),
	       '-dUseFlateCompression=true', $in, $out);
exit 0 if ( !$r && -f $out );

# 3. pstopdf (BSD/MacOS X utility)
my $r = system('pstopdf', $in, '-o', $out);
exit 0 if ( !$r && -f $out );

# Otherwise, fail
unlink($out);
exit 1;