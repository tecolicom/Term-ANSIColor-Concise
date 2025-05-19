# -*- indent-tabs-mode: nil -*-

=head1 SEE ALSO

L<Graphics::ColorObject>

L(<https://qiita.com/yoya/items/96c36b069e74398796f3>

=cut

package Term::ANSIColor::Concise::ColorObject;

our $VERSION = "2.08";

use v5.14;
use warnings;
use utf8;

use Data::Dumper;
use parent 'Graphics::ColorObject';

package Graphics::ColorObject {
    no warnings 'redefine';
    my $namecolor = \&__PACKAGE__::namecolor;
    *namecolor = sub {
        return undef if not defined $_[1];
        goto $namecolor;
    }
}

sub rgb {
    my $self = shift;
    my $class = ref $self ? ref $self : $self;
    if (@_) {
        bless $self->SUPER::new_RGB255(\@_), $class;
    } else {
        map int, @{$self->as_RGB255};
    }
}

sub hsl {
    my $self = shift;
    my $class = ref $self ? ref $self : $self;
    if (@_) {
        my($h, $s, $l) = @_;
        bless $self->SUPER::new_HSL([ $h, $s/100, $l/100 ]), $class;
    } else {
        my($h, $s, $l) = @{$self->as_HSL};
        map int, ($h, $s * 100, $l * 100);
    }
}

sub lab {
    my $self = shift;
    my $class = ref $self ? ref $self : $self;
    if (@_) {
        my($L, $a, $b) = @_;
        bless Graphics::ColorObject->new_Lab([ $L, $a, $b]), $class;
    } else {
        my($L, $a, $b) = @{$self->as_Lab};
        map int, ($L, $a, $b);
    }
}

sub luv {
    my $self = shift;
    my $class = ref $self ? ref $self : $self;
    if (@_) {
        my($L, $u, $v) = @_;
        bless Graphics::ColorObject->new_Luv([ $L, $u / 100, $v / 100]), $class;
    } else {
        my($L, $u, $v) = @{$self->as_Lab};
        map int, ($L, $u * 100, $v * 100);
    }
}

sub luminance {
    my $color = shift;
    if (@_) {
        $color->set_luminance(@_);
    } else {
        $color->get_luminance;
    }
}

use List::Util qw(pairs);

sub set {
    my $map = shift;
    $_[$_->[0]] = $_->[1] for pairs @$map;
    @_;
}

our %LUM = (Lab => 1);

sub get_luminance {
    my $color = shift;
    if    ($LUM{Lab}) { int $color->as_Lab->[0] }
    elsif ($LUM{Luv}) { int $color->as_Luv->[0] }
    elsif ($LUM{HSL}) { int($color->as_HSL->[2] * 100) }
    else { die }
}

sub set_luminance {
    my $color = shift;
    my $L = shift;
    if    ($LUM{Lab}) { __PACKAGE__->lab(set([ 0 => $L ], $color->lab)) }
    elsif ($LUM{Luv}) { __PACKAGE__->luv(set([ 0 => $L ], $color->luv)) }
    elsif ($LUM{HSL}) { __PACKAGE__->hsl(set([ 2 => $L ], $color->hsl)) }
    else { die }
}

1;
