import UIKit
import XCTest

class Bug {
    enum State {
        case open
        case closed
    }
    
    let state: State
    let timestamp: Date
    let comment: String
    
    init(state: State, timestamp: Date, comment: String) {
        // To be implemented
        //initialize class constant variable
        self.state = state
        self.timestamp = timestamp
        self.comment = comment
        
    }
    
    init(jsonString: String) throws {
        // To be implemented
        //extract json into dictionary
     let json = jsonString.data(using: .utf8)
        let dictionary = try JSONSerialization.jsonObject(with: json!, options: []) as? [String : AnyObject]
        
       let stateString = (dictionary?["state"] as? String)!
        if stateString == "open" {
            self.state = State.open
        }
        else {
            self.state = State.closed
        }
        
        self.timestamp = Date(timeIntervalSince1970: TimeInterval((dictionary?["timestamp"])! as! NSNumber))
        self.comment = dictionary?["comment"] as! String
        
        
    }
}

enum TimeRange {
    case pastDay
    case pastWeek
    case pastMonth
}

class Application {
    var bugs: [Bug]
    
    init(bugs: [Bug]) {
        self.bugs = bugs
    }
    
    func findBugs(state: Bug.State?, timeRange: TimeRange) -> [Bug]{
    
        var packOfBugs = [Bug]() //array of bugs
        let date = Date()
        
        let pastDay = date.addingTimeInterval(-1*(60*60*24)) //estimate date in pastday
        let pastWeek = date.addingTimeInterval(-1*(60*60*24*7)) //estimate date in pastweek
        let pastMonth = date.addingTimeInterval(-1*(60*60*24*30)) //estimate date in pastmonth
        
        for findBug in bugs{
            if findBug.state == state{ //check state opened or closed
            if findBug.timestamp <= pastDay
            {packOfBugs.append(findBug)} 
            
            if findBug.timestamp <= pastWeek
            {packOfBugs.append(findBug)}
            
            if findBug.timestamp <= pastMonth
            {packOfBugs.append(findBug)}
            }
      
            
        }
        
        return packOfBugs
        
        

        
        
   
    
    



    }
}



class UnitTests : XCTestCase {
    lazy var bugs: [Bug] = {
        var date26HoursAgo = Date()
        date26HoursAgo.addTimeInterval(-1 * (26 * 60 * 60))
        
        var date2WeeksAgo = Date()
        date2WeeksAgo.addTimeInterval(-1 * (14 * 24 * 60 * 60))
        
        let bug1 = Bug(state: .open, timestamp: Date(), comment: "Bug 1")
        let bug2 = Bug(state: .open, timestamp: date26HoursAgo, comment: "Bug 2")
        let bug3 = Bug(state: .closed, timestamp: date2WeeksAgo, comment: "Bug 2")

        return [bug1, bug2, bug3]
    }()
    
    lazy var application: Application = {
        let application = Application(bugs: self.bugs)
        return application
    }()

    func testFindOpenBugsInThePastDay() {
        let bugs = application.findBugs(state: .open, timeRange: .pastDay)
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
        XCTAssertEqual(bugs[0].comment, "Bug 1", "Invalid bug order")
    }
    
    func testFindClosedBugsInThePastMonth() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastMonth)
        
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
    }
    
    func testFindClosedBugsInThePastWeek() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastWeek)
        
        XCTAssertTrue(bugs.count == 0, "Invalid number of bugs")
    }
    
    func testInitializeBugWithJSON() {
        do {
            let json = "{\"state\": \"open\",\"timestamp\": 1493393946,\"comment\": \"Bug via JSON\"}"

            let bug = try Bug(jsonString: json)
            
            XCTAssertEqual(bug.comment, "Bug via JSON")
            XCTAssertEqual(bug.state, .open)
            XCTAssertEqual(bug.timestamp, Date(timeIntervalSince1970: 1493393946))
        } catch {
            print(error)
        }
    }
}

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(String(describing: testCase.name)), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

TestRunner().runTests(testClass: UnitTests.self)
