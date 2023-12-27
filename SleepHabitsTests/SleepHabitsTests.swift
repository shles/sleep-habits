//
//  SleepHabitsTests.swift
//  SleepHabitsTests
//
//  Created by Artemis Shlesberg on 2/21/23.
//

import XCTest

extension DataPoint: Equatable {
    static func == (lhs: DataPoint, rhs: DataPoint) -> Bool {
        return lhs.y == rhs.y && lhs.x == rhs.x
    }
    
    
}

final class SleepHabitsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStrided() throws {
        let dataPoints: [DataPoint] = [
            DataPoint(x: 0, y: 0.4),
            DataPoint(x: 1, y: 0.7),
            DataPoint(x: 2, y: 0.3),
            DataPoint(x: 3, y: 0.9),
            DataPoint(x: 4, y: 0.6),
            DataPoint(x: 5, y: 0.4),
            DataPoint(x: 6, y: 0.7),
        ]
        
        let strided = LineChart.strided(data: dataPoints)
        
        XCTAssertEqual(dataPoints.map { $0.y }, strided)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
