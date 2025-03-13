//
//  ConfigOptions.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation

struct ConfigOptions: Codable {
    static let `default`: ConfigOptions = .init(
        arrowColor: "#000000",
        rhythmColor: "#555555",
        articulationColor: "#555555",
        beatTextHeight: 30,
        beatTextFontSize: 0.8,
        beamStrokeWidth: 2,
        beamStemHeight: 8,
        strumWidth: 20,
        strumHeight: 80,
        strumGap: 30,
        headerHeight: 30,
        headerFontSize: 0.8
    )
    
    let arrowColor: String
    let rhythmColor: String
    let articulationColor: String
    let beatTextHeight: CGFloat
    let beatTextFontSize: CGFloat
    let beamStrokeWidth: CGFloat
    let strumWidth: CGFloat
    let strumHeight: CGFloat
    let strumGap: CGFloat
    let headerHeight: CGFloat
    let beamStemHeight: CGFloat
    let headerFontSize: CGFloat
}
