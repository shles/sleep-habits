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
                ScrollView {
                    LineChart(graphs: [
                        GraphData(
                            id: 0,
                            dataPoints: LineChart.strided( data: dataSource.consistencies
                                .sorted(by: {
                                    $0.standardDeviation < $1.standardDeviation
                                })
                                .map { consisencyPoint in
                                    DataPoint(
                                        x: consisencyPoint.standardDeviation,
                                        y: consisencyPoint.deepSleepPercantage
                                    )
                                }
                            ),
                            title: "Consystency",
                            legend: "How time to bed affects you sleep",
                            form: .insight),
                        
                        GraphData(
                            id: 1,
                            dataPoints: dataSource.consistencies
                                .sorted(by: {
                                    $0.id < $1.id
                                })
                                .map {
                                    $0.standardDeviation
                                }
                            ,
                            title: "Consystency",
                            legend: "How time to bed affects you sleep",
                            form: .hystory),
                        
                    ])
//                    LineChart(dataPoints: dataSource.consistencies.map({ consisencyPoint in
//                        //                    consisencyPoints.map {
//                        DataPoint(
//                            x: consisencyPoint.standardDeviation,
//                            y: consisencyPoint.deepSleepPercantage)
//                        //                    }
//                    }))
//                    LineChart(dataPoints: dataSource.consistencies.map({ consisencyPoint in
//                        //                    consisencyPoints.map {
//                        DataPoint(
//                            x: consisencyPoint.standardDeviation,
//                            y: consisencyPoint.deepSleepPercantage)
//                        //                    }
//                    }))
                    
                    Chart(dataSource.allNights[0].phases) {
                        BarMark(
                            xStart: .value("Start Time", $0.startDate),
                            xEnd: .value("End Time", $0.endDate),
                            y: .value("Job", $0.value)
                        ).opacity(0.2)
                    }
                    .frame(height: 250)
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
