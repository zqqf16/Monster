//
//  ConfigTests.swift
//  MonsterTests
//
//  Created by zqqf16 on 2022/9/3.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import XCTest
@testable import Monster

final class ConfigTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCodable() throws {
        let config = VMConfig(
            "Test vm",
            os: .macOS,
            memorySize: 4.GB,
            diskSize: 40.GB,
            cpuCount: 4.core,
            restoreImage: "macos11.2.ipsw",
            bundlePath: "~/Documents/Test.vm"
        )
        
        let jsonData = try JSONEncoder().encode(config)
        let config2 = try JSONDecoder().decode(VMConfig.self, from: jsonData)
        
        XCTAssertEqual(config.id, config2.id)
        XCTAssertEqual(config.name, config2.name)
        XCTAssertEqual(config.os, config2.os)
        XCTAssertEqual(config.memorySize, config2.memorySize)
        XCTAssertEqual(config.diskSize, config2.diskSize)
        XCTAssertEqual(config.cpuCount, config2.cpuCount)
        XCTAssertEqual(config.restoreImagePath, config2.restoreImagePath)
        XCTAssertEqual(config.bundlePath, config2.bundlePath)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
