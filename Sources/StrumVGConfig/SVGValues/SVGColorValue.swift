//
//  SVGColorValue.swift
//  strumvg
//
//  Created by Edon Valdman on 9/24/26.
//

import Foundation
import OrderedJSON

public enum SVGColorValue {
    public static let examples: JSONValue = [
        "#000",
        "#000000",
        "black",
        "white",
        "aliceblue",
        "rgb(255 0 153)",
        "rgb(255 0 153 / 80%)",
        "hsl(150 30% 60%)",
        "hsl(150 30% 60% / 80%)",
        "hwb(12 50% 0%)",
        "hwb(194 0% 0% / 0.5)",
        "lab(50% 40 59.5)",
        "lab(50% 40 59.5 / 0.5)",
    ]
}
