//
//  DataSource.swift
//  SleepHabits
//
//  Created by Артeмий Шлесберг on 12.11.2022.
//

import Foundation
import HealthKit


struct SleepPercentageRecord: Identifiable {
    var id: Int
    let timeStarted: Date
    /// in percent of total duration
    let deepSleep: Double
}

class SleepRecord {
    let inBed: HKCategorySample
    let phases: [HKCategorySample]
    
    private var deepSleepPercentage: Double?
    private var coreSleepPercentage: Double?
    private var REMSleepPercentage: Double?
    private var awakePercentage: Double?
    
    init(inBed: HKCategorySample, phases: [HKCategorySample]) {
        self.inBed = inBed
        self.phases = phases
    }
    
    func percentage(of type: HKCategoryValueSleepAnalysis) -> Double {
        let result: Double?
        switch type {
        case .inBed:
            result = 100.0
        case .awake:
            result = awakePercentage
        case .asleepCore:
            result = coreSleepPercentage
        case .asleepDeep:
            result = deepSleepPercentage
        case .asleepREM:
            result = REMSleepPercentage
        case .asleepUnspecified:
            result = 0
        @unknown default:
            result = 0
        }
        
        if let result = result {
            return result
        } else {
            countPercentages()
            return percentage(of: type)
        }
    }
    
    private func countPercentages() {
        let inBedDuration = inBed.endDate.timeIntervalSince(inBed.startDate)
        var deepSleepDuration: TimeInterval = 0
        var remDuration: TimeInterval = 0
        var coreDuration: TimeInterval = 0
        for sample in phases {
            // if sample is deep sleep and started after the sleep start but before the end
            if
                sample.startDate.timeIntervalSince(inBed.startDate) >= 0 &&
                sample.endDate.timeIntervalSince(inBed.endDate) <= 0 {
                // add duration of sleep
                
                switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                case .asleepDeep:
                    deepSleepDuration += sample.endDate.timeIntervalSince(sample.startDate)
                case .asleepCore:
                    coreDuration += sample.endDate.timeIntervalSince(sample.startDate)
                case .asleepREM:
                    remDuration += sample.endDate.timeIntervalSince(sample.startDate)
                default:
                    continue
                }
                
            }
        }
        deepSleepPercentage = deepSleepDuration / inBedDuration * 100.0
        coreSleepPercentage = coreDuration / inBedDuration * 100.0
        REMSleepPercentage = remDuration / inBedDuration * 100.0
        awakePercentage = 100.0 - deepSleepPercentage! - coreSleepPercentage! - REMSleepPercentage!
    }
    
    var minutesToBed: Int {
        
//        var components = Calendar.current.dateComponents(in: <#T##TimeZone#>, from: <#T##Date#>)
        
        return 0
    }
}

struct AveragesSleep: Identifiable {
    var id: Int
    var date: Date
    var value: Double
    var type: HKCategoryValueSleepAnalysis
    // add standart deviation
}

struct ConsistencyPoint: Identifiable {
    let id: Int
    var standardDeviation: Double
    var deepSleepPercantage: Double
    var timeToBed: Double
}

class DataSource: ObservableObject {
    let healthStore = HKHealthStore()
//    @Published var deepRecords: [SleepRecord] = []
    @Published var deepAveragesSleepRecords: [AveragesSleep] = []
//    @Published var coreRecords: [SleepRecord] = []
    @Published var coreAveragesSleepRecords: [AveragesSleep] = []
//    @Published var remRecords: [SleepRecord] = []
    @Published var remAveragesSleepRecords: [AveragesSleep] = []
    
    @Published var consistencies: [ConsistencyPoint] = []
    
    @Published var allNights: [SleepRecord] = []
    
//    struct SleepScheduleRecord {
//        var day: Date
//        var timeToBed: Double
//    }
        
    init() {
        updateData()
    }
    
    func updateData() {
        requestAuth { [weak self] success in
            if success {
                self?.requestSamples { [weak self] samples in
                    guard let self = self else { return }
                    let nights = self.packNights(samples: samples)
                    self.allNights = nights
                    self.processConsistency(nights: nights)
//                    if let data = self?.processData(samples: samples) {
//                        DispatchQueue.main.async {
////                            self?.deepRecords = data.0
//                            self?.deepAveragesSleepRecords = self!.averages(records: data.0, withType: .asleepDeep) + self!.averages(records: data.1, withType: .asleepREM) + self!.averages(records: data.2, withType: .asleepCore)
//                        }
//                    }
                }
            }
        }
    }
    
    private func averages(records: [SleepPercentageRecord], withType type: HKCategoryValueSleepAnalysis) -> [AveragesSleep] {
        var averages: [Date : [Double]] = [:]
        
        for record in records {
            if var av = averages[record.timeStarted] {
                av.append(record.deepSleep)
            } else {
                averages[record.timeStarted] = [record.deepSleep]
            }
        }
        
        var id = 0
        var result: [AveragesSleep] = []
        for av in averages {
            result.append(AveragesSleep(id: id, date: av.key, value: av.value.reduce(0, { $0 + $1
            }) / Double(av.value.count), type: type))
            id += 1
        }
        return result
    }
    
