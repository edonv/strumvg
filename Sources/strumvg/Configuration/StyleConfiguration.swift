//
//  StyleConfiguration.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation

struct StyleConfiguration: Codable {
    let colors: Colors
    let textSizes: TextSizes
    let strumSizes: StrumSizes
    let beamSizes: BeamSizes
    
    struct Colors: Codable {
        /// ``StyleConfiguration/Args/Colors-swift.struct/arrows``
        let arrows: String
        /// ``StyleConfiguration/Args/Colors-swift.struct/rhythms``
        let rhythms: String
        /// ``StyleConfiguration/Args/Colors-swift.struct/headers``
        let headers: String
        
        static var `default`: Self {
            StyleConfiguration.default.colors
        }
    }
    
    struct TextSizes: Codable {
        /// ``StyleConfiguration/Args/TextSizes-swift.struct/beatTextHeight``
        let beatTextHeight: CGFloat
        /// ``StyleConfiguration/Args/TextSizes-swift.struct/beatFontSize``
        let beatFontSize: CGFloat
        /// ``StyleConfiguration/Args/TextSizes-swift.struct/headerTextHeight``
        let headerTextHeight: CGFloat
        /// ``StyleConfiguration/Args/TextSizes-swift.struct/headerFontSize``
        let headerFontSize: CGFloat
        /// ``StyleConfiguration/Args/TextSizes-swift.struct/tripletFontSize``
        let tripletFontSize: CGFloat
        
        static var `default`: Self {
            StyleConfiguration.default.textSizes
        }
    }
    
    struct StrumSizes: Codable {
        /// ``StyleConfiguration/Args/StrumSizes-swift.struct/width``
        let width: CGFloat
        /// ``StyleConfiguration/Args/StrumSizes-swift.struct/height``
        let height: CGFloat
        /// ``StyleConfiguration/Args/StrumSizes-swift.struct/gap``
        let gap: CGFloat
        
        static var `default`: Self {
            StyleConfiguration.default.strumSizes
        }
    }
    
    struct BeamSizes: Codable {
        /// ``StyleConfiguration/Args/BeamSizes-swift.struct/strokeWidth``
        let strokeWidth: CGFloat
        /// ``StyleConfiguration/Args/BeamSizes-swift.struct/stemHeight``
        let stemHeight: CGFloat
        
        static var `default`: Self {
            StyleConfiguration.default.beamSizes
        }
    }
    
    static let `default` = StyleConfiguration(
        colors: .init(
            arrows: "#000000",
            rhythms: "#555555",
            headers: "#000000"
        ),
        textSizes: .init(
            beatTextHeight: 30,
            beatFontSize: 0.8,
            headerTextHeight: 30,
            headerFontSize: 0.8,
            tripletFontSize: 14
        ),
        strumSizes: .init(
            width: 20,
            height: 80,
            gap: 30
        ),
        beamSizes: .init(
            strokeWidth: 2,
            stemHeight: 8
        )
    )
    
    func overlaying(
        with args: StyleConfiguration.Args
    ) -> StyleConfiguration {
        return .init(
            colors: .init(
                arrows: args.colors.arrows
                    ?? self.colors.arrows,
                rhythms: args.colors.rhythms
                    ?? self.colors.rhythms,
                headers: args.colors.headers
                    ?? self.colors.headers
            ),
            textSizes: .init(
                beatTextHeight: args.textSizes.beatTextHeight
                    ?? self.textSizes.beatTextHeight,
                beatFontSize: args.textSizes.beatFontSize
                    ?? self.textSizes.beatFontSize,
                headerTextHeight: args.textSizes.headerTextHeight
                    ?? self.textSizes.headerTextHeight,
                headerFontSize: args.textSizes.headerFontSize
                    ?? self.textSizes.headerFontSize,
                tripletFontSize: args.textSizes.tripletFontSize
                    ?? self.textSizes.tripletFontSize
            ),
            strumSizes: .init(
                width: args.strumSizes.width
                    ?? self.strumSizes.width,
                height: args.strumSizes.height
                    ?? self.strumSizes.height,
                gap: args.strumSizes.gap
                    ?? self.strumSizes.gap
            ),
            beamSizes: .init(
                strokeWidth: args.beamSizes.strokeWidth
                    ?? self.beamSizes.strokeWidth,
                stemHeight: args.beamSizes.stemHeight
                    ?? self.beamSizes.stemHeight
            )
        )
    }
}

