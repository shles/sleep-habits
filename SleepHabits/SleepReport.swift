//
//  SleepReport.swift
//  SleepHabits
//
//  Created by Artemis Shlesberg on 2/22/23.
//

import Foundation

struct SleepReport {
    /// Day of the sleep end
    var date: Date
    var sleepScore: Float
    var isBetterThanLast: Bool
    /// In minutes
    var sleepDuration: Int
    
    var timeToFallAsleep: Int
    var timeInDeepSleep: Int
    var timeInBed: Int
    var percentageAwake: Float
    
    var yesterdayTasks: [SleepTask]
    var sleepingGraphData: [SleepStageData]
    
    var breathingRateRange: BreathingRateRange
    var heartRateRange: HeartRateRange
}

struct SleepTask {
    var title: String
    var isCompleted: Bool
    var format: String
    var goal: Int?
    var actualResult: Int?
}

struct SleepStageData {
    var timestamp: Date
    var stage: String
}

struct BreathingRateRange {
    var isSteady: Bool
    var minimum: Float
    var maximum: Float
}

struct HeartRateRange {
    var isSteady: Bool
    var minimum: Int
    var maximum: Int
}
