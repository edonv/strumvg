//
//  StyleConfiguration.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import Configuration

public struct StyleConfiguration: Codable {
    public let colors: Colors
    public let textSizes: TextSizes
    public let strumSizes: StrumSizes
    public let beamSizes: BeamSizes
    public let barlineSizes: BarlineSizes
    public let fonts: Fonts
    
    public struct Colors: Codable {
        /// The color of the arrows.
        ///
        /// Default value: `#000000` (black)
        public let arrows: String
        /// The color of the rhythm text and stems below the arrows.
        public let rhythms: String
        /// The color of the articulations and header text above the arrows.
        public let headers: String
        /// The color of the barlines.
        /// > Default: `#000000` (black)
        public let barlines: String
        
        public init(
            arrows: String,
            rhythms: String,
            headers: String,
            barlines: String
        ) {
            self.arrows = arrows
            self.rhythms = rhythms
            self.headers = headers
            self.barlines = barlines
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
                )
            )
        }
    }
    
    public struct TextSizes: Codable {
        /// The height of the space reserved for rhythm text below the arrows.
        public let beatTextHeight: CGFloat
        /// The relative font-size of the rhythm text below the arrows, as a fraction of its height.
        public let beatFontSizeRatio: CGFloat
        /// The height of the space reserved for articulations and header text above the arrows.
        public let headerTextHeight: CGFloat
        /// The relative font-size of the articulations and header text above the arrows, as a fraction of its height.
        public let headerFontSizeRatio: CGFloat
        /// The actual font-size of the triplet label, if applicable.
        public let tripletFontSize: CGFloat
        
        /// The actual font size to use for beat text, computed automatically.
        package var beatFontSize: CGFloat {
            beatTextHeight * beatFontSizeRatio
        }
        
        /// The actual font size to use for header text, computed automatically.
        package var headerFontSize: CGFloat {
            headerTextHeight * headerFontSizeRatio
        }
        
        /// The vertical space between a triplet beam and the `3` text.
        private static let triplet3TextGap: CGFloat = 2
        /// The vertical offset between the bottom of a `RhythmicGroup`'s beams and the baseline of the "triplet 3" text.
        package var triplet3TextOffsetY: CGFloat {
            tripletFontSize + TextSizes.triplet3TextGap
        }
        
        public init(
            beatTextHeight: CGFloat,
            beatFontSize: CGFloat,
            headerTextHeight: CGFloat,
            headerFontSize: CGFloat,
            tripletFontSize: CGFloat
        ) {
            self.beatTextHeight = beatTextHeight
            self.beatFontSizeRatio = beatFontSize
            self.headerTextHeight = headerTextHeight
            self.headerFontSizeRatio = headerFontSize
            self.tripletFontSize = tripletFontSize
        }
        
        public init(config: ConfigReader) {
            self.init(
                beatTextHeight: config.cgFloat(
                    forKey: "beatTextHeight",
                    default: 30
                ),
                beatFontSize: config.cgFloat(
                    forKey: "beatFontSize",
                    default: 0.8
                ),
                headerTextHeight: config.cgFloat(
                    forKey: "headerTextHeight",
                    default: 30
                ),
                headerFontSize: config.cgFloat(
                    forKey: "headerFontSize",
                    default: 0.8
                ),
                tripletFontSize: config.cgFloat(
                    forKey: "tripletFontSize",
                    default: 14
                )
            )
        }
    }
    
    public struct StrumSizes: Codable {
        /// The width of the space reserved for each strum arrow.
        ///
        /// This is the width of the space reserved for each \"rhythmic column\" composed of arrow, header text, and beat text. It also defines the maximum width of a strum's arrowhead.
        public let width: CGFloat
        /// The height of each strum arrow.
        public let height: CGFloat
        /// The relative stroke width of a strum arrow's lines, as a fraction of ``width``.
        public let strokeWidthRatio: CGFloat
        /// The horizontal space between each strum.
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
            strokeWidth: CGFloat,
            gap: CGFloat
        ) {
            self.width = width
            self.height = height
            self.strokeWidthRatio = strokeWidth
            self.gap = gap
        }
        
        public init(config: ConfigReader) {
            self.init(
                width: config.cgFloat(forKey: "width", default: 20),
                height: config.cgFloat(forKey: "height", default: 80),
                strokeWidth: config.cgFloat(forKey: "strokeWidth", default: 0.2),
                gap: config.cgFloat(forKey: "gap", default: 30)
            )
        }
    }
    
    public struct BeamSizes: Codable {
        /// The stroke width of the rhythm stems/beams below the arrows.
        public let strokeWidth: CGFloat
        /// The vertical length of the beam stems.
        public let stemHeight: CGFloat
        
        /// Space out beams by `1.5 * strokeWidth`, or `1` (whichever is larger)
        package var beamStrokeVerticalGap: CGFloat {
            max(1.5 * strokeWidth, 1)
        }
        
        public init(strokeWidth: CGFloat, stemHeight: CGFloat) {
            self.strokeWidth = strokeWidth
            self.stemHeight = stemHeight
        }
        
        public init(config: ConfigReader) {
            self.init(
                strokeWidth: config.cgFloat(forKey: "strokeWidth", default: 2),
                stemHeight: config.cgFloat(forKey: "stemHeight", default: 8)
            )
        }
    }
    
    public struct BarlineSizes: Codable {
        /// The stroke width of the barlines.
        /// > Default: `2`
        public let strokeWidth: CGFloat
        /// The relative height of a barline, as a fraction of ``StyleConfiguration/StrumSizes/height``.
        /// > Default: `1.25`
        public let heightRatio: CGFloat
        /// The relative width of a gap between a barline and adjacent \"rhythmic columns\", as a fraction of ``StyleConfiguration/StrumSizes/gap``.
        /// > Default: `0.5`
        public let gapRatio: CGFloat
        
        /// Computed height of a barline, using ``StyleConfiguration/StrumSizes`` as a reference point.
        package func height(withStrumSizes strumSizes: StrumSizes) -> CGFloat {
            strumSizes.height * heightRatio
        }
        
        /// Computed gap width on either side of a barline, using ``StyleConfiguration/StrumSizes`` as a reference point.
        package func gap(withStrumSizes strumSizes: StrumSizes) -> CGFloat {
            strumSizes.gap * gapRatio
        }
        
        public init(strokeWidth: CGFloat, heightRatio: CGFloat, gapRatio: CGFloat) {
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
    
    public struct Fonts: Codable {
        /// Font styling for header text.
        public let strumHeader: Styling
        /// Font styling for text inserted in place of arrows.
        public let arrowText: Styling
        /// Font styling for rhythm count text.
        public let countChar: Styling
        /// Font styling for triplet labels (`"3"`), if applicable.
        public let tripletText: Styling
        
        public init(
            strumHeader: Styling,
            arrowText: Styling,
            countChar: Styling,
            tripletText: Styling
        ) {
            self.strumHeader = strumHeader
            self.arrowText = arrowText
            self.countChar = countChar
            self.tripletText = tripletText
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
                tripletText: .init(
                    config: config.scoped(to: "tripletText"),
                    default: .default
                )
            )
        }
        
        public struct Styling: Codable {
            /// Font family name.
            ///
            /// Attribute: `font-family`
            ///
            /// Default: `sans-serif`
            public let family: String
            /// Font weight.
            ///
            /// Attribute: `font-weight`
            ///
            /// Default: `normal`
            public let weight: String
            /// Font weight.
            ///
            /// Attribute: `font-style`
            ///
            /// Default: `normal`
            public let style: String
            
            public init(family: String, weight: String, style: String) {
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
                    weight: config.string(
                        forKey: "weight",
                        default: defaultValue.weight
                    ),
                    style: config.string(
                        forKey: "style",
                        default: defaultValue.style
                    )
                )
            }
            
            public static var `default`: Styling {
                .init(
                    family: "sans-serif",
                    weight: "normal",
                    style: "normal"
                )
            }
            
            public var bold: Styling {
                .init(
                    family: family,
                    weight: "bold",
                    style: "normal"
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
            fonts: .init(config: config.scoped(to: "fonts"))
        )
    }
}
