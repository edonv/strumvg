//
//  StrumModelsTests.swift
//  strumvg
//
//  Created by Edon Valdman on 9/10/26.
//

import Testing
@testable import StrumModels

struct StrumModelsTests {
    private let parsingPatterns: [String: Pattern] = [
        "|DuD D  u|D D uDu-8|": .init(measures: [
            .init(
                groups: [
                    .init(strums: [
                        .init(kind: .down),
                        .init(kind: .up),
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .space),
                        .init(kind: .up),
                    ])
                ],
                timing: .init(duration: .eighth, triplet: false)
            ),
            .init(
                groups: [
                    .init(strums: [
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .up),
                        .init(kind: .down),
                        .init(kind: .up),
                        .init(kind: .space),
                    ])
                ],
                timing: .init(duration: .eighth, triplet: false)
            ),
        ]),
        "|{hD}rr{rD}sADMD u-8t|udu d d -4": .init(measures: [
            .init(
                groups: [
                    .init(strums: [
                        .init(kind: .down, heading: "h"),
                        .init(kind: .rest),
                        .init(kind: .rest),
                        .init(kind: .down, heading: "r"),
                        .init(kind: .other("s")),
                        .init(kind: .downArpeggio),
                        .init(kind: .down),
                        .init(kind: .downMuted),
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .up),
                        .init(kind: .space),
                    ])
                ],
                timing: .init(duration: .eighth, triplet: true)
            ),
            .init(
                groups: [
                    .init(strums: [
                        .init(kind: .up),
                        .init(kind: .down),
                        .init(kind: .up),
                        .init(kind: .space),
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .down),
                        .init(kind: .space),
                    ])
                ],
                timing: .init(duration: .quarter, triplet: false)
            ),
        ]),
        "d  uMmMu u-16t": .init(measures: [
            .init(
                groups: [
                    .init(strums: [
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .space),
                        .init(kind: .up),
                        .init(kind: .downMuted),
                        .init(kind: .upMuted),
                        .init(kind: .downMuted),
                        .init(kind: .up),
                        .init(kind: .space),
                        .init(kind: .up),
                        .init(kind: .space),
                        .init(kind: .space),
                        
                    ])
                ],
                timing: .init(duration: .sixteenth, triplet: true)
            ),
        ]),
        "|DuD D  u-8|D DuDu -4|": .init(measures: [
            .init(
                groups: [
                    .init(strums: [
                        .init(kind: .down),
                        .init(kind: .up),
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .space),
                        .init(kind: .up),
                    ])
                ],
                timing: .init(duration: .eighth, triplet: false)
            ),
            .init(
                groups: [
                    .init(strums: [
                        .init(kind: .down),
                        .init(kind: .space),
                        .init(kind: .down),
                        .init(kind: .up),
                        .init(kind: .down),
                        .init(kind: .up),
                        .init(kind: .space),
                    ])
                ],
                timing: .init(duration: .quarter, triplet: false)
            ),
        ]),
    ]
    
    @Test func testParsing() async throws {
        for (patternString, pattern) in parsingPatterns {
            #expect(Pattern(rawValue: patternString) == pattern)
        }
    }
    
    @Test func testRepeatPatternValidation() {
        let patterns: [String: Bool] = [
            "|:DuD D  u:|D D uDu:|-8": false,
            "|:DuD D  u|D D uDu:|-8": true,
            "|:DuD D  u:|D D uDu|-8": true,
            "|:DuD D  u:|:D D uDu:|-8": true,
            "|DuD D  u:|D D uDu:|-8": false,
        ]
        
        for (patternString, expectation) in patterns {
            #expect((Pattern(rawValue: patternString) != nil) == expectation)
        }
    }
}
