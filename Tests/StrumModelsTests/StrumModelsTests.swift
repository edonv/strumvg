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
        "|8/2-DuD D  u|D D uDu|": .init(measures: [
            .init(
                strums: [
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .space),
                    .init(kind: .up),
                ],
                timing: .init(duration: .eighth, subdivision: .two, tuplet: false)
            ),
            .init(
                strums: [
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .up),
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .space),
                ],
                timing: .init(duration: .eighth, subdivision: .two, tuplet: false)
            ),
        ]),
        "|8/3t-{hD}rr{rD}sADMD u|4-udu d d ": .init(measures: [
            .init(
                strums: [
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
                ],
                timing: .init(duration: .eighth, subdivision: .three, tuplet: true)
            ),
            .init(
                strums: [
                    .init(kind: .up),
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .space),
                ],
                timing: .init(duration: .quarter, tuplet: false)
            ),
        ]),
        "16/3t-d  uMmMu u": .init(measures: [
            .init(
                strums: [
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
                ],
                timing: .init(duration: .sixteenth, subdivision: .three, tuplet: true)
            ),
        ]),
        "|8-DuD D  u|4-D DuDu |": .init(measures: [
            .init(
                strums: [
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .space),
                    .init(kind: .up),
                ],
                timing: .init(duration: .eighth, tuplet: false)
            ),
            .init(
                strums: [
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .space),
                ],
                timing: .init(duration: .quarter, tuplet: false)
            ),
        ]),
        "|:8/2-DuD D  u|D D uDu:|": .init(measures: [
            .init(
                strums: [
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .space),
                    .init(kind: .up),
                ],
                timing: .init(duration: .eighth, subdivision: .two, tuplet: false),
                repeatStart: true
            ),
            .init(
                strums: [
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .down),
                    .init(kind: .space),
                    .init(kind: .up),
                    .init(kind: .down),
                    .init(kind: .up),
                    .init(kind: .space),
                ],
                timing: .init(duration: .eighth, subdivision: .two, tuplet: false),
                repeatEnd: true
            ),
        ]),
    ]
    
    @Test func testParsing() throws {
        for (patternString, pattern) in parsingPatterns {
            let p = try Pattern.parser().parse(patternString)
            #expect(p == pattern)
        }
    }
    
    @Test func testRepeatPatternValidation() {
        let patterns: [String: Bool] = [
            "|:8-DuD D  u:|D D uDu:|": false,
            "|:8-DuD D  u|D D uDu:|": true,
            "|:8-DuD D  u:|D D uDu|": true,
            "|:8-DuD D  u:|:D D uDu:|": true,
            "|8-DuD D  u:|D D uDu:|": false,
        ]
        
        for (patternString, expectation) in patterns {
            let pattern = try? Pattern.parser().parse(patternString)
            #expect((pattern != nil) == expectation, "\(patternString)")
        }
    }
}
