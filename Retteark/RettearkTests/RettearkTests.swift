//
//  RettearkTests.swift
//  RettearkTests
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import XCTest
@testable import Retteark

final class RettearkTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testlagOppgaver() {
        var testString = "1-4";
        var testSvar: [String] = ["1","2","3","4"];
        
        XCTAssertEqual(lagOppgaver(input: testString), testSvar, "Test testlagOppgaver testString = '1-4' feillet")
        
        testString = "1.a-d"
        testSvar = ["1a","1b","1c","1d"]
        XCTAssertEqual(lagOppgaver(input: testString), testSvar, "Test testlagOppgaver testString = '1.a-d' feillet")
        
        testString = "1 .a-d"
        testSvar = ["1 a","1 b","1 c","1 d"]
        XCTAssertEqual(lagOppgaver(input: testString), testSvar, "Test testlagOppgaver testString = '1 .a-d' feillet")
        
        testString = "a-D"
        testSvar = ["a","b","c","d"]
        XCTAssertEqual(lagOppgaver(input: testString), testSvar, "Test testlagOppgaver testString = 'a-D' feillet")
        
        testString = "A-d"
        testSvar = ["A","B","C","D"]
        XCTAssertEqual(lagOppgaver(input: testString), testSvar, "Test testlagOppgaver testString = 'A-D' feillet")
    }

}
