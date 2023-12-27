//
//  LineChart.swift
//  SleepHabits
//
//  Created by Artemis Shlesberg on 2/20/23.
//

import SwiftUI

import SwiftUICharts

enum GraphType {
    case hystory
    case insight
}

struct GraphData: Identifiable {
    var id: Int
    var dataPoints: [Double]
    var title: String
    var legend: String
    var form: GraphType
}

struct DataPoint {
    let x: Double
    let y: Double
}

struct LineChart: View {
//    let dataPoints: [DataPoint]
    
    func normilized(data: [DataPoint]) -> [DataPoint] {
        
        guard !data.isEmpty else {return []}
        let maxY = data.map { $0.y }.max()!
        let minY = data.map { $0.y }.min()!
        let maxX = data.map { $0.x }.max()!
        let minX = data.map { $0.x }.min()!
        
        let normalized = data
            .map {
                DataPoint(x: ($0.x - minX) / maxX, y: ($0.y - minY) / maxY)
            }
            .sorted {
                $0.x < $1.x
            }
        return normalized
    }
    
    static func strided (data: [DataPoint]) -> [Double] {
        
        guard !data.isEmpty else {return []}
        let maxY = data.map { $0.y }.max()!
        let minY = data.map { $0.y }.min()!
        let maxX = data.map { $0.x }.max()!
        let minX = data.map { $0.x }.min()!
        
        let numberOfSteps = 7.0
        let step = (maxX - minX) / (numberOfSteps )
        
        var strided: [Double] = []
        var sum = 0.0
        var num = 0
        var t = minX + step
        for point in data {
            if point.x < t {
                sum += point.y
                num += 1
            } else {
                if num > 0 {
                    strided.append(sum / Double(num))
                }
                sum = point.y
                num = 1
                t += step
            }
        }
        if num > 0 {
            strided.append(sum / Double(num))
        }
        
        return strided
        
    }
    
    func appendedTo30(data: [Double]) -> [Double] {
        if data.count >= 30 {
            return data.suffix(30)
        } else {
            return Array(repeating: 0.0, count: 30 - data.count) + data
        }
    }
    
    var graphs: [GraphData]
    
    var body: some View {
        VStack {
            PaginatableScroll(pageCount: 3) {
                ForEach(graphs) { graph in
                    VStack {
                        switch graph.form {
                        case .insight:
                            LineChartView(
                                data: graph.dataPoints,
                                title: graph.title,
                                legend: graph.legend,
                                style: Styles.lineChartStyleOne, form:
                                    //                                ChartForm.medium
                                CGSize(width: UIScreen.main.bounds.width - 20, height: 230)
                            )
                            //                        .frame(height: 200)
                            .allowsHitTesting(false)
                            //                        Spacer(minLength: 20)
                        case .hystory:
                            BarChartView(
                                
                                data: ChartData(points: appendedTo30(data: graph.dataPoints)),
                                title: graph.title,
                                legend: graph.legend,
                                style: Styles.lineChartStyleOne, form:
                                    //                                ChartForm.medium
                                CGSize(width: UIScreen.main.bounds.width - 20, height: 230)
                            )
                        }
                    }
                }
            }
        }
    }
    
    var emptyState: some View = {
        VStack {
            Image(systemName: "arrow.triangle.2.circlepath.doc.on.clipboard")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("No data to display")
        }
    }()
}

fileprivate let preViewGraphs: [GraphData] = [
    GraphData(id: 0, dataPoints: [0.4, 0.7, 0.3, 0.9, 0.6, 0.4, 0.7], title: "Insight", legend: "How your sleep quality", form: .insight),
    GraphData(id: 1, dataPoints: [0.4, 0.7, 0.3, 0.9, 0.6, 0.4, 0.7], title: "History", legend: "How your sleep quality", form: .hystory)
]

struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(graphs: preViewGraphs)
//            .frame(height: 100)
//            .padding()
//            .background(Color.green)
    }
}
