# Copyright (C) 2009 TWIKI.NET (http://www.twiki.net)
# Copyright (C) 2009-2015 Foswiki Contributors
# Copyright (C) 2014-2015 Modell Aachen GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# For licensing info read LICENSE file in the Foswiki root.

package Foswiki::Contrib::Stringifier::Plugins::XLSX;
use Foswiki::Contrib::Stringifier::Base ();
our @ISA = qw( Foswiki::Contrib::Stringifier::Base );

my $xlsx2txt = $Foswiki::cfg{StringifierContrib}{xlsx22txtCmd} || '../tools/xlsx2txt.pl';

__PACKAGE__->register_handler("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", ".xlsx");

use Error qw(:try);

sub stringForFile {
    my ($self, $filename) = @_;
    my $cmd = $xlsx2txt . ' %FILENAME|F% - ';
    my ($text, $error) = Foswiki::Sandbox->sysCommand($cmd, FILENAME => $filename);

    return '' if $error;
    return $text;
}

1;
