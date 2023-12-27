//
//  SleepRecordTests.swift
//  SleepHabitsTests
//
//  Created by Artemis Shlesberg on 2/22/23.
//

import XCTest
import HealthKit
@testable import SleepHabits

class SleepRecordTests: XCTestCase {
    
    func testPercentage() {
        let inBedSample = HKCategorySample(
            type: HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            value: HKCategoryValueSleepAnalysis.inBed.rawValue,
            start: Date(timeIntervalSinceNow: -3600),  // Set a valid start date
            end: Date(timeIntervalSinceNow: -1800)     // Set a valid end date
        )
        
        let deepSleepSample = HKCategorySample(
            type: HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            value: HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            start: Date(timeIntervalSinceNow: -2401),  // Set a valid start date
            end: Date(timeIntervalSinceNow: -1801)     // Set a valid end date
        )
        
        let coreSleepSample = HKCategorySample(
            type: HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            value: HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            start: Date(timeIntervalSinceNow: -2401),  // Set a valid start date
            end: Date(timeIntervalSinceNow: -1801)     // Set a valid end date
        )
        
        let remSleepSample = HKCategorySample(
            type: HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            value: HKCategoryValueSleepAnalysis.asleepREM.rawValue,
            start: Date(timeIntervalSinceNow: -2401),  // Set a valid start date
            end: Date(timeIntervalSinceNow: -1801)     // Set a valid end date
        )
        
        let phases = [deepSleepSample, coreSleepSample, remSleepSample]
        let sleepRecord = SleepRecord(inBed: inBedSample, phases: phases)
        
        XCTAssertEqual(sleepRecord.percentage(of: .inBed), 100.0)
        XCTAssertEqual(sleepRecord.percentage(of: .asleepDeep), 33.33, accuracy: 0.01)
        XCTAssertEqual(sleepRecord.percentage(of: .asleepCore), 33.33, accuracy: 0.01)
        XCTAssertEqual(sleepRecord.percentage(of: .asleepREM), 33.33, accuracy: 0.01)
        XCTAssertEqual(sleepRecord.percentage(of: .awake), 0, accuracy: 0.01)
    }
}
