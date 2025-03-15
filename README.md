# strumvg

## Usage

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
- [ ] Allow specifying JSON file for configuration options, rather than having to use command-line options for everything.   
- [ ] Add font customizing, also maybe classes/CSS/`<style>` for styling SVG.
- [ ] Allow `|` to be used as a barline to reset beat counting.
- [ ] Add to `homebrew`/equivalents?
