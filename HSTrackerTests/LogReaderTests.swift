//
//  LogReaderTests.swift
//  HSTracker
//
//  Created by Istvan Fehervari on 21/03/2017.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import XCTest
import Foundation

@testable import HSTracker

class LogReaderTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testTimeStamp() {
		
		let lines = ["D 00:06:10.0000000 GameState",
		             "D 00:06:10.0010000 GameState",
		             "D 00:06:10 GameState.DebugPrintPower() -     tag=ZONE value=PLAY"]
		let loglines = lines.map { LogLine(namespace: .power, line: $0) }
	
		XCTAssertEqual(loglines[0].time, loglines[2].time)
		XCTAssert(loglines[1].time > loglines[2].time, "\(loglines[1].time) is not bigger than \(loglines[2].time)")
	}
	
	func testLineContent() {
		let line = "D 00:06:10.0010000 GameState.DebugPrintPower() -     tag=ZONE value=PLAY"
		let lineItem = LogLine(namespace: .power, line: line)
		
		let dateStringFormatter = DateFormatter()
		dateStringFormatter.dateFormat = "HH:mm:ss.SSSSSSS"
		
		let str = String(format: "D %@ %@",dateStringFormatter.string(from: lineItem.time), lineItem.content)
		XCTAssertEqual(line, str)
	}
	
	func testDayRollover() {
		
		let future = Calendar.current.date(byAdding: .second, value: 5, to: Date())!
		if trimTime(date: future) > trimTime(date: Date()) {
			Thread.sleep(forTimeInterval: 5)
		}
		
		let line = "D 23:59:59.9999999 GameState.DebugPrintPower() -     tag=ZONE value=PLAY"
		let lineItem = LogLine(namespace: .power, line: line)

		XCTAssertEqual(trimTime(date: lineItem.time), trimTime(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())! ))
	}
	
	func trimTime(date: Date) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = DateFormatter.Style.none
		dateFormatter.dateStyle = DateFormatter.Style.short
		
		let str = dateFormatter.string(from: date) // 12/15/16
		
		return dateFormatter.date(from: str)!
	}
}
