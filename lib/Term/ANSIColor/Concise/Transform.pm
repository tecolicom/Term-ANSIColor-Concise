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
    if    ($mark->{'-'}) { $v - $amnt }
    elsif ($mark->{'+'}) { $v + $amnt }
    elsif ($mark->{'='}) { $amnt }
    elsif ($mark->{'*'}) { $v * $amnt / 100 }
    elsif ($mark->{'%'}) { ($v + $amnt) % ($base || 100) }
}

sub transform {
    my($tones, @rgb24) = @_;
    my $color = Color->rgb(@rgb24);
    while ($tones =~ /(?<tone>(?<m>[-+=*%])(?<c>[A-Za-z])(?<abs>\d*))/xg) {
        my($tone, $m, $c, $abs) = ($+{tone}, $+{m}//'', $+{c}, $+{abs}//0);
        my $com  = { map { $_ => 1 } $c =~ /./g };
        my $mark = { map { $_ => 1 } $m =~ /./g };
        $color = do {
            # Lightness
            if ($com->{l}) {
                my($h, $s, $l) = $color->hsl;
                Color->hsl($h, $s, adjust($l, $abs, $mark));
            }
            # Luminance
            elsif ($com->{y}) {
                $color->luminance(adjust($color->luminance, $abs, $mark));
            }
            # Saturation
            elsif ($com->{s}) {
                my($h, $s, $l) = $color->hsl;
                Color->hsl($h, adjust($s, $abs, $mark), $l);
            }
            # Inverse
            elsif ($com->{i}) {
                Color->rgb(map { 255 - $_ } $color->rgb);
            }
            # Luminance Grayscale
            elsif ($com->{g}) {
                my($h, $s, $l) = $color->hsl;
                my $y = $color->luminance;
                my $g = int($y * 255 / 100);
                Color->rgb($g, $g, $g)
            }
            # Lightness Grayscale
            elsif ($com->{G}) {
                $color->greyscale;
            }
            # Hue / Complement
            elsif ($com->{h} || $com->{c} || $com->{r}) {
                my($h, $s, $l) = $color->hsl;
                my $dig = $com->{c} ? 180 : $abs;
                $dig = -$dig if $mark->{'-'};
                my $c = Color->hsl(($h + $dig) % 360, $s, $l);
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
