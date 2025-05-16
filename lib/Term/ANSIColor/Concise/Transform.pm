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
use aliased 'Term::ANSIColor::Concise::Color';

sub adjust {
    my($v, $amnt, $mark, $base) = @_;

    if    ($mark->{'='}) { $v  = $amnt }
    elsif ($mark->{'*'}) { $v *= $amnt / 100 }
    else                 { $v += $amnt }

    if    ($mark->{'%'}) { $v %= $base || 100 }
    else                 { $v  = min(100, max(0, $v)) }
}

sub transform {
    my($tones, @rgb24) = @_;
    my $color = Color->rgb(@rgb24);
    while ($tones =~ /(?<tone>(?<m>[-+=*%])(?<c>[A-Za-z])(?<abs>\d*))/xg) {
        my($tone, $m, $c, $abs) = ($+{tone}, $+{m}//'', $+{c}, $+{abs}//0);
        my $val  = $m eq '-' ? -$abs : $abs;
        my $com  = { map { $_ => 1 } $c =~ /./g };
        my $mark = { map { $_ => 1 } $m =~ /./g };
        $color = do {
            # Lightness
            if ($com->{l}) {
                my($h, $s, $l) = $color->hsl;
                $l = $mark->{'='} ? $val : adjust($l, $val, $mark);
                Color->hsl($h, $s, $l);
            }
            # Luminance
            elsif ($com->{y}) {
                my $y = $color->luminance;
                my($h, $s, $l) = $color->hsl;
                my $ny = $mark->{'='} ? $val : adjust($y, $val, $mark);
                $color->luminance($ny);
            }
            # Saturation
            elsif ($com->{s}) {
                if ($mark->{'='}) {
                    my($h, $s, $l) = $color->hsl;
                    Color->hsl($h, $val, $l);
                } else {
                    my @opt = $mark->{'*'} ? 'relative' : ();
                    $mark->{'-'} ? $color->desaturate("$abs%", @opt)
                                 : $color->  saturate("$abs%", @opt);
                }
            }
            # Inverse
            elsif ($com->{i}) {
                $color->rgb(map 255 - $_, $color->rgb);
            }
            # Greyscale
            elsif ($com->{g}) {
                $color->greyscale;
            }
            # Hue / Complement
            elsif ($com->{h} || $com->{c} || $com->{r}) {
                my($h, $s, $l) = $color->hsl;
                my $dig = $com->{c} ? 180 : $val;
                $h = ($h + $dig) % 360;
                my $c = Color->hsl($h, $s, $l);
                $com->{r} ? $c->luminance($color->luminance)
                          : $c;
            }
            else {
                die "$tone: Invalid color adjustment parameter.\n";
            }
        };
    }
    $color->rgb;
}

1;
