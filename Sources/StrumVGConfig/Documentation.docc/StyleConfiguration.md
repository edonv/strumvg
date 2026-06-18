# ``StyleConfiguration``

## Overview

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

## Topics

### Instance Properties

- ``colors``
- ``textSizes``
- ``strumSizes``
- ``beamSizes``
- ``barlineSizes``
- ``fonts``

### Structures

- ``StyleConfiguration/Colors``
- ``StyleConfiguration/TextSizes``
- ``StyleConfiguration/StrumSizes``
- ``StyleConfiguration/BeamSizes``
- ``StyleConfiguration/BarlineSizes``
- ``StyleConfiguration/Fonts``
