//
//  ConfigReader+CGFloat.swift
//  strumvg
//
//  Created by Edon Valdman on 6/16/26.
//

import Foundation
import Configuration

extension ConfigReader {
    func cgFloat(
        forKey key: ConfigKey,
        isSecret: Bool = false,
        default defaultValue: CGFloat,
        fileID: String = #fileID,
        line: UInt = #line
    ) -> CGFloat {
        .init(
            double(
                forKey: key,
                isSecret: isSecret,
                default: defaultValue,
                fileID: fileID,
                line: line
            )
        )
    }
}
