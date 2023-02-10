//
//  DataSource+consistency.swift
//  SleepHabits
//
//  Created by Артeмий Шлесберг on 26.11.2022.
//

import Foundation
import HealthKit

class AverageBuffer {
    private(set)var buffer: [Double]
    let size: Int
    
    private var currentIndex = 0
    
    var currentAverage: Double? {
        if currentIndex < (size - 1) {
            return nil
        }
        return Double(buffer.reduce(0, { $0 + $1})) / Double(size)
    }
    
    //standard deviation is equal to the square root of the variance:
    var standartDeviation: Double? {
        guard let average = currentAverage else {
            return nil
        }
        return sqrt(buffer.reduce(0) { $0 + pow(average - $1, 2) } / Double(size))
    }
    
    init(size: Int) {
        self.size = size
        buffer = [Double](repeating: 0, count: size)
    }
    
    
    func update(with value: Double) {
        buffer[currentIndex % size] = value
        currentIndex += 1
    }
    
    
}

extension DataSource {
    func processConsistency(nights: [SleepRecord]) {
        let averagesBuffer = AverageBuffer(size: 7)
        
        var result: [ConsistencyPoint] = []
        
        var id = 0
        for night in nights {
            // get percent of sleep
            let deepSleepPercantage: Double = night.percentage(of: .asleepDeep)
            guard deepSleepPercantage > 0 else {
                continue
            }
                //get minutes in day and put into buffer

            let formatedDate = Calendar.current.dateComponents([.hour, .minute], from: formatDate(sample: night.inBed)!)
//            let formatedDate = formatDate(sample: night.inBed)!
            let minutesInDay = formatedDate.hour! * 60 + formatedDate.minute!
//            let minutesInDay = formatedDate.timeIntervalSince1970
            averagesBuffer.update(with: Double(minutesInDay))
            
            
            if let stdDev = averagesBuffer.standartDeviation {
                
                if stdDev > 200 {
                    continue
                }
                
                if deepSleepPercantage > 20 {
                    continue
                }
 
                result.append(ConsistencyPoint(id: id,standardDeviation: stdDev, deepSleepPercantage: deepSleepPercantage, timeToBed: Double(minutesInDay)))
                id += 1
            }
        }
        
        // calc trend
        
        var sumX: Double  = 0
        var sumY: Double  = 0
        var sumX2: Double  = 0
        var sumXY: Double = 0
        
        for r in result {
            sumX += r.standardDeviation
            sumX2 += r.standardDeviation * r.standardDeviation
            sumY += r.deepSleepPercantage
            sumXY += r.deepSleepPercantage * r.standardDeviation
        }
        
        let bTrend = (Double(result.count) * sumXY - sumX * sumY) / (Double(result.count) * sumX2 - pow(sumX, 2))
        
        print(bTrend)
        
        DispatchQueue.main.async {
            self.consistencies = result
        }
    }
}
