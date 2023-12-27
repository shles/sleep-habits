//
//  DataSource+SleepReport.swift
//  SleepHabits
//
//  Created by Artemis Shlesberg on 2/22/23.
//

import Foundation
import HealthKit

extension DataSource {
    var lastNight: SleepRecord? {
        allNights.first
    }
}

extension DataSource {
    func getSleepReport() async throws -> SleepReport? {
        guard let lastNight = self.lastNight  else {
            print("cant get last night")
            return nil
        }
        let timeInBed = lastNight.inBed.endDate.timeIntervalSince(lastNight.inBed.startDate)
        let minutesInBed = timeInBed / 60
        let durationTimeInterval = timeInBed * (1 - lastNight.percentage(of: .awake))
        //TODO: check
        let durationMinutes = durationTimeInterval / 60
        
        let date = lastNight.inBed.endDate
        //TODO: check
        let timeToFallAsleep = (lastNight.phases.first(where: { $0.enumValue != .awake && $0.enumValue != .inBed })?.startDate.timeIntervalSince(lastNight.inBed.startDate) ?? 0) / 60
        
        let deepSleepDuration = timeInBed * lastNight.percentage(of: .asleepDeep) / 60
        let percentageAwake = lastNight.percentage(of: .awake)
        let sleepSample = lastNight.inBed
        
        let (breathingRateRange, heartRateRange) = try await getHeartAndBreathingRates(for: lastNight.inBed)
        
//         Create a new sleep report with the relevant data
        let sleepReport = SleepReport(date: date,
                                      sleepScore: 0,
                                      isBetterThanLast: false,
                                      sleepDuration: Int(durationMinutes),
                                      timeToFallAsleep: Int(timeToFallAsleep),
                                      timeInDeepSleep: Int(deepSleepDuration),
                                      timeInBed: Int(minutesInBed),
                                      percentageAwake: Float(percentageAwake),
                                      yesterdayTasks: [],
                                      sleepingGraphData: [],
                                      breathingRateRange: breathingRateRange,
                                      heartRateRange: heartRateRange)
        
        
        return sleepReport
    }
    
    func getHeartAndBreathingRates(for sleepSample: HKCategorySample) async throws -> (BreathingRateRange, HeartRateRange) {
        // Retrieve the heart rate and breathing rate samples that occurred during the sleep sample
        let heartRateSamples = try await getHeartRateSamples(for: sleepSample)
        let breathingRateSamples = try await getBreathingRateSamples(for: sleepSample)
        
        // Calculate the heart rate and breathing rate ranges for the sleep sample
        let heartRateValues = heartRateSamples.map { sample in sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) }
        let heartRateRange = HeartRateRange(isSteady: true, minimum: Int(heartRateValues.min() ?? 0.0), maximum: Int(heartRateValues.max() ?? 0.0))
        
        let breathingRateValues = breathingRateSamples.map { sample in sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) }
        let breathingRateRange = BreathingRateRange(isSteady: true, minimum:  Float(breathingRateValues.min() ?? 0.0), maximum: Float(breathingRateValues.max() ?? 0.0))
        return (breathingRateRange, heartRateRange)
    }
    
    func getHeartRateSamples(for sleepSample: HKCategorySample) async throws -> [HKQuantitySample] {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: sleepSample.startDate, end: sleepSample.endDate, options: .strictEndDate)
        return await withCheckedContinuation({ continuation in
            let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                
                guard let quantitySamples = samples as? [HKQuantitySample] else {
                    print("error geting heartRate, \(String(describing: error))")
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: quantitySamples)
            }
            HKHealthStore().execute(query)
        })
    }

    // Define a function that retrieves breathing rate samples that occurred during a given sleep sample
    func getBreathingRateSamples(for sleepSample: HKCategorySample) async throws -> [HKQuantitySample] {
        let breathingRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
        let predicate = HKQuery.predicateForSamples(withStart: sleepSample.startDate, end: sleepSample.endDate, options: .strictEndDate)
        return await withCheckedContinuation({ continuation in
            let query = HKSampleQuery(sampleType: breathingRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                guard let samples = samples as? [HKQuantitySample] else {
                    print("erroe geting breathing rate, \(String(describing: error))")
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: samples)
            }
            HKHealthStore().execute(query)
        })
    }
}
