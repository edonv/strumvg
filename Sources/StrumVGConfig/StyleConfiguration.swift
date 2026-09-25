//
//  StyleConfiguration.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import Configuration
import JSONSchemaBuilder
import JSONSchemaConversion

/// Configurable properties for customizing the SVG output of `strumvg`.
///
/// Size-related properties are either an SVG user unit measurement or a ratio relative to another concrete property.
@Schemable(optionalNulls: false)
@SchemaOptions(
    .title("strumvg Style Configuration"),
    .description("Configurable properties for customizing the SVG output of `strumvg`.\n\nSize-related properties are either an SVG user unit measurement or a ratio relative to another concrete property."),
)
public struct StyleConfiguration: Codable {
    /// Styling related to colors.
    public let colors: Colors
    /// Styling related to text sizes.
    public let textSizes: TextSizes
    /// Styling related to strum sizes.
    public let strumSizes: StrumSizes
    /// Styling related to beam sizes.
    public let beamSizes: BeamSizes
    /// Styling related to barline sizes.
    public let barlineSizes: BarlineSizes
    /// Styling relating to repeats.
    public let repeats: Repeats
    /// Styling related to fonts.
    public let fonts: Fonts
    
    /// Color styling properties
    ///
    /// Color values can be any string recognized by [SVG/CSS as a color](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value).
    @Schemable(optionalNulls: false)
    public struct Colors: Codable {
        /// The color of the arrows.
        @SchemaOptions(.default(.string("#000000")), .examples(SVGColorValue.examples))
        public let arrows: String
        /// The color of the rhythm text and stems below the arrows.
        @SchemaOptions(.default(.string("#555555")), .examples(SVGColorValue.examples))
        public let rhythms: String
        /// The color of the articulations and header text above the arrows.
        @SchemaOptions(.default(.string("#000000")), .examples(SVGColorValue.examples))
        public let headers: String
        /// The color of the barlines.
        @SchemaOptions(.default(.string("#000000")), .examples(SVGColorValue.examples))
        public let barlines: String
        /// The color of the repeat signs.
        @SchemaOptions(.default(.string("#000000")), .examples(SVGColorValue.examples))
        public let repeats: String
        
        public init(
            arrows: String,
            rhythms: String,
            headers: String,
            barlines: String,
            repeats: String
        ) {
            self.arrows = arrows
            self.rhythms = rhythms
            self.headers = headers
            self.barlines = barlines
            self.repeats = repeats
        }
        
        public init(config: ConfigReader) {
            self.init(
                arrows: config.string(
                    forKey: "arrows",
                    default: "#000000"
                ),
                rhythms: config.string(
                    forKey: "rhythms",
                    default: "#555555"
                ),
                headers: config.string(
                    forKey: "headers",
                    default: "#000000"
                ),
                barlines: config.string(
                    forKey: "barlines",
                    default: "#000000"
                ),
                repeats: config.string(
                    forKey: "repeats",
                    default: "#000000"
                )
            )
        }
    }
    
    /// Text sizing properties
    ///
    /// Properties denoted as a "height" refer to the amount of vertical space (in SVG user units) that will be reserved for that text.
    ///
    /// Properties denoted as a "font size" will translate to the `font-size` attribute.
    @Schemable(optionalNulls: false)
    public struct TextSizes: Codable {
        /// The height of the space reserved for rhythm text below the arrows.
        @SchemaOptions(.default(30))
        @NumberOptions(.minimum(0))
        public let beatTextHeight: CGFloat
        /// The relative font-size of the rhythm text below the arrows, as a fraction of ``beatTextHeight``.
        @SchemaOptions(.default(0.8))
        @NumberOptions(.minimum(0))
        public let beatFontSizeRatio: CGFloat
        /// The height of the space reserved for articulations and header text above the arrows.
        @SchemaOptions(.default(30))
        @NumberOptions(.minimum(0))
        public let headerTextHeight: CGFloat
        /// The relative font-size of the articulations and header text above the arrows, as a fraction of ``headerTextHeight``.
        @SchemaOptions(.default(0.8))
        @NumberOptions(.minimum(0))
        public let headerFontSizeRatio: CGFloat
        /// The actual font-size of the tuplet label, if applicable.
        @SchemaOptions(.default(14))
        @NumberOptions(.minimum(0))
        public let tupletFontSize: CGFloat
        
