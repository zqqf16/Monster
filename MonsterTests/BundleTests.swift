//
//  BundleTests.swift
//  MonsterTests
//
//  Created by zqqf16 on 2022/9/3.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import XCTest
@testable import Monster

final class BundleTests: XCTestCase {

    var bundle: VMBundle!
    
    override func setUpWithError() throws {
        let url = try createBundle()
        bundle = VMBundle(url)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(atPath: bundle.url.path)
    }
    
    func createBundle() throws -> URL {
        let name = UUID().uuidString + ".vm"
        let path = NSTemporaryDirectory() + "/\(name)"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
    
        return URL(filePath: path)
    }
    
    func testNeedInstall() throws {
        XCTAssertTrue(bundle.needInstall)
        FileManager.default.createFile(atPath: bundle.diskImageURL.path, contents: nil)
        XCTAssertFalse(bundle.needInstall)
    }

    func testConfig() throws {
        XCTAssertNil(bundle.loadConfig())
        
        let target = VMConfig("Test VM", os: .macOS, memorySize: 4.GB, diskSize: 100.GB, cpuCount: 4.core)
        try bundle.save(config: target)
        let config = bundle.loadConfig()!
        
        XCTAssertEqual(config.name, target.name)
        XCTAssertEqual(config.id, target.id)
        XCTAssertEqual(config.diskSize, target.diskSize)
        XCTAssertEqual(config.restoreImagePath, target.restoreImagePath)
        XCTAssertEqual(config.bundlePath, bundle.url.path)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
