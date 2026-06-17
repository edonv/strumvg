//
//  StyleConfiguration.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import Configuration

struct StyleConfiguration: Codable {
    let colors: Colors
    let textSizes: TextSizes
    let strumSizes: StrumSizes
    let beamSizes: BeamSizes
    let fonts: Fonts
    
    struct Colors: Codable {
        /// The color of the arrows.
        ///
        /// Default value: `#000000` (black)
        let arrows: String
        /// The color of the rhythm text and stems below the arrows.
        let rhythms: String
        /// The color of the articulations and header text above the arrows.
        let headers: String
        
        init(arrows: String, rhythms: String, headers: String) {
            self.arrows = arrows
            self.rhythms = rhythms
            self.headers = headers
        }
        
        init(config: ConfigReader) {
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
                )
            )
        }
    }
    
    struct TextSizes: Codable {
        /// The height of the space reserved for rhythm text below the arrows.
        let beatTextHeight: CGFloat
        /// The relative font-size of the rhythm text below the arrows, as a fraction of its height.
        let beatFontSize: CGFloat
        /// The height of the space reserved for articulations and header text above the arrows.
        let headerTextHeight: CGFloat
        /// The relative font-size of the articulations and header text above the arrows, as a fraction of its height.
        let headerFontSize: CGFloat
        /// The actual font-size of the triplet label, if applicable.
        let tripletFontSize: CGFloat
        
        var beatFontSizeActual: CGFloat {
            beatTextHeight * beatFontSize
        }
        
        var headerFontSizeActual: CGFloat {
            headerTextHeight * headerFontSize
        }
        
        /// The vertical space between a triplet beam and the `3` text.
        private let triplet3TextGap: CGFloat = 2
        var triplet3TextOffsetY: CGFloat {
            tripletFontSize + triplet3TextGap
        }
        
        init(
            beatTextHeight: CGFloat,
            beatFontSize: CGFloat,
            headerTextHeight: CGFloat,
            headerFontSize: CGFloat,
            tripletFontSize: CGFloat
        ) {
            self.beatTextHeight = beatTextHeight
            self.beatFontSize = beatFontSize
            self.headerTextHeight = headerTextHeight
            self.headerFontSize = headerFontSize
            self.tripletFontSize = tripletFontSize
        }
        
        init(config: ConfigReader) {
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
    
    struct StrumSizes: Codable {
        /// The width of the space reserved for each strum arrow.
        ///
        /// This is the width of the space reserved for each \"rhythmic column\" composed of arrow, header text, and beat text. It also defines the maximum width of a strum's arrowhead.
        let width: CGFloat
        /// The height of each strum arrow.
        let height: CGFloat
        /// The horizontal space between each strum.
        let gap: CGFloat
        
        private let strokeWidthRatio: CGFloat = 0.2
        var strokeWidth: CGFloat {
            width * strokeWidthRatio
        }
        
        private let arrowHeadHeightRatio: CGFloat = 0.2
        var arrowLineHeight: CGFloat {
            height * (1 - arrowHeadHeightRatio)
        }
        var arrowHeadHeight: CGFloat {
            height * arrowHeadHeightRatio
        }
        
        /// Used as the `font-size` for characters inserts as strums.
        var charStrumTextSize: CGFloat {
            height / 2
        }
        
        init(width: CGFloat, height: CGFloat, gap: CGFloat) {
            self.width = width
            self.height = height
            self.gap = gap
        }
        
        init(config: ConfigReader) {
            self.init(
                width: config.cgFloat(forKey: "width", default: 20),
                height: config.cgFloat(forKey: "height", default: 80),
                gap: config.cgFloat(forKey: "gap", default: 30)
            )
        }
    }
    
    struct BeamSizes: Codable {
        /// The stroke width of the rhythm stems/beams below the arrows.
        let strokeWidth: CGFloat
        /// The vertical length of the beam stems.
        let stemHeight: CGFloat
        
        /// Space out beams by `1.5 * strokeWidth`, or `1` (whichever is larger)
        var beamStrokeVerticalGap: CGFloat {
            max(1.5 * strokeWidth, 1)
        }
        
        init(strokeWidth: CGFloat, stemHeight: CGFloat) {
            self.strokeWidth = strokeWidth
            self.stemHeight = stemHeight
        }
        
        init(config: ConfigReader) {
            self.init(
                strokeWidth: config.cgFloat(forKey: "strokeWidth", default: 2),
                stemHeight: config.cgFloat(forKey: "stemHeight", default: 8)
            )
        }
    }
    
    struct Fonts: Codable {
        /// Font styling for header text.
        let strumHeader: Styling
        /// Font styling for text inserted in place of arrows.
        let arrowText: Styling
        /// Font styling for rhythm count text.
        let countChar: Styling
        /// Font styling for triplet labels (`"3"`), if applicable.
        let tripletText: Styling
        
        init(
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
        
        init(config: ConfigReader) {
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
        
        struct Styling: Codable {
            /// Font family name.
            ///
            /// Attribute: `font-family`
            ///
            /// Default: `sans-serif`
            let family: String
            /// Font weight.
            ///
            /// Attribute: `font-weight`
            ///
            /// Default: `normal`
            let weight: String
            /// Font weight.
            ///
            /// Attribute: `font-style`
            ///
            /// Default: `normal`
            let style: String
            
            init(family: String, weight: String, style: String) {
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
            
            static var `default`: Styling {
                .init(
                    family: "sans-serif",
                    weight: "normal",
                    style: "normal"
                )
            }
            
            var bold: Styling {
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
    init(config: ConfigReader) {
        self.init(
            colors: .init(config: config.scoped(to: "colors")),
            textSizes: .init(config: config.scoped(to: "textSizes")),
            strumSizes: .init(config: config.scoped(to: "strumSizes")),
            beamSizes: .init(config: config.scoped(to: "beamSizes")),
            fonts: .init(config: config.scoped(to: "fonts"))
        )
    }
}