    func packNights(samples: [HKCategorySample]) -> [SleepRecord] {
        var nights: [SleepRecord] = []
        let inBed = samples.filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }
        for bed in inBed {
            var phasesDuringNight: [HKCategorySample] = []
            for sample in samples {
                // if sample is deep sleep and started after the sleep start but before the end
                if
                    sample.startDate.timeIntervalSince(bed.startDate) >= 0 &&
                        sample.endDate.timeIntervalSince(bed.endDate) <= 0 {
                    // add duration of sleep
                    
                    switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                    case .asleepDeep, .asleepCore, .asleepREM:
                        phasesDuringNight.append(sample)
                    default:
                        continue
                    }
                    
                }
            }
            nights.append(SleepRecord(inBed: bed, phases: phasesDuringNight))
        }
        return nights
    }
    
    
    let rollingAverageWindowSize = 7
    ///deep, rem, core
    private func processData(samples: [HKCategorySample]) -> ([SleepPercentageRecord], [SleepPercentageRecord], [SleepPercentageRecord]) {
        var deepSleepRecords: [SleepPercentageRecord] = []
        var remSleepRecords: [SleepPercentageRecord] = []
        var coreSleepRecords: [SleepPercentageRecord] = []
        var recordId = 0
        let inBed = samples.filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }
        for bed in inBed {
            let inBedDuration = bed.endDate.timeIntervalSince(bed.startDate)
            var deepSleepDuration: TimeInterval = 0
            var remDuration: TimeInterval = 0
            var coreDuration: TimeInterval = 0
            for sample in samples {
                // if sample is deep sleep and started after the sleep start but before the end
                if
                    sample.startDate.timeIntervalSince(bed.startDate) >= 0 &&
                    sample.endDate.timeIntervalSince(bed.endDate) <= 0 {
                    // add duration of sleep
                    
                    switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                    case .asleepDeep:
                        deepSleepDuration += sample.endDate.timeIntervalSince(sample.startDate)
                    case .asleepCore:
                        coreDuration += sample.endDate.timeIntervalSince(sample.startDate)
                    case .asleepREM:
                        remDuration += sample.endDate.timeIntervalSince(sample.startDate)
                    default:
                        continue
                    }
                    
                }
            }
            let percentageOfDeepSleep = deepSleepDuration / inBedDuration
            let percentageOfcoreSleep = coreDuration / inBedDuration
            let percentageOfremSleep = remDuration / inBedDuration
            if
                percentageOfDeepSleep > 0,
                inBedDuration > 4 * 60 * 60,
                let formattedDate = formatDate(sample: bed)
            {
                deepSleepRecords.append(
                    SleepPercentageRecord(
                        id: deepSleepRecords.count,
                        timeStarted: formattedDate,
                        deepSleep: percentageOfDeepSleep))
                
                remSleepRecords.append(
                    SleepPercentageRecord(
                        id: remSleepRecords.count,
                        timeStarted: formattedDate,
                        deepSleep: percentageOfremSleep))
                
                coreSleepRecords.append(
                    SleepPercentageRecord(
                        id: coreSleepRecords.count,
                        timeStarted: formattedDate,
                        deepSleep: percentageOfcoreSleep))
            }
            
            // ---- Consistency
            
            if recordId >= (rollingAverageWindowSize - 1) {
                
                var summ = 0
                for i in (recordId - rollingAverageWindowSize + 1)..<(recordId) {
                    // 
                    inBed[i]
                }
            }
            recordId += 1
            // ----
        }
        return (deepSleepRecords, remSleepRecords, coreSleepRecords)
    }
    
    /// Returns a date shifted to the current timezone to compare absolute time of the day
    func formatDate(sample: HKCategorySample) -> Date? {
//        var components = Calendar.current.dateComponents([.timeZone, .hour, .minute, .second], from: sample.startDate)
        if let timeZoneId = sample.metadata?[HKMetadataKeyTimeZone] as? String,
           let timeZone = TimeZone(identifier: timeZoneId){
            var components = Calendar.current.dateComponents(in: timeZone, from: sample.startDate)
            components.timeZone = TimeZone.current
            if let formattedDate = Calendar.current.date(from: components) {
                
                var components = Calendar.current.dateComponents([.hour, .minute, .second], from: formattedDate)
                components.hour = (components.hour! + 12 ) % 24
                print("\(sample.metadata?[HKMetadataKeyTimeZone]) \(components)")
                return Calendar.current.date(from: components)
            }
        }
        return nil
    }
    
    private func requestAuth(completion: @escaping (Bool) -> () ) {
        let allTypes = Set([HKCategoryType(.sleepAnalysis)])
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                NSLog("Not allowed: \(error.debugDescription)")
            }
            completion(success)
        }
    }
    
    private func requestSamples(completion: @escaping ([HKCategorySample]) -> ()) {
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
                
                // Use a sortDescriptor to get the recent data first
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                
                // we create our query with a block completion to execute
                let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 10000, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                    
                    if error != nil {
                        
                        // something happened
                        NSLog("Couldn't request samples: \(error.debugDescription)")
                        return
                        
                    }
                    
                    if let result = tmpResult {
                        completion(result.compactMap { $0 as? HKCategorySample})
                    }
                }
                
                // finally, we execute our query
            healthStore.execute(query)
        }
    }
}
