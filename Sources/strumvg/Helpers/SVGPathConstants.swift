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

internal func quarterRestNode() -> Node<SVG.DocumentContext> {
    .element(
        named: "svg",
        nodes: [
            // SVG attributes
            .attribute(named: "id", value: NoteDuration.quarter.restPathReuseID),
            .attribute(named: "width", value: "5.297"),
            .attribute(named: "height", value: "14.277"),
            .attribute(named: "viewBox", value: "0 0 5.297 14.277"),
            
            // Path element
            .element(
                named: "path",
                nodes: [
                    .attribute(named: "stroke-width", value: "0"),
                    .attribute(named: "stroke-linejoin", value: "round"),
                    .attribute(named: "d", value: "M1.709.033a.4.4 0 01.262-.02c.058.02.457.5 1.574 1.813.816.976 1.512 1.836 1.574 1.894a.72.72 0 01.137.715c-.117.321-.418.66-1.156 1.278-.24.18-.497.398-.555.476-.481.442-.738 1.117-.72 1.754.04.5.2.898.56 1.316.14.18 1.156 1.375 1.492 1.774.18.22.223.316.14.457-.058.141-.257.22-.398.16a1 1 0 01-.16-.14c-.535-.536-1.813-.856-2.391-.598-.218.101-.34.262-.437.558-.238.657-.04 1.895.379 2.493.117.136.117.2.058.277-.058.04-.14.06-.2 0-.038-.02-.378-.457-.558-.738C.873 12.845.435 11.97.217 11.31c-.24-.734-.282-1.234-.121-1.574a.48.48 0 01.28-.277c.419-.2 1.653.02 2.75.476l.079.04-.06-.059c-.061-.059-.858-.996-1.971-2.332-.821-.953-.84-.977-.821-1.254 0-.12 0-.199.043-.278.118-.3.438-.64 1.133-1.238.242-.18.5-.398.559-.476.699-.657.918-1.696.519-2.512-.101-.238-.18-.36-.636-.875-.2-.262-.4-.5-.418-.52-.063-.14.019-.34.156-.398"),
                ]
            )
        ]
    )
}

internal func eighthRestNode() -> Node<SVG.DocumentContext> {
    .element(
        named: "svg",
        nodes: [
            // SVG attributes
            .attribute(named: "id", value: NoteDuration.eighth.restPathReuseID),
            .attribute(named: "width", value: "1.012"),
            .attribute(named: "height", value: "1.86"),
            .attribute(named: "viewBox", value: "0 0 1.012 1.86"),
            
            // Path element
            .element(
                named: "path",
                nodes: [
                    .attribute(named: "stroke-width", value: "0"),
                    .attribute(named: "stroke-linejoin", value: "round"),
                    .attribute(named: "d", value: "M.3 1.82a.17.17 0 00.112.04.16.16 0 00.108-.04L1.012.14C.992.092.924.092.9.14.872.2.72.392.656.392.54.392.556.268.516.156.484.06.392 0 .292 0A.29.29 0 000 .288C0 .472.164.604.348.604A1.3 1.3 0 00.768.516L.3 1.82Z"),
                ]
            )
        ]
    )
}

internal func sixteenthRestNode() -> Node<SVG.DocumentContext> {
    .element(
        named: "svg",
        nodes: [
            // SVG attributes
            .attribute(named: "id", value: NoteDuration.sixteenth.restPathReuseID),
            .attribute(named: "width", value: "1.304"),
            .attribute(named: "height", value: "2.860"),
            .attribute(named: "viewBox", value: "0 0 1.304 2.860"),
            
            // Path element
            .element(
                named: "path",
                nodes: [
                    .attribute(named: "stroke-width", value: "0"),
                    .attribute(named: "stroke-linejoin", value: "round"),
                    .attribute(named: "d", value: "m.368 2.82.404-1.308a1.3 1.3 0 01-.424.092C.164 1.604 0 1.472 0 1.288 0 1.128.128 1 .288 1c.1 0 .196.06.228.156.04.112.02.236.136.236.064 0 .22-.204.24-.272l.184-.604A1.3 1.3 0 01.66.604C.476.604.312.472.312.288A.29.29 0 01.604 0c.1 0 .192.06.224.156.04.112.02.236.136.236.06 0 .2-.196.228-.252.024-.048.092-.048.112 0L.588 2.82a.16.16 0 01-.108.04.17.17 0 01-.112-.04z"),
                ]
            )
        ]
    )
}
