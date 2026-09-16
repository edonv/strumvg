# strumvg

A command-line tool for generating SVG of a guitar strumming pattern from a formatted string.

## Usage

### First Time

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

INPUT/OUTPUT OPTIONS:
  -i, --stdin/-a, --arg=<pattern>
                          Source for input pattern string. (default: --stdin)
  -o, --stdout/-l, --log/-f, --file=<file-path>.svg
                          Destination for output SVG content. (default: --stdout)

OPTIONS:
  -h, --help              Show help information.
```

### String Format

The string format is as follows:

```
[|][:]<noteLength>[/subdivision][t]-<pattern>[:][|]
```

#### `noteLength`

`noteLength` dictates what duration each counted beat is:

- `4`: 1/4 (quarter) notes
- `8`: 1/8 (eighth) notes
- `16`: 1/16 (sixteenth) notes

#### `subdivision`

`subdivision` can optionally be provided (prefixed with a `/`) to specify the number of subdivisions the beat should be broken into:

- `1`: no subdivision
  - Example: "1 2 3 4", etc.
- `2`: two subdivisions
  - Example: "1 + 2 + 3 + 4 +", etc.
- `3`: three subdivisions
  - This will be treated as though `noteLength` is dotted, so that each beat is "dotted `noteLength`".
  - Example: "1 + a 2 + a 3 + a 4 + a", etc.
- `4`: four subdivisions
  - Example: "1 e + a 2 e + a 3 e + a 4 e + a", etc.

If ommitted, it will default to a subdivision of `1`.

#### `t`

`t` can optionally be specified to generically define the rhythm as a "tuplet," and is not specific to a subdivision of 3. When present, the output will mark every beat grouping with the number of subdivisions (such as a triplet if `subdivision` is `3`, or as a duplet if `subdivision` is `2`).

#### `pattern`

`pattern` can be any of the following characters:

- `D`/`d`: Down-stroke
- `u`/`U`: Up-stroke
- `M`: Muted down-stroke
- `m`: Muted up-stroke
- `A`: Arpeggio down-stroke
- `a`: Arpeggio up-stroke
- <code>&nbsp;</code>: Pause
- `r`: Rest
- Any other character (except for `|`/`:`) is just inserted

Optionally, each strum in `pattern` can have a heading character. To indicate this in the formatted string, wrap any given character in curly braces (`{` and `}`) and preface the character with the heading character.

#### Multiple Measures (`|`)

Additionally, patterns can contain multiple measures of strums, specified by separating measures with `|` (pipe) characters.

Multiple measures can even have different rhythmic groupings (`noteLength`) by specifying the note length at the start of each measure. While the first measure must always have a timing specification, following measures can omit it if it should use the same timing as the previous measure.

#### Repeats (`:`)

Patterns can have repeats as well. Repeat signs (`:`) can be specified at the start or end of a measure, just after or before (respectively) a barline. If a measure has a repeat sign at the start AND includes a timing specification, the repeat sign must come first.

Repeats can also span multiple measures, though the program does validate that repeat signs are in logical positions in the pattern. That is, a pattern such as `|:4-d d d d |: u u u u|` will fail to validate, as each "starting repeat" sign doesn't have a matching "ending".

### Examples

Basic Examples:

```
8-{xD}f{xu}AaMmr
16/3t-D  D u  uD u
4-D umarDx
```

Barline/Multi-Measure Examples:

```
|8-DuD D  u|
|8-DuD D  u
8-DuD D  u|
|:8-DuD D  u:|
|:4-DuD D  u:|:D DuDu :|
|:8-DuD D  u|4-D DuDu :|
|2/4-d d d du|: ud d du:|
```

### Styling

To customize the output, you can use a combination of a JSON/YAML configuration file and CLI arguments. For the JSON schema, [see here](./.github/strumvg-schema.json).

Any property available in a config file can be specified in a CLI argument. Nested properties are just linked together with dashes, and the argument starts with a double dash (`--`). Any standard syntax for providing a value for an option is supported. Any properties that use camel case (i.e. `beamSizes.strokeWidth`) are converted to kebab case (i.e. `--beam-sizes-stroke-width`).

Example:

```json
{
    "colors": {
        "arrows": "blue",
        "rhythms": "yellow",
        "headers": "green"
    }
}
```

is equivalent to:

```shell
strumvg ... --colors-arrows blue --colors-rhythms="yellow" --colors-headers=green
```

## To-Do's

- [x] FIX ISSUE WITH INCOMPLETE NUMBER OF BEATS PER GROUP NOT GETTING BEAMS/STEMS
- [x] Make capitalized strums DOWN (because they're on beat).
- [x] Allow specifying JSON file for configuration options, rather than having to use command-line options for everything.   
- [x] Add font customizing, also maybe classes/CSS/`<style>` for styling SVG.
- [x] Refactored config stuff to use https://github.com/apple/swift-configuration
- [x] Allow `|` to be used as a barline to reset beat counting.
- [ ] Figure out some way to better vertically center header, count, and strum characters
    - `dominant-baseline`/`alignment-baseline` don't work when embedded in PDFs by ChordPro
- [x] Add testing suite for testing parsing of pattern strings
    - [x] Move all saved pattern string arguments into a test suite
- [ ] Add JSON schema docs generator with GitHub Actions to host with GitHub Pages (`.github/docs`)
- [ ] Update stem beams to connect between groups if `timing` is 16th note
- [ ] Add to `homebrew`/equivalents?
- [ ] Add step to Action that regex replaces the version number in the strumvg command configuration.
- [x] Replace rhythmic indicator with some sort of combo of time signature and subdivision
    - Examples:
        - 2/2 with 16th note subdivision
        - 4/4 with 4th note sub
        - 3/4 with 8th note sub
        - 6/8 with dotted 4th sub or 8th note sub
    - have a default subdivision per possible time signature
    - [x] What to do when `noteLength` should have flags/beams, but `subdivision` is `1` (no notes will be beamed together)?
- [ ] Option to hide `3` when in triplet (or 6/8 or 12/8)
- [ ] Add repeats
- [ ] Move/namespace `StrumKind` and `Variant`
- [ ] Add support for additional `subdivision` values
- [ ] Update style configuration types to be generated from JSON Schema then implement `swift-configuration` initializers via extension
