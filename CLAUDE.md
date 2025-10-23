# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Term::ANSIColor::Concise is a Perl module that provides a concise notation for generating ANSI terminal color sequences. It supports 256-color and 24-bit true color modes, multiple color spaces (RGB, HSL, LCH, Lab), dynamic color adjustments, and X11 color names.

**Version**: 3.01
**Author**: Kazumasa Utashiro (CPAN ID: UTASHIRO)
**License**: Perl 5 (Artistic 1.0 / GPL 1.0+)

## Resources

- **GitHub Repository**: https://github.com/tecolicom/Term-ANSIColor-Concise
- **Issue Tracker**: https://github.com/tecolicom/Term-ANSIColor-Concise/issues
- **CPAN Page**: https://metacpan.org/release/Term-ANSIColor-Concise
- **CI/CD**: GitHub Actions (`.github/workflows/test.yml`)

### Related Modules

- **Getopt::EX::Colormap** - Command-line option handling with color mapping (this module was originally part of it)
- **App::ansiecho** - Command-line tool for using this module's functions
- **App::Greple** - Text search tool that extensively uses this module
- **Graphics::ColorObject** - Color space conversion backend
- **Graphics::ColorNames::X** - X11 color name database
- **Colouring::In** - Color utilities dependency

## Module Architecture

### Core Modules

- **lib/Term/ANSIColor/Concise.pm** - Main module that exports color generation functions (`ansi_color`, `ansi_code`, `ansi_pair`, `csi_code`). Handles color specification parsing, 256-to-RGB mapping, and ANSI sequence generation.

- **lib/Term/ANSIColor/Concise/ColorObject.pm** - Color space conversion wrapper extending `Graphics::ColorObject`. Provides methods for RGB, HSL, LCH, Lab color spaces and luminance calculations.

- **lib/Term/ANSIColor/Concise/Transform.pm** - Color modification engine that applies dynamic adjustments (lightness, saturation, hue shifts, luminance, complement, inverse, grayscale) using modifier syntax like `+l10`, `-s20`, `=h180`.

- **lib/Term/ANSIColor/Concise/Color.pm** - Legacy color handling interface (check implementation before assuming usage patterns).

- **lib/Term/ANSIColor/Concise/ColorUtils.pm** - Shared utility functions for color operations.

- **lib/Term/ANSIColor/Concise/Table.pm** - Generates visual color tables for displaying the 256-color palette.

- **lib/Term/ANSIColor/Concise/Util.pm** - General utility functions shared across modules.

### Color Processing Pipeline

1. **Input parsing** - Color specs are parsed (e.g., `"R"`, `"505"`, `"#FF0000"`, `"<red>+l10"`, `"hsl(240,100,50)"`)
2. **Color space conversion** - Specs converted to RGB values via ColorObject
3. **Transformation** - Modifiers applied through Transform module (`+l`, `-s`, `=h`, etc.)
4. **Quantization** - RGB values mapped to 256-color palette (or 24-bit if `$RGB24` enabled)
5. **ANSI sequence generation** - Produces appropriate escape sequences with reset codes

### Environment Variables

The module respects several environment variables that control behavior:

- `NO_COLOR` - Disables all color output when set
- `ANSICOLOR_RGB24` / `COLORTERM=truecolor` - Enables 24-bit color mode
- `ANSICOLOR_NO_RESET_EL` - Disables Erase Line sequences in reset codes
- `ANSICOLOR_LINEAR_256` / `ANSICOLOR_LINEAR_GRAY` - Linear vs non-linear color mapping
- `ANSICOLOR_NO_NO_COLOR` - Override NO_COLOR behavior
- `ANSICOLOR_SPLIT_ANSI` - Controls ANSI sequence splitting
- `ANSICOLOR_NO_CUMULATIVE` - Disables cumulative color policy
- `TAC_COLOR_PACKAGE` - Allows plugging alternative ColorObject implementations

## Development Commands

### Building and Installing

This is a Perl module using Minilla and Module::Build::Tiny:

```bash
# Install dependencies
cpanm --installdeps .

# Build distribution tarball
minil dist

# Test distribution build
minil dist --test

# Clean build artifacts
minil clean
```

### Testing

