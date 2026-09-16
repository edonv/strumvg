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
//            print(p)
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
    
    @Test func testParsingDoesNotFail() throws {
        let patterns = [
            "|8-DuD D  u|",
            "|8-DuD D  u",
            "8-DuD D  u|",
            "8-DuD D  u|",
            "|8-DuD D  u|",
            "|4-DuD D  u|D DuDu |",
            "|8-DuD D  u|4-D DuDu |",
        ]
        
        for pattern in patterns {
            _ = try Pattern.parser().parse(pattern)
        }
    }
    
    @Test func testEffectiveDuration() {
        for duration in NoteDuration.allCases {
            for subdivision in Timing.Subdivision.allCases {
                // `tuplet` is irrelevant to this test
                let timing = Timing(duration: duration, subdivision: subdivision, tuplet: false)
                
                let effectiveDuration: Timing.EffectiveDuration
                switch (duration, subdivision) {
                case (_, .one):
                    effectiveDuration = .init(
                        duration: duration.rawValue,
                        beamBarCount: duration.beamBarCount,
                        stemLengthRatio: duration.stemLengthRatio
                    )
                    
                case (.half, .two):
                    effectiveDuration = .init(
                        duration: NoteDuration.quarter.rawValue,
                        beamBarCount: NoteDuration.quarter.beamBarCount,
                        stemLengthRatio: NoteDuration.quarter.stemLengthRatio
                    )
                case (.half, .three):
                    effectiveDuration = .init(
                        duration: NoteDuration.quarter.rawValue,
                        beamBarCount: NoteDuration.quarter.beamBarCount,
                        stemLengthRatio: NoteDuration.quarter.stemLengthRatio
                    )
                case (.half, .four):
                    effectiveDuration = .init(
                        duration: NoteDuration.eighth.rawValue,
                        beamBarCount: NoteDuration.eighth.beamBarCount,
                        stemLengthRatio: NoteDuration.eighth.stemLengthRatio
                    )
                    
                case (.quarter, .two):
                    effectiveDuration = .init(
                        duration: NoteDuration.eighth.rawValue,
                        beamBarCount: NoteDuration.eighth.beamBarCount,
                        stemLengthRatio: NoteDuration.eighth.stemLengthRatio
                    )
                case (.quarter, .three):
                    effectiveDuration = .init(
                        duration: NoteDuration.eighth.rawValue,
                        beamBarCount: NoteDuration.eighth.beamBarCount,
                        stemLengthRatio: NoteDuration.eighth.stemLengthRatio
                    )
                case (.quarter, .four):
                    effectiveDuration = .init(
                        duration: NoteDuration.sixteenth.rawValue,
                        beamBarCount: NoteDuration.sixteenth.beamBarCount,
                        stemLengthRatio: NoteDuration.sixteenth.stemLengthRatio
                    )
                    
                case (.eighth, .two):
                    effectiveDuration = .init(
                        duration: NoteDuration.sixteenth.rawValue,
                        beamBarCount: NoteDuration.sixteenth.beamBarCount,
                        stemLengthRatio: NoteDuration.sixteenth.stemLengthRatio
                    )
                case (.eighth, .three):
                    effectiveDuration = .init(
                        duration: NoteDuration.sixteenth.rawValue,
                        beamBarCount: NoteDuration.sixteenth.beamBarCount,
                        stemLengthRatio: NoteDuration.sixteenth.stemLengthRatio
                    )
                case (.eighth, .four):
                    effectiveDuration = .init(
                        duration: NoteDuration.sixteenth.rawValue * 2,
                        beamBarCount: NoteDuration.sixteenth.beamBarCount + 1,
                        stemLengthRatio: NoteDuration.sixteenth.stemLengthRatio
                    )
                    
                case (.sixteenth, .two):
                    effectiveDuration = .init(
                        duration: NoteDuration.sixteenth.rawValue * 2,
                        beamBarCount: NoteDuration.sixteenth.beamBarCount + 1,
                        stemLengthRatio: NoteDuration.sixteenth.stemLengthRatio
                    )
                case (.sixteenth, .three):
                    effectiveDuration = .init(
                        duration: NoteDuration.sixteenth.rawValue * 2,
                        beamBarCount: NoteDuration.sixteenth.beamBarCount + 1,
                        stemLengthRatio: NoteDuration.sixteenth.stemLengthRatio
                    )
                case (.sixteenth, .four):
                    effectiveDuration = .init(
                        duration: NoteDuration.sixteenth.rawValue * 4,
                        beamBarCount: NoteDuration.sixteenth.beamBarCount + 2,
                        stemLengthRatio: NoteDuration.sixteenth.stemLengthRatio
                    )
                }
                
                #expect(timing.effectiveDuration == effectiveDuration, "\(timing)")
            }
        }
    }
}
