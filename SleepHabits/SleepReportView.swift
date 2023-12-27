//
//  SleepReportView.swift
//  SleepHabits
//
//  Created by Artemis Shlesberg on 2/24/23.
//

import SwiftUI

extension Color {
    static var sleepBlue: Color {
        Color(red: 5.0 / 255.0, green: 28.0 / 255.0, blue: 55.0 / 255.0)
    }
}

/// 8h12m
func formatTimeInterval(_ timeInterval: Int) -> String {
    let minutes = "\(timeInterval % 60)m"
    if timeInterval >= 60 {
        let hours = "\(timeInterval / 60)h"
        return hours + minutes
    } else {
        return minutes
    }
    
}

let yesterdayTasks = [
    SleepTask(title: "Complete work on Sleep app", isCompleted: true, format: "Great job!"),
    SleepTask(title: "Go for a walk", isCompleted: false, format: "", goal: 10000, actualResult: 8500)
]

let sleepReport = SleepReport(
    date: Date(),
    sleepScore: 85,
    isBetterThanLast: true,
    sleepDuration: 245,
    timeToFallAsleep: 15,
    timeInDeepSleep: 40,
    timeInBed: 480,
    percentageAwake: 20,
    yesterdayTasks: yesterdayTasks,
    sleepingGraphData: [],
    breathingRateRange: BreathingRateRange(isSteady: true, minimum: 60, maximum: 80),
    heartRateRange: HeartRateRange(isSteady: true, minimum: 60, maximum: 80)
)


struct SleepReportView: View {
    var report: SleepReport
    
    var body: some View {
        ScrollView {
            VStack {
                ReportHeaderView(report: report)
                ReportBodyView(report: report)
            }
        }
    }
}

struct ReportBodyView: View {
    
    var report: SleepReport
    
    var body: some View {
        ZStack {
            Color.white
            VStack {
                HStack {
                    Text("Night at a glance")
                        .fontWeight(.semibold)
                        .font(.title)
                        .padding(16)
                    Spacer()
                }
                // MARK: - stats
                HStack {
                    SleepStatView(sleepStat: SleepStat(title: "time to fall asleep", value: "\(report.timeToFallAsleep)", trend: .up, iconName: "moon.zzz.fill"))
                    SleepStatView(sleepStat: SleepStat(title: "time to fall asleep", value: "\(report.timeToFallAsleep)", trend: .up, iconName: "moon.zzz.fill"))
                }
                // MARK: - tasks
                HStack {
                    Text("Yesterday tasks")
                        .fontWeight(.semibold)
                        .font(.title3)
                        .padding(16)
                    Spacer()
                }
                VStack {
                    HStack {
                        SleepReportTaskView(sleepTask: report.yesterdayTasks[0])
                        SleepReportTaskView(sleepTask: report.yesterdayTasks[1])
                    }
                    HStack {
                        SleepReportTaskView(sleepTask: report.yesterdayTasks[0])
                        SleepReportTaskView(sleepTask: report.yesterdayTasks[1])
                    }
                }
                // MARK: - graph
                HStack {
                    Text("Sleep Graph")
                        .fontWeight(.semibold)
                        .font(.title3)
                        .padding(16)
                    Spacer()
                }
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(height: 200)
                    .padding(12)
                
                // MARK: - insights
                HStack {
                    Text("Sleep insights")
                        .fontWeight(.semibold)
                        .font(.title3)
                        .padding(16)
                    Spacer()
                }
                
                VStack {
                    ReportInsightView(insight: SleepInsight(title: "Steady breathing", value: "\(report.breathingRateRange.minimum) - \(report.breathingRateRange.maximum)"))
                    ReportInsightView(insight: SleepInsight(title: "Steady breathing", value: "\(report.breathingRateRange.minimum) - \(report.breathingRateRange.maximum)"))
                    ReportInsightView(insight: SleepInsight(title: "Steady breathing", value: "\(report.breathingRateRange.minimum) - \(report.breathingRateRange.maximum)"))
                    
                }
                
                Button(action: {}) {
                    Text("How to improve your sleep")
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background {
                    Color.sleepBlue
                }
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(12)
                
                Button(action: {}) {
                    Text("About the score")
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background {
                    Color.sleepBlue.opacity(0.3)
                }
                .foregroundColor(.sleepBlue)
                .cornerRadius(12)
                .padding(12)
                
            }
        }
    }
}

struct SleepInsight {
    var title: String
    var value: String
}

struct ReportInsightView: View {
    
    var insight: SleepInsight
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(width: 20, height: 20)
                
            Text(insight.title)
                .font(.subheadline)
            Spacer()
            Text(insight.value)
                .fontWeight(.medium)
                .font(.system(size: 20, weight: .medium))
            Image(systemName: "chevron.right")
                .opacity(0.3)
        }
        .padding([.leading, .trailing], 12)
        .padding([.top, .bottom], 6)
    }
}

