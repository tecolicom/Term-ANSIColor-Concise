# -*- indent-tabs-mode: nil -*-

package Term::ANSIColor::Concise::Transform;

our $VERSION = "2.08";

use v5.14;
use warnings;
use utf8;

use Exporter 'import';
our @EXPORT      = qw();
our @EXPORT_OK   = qw(transform);
our %EXPORT_TAGS = (all => [ @EXPORT_OK ]);

use Data::Dumper;
use List::Util qw(min max any);
use Colouring::In;

our %TOOL = %Colouring::In::TOOL;

sub hsl {
    my $color = shift;
    my $hsl = $color->toHSL;
    my @hsl = $hsl =~ /[\d.]+/g;
    @hsl == 3 or die;
    @hsl;
}

sub adjust {
    my($v, $amnt, $mark, $base) = @_;
    my %mark = map { $_ => 1 } $mark =~ /./g;

    if    ($mark{'='}) { $v  = $amnt }
    elsif ($mark{'*'}) { $v *= $amnt / 100 }
    else               { $v += $amnt }

    if    ($mark{'%'}) { $v %= $base || 100 }
    else               { $v = min(100, max(0, $v)) }
}

sub transform {
    my($tones, @rgb24) = @_;
    my $color = Colouring::In->rgb(@rgb24);
    while ($tones =~ /(?<tone>(?<mark>[-+*%])(?<com>[A-Za-z])(?<abs>\d*))/xng) {
        my($tone, $mark, $com, $abs) = ($+{tone}, $+{mark}//'', $+{com}, $+{abs}//0);
        my $val = $mark eq '-' ? -$abs : $abs;
        my %com = map { $_ => 1 } $com =~ /./g;
        $color = do {
            my $is = sub { any { lc $com eq $_ } @_ };
            # Lightness
            if ($com{l}) {
                my($h, $s, $l) = hsl($color);
                $l = adjust($l, $val, $mark);
                Colouring::In->hsl($h, $s, $l);
            }
            # Saturation
            elsif ($com{s}) {
                my @opt = $mark eq '*' ? 'relative' : ();
                $mark eq '-' ? $color->desaturate("$abs%", @opt)
                             : $color->  saturate("$abs%", @opt);
            }
            # Inverse
            elsif ($com{i}) {
                $color->rgb(map 255 - $_, $color->colour);
            }
            # Greyscale
            elsif ($com{g}) {
                $color->greyscale;
            }
            # Hue / Complement
            elsif ($com{h} || $com{c}) {
                my($h, $s, $l) = hsl($color);
                my $dig = $com{c} ? 180 : $val;
                $h = ($h + $dig) % 360;
                Colouring::In->hsl($h, $s, $l);
            }
            else {
                die "$tone: Invalid color adjustment parameter.\n";
            }
        };
    }
    map int, $color->colour;
}

1;
