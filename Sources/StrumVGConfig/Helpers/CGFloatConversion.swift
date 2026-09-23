//
//  CGFloatConversion.swift
//  strumvg
//
//  Created by Edon Valdman on 9/18/26.
//

import Foundation
import JSONSchemaBuilder
import JSONSchemaConversion

public struct CGFloatConversion: Schemable {
    public static var schema: some JSONSchemaComponent<CGFloat> {
        JSONNumber()
            .map { CGFloat($0) }
    }
}

extension Conversions {
    internal static var cgFloat: CGFloatConversion.Type { CGFloatConversion.self }
}