        /// The actual font size to use for beat text, computed automatically.
        package var beatFontSize: CGFloat {
            beatTextHeight * beatFontSizeRatio
        }
        
        /// The actual font size to use for header text, computed automatically.
        package var headerFontSize: CGFloat {
            headerTextHeight * headerFontSizeRatio
        }
        
        /// The vertical space between a tuplet beam and the tuplet text.
        private static let tuplet3TextGap: CGFloat = 2
        /// The vertical offset between the bottom of a `RhythmicGroup`'s beams and the baseline of the tuplet text.
        package var tuplet3TextOffsetY: CGFloat {
            tupletFontSize + TextSizes.tuplet3TextGap
        }
        
        public init(
            beatTextHeight: CGFloat,
            beatFontSizeRatio: CGFloat,
            headerTextHeight: CGFloat,
            headerFontSizeRatio: CGFloat,
            tupletFontSize: CGFloat
        ) {
            self.beatTextHeight = beatTextHeight
            self.beatFontSizeRatio = beatFontSizeRatio
            self.headerTextHeight = headerTextHeight
            self.headerFontSizeRatio = headerFontSizeRatio
            self.tupletFontSize = tupletFontSize
        }
        
        public init(config: ConfigReader) {
            self.init(
                beatTextHeight: config.cgFloat(
                    forKey: "beatTextHeight",
                    default: 30
                ),
                beatFontSizeRatio: config.cgFloat(
                    forKey: "beatFontSizeRatio",
                    default: 0.8
                ),
                headerTextHeight: config.cgFloat(
                    forKey: "headerTextHeight",
                    default: 30
                ),
                headerFontSizeRatio: config.cgFloat(
                    forKey: "headerFontSizeRatio",
                    default: 0.8
                ),
                tupletFontSize: config.cgFloat(
                    forKey: "tupletFontSize",
                    default: 14
                )
            )
        }
    }
    
    /// Strum sizing properties
    @Schemable(optionalNulls: false)
    public struct StrumSizes: Codable {
        /// The width of the space reserved for each strum arrow.
        ///
        /// This is the width of the space reserved for each "rhythmic column" composed of arrow, header text, and beat text. It also defines the maximum width of a strum's arrowhead.
        @SchemaOptions(.default(20))
        @NumberOptions(.minimum(0))
        public let width: CGFloat
        /// The height of each strum arrow.
        @SchemaOptions(.default(80))
        @NumberOptions(.minimum(0))
        public let height: CGFloat
        /// The relative stroke width of a strum arrow's lines, as a fraction of ``width``.
        @SchemaOptions(.default(0.2))
        @NumberOptions(.minimum(0))
        public let strokeWidthRatio: CGFloat
        /// The horizontal space between each strum.
        @SchemaOptions(.default(30))
        @NumberOptions(.minimum(0))
        public let gap: CGFloat
        
        /// The computed stroke width of a strum arrow's lines.
        package var strokeWidth: CGFloat {
            width * strokeWidthRatio
        }
        
        /// The relative height of an arrow's head, as a fraction of ``height``.
        private static let arrowHeadHeightRatio: CGFloat = 0.2
        /// The computed height of a strum arrow's line.
        package var arrowLineHeight: CGFloat {
            height * (1 - StrumSizes.arrowHeadHeightRatio)
        }
        /// The computed height of a strum arrow's head.
        package var arrowHeadHeight: CGFloat {
            height * StrumSizes.arrowHeadHeightRatio
        }
        
        /// Used as the `font-size` for characters inserts as strums.
        package var charStrumTextSize: CGFloat {
            height / 2
        }
        
        public init(
            width: CGFloat,
            height: CGFloat,
            strokeWidthRatio: CGFloat,
            gap: CGFloat
        ) {
            self.width = width
            self.height = height
            self.strokeWidthRatio = strokeWidthRatio
            self.gap = gap
        }
        
        public init(config: ConfigReader) {
            self.init(
                width: config.cgFloat(forKey: "width", default: 20),
                height: config.cgFloat(forKey: "height", default: 80),
                strokeWidthRatio: config.cgFloat(forKey: "strokeWidthRatio", default: 0.2),
                gap: config.cgFloat(forKey: "gap", default: 30)
            )
        }
    }
    