// MARK: - Manual Decodable Inits
// (this is to ensure default values)

extension StyleConfiguration {
    init(args: Args) {
        self.init(
            colors: .init(
                arrows: args.colors.arrows ?? Self.default.colors.arrows,
                rhythms: args.colors.rhythms ?? Self.default.colors.rhythms,
                headers: args.colors.headers ?? Self.default.colors.headers
            ),
            textSizes: .init(
                beatTextHeight: args.textSizes.beatTextHeight ?? Self.default.textSizes.beatTextHeight,
                beatFontSize: args.textSizes.beatFontSize ?? Self.default.textSizes.beatFontSize,
                headerTextHeight: args.textSizes.headerTextHeight ?? Self.default.textSizes.headerTextHeight,
                headerFontSize: args.textSizes.headerFontSize ?? Self.default.textSizes.headerFontSize,
                tripletFontSize: args.textSizes.tripletFontSize ?? Self.default.textSizes.tripletFontSize
            ),
            strumSizes: .init(
                width: args.strumSizes.width ?? Self.default.strumSizes.width,
                height: args.strumSizes.height ?? Self.default.strumSizes.height,
                gap: args.strumSizes.gap ?? Self.default.strumSizes.gap
            ),
            beamSizes: .init(
                strokeWidth: args.beamSizes.strokeWidth ?? Self.default.beamSizes.strokeWidth,
                stemHeight: args.beamSizes.stemHeight ?? Self.default.beamSizes.stemHeight
            )
        )
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.colors = try container.decodeIfPresent(StyleConfiguration.Colors.self, forKey: .colors) ?? .default
        self.textSizes = try container.decodeIfPresent(StyleConfiguration.TextSizes.self, forKey: .textSizes) ?? .default
        self.strumSizes = try container.decodeIfPresent(StyleConfiguration.StrumSizes.self, forKey: .strumSizes) ?? .default
        self.beamSizes = try container.decodeIfPresent(StyleConfiguration.BeamSizes.self, forKey: .beamSizes) ?? .default
    }
}

extension StyleConfiguration.Colors {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.arrows = try container.decodeIfPresent(String.self, forKey: .arrows) ?? Self.default.arrows
        self.rhythms = try container.decodeIfPresent(String.self, forKey: .rhythms) ?? Self.default.rhythms
        self.headers = try container.decodeIfPresent(String.self, forKey: .headers) ?? Self.default.headers
    }
}

extension StyleConfiguration.TextSizes {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.beatTextHeight = try container.decodeIfPresent(CGFloat.self, forKey: .beatTextHeight) ?? Self.default.beatTextHeight
        self.beatFontSize = try container.decodeIfPresent(CGFloat.self, forKey: .beatFontSize) ?? Self.default.beatFontSize
        self.headerTextHeight = try container.decodeIfPresent(CGFloat.self, forKey: .headerTextHeight) ?? Self.default.headerTextHeight
        self.headerFontSize = try container.decodeIfPresent(CGFloat.self, forKey: .headerFontSize) ?? Self.default.headerFontSize
        self.tripletFontSize = try container.decodeIfPresent(CGFloat.self, forKey: .tripletFontSize) ?? Self.default.tripletFontSize
    }
}

extension StyleConfiguration.StrumSizes {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try container.decodeIfPresent(CGFloat.self, forKey: .width) ?? Self.default.width
        self.height = try container.decodeIfPresent(CGFloat.self, forKey: .height) ?? Self.default.height
        self.gap = try container.decodeIfPresent(CGFloat.self, forKey: .gap) ?? Self.default.gap
    }
}

extension StyleConfiguration.BeamSizes {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.strokeWidth = try container.decodeIfPresent(CGFloat.self, forKey: .strokeWidth) ?? Self.default.strokeWidth
        self.stemHeight = try container.decodeIfPresent(CGFloat.self, forKey: .stemHeight) ?? Self.default.stemHeight
    }
}
