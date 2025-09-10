# strumvg

## Usage

The first time you run `strumvg` on macOS, you'll need to call the following command to give your computer permission:

```shell
chmod 755 strumvg-macos
xattr -d com.apple.quarantine strumvg-macos
```

### Help

```
OVERVIEW: A command for generating an SVG of a strumming pattern.

Any SVG-compatible value can be used for any option.

USAGE: strumvg [<options>] [<pattern-string>]

ARGUMENTS:
  <pattern-string>        The string representation of a pattern.

IN/OUT OPTIONS:
  -i, --stdin/-a, --arg   Source for input pattern string. (default: -a)
  -o, --stdout/-l, --log  Destination for output SVG content. (default: -l)

CONFIGURATION:
  --arrow-color <arrow-color>
                          The color of the arrows. (default: #000000)
  --rhythm-color <rhythm-color>
                          The color of the rhythm text and stems below the
                          arrows. (default: #555555)
  --header-color <header-color>
                          The color of the articulations and header text above
                          the arrows. (default: #000000)
  --beat-text-height <beat-text-height>
                          The height of the space reserved for rhythm text
                          below the arrows. (default: 30.0)
  --beat-font-size <beat-font-size>
                          The actual font-size of the rhythm text below the
                          arrows, relative to its height. (default: 0.8)
  --header-text-height <header-text-height>
                          The height of the space reserved for articulations
                          and header text above the arrows. (default: 30.0)
  --header-font-size <header-font-size>
                          The actual font-size of the articulations and header
                          text above the arrows, relative to its height.
                          (default: 0.8)
  --triplet-font-size <triplet-font-size>
                          The actual font-size of the triplet label, if
                          applicable. (default: 14.0)
  --strum-width <strum-width>
                          The width of each strum arrow. (default: 20.0)
        This is also the width of the space reserved for each "rhythmic column"
        composed of arrow, header text, and beat text.
  --strum-height <strum-height>
                          The height of each strum arrow. (default: 80.0)
  --strum-gap <strum-gap> The horizontal space between each strum  (default:
                          30.0)
  --beam-stroke-width <beam-stroke-width>
                          The stroke width of the rhythm stems/beams below the
                          arrows. (default: 2.0)
  --beam-steam-height <beam-steam-height>
                          The vertical length of the beam stems. (default: 8.0)

OPTIONS:
  -h, --help              Show help information.
```

### String Format

The string format is as follows:

`[pattern]-[noteLength]`

`pattern` can be any of the following characters:

- `D`/`d`: Down-stroke
- `u`/`U`: Up-stroke
- `M`: Muted down-stroke
- `m`: Muted up-stroke
- `A`: Arpeggio down-stroke
- `a`: Arpeggio up-stroke
- <code>&nbsp;</code>: Pause
- `r`: Rest
- Any other character (except for `-`) is just inserted

`noteLength` can be any of the following characters:

- `4`: 1/4 (quarter) notes
- `8`: 1/8 (eighth) notes
- `16`: 1/16 (sixteenth) notes
- `4t`: Triplet 1/4 notes
- `8t`: Triplet 1/8 notes
- `16t`: Triplet 1/16 notes

Optionally, each note in `pattern` can have a heading character. To indicate this in the formatted string, wrap any given character in curly braces (`{` and `}`) and preface the character with the heading character.

Examples:

- `{xD}f{xu}AaMmr-8`
- `D  D u  uD u-16t`
- `D umarDx-4`

## To-Do's

- [x] Make capitalized strums DOWN (because they're on beat).
- [x] Allow specifying JSON file for configuration options, rather than having to use command-line options for everything.   
- [x] Add font customizing, also maybe classes/CSS/`<style>` for styling SVG.
- [ ] Allow `|` to be used as a barline to reset beat counting.
- [ ] Add to `homebrew`/equivalents?
- [ ] Add step to Action that regex replaces the version number in the strumvg command configuration.