struct ReportHeaderView: View {
    
    var report: SleepReport
    
    var body: some View {
        
        
            HStack(alignment: .top) {
                VStack(alignment: .leading,spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Good morning!")
                            .fontWeight(.semibold)
                            .font(.title)
                        
                        Text(report.date.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .opacity(0.70)
                    }
                    
                    
                    (Text("You had ") + Text(formatTimeInterval(report.sleepDuration))
                        .fontWeight(.bold)
                         + Text(" of sleep and the quality was ") + Text(report.isBetterThanLast ? "slightly better than yestarday" : "Yestarday was slightly better"))
                    .font(.subheadline)
                    
                }
                Spacer()
                ScoreWheelView(report: report)
            }
            .foregroundColor(.white)
            .padding(20)
        
//        .frame(width: 196, height: 49)
    }
}

struct ScoreWheelView: View {
    let side = 120.0
    
    var report: SleepReport
    var body: some View {
        ZStack {
            Ellipse()
                .stroke(Color(red: 0.41, green: 0.79, blue: 0.52), lineWidth: 15)
                .opacity(0.30)
                .frame(width: side, height: side)
            
            VStack {
                Text("Quality")
                    .font(.subheadline)
                    .opacity(0.70)
                
                Text("\(Int(report.sleepScore))")
                    .fontWeight(.semibold)
                    .font(.largeTitle)
            }
            .foregroundColor(.white)
            .frame(width: side, height: side)

            .cornerRadius(70)
            .overlay(Circle()
                .trim(from: 0, to: CGFloat(report.sleepScore / 100.0))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .frame(width: side, height: side)
                .shadow(color: .green.opacity(0.5) , radius: 12)
             
            )
            
        }
        .frame(width: side, height: side)
    }
}

struct SleepStat {
    enum Trend {
        case up, down, none
        
        var iconName: String {
            switch self {
            case .up:
                return "arrow.up.right"
            case .down:
                return "arrow.down.right"
            case .none:
                return ""
            }
        }
    }
    var title: String
    var value: String
    var trend: Trend
    var iconName: String
}

struct SleepStatView: View {
    
    var sleepStat: SleepStat
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: sleepStat.iconName)
                .resizable()
                .scaledToFit()
            .opacity(0.40)
            .frame(width: 24,height: 24)

            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    Text(sleepStat.value)
                        .fontWeight(.medium)
                        .font(.title3)
                    Image(systemName: sleepStat.trend.iconName)
                            .resizable()
                            .scaledToFit()
                        .opacity(0.40)
                        .frame(width: 14,height: 14)
                }

                Text(sleepStat.title)
                    .font(.subheadline)
                    .opacity(0.40)
            }
            
        }
        .padding(12)
        .foregroundColor(.sleepBlue)

    }
}

struct SleepReportTaskView: View {
    var sleepTask: SleepTask
    var body: some View {
        ZStack(alignment: .leading) {
            
            HStack {
                
                VStack(alignment: .leading) {
                    Text(sleepTask.title)
                        .font(.subheadline)
                    
                    if let goal = sleepTask.goal, let result = sleepTask.actualResult {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("\(result)")
                                .font(.system(size: 20, weight: .medium))
                             
                             
                             Text("/\(goal)")
                                .font(.system(size: 14, weight: .medium))
                                .opacity(0.3)
                        }
                    }
                }
                Spacer()
                //checkmark.circle.fill
                Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .opacity(sleepTask.isCompleted ? 1 : 0.40)
                    .frame(width: 24,height: 24)
                    
            }
            .padding(12)
        }
        .frame(width: 166, height: 66)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
        .foregroundColor(.sleepBlue)
    }
}

struct SleepReportView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ZStack {
                Color.sleepBlue
                    .ignoresSafeArea()
//                    .frame(width: 400, height: 400)
                SleepReportView(report: sleepReport)
            }
        }
    }
}
