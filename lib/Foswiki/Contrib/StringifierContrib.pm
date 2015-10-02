# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2009-2011 Foswiki Contributors
#
# For licensing info read LICENSE file in the Foswiki root.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at 
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Contrib::StringifierContrib;
our $VERSION = '3.0';
our $RELEASE = "3.0";

# Core modules
use File::Spec;

# MaintenancePlugin integration
sub maintenanceHandler {
    Foswiki::Plugins::MaintenancePlugin::registerCheck("stringifiercontrib:xlsxtoosl", {
        name => "StringifierContrib dependencies: Fast stringifier for xlsx.",
        description => "Checks if xlsx2cvs is available.",
        check => sub {
            my $result = { result => 0 };
            unless (scalar (grep { (-f $_ && -x $_)} (map {File::Spec->catfile($_, 'xlsx2csv')} File::Spec->path()))) {
                $result->{result} = 1;
                $result->{priority} = 1;
                $result->{solution} = "Install xlsx, if possible.";
            }
            return $result;
        }
    });
    Foswiki::Plugins::MaintenancePlugin::registerCheck("stringifiercontrib:xlsxcpan", {
        name => "StringifierContrib dependencies: CPAN module for xlsx stringifying.",
        description => "Checks if module Spreadsheet::ParseXLSX is available.",
        check => sub {
            my $result = { result => 0 };
            my $parser = '';
            eval('require Spreadsheet::ParseXLSX; $parser = Spreadsheet::ParseXLSX->new;');
            unless ($parser) {
                $result->{result} = 1;
                $result->{priority} = 1;
                $result->{solution} = "Install CPAN module Spreadsheet::ParseXLSX.";
            }
            return $result;
        }
    });
    Foswiki::Plugins::MaintenancePlugin::registerCheck('stringifiercontrib:commands', {
        name => "StringifierContrib commands valid",
        description => "Stringifier commands appear to be functional.",
        check => sub {
            my $result = { result => 0 };
            if ( my @cmds = keys( %{$Foswiki::cfg{StringifierContrib}} ) ) {
                my $indexer = $Foswiki::cfg{StringifierContrib}{WordIndexer};
                my @offenders = ();
                my @path = ('');
                push @path, File::Spec->path();
                for my $cmd ( @cmds ) {
                    if ( $cmd =~ /Cmd$/ ) {
                        # Do not check unused word indexers.
                        if ( ( ( $indexer eq 'wv' ) && ( $cmd =~ /^(abiwordCmd)|(antiwordCmd)$/) )
                            or ( ( $indexer eq 'antiword' ) && ( $cmd =~ /^(abiwordCmd)|(wvTextCmd)$/ ) )
                            or ( ( $indexer eq 'abiword'  ) && ( $cmd =~ /^(antiwordCmd)|(wvTextCmd)$/ ) ) ) {
                            next;
                        }
                        # Omit parameters
                        my $executable = ( split( / /, $Foswiki::cfg{StringifierContrib}{$cmd} ) )[0];
                        my $found = 0;
                        # check local dir, then PATH
                        if ( $executable =~ /^\./ ) {
                            if ( -x $executable ) { $found = 1; last; }
                        }
                        for my $check ( map { File::Spec->catfile( $_, $executable ) } @path ) {
                            if ( -x $check ) { $found = 1; last; }
                        }
                        unless ( $found ) {
                            push @offenders, "{StringifierContrib}{$cmd}";
                        }
                    }
                }
                if ( scalar @offenders > 0 ) {
                        $result->{result} = 1;
                        $result->{priority} = ERROR;
                        $result->{solution} = "Check the following StringifierContrib commands: " . join( ', ', @offenders ) . ".";
                }
            }
            return $result;
        },
        experimental => 0
    });
    Foswiki::Plugins::MaintenancePlugin::registerCheck("stringifiercontrib:debug", {
        name => "StringifierContrib debug mode",
        description => "Check if Debug mode is off",
        check => sub {
            my $result = { result => 0 };
            if ($Foswiki::cfg{StringifierContrib}{Debug}) {
                $result->{result} = 1;
                $result->{priority} = 1;
                $result->{solution} = "Disable {StringifierContrib}{Debug} via /bin/configure";
            }
            return $result;
        }
    });
}

1;
