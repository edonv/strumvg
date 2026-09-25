//
//  SVGFontStyleValue.swift
//  strumvg
//
//  Created by Edon Valdman on 9/24/26.
//

import Foundation

/// https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-style#values
public struct SVGFontStyleValue: Sendable, Hashable {
    private var value: Value
    
    private init(value: Value) {
        self.value = value
    }
    
    fileprivate init?(stringValue: String) {
        switch stringValue {
        case "normal":
            self.value = .normal
        case "italic":
            self.value = .italic
        case "oblique":
            self.value = .oblique(nil)
        default:
            guard stringValue.starts(with: "oblique "),
                  let angle = SVGAngleValue(stringValue: String(stringValue.trimmingPrefix("oblique "))) else { return nil }
            self.value = .oblique(angle)
        }
    }
    
    package var stringValue: String {
        switch value {
        case .normal:
            "normal"
        case .italic:
            "italic"
        case .oblique(let angle):
            if let angle {
                "oblique \(angle.stringValue)"
            } else {
                "oblique"
            }
        }
    }
    
    private enum Value: Sendable, Hashable {
        case normal, italic
        case oblique(SVGAngleValue?)
    }
    
    internal static let normal: SVGFontStyleValue = .init(value: .normal)
    internal static let italic: SVGFontStyleValue = .init(value: .italic)
    internal static let oblique: SVGFontStyleValue = .init(value: .oblique(nil))
    internal static func oblique(_ angle: SVGAngleValue) -> SVGFontStyleValue { .init(value: .oblique(angle)) }
}

// MARK: Codable

extension SVGFontStyleValue: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let string = try container.decode(String.self)
        guard let value = SVGFontStyleValue(stringValue: string) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Font style value is an invalid string."
                )
            )
        }
        
        self = value
    }
}

// MARK: Schemable

import JSONSchemaBuilder
import OrderedJSON

extension SVGFontStyleValue: Schemable {
    public static var schema: some JSONSchemaComponent<SVGFontStyleValue> {
        JSONComposition.OneOf(into: String.self) {
            JSONString()
                .title("Font style")
                .enumValues {
                    "normal"
                    "italic"
                    "oblique"
                }
            
            JSONString()
                .title("Oblique font style with specified angle")
                .pattern("^oblique ((?:\\+|-)?\\d+\\.?\\d*)(deg|grad|rad|turn)$")
        }
        .compactMap { SVGFontStyleValue(stringValue: $0) }
        .examples {
            "oblique 45deg"
            "oblique 0.5rad"
            "oblique 200grad"
            "oblique 0.25turn"
        }
    }
}

// MARK: ConfigReader

import Configuration

extension ConfigReader {
    func svgFontStyle(
        forKey key: ConfigKey,
        isSecret: Bool = false,
        default defaultValue: SVGFontStyleValue,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> SVGFontStyleValue {
        let string = string(
            forKey: key,
            isSecret: isSecret,
            fileID: fileID,
            line: line
        )
        
        return string
            .flatMap(SVGFontStyleValue.init(stringValue:))
            ?? defaultValue
    }
}
