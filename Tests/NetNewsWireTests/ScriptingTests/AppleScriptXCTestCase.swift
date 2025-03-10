//
//  AppleScriptXCTestCase.swift
//  NetNewsWireUITests
//
//  Created by Olof Hellman on 2/10/18.
//  Copyright © 2018 Ranchero Software. All rights reserved.
//

import XCTest

final class AppleScriptXCTestCase: XCTestCase {

    /*
        @function doIndividualScript
        @param filename -- name of a .applescript (sans extension) in the test bundle's
                           Resources/TestScripts directory
        @brief  given a file, loads the script and runs it.  Expects a result from running
                the script of the form
                     {test_result:true, script_result:<anything>}
                if the test_result is false or is missing, the test fails
        @return  the value of script_result, if any
    */
    func doIndividualScript(filename: String) -> NSAppleEventDescriptor? {
        var errorDict: NSDictionary?
        let testBundle = Bundle(for: type(of: self))
        let url = testBundle.url(forResource: filename, withExtension: "scpt")
        guard let testScriptUrl = url  else {
            XCTFail("Failed Getting script URL")
            return nil
        }

        guard let testScript = NSAppleScript(contentsOf: testScriptUrl, error: &errorDict) else {
            print("error is \(String(describing: errorDict))")
            XCTFail("Failed initializing NSAppleScript")
            return nil
        }

        let scriptResult = testScript.executeAndReturnError(&errorDict)
        if errorDict != nil {
            print("error is \(String(describing: errorDict))")
            XCTFail("Failed executing script")
            return nil
        }

        let usrfDictionary = scriptResult.usrfDictionary()
        guard let testResult = usrfDictionary["test_result"] else {
            XCTFail("test script didn't return test result in usrf")
            return nil
        }

        if testResult.booleanValue != true {
            print("test_result was \(testResult)")
            print("script_result was \(String(describing: usrfDictionary["script_result"]))")
        }

        XCTAssert(testResult.booleanValue == true, "test_result should be true")
        return usrfDictionary["script_result"]
    }
}
