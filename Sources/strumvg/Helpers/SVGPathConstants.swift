//
//  SVGPathConstants.swift
//  strumvg
//
//  Created by Edon Valdman on 3/13/25.
//

import Foundation
import Plot
import PlotSVG
import StrumModels

/// - Parameters:
///   - duration: Rest duration
///   - width: Width of strum space
///   - height: Height of strum space
internal func restNode(
    duration: NoteDuration,
    width: CGFloat,
    height: CGFloat
) -> Node<SVG.DocumentContext> {
    let scaleFactor: CGFloat = 0.75
    let scaledWidth = width * scaleFactor
    let scaledHeight = height * scaleFactor
    
    let originalSize = restOriginalSize(for: duration)
    
    let x = (width / 2) - (scaledWidth / 2)
    let y = (height / 2) - (scaledHeight / 2)
    
    return .element(
        named: "svg",
        nodes: [
            // SVG attributes
            .attribute(named: "x", value: x, format: numberFormat),
            .attribute(named: "y", value: y, format: numberFormat),
            .attribute(named: "width", value: scaledWidth, format: numberFormat),
            .attribute(named: "height", value: scaledHeight, format: numberFormat),
            restViewBoxNode(with: originalSize),
            
            // Path element
            restPathNode(for: duration),
        ]
    )
}

private func restViewBoxNode(with size: CGSize) -> Node<SVG.DocumentContext> {
    .attribute(named: "viewBox", value: "0 0 \(size.width) \(size.height)")
}

private func restOriginalSize(for duration: NoteDuration) -> CGSize {
    switch duration {
    case .quarter:
        return .init(width: 5.297, height: 14.277)
    case .eighth:
        return .init(width: 5.019001, height: 9.259301)
    case .sixteenth:
        return .init(width: 6.477, height: 14.248)
    }
}

private func restPathNode(for duration: NoteDuration) -> Node<SVG.DocumentContext> {
    switch duration {
    case .quarter:
        return .element(
            named: "path",
            nodes: [
                .attribute(named: "stroke", value: "none"),
                .attribute(named: "stroke-linejoin", value: "round"),
                .attribute(named: "d", value: "M1.709.033a.4.4 0 01.262-.02c.058.02.457.5 1.574 1.813.816.976 1.512 1.836 1.574 1.894a.72.72 0 01.137.715c-.117.321-.418.66-1.156 1.278-.24.18-.497.398-.555.476-.481.442-.738 1.117-.72 1.754.04.5.2.898.56 1.316.14.18 1.156 1.375 1.492 1.774.18.22.223.316.14.457-.058.141-.257.22-.398.16a1 1 0 01-.16-.14c-.535-.536-1.813-.856-2.391-.598-.218.101-.34.262-.437.558-.238.657-.04 1.895.379 2.493.117.136.117.2.058.277-.058.04-.14.06-.2 0-.038-.02-.378-.457-.558-.738C.873 12.845.435 11.97.217 11.31c-.24-.734-.282-1.234-.121-1.574a.48.48 0 01.28-.277c.419-.2 1.653.02 2.75.476l.079.04-.06-.059c-.061-.059-.858-.996-1.971-2.332-.821-.953-.84-.977-.821-1.254 0-.12 0-.199.043-.278.118-.3.438-.64 1.133-1.238.242-.18.5-.398.559-.476.699-.657.918-1.696.519-2.512-.101-.238-.18-.36-.636-.875-.2-.262-.4-.5-.418-.52-.063-.14.019-.34.156-.398"),
            ]
        )
    case .eighth:
        return .element(
            named: "path",
            nodes: [
                .attribute(named: "stroke", value: "none"),
                .attribute(named: "stroke-linejoin", value: "round"),
                .attribute(named: "d", value: "m1.137.0363c-.52.098-.918.457-1.098.953-.039.16-.039.199-.039.418 0 .301.019.461.16.699.199.399.617.719 1.094.836.5.141 1.336.02 2.293-.297l.238-.082-1.176 3.25-1.156 3.246s.039.02.102.063c.117.078.316.137.457.137.238 0 .539-.137.578-.258 0-.039.558-1.934 1.234-4.184l1.195-4.125-.039-.058c-.097-.121-.296-.16-.418-.063-.039.039-.101.121-.14.18-.18.301-.637.836-.875 1.035-.219.18-.34.199-.539.121-.18-.098-.239-.199-.36-.738-.117-.535-.257-.778-.558-.977-.278-.179-.637-.238-.953-.156z"),
            ]
        )
    case .sixteenth:
        return .element(
            named: "path",
            nodes: [
                .attribute(named: "stroke", value: "none"),
                .attribute(named: "stroke-linejoin", value: "round"),
                .attribute(named: "d", value: "M2.691.0363c.321-.082.68-.023.957.156.297.199.438.442.559.977.117.539.18.64.359.738.2.078.317.039.536-.141.16-.16.441-.496.64-.816.238-.359.238-.359.317-.398.14-.059.3-.039.379.082l.039.058-1.774 6.633c-.976 3.649-1.773 6.656-1.793 6.676 0 .062-.16.16-.316.199-.16.063-.321.063-.481 0-.16-.039-.316-.16-.316-.18.039-.097 1.992-6.453 1.992-6.453 0-.019-.141.02-.301.078-.379.121-.758.219-1.074.278-.379.062-.937.062-1.156 0-.481-.117-.899-.438-1.098-.836-.137-.238-.16-.399-.16-.696 0-.218 0-.261.043-.417.117-.301.316-.579.578-.758.555-.36 1.274-.301 1.692.16.16.156.238.375.339.773.121.539.18.641.36.739.218.101.359.039.636-.239.297-.3.637-.777.739-1.035.039-.101.933-3.008.933-3.031 0-.02-.117.023-.257.082-.958.316-1.754.418-2.25.277-.481-.117-.899-.437-1.098-.836-.141-.238-.16-.398-.16-.699 0-.219 0-.258.043-.418.175-.496.574-.855 1.093-.953Z"),
            ]
        )
    }
}
