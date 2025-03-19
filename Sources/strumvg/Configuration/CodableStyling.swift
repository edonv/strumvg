//
//  CodableStyling.swift
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
        let arrows: String
        let rhythms: String
        let headers: String
        
        static var `default`: Self {
            StyleConfiguration.default.colors
        }
    }
    
    struct TextSizes: Codable {
        let beatTextHeight: CGFloat
        let beatFontSize: CGFloat
        let headerTextHeight: CGFloat
        let headerFontSize: CGFloat
        let tripletFontSize: CGFloat
        
        static var `default`: Self {
            StyleConfiguration.default.textSizes
        }
    }
    
    struct StrumSizes: Codable {
        let width: CGFloat
        let height: CGFloat
        let gap: CGFloat
        
        static var `default`: Self {
            StyleConfiguration.default.strumSizes
        }
    }
    
    struct BeamSizes: Codable {
        let strokeWidth: CGFloat
        let stemHeight: CGFloat
        
        static var `default`: Self {
            StyleConfiguration.default.beamSizes
        }
    }
    
    private static let `default` = StyleConfiguration(
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
}

// MARK: - Manual Decodable Inits
// (this is to ensure default values)

extension StyleConfiguration {
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
