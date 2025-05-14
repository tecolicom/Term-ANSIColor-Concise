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

use List::Util qw(any);
use Colouring::In;

sub transform {
    my($tones, @rgb24) = @_;
    my $color = Colouring::In->rgb(@rgb24);
    while ($tones =~ /(?<tone>(?<sign>[-+])(?<com>[A-Za-z])(?<val>\d*))/xng) {
        my($tone, $sign, $com, $val) = ($+{tone}, $+{sign}//'', $+{com}, $+{val}//0);
        $color = do {
            my @opt = $com =~ /[A-Z]/ ? 'relative' : ();
            my $is = sub { any { lc $com eq $_ } @_ };
            # Lightness
            if ($is->('l')) {
                $sign eq '-' ? $color-> darken("$val%", @opt)
                             : $color->lighten("$val%", @opt);
            }
            # Saturation
            elsif ($is->('s')) {
                $sign eq '-' ? $color->desaturate("$val%", @opt)
                             : $color->  saturate("$val%", @opt);
            }
            # Inverse
            elsif ($is->('i')) {
                $color->rgb(map 255 - $_, $color->colour);
            }
            # Greyscale
            elsif ($is->('g')) {
                $color->greyscale;
            }
            # Hue / Complement
            elsif ($is->(qw'h c')) {
                my $hsl = $color->toHSL;
                my $dig = $is->('c') ? 180 : int $sign.$val;
                $hsl =~ s/(\d+)/($1 + $dig) % 360/e or die "Panic";
                Colouring::In->new($hsl);
            } else {
                die "$tone: Invalid color adjustment parameter.\n";
            }
        };
    }
    map int, $color->colour;
}

1;
