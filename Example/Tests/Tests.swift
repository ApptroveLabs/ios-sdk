import XCTest
@testable import trackier_ios_sdk

class Tests: XCTestCase {

    // Every request body carries the ATT status and an isLAT that agrees with it.
    func testGetData_SendsAttStatusAndIsLAT() {
        let body = TrackierWorkRequest(kind: TrackierWorkRequest.KIND_INSTALL, appToken: "test", mode: "testing").getData()

        guard let attStatus = body["attStatus"] as? String else {
            return XCTFail("expected attStatus in the body, got \(String(describing: body["attStatus"]))")
        }
        XCTAssertTrue(["authorized", "denied", "restricted", "not_determined"].contains(attStatus), "unexpected attStatus \(attStatus)")

        guard let isLAT = body["isLAT"] as? Bool else {
            return XCTFail("expected isLAT in the body, got \(String(describing: body["isLAT"]))")
        }
        XCTAssertEqual(isLAT, attStatus != "authorized", "isLAT must be true unless tracking is authorized")
    }

    // A fresh simulator has never shown the ATT prompt.
    func testGetATTStatus_FreshSimulatorIsNotDetermined() {
        if #available(iOS 14, *) {
            XCTAssertEqual(DeviceInfo.getATTStatus(), "not_determined")
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

}