```bash
# Run all tests (recommended)
minil test

# Run all tests with verbose output
prove -lv

# Test specific functionality
perl -Ilib t/01_color.t      # Basic color generation
perl -Ilib t/02_no_color.t   # NO_COLOR environment handling
perl -Ilib t/03_colorspace.t # Color space conversions
perl -Ilib t/04_adjustment.t # Color modification/adjustment

# Test with environment variables
ANSICOLOR_RGB24=1 perl -Ilib t/01_color.t
NO_COLOR=1 perl -Ilib t/02_no_color.t

# Run extended tests (require additional test modules)
prove -l xt/minilla/
```

### Manual Testing

```bash
# Quick color demonstration
perl -Ilib -MTerm::ANSIColor::Concise=:all -e 'print ansi_color("R", "Red text"), "\n"'

# Show 256-color table
perl -Ilib -MTerm::ANSIColor::Concise::Table=:all -e colortable

# Test color transformations
perl -Ilib -MTerm::ANSIColor::Concise=:all -e 'print ansi_color("<red>+l20", "Lightened red"), "\n"'

# Test color spaces
perl -Ilib -MTerm::ANSIColor::Concise=:all -e 'print ansi_color("hsl(240,100,50)", "Blue via HSL"), "\n"'

# Test 24-bit color mode
ANSICOLOR_RGB24=1 perl -Ilib -MTerm::ANSIColor::Concise=:all -e 'print ansi_color("#FF6B35", "True color"), "\n"'
```

### Release Process

This project uses Minilla for releases:

```bash
# Update version and create release
minil release

# Test release process without uploading
minil release --test

# Build distribution
minil dist

# Check distribution
minil dist --test
```

Configuration is in `minil.toml`:
- Uses Module::Build::Tiny as module maker
- Releases to CPAN automatically when on `main` branch
- Badges: GitHub Actions test status and MetaCPAN

## Key Implementation Details

### Color Specification Syntax

The module uses a compact notation system:

- **Basic 8+8 colors**: Single letters (`R`=red, `G`=green, uppercase=normal, lowercase=bright)
- **Effects**: `D`=bold, `U`=underline, `S`=reverse, `I`=italic, `F`=flash, etc.
- **6x6x6 palette**: Three digits 0-5 (e.g., `505`=magenta, `055`=cyan)
- **Gray scales**: `L00` to `L25` (24 gray levels plus black/white)
- **24-bit RGB**: `#RRGGBB`, `#RGB`, `(R,G,B)`, `rgb(R,G,B)`
- **Color spaces**: `hsl(H,S,L)`, `lch(L,C,H)`, `lab(L,a,b)`
- **Named colors**: `<red>`, `<aliceblue>`, `<gray50>` (X11 color names)
- **Modifiers**: Appended to any color spec: `+l10` (lighten), `-s20` (desaturate), `=h180` (set hue), `c` (complement), `i` (invert), `g`/`G` (grayscale)
- **Foreground/background**: Slash separates (`R/G` = red on green background)

### Reset Sequence Strategy

The module generates smart reset sequences using `\e[m\e[K` (RESET + Erase Line) to prevent background color bleeding when scrolling. This can be disabled via `$NO_RESET_EL` or environment variable for terminals that handle `EL` poorly (like Apple Terminal).

For use with `less`, set:
```bash
LESS=-cR
LESSANSIENDCHARS=mK
```

### Color Quantization

For 256-color mode, 24-bit RGB values are mapped using either linear interpolation (`$LINEAR_256`) or a non-linear perceptual mapping (default). Grays are detected when R=G=B and mapped to the 24-step grayscale palette (colors 232-255).

### Cumulative Color Policy

Since version 2.05, the module supports cumulative color application - when applying colors to already-colored text, specifications are combined rather than replaced. This can be disabled via `$NO_CUMULATIVE` or `ANSICOLOR_NO_CUMULATIVE`.

## Testing Philosophy

- Tests use UTF-8 and strict/warnings
- Environment variables are cleared at test start to ensure clean state
- Tests verify both 256-color and 24-bit RGB output modes
- Multi-line text handling and nested color specs are tested
- Color space conversions tested with known reference values
- The `t/getoptlong/` directory is a git submodule for integration testing

## CI/CD

GitHub Actions workflow tests against multiple Perl versions:
- Perl 5.40, 5.38, 5.30, 5.28, 5.24, 5.18, 5.16, 5.14
- Uses `shogo82148/actions-setup-perl` action
- Initializes git submodule for tests
- Installs dependencies via cpanm
- Runs full test suite