    /// Beam and rhythmic-grouping sizing properties
    @Schemable(optionalNulls: false)
    public struct BeamSizes: Codable {
        /// The stroke width of the rhythm stems/beams below the arrows.
        @SchemaOptions(.default(2))
        @NumberOptions(.minimum(0))
        public let strokeWidth: CGFloat
        /// The vertical length of the beam stems.
        @SchemaOptions(.default(8))
        @NumberOptions(.minimum(0))
        public let stemHeight: CGFloat
        /// The width of a stem's flag.
        ///
        /// This is only used when each beat's duration is an eighth note or shorter and is not being subdivided.
        @SchemaOptions(.default(5))
        @NumberOptions(.minimum(0))
        public let flagWidth: CGFloat
        
        /// Space out beams by `1.5 * strokeWidth`, or `1` (whichever is larger)
        package var beamStrokeVerticalGap: CGFloat {
            max(1.5 * strokeWidth, 1)
        }
        
        public init(strokeWidth: CGFloat, stemHeight: CGFloat, flagWidth: CGFloat) {
            self.strokeWidth = strokeWidth
            self.stemHeight = stemHeight
            self.flagWidth = flagWidth
        }
        
        public init(config: ConfigReader) {
            self.init(
                strokeWidth: config.cgFloat(forKey: "strokeWidth", default: 2),
                stemHeight: config.cgFloat(forKey: "stemHeight", default: 12),
                flagWidth: config.cgFloat(forKey: "flagWidth", default: 5)
            )
        }
    }
    
    /// Barline sizing properties
    @Schemable(optionalNulls: false)
    public struct BarlineSizes: Codable {
        /// The stroke width of the barlines.
        @SchemaOptions(.default(2))
        @NumberOptions(.minimum(0))
        public let strokeWidth: CGFloat
        /// The relative height of a barline, as a fraction of ``StyleConfiguration/StrumSizes/height``.
        @SchemaOptions(.default(1.25))
        @NumberOptions(.minimum(0))
        public let heightRatio: CGFloat
        /// The relative width of a gap between a barline and adjacent "rhythmic columns", as a fraction of ``StyleConfiguration/StrumSizes/gap``.
        @SchemaOptions(.default(0.5))
        @NumberOptions(.minimum(0))
        public let gapRatio: CGFloat
        
        /// Computed height of a barline, using ``StyleConfiguration/StrumSizes`` as a reference point.
        package func height(withStrumSizes strumSizes: StrumSizes) -> CGFloat {
            strumSizes.height * heightRatio
        }
        
        /// Computed gap width on either side of a barline, using ``StyleConfiguration/StrumSizes`` as a reference point.
        package func gap(withStrumSizes strumSizes: StrumSizes) -> CGFloat {
            strumSizes.gap * gapRatio
        }
        
        public init(
            strokeWidth: CGFloat,
            heightRatio: CGFloat,
            gapRatio: CGFloat
        ) {
            self.strokeWidth = strokeWidth
            self.heightRatio = heightRatio
            self.gapRatio = gapRatio
        }
        
        public init(config: ConfigReader) {
            self.init(
                strokeWidth: config.cgFloat(forKey: "strokeWidth", default: 2),
                heightRatio: config.cgFloat(forKey: "heightRatio", default: 1.25),
                gapRatio: config.cgFloat(forKey: "gapRatio", default: 0.5)
            )
        }
    }
    
    /// Repeats sizing properties
    @Schemable(optionalNulls: false)
    public struct Repeats: Codable {
        /// The relative distance repeat signs' horizontal centers are away from the barline, as a fraction of the gap between a barline and its adject strums.
        @SchemaOptions(.default(0.5))
        @NumberOptions(.minimum(0))
        public let horizontalInsetRatio: CGFloat
        /// The relative distance each repeat sign dot's vertical center is inset from the top or bottom of the height of the strum arrows, as a fraction of ``StyleConfiguration/StrumSizes/height``.
        @SchemaOptions(.default(0.333))
        @NumberOptions(.minimum(0))
        public let verticalInsetRatio: CGFloat
        /// Radius of the repeat signs' dots.
        @SchemaOptions(.default(3))
        @NumberOptions(.minimum(0))
        public let dotRadius: CGFloat
        
        public init(
            horizontalInsetRatio: CGFloat,
            verticalInsetRatio: CGFloat,
            dotRadius: CGFloat
        ) {
            self.horizontalInsetRatio = horizontalInsetRatio
            self.verticalInsetRatio = verticalInsetRatio
            self.dotRadius = dotRadius
        }
        
