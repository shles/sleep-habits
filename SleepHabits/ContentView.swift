//
//  ContentView.swift
//  SleepHabits
//
//  Created by Артeмий Шлесберг on 12.11.2022.
//

import SwiftUI
import Charts
import HealthKit

extension HKCategorySample: Identifiable {
    
}

struct ContentView: View {
    
    @ObservedObject var dataSource = DataSource()
    
    var body: some View {
        VStack {
            if dataSource.allNights.count > 0 {
                Chart(dataSource.allNights[0].phases) {
                    //                PointMark(x: .value("Time went to bed", $0.timeStarted), y: .value("Time in deep sleep", $0.deepSleep))
                    //            }
                    BarMark(
                        xStart: .value("Start Time", $0.startDate),
                        xEnd: .value("End Time", $0.endDate),
                        y: .value("Job", $0.value)
                    ).opacity(0.2)
                    // Averages on going to bed time
                    //            Chart(dataSource.deepAveragesSleepRecords) {
                    //                BarMark(
                    //                    x: .value("Time went to bed", $0.date),//"\($0.date.formatted(date: .omitted, time: .shortened))"),
                    //                    y: .value("Time in deep sleep", $0.value)
                    //                ).foregroundStyle(by: .value("Stage", $0.type.rawValue))
                    //            }
                    // Consistency
                    //            Chart(dataSource.consistencies) {
                    //                            PointMark(
                    //                                x: .value("Time went to bed", $0.standardDeviation),//"\($0.date.formatted(date: .omitted, time: .shortened))"),
                    //                                y: .value("Time in deep sleep", $0.deepSleepPercantage)
                    //                            )
                    
                    
                    //To bed
                    //                PointMark(
                    //                    x: .value("Time went to bed", $0.id),//"\($0.date.formatted(date: .omitted, time: .shortened))"),
                    //                    y: .value("Time in deep sleep", $0.timeToBed)
                    //                )
                }
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
