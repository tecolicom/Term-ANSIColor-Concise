# -*- indent-tabs-mode: nil -*-

package Term::ANSIColor::Concise::Color;

our $VERSION = "2.08";

use v5.14;
use warnings;
use utf8;

use Exporter 'import';
our @EXPORT      = qw();
our @EXPORT_OK   = qw();
our %EXPORT_TAGS = (all => [ @EXPORT_OK ]);

use Data::Dumper;

use parent 'Colouring::In';

sub rgb {
    my $self = shift;
    if (@_) {
        bless $self->SUPER::rgb(@_), $self;
    } else {
        map int, $self->colour;
    }
}

sub hsl {
    my $self = shift;
    if (@_) {
        bless $self->SUPER::hsl(@_), $self;
    } else {
        $self->hslArray;
    }
}

sub hslArray {
    my $color = shift;
    my $hsl = $color->toHSL;
    my @hsl = $hsl =~ /[\d.]+/g;
    @hsl == 3 or die;
    map int($_ + 0.5), @hsl;
}

sub luminance {
    my $color = shift;
    if (@_) {
        $color->set_luminance(@_);
    } else {
        $color->get_luminance;
    }
}

sub get_luminance {
    my $color = shift;
    my($r, $g, $b) = $color->rgb;
    my $y = 0.2126 * $r + 0.7152 * $g + 0.0722 * $b;
    int($y / 255 * 100);
}

sub set_luminance {
    my $color = shift;
    my $target = shift;
    my($h, $s, $ol) = $color->hsl;
    my $y = $color->luminance;
    return $color if abs($y - $target) < 1;
    my($low, $high) = $y < $target ? ($ol, 100) : (0, $ol);
    my @y; @y[0, $ol, 100] = (0, $y, 100);
    my $l = int(
        $low + ($high-$low) * ($target-$y[$low])/($y[$high]-$y[$low]) + 0.5
    );
    my $count = 0;
    my $dist = 2;
    while (abs($y - $target) >= $dist) {
        die "long loop ($count)\n" if ++$count >= 20;
        my $new = __PACKAGE__->hsl($h, $s, $l);
        $y[$l] = my $y = $new->luminance;
        if (abs($y - $target) < $dist) {
            last;
        } elsif ($y < $target) {
            $low = $l;
        } else {
            $high = $l;
        }
        $l = int(($low + $high) / 2 + 0.5);
    }
    __PACKAGE__->hsl($h, $s, $l);
}

1;