        public init(config: ConfigReader) {
            self.init(
                horizontalInsetRatio: config.cgFloat(forKey: "horizontalInsetRatio", default: 0.5),
                verticalInsetRatio: config.cgFloat(forKey: "verticalInsetRatio", default: 1 / 3),
                dotRadius: config.cgFloat(forKey: "dotRadius", default: 3)
            )
        }
    }
    
    /// Font properties
    @Schemable(optionalNulls: false)
    public struct Fonts: Codable {
        /// Font styling for header text.
        @SchemaOptions(
            .customSchema(Styling.self),
            .default([
                "family": "sans-serif",
                "weight": "bold",
                "style": "normal"
            ])
        )
        public let strumHeader: Styling
        /// Font styling for text inserted in place of arrows.
        @SchemaOptions(
            .customSchema(Styling.self),
            .default([
                "family": "sans-serif",
                "weight": "bold",
                "style": "normal"
            ])
        )
        public let arrowText: Styling
        /// Font styling for rhythm count text.
        @SchemaOptions(
            .customSchema(Styling.self),
            .default([
                "family": "sans-serif",
                "weight": "bold",
                "style": "normal"
            ])
        )
        public let countChar: Styling
        /// Font styling for tuplet labels (`"3"`), if applicable.
        @SchemaOptions(
            .customSchema(Styling.self),
            .default([
                "family": "sans-serif",
                "weight": "normal",
                "style": "normal"
            ])
        )
        public let tupletText: Styling
        
        public init(
            strumHeader: Styling,
            arrowText: Styling,
            countChar: Styling,
            tupletText: Styling
        ) {
            self.strumHeader = strumHeader
            self.arrowText = arrowText
            self.countChar = countChar
            self.tupletText = tupletText
        }
        
        public init(config: ConfigReader) {
            self.init(
                strumHeader: .init(
                    config: config.scoped(to: "strumHeader"),
                    default: .default.bold
                ),
                arrowText: .init(
                    config: config.scoped(to: "arrowText"),
                    default: .default.bold
                ),
                countChar: .init(
                    config: config.scoped(to: "countChar"),
                    default: .default.bold
                ),
                tupletText: .init(
                    config: config.scoped(to: "tupletText"),
                    default: .default
                )
            )
        }
        
        /// A set of font specification properties.
        ///
        /// Includes values for `font-family`, `font-weight`, and `font-style` attributes.
        @Schemable(optionalNulls: false)
        public struct Styling: Codable {
            public typealias Weight = SVGFontWeightValue
            public typealias Style = SVGFontStyleValue
            
            /// Font family name.
            ///
            /// Values can be any string recognized by [SVG/CSS as a font family](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-family).
            ///
            /// Attribute: `font-family`
            public let family: String
            /// Font weight.
            ///
            /// Values can be any string recognized by [SVG/CSS as a font weight](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-weight).
            ///
            /// Attribute: `font-weight`
            public let weight: Weight
            /// Font style.
            ///
            /// Values can be any string recognized by [SVG/CSS as a font style](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-style).
            ///
            /// Attribute: `font-style`
            public let style: Style
            
            public init(family: String, weight: Weight, style: Style) {
                self.family = family
                self.weight = weight
                self.style = style
            }
            
            fileprivate init(
                config: ConfigReader,
                default defaultValue: Styling
            ) {
                self.init(
                    family: config.string(
                        forKey: "family",
                        default: defaultValue.family
                    ),
                    weight: config.svgFontWeight(
                        forKey: "weight",
                        default: defaultValue.weight
                    ),
                    style: config.svgFontStyle(
                        forKey: "style",
                        default: defaultValue.style
                    )
                )
            }
            
            public static var `default`: Styling {
                .init(
                    family: "sans-serif",
                    weight: .normal,
                    style: .normal
                )
            }
            
            public var bold: Styling {
                .init(
                    family: family,
                    weight: .bold,
                    style: style
                )
            }
        }
    }
}

// MARK: - ConfigReader

extension StyleConfiguration {
    public init(config: ConfigReader) {
        self.init(
            colors: .init(config: config.scoped(to: "colors")),
            textSizes: .init(config: config.scoped(to: "textSizes")),
            strumSizes: .init(config: config.scoped(to: "strumSizes")),
            beamSizes: .init(config: config.scoped(to: "beamSizes")),
            barlineSizes: .init(config: config.scoped(to: "barlineSizes")),
            repeats: .init(config: config.scoped(to: "repeats")),
            fonts: .init(config: config.scoped(to: "fonts"))
        )
    }
}
