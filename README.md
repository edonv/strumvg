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

- [x] Make capitalized strums DOWN (because they're on beat).
- [x] Allow specifying JSON file for configuration options, rather than having to use command-line options for everything.   
- [x] Add font customizing, also maybe classes/CSS/`<style>` for styling SVG.
- [x] Refactored config stuff to use https://github.com/apple/swift-configuration
- [x] Allow `|` to be used as a barline to reset beat counting.
- [ ] Update stem beams to connect between groups if `timing` is 16th note
- [ ] Add to `homebrew`/equivalents?
- [ ] Add step to Action that regex replaces the version number in the strumvg command configuration.
