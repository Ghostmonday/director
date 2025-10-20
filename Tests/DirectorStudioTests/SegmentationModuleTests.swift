import XCTest
@testable import DirectorStudio

final class SegmentationModuleTests: XCTestCase {
    
    var module: SegmentationModule!
    
    override func setUp() {
        super.setUp()
        module = SegmentationModule()
    }
    
    override func tearDown() {
        module = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testModuleInitialization() {
        XCTAssertEqual(module.id, "segmentation")
        XCTAssertEqual(module.name, "Segmentation")
        XCTAssertTrue(module.isEnabled)
    }
    
    func testModuleProtocolConformance() {
        XCTAssertTrue(module is ModuleProtocol)
    }
    
    // MARK: - Input Validation Tests
    
    func testValidateInputWithValidStory() {
        let input = SegmentationInput(story: "Once upon a time", maxDuration: 30)
        let isValid = module.validate(input: input)
        XCTAssertTrue(isValid)
    }
    
    func testValidateInputWithEmptyStory() {
        let input = SegmentationInput(story: "", maxDuration: 30)
        let isValid = module.validate(input: input)
        XCTAssertFalse(isValid)
    }
    
    func testValidateInputWithInvalidDuration() {
        let input = SegmentationInput(story: "Test story", maxDuration: 0)
        let isValid = module.validate(input: input)
        XCTAssertFalse(isValid)
    }
    
    func testValidateInputWithExcessiveDuration() {
        let input = SegmentationInput(story: "Test story", maxDuration: 100)
        let isValid = module.validate(input: input)
        XCTAssertFalse(isValid)
    }
    
    // MARK: - Execution Tests
    
    func testExecuteModuleWithValidInput() async throws {
        let input = SegmentationInput(story: "Once upon a time, there was a princess.", maxDuration: 30)
        let output = try await module.execute(input: input)
        
        XCTAssertNotNil(output)
        XCTAssertEqual(output.originalStory, "Once upon a time, there was a princess.")
        XCTAssertEqual(output.maxDuration, 30)
        XCTAssertFalse(output.segments.isEmpty)
    }
    
    func testExecuteModuleWithInvalidInput() async {
        let input = SegmentationInput(story: "", maxDuration: 30)
        
        do {
            _ = try await module.execute(input: input)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is SegmentationError)
        }
    }
    
    // MARK: - Segmentation Logic Tests
    
    func testSegmentationWithShortStory() async throws {
        let input = SegmentationInput(story: "Short story.", maxDuration: 30)
        let output = try await module.execute(input: input)
        
        XCTAssertEqual(output.segments.count, 1)
        XCTAssertEqual(output.segments.first?.text, "Short story.")
    }
    
    func testSegmentationWithLongStory() async throws {
        let longStory = String(repeating: "This is a sentence. ", count: 50)
        let input = SegmentationInput(story: longStory, maxDuration: 30)
        let output = try await module.execute(input: input)
        
        XCTAssertGreaterThan(output.segments.count, 1)
        XCTAssertTrue(output.segments.allSatisfy { $0.duration <= 30 })
    }
    
    // MARK: - CLI Test Framework Integration
    
    func testCLITestFramework() async throws {
        let input = SegmentationInput(story: "Test story for CLI testing", maxDuration: 30)
        let result = try await CLITestFramework.testModule(module, input: input)
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.moduleId, "segmentation")
        XCTAssertEqual(result.moduleName, "Segmentation")
        XCTAssertGreaterThan(result.duration, 0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithVeryLongStory() {
        let veryLongStory = String(repeating: "This is a test sentence for performance testing. ", count: 1000)
        let input = SegmentationInput(story: veryLongStory, maxDuration: 30)
        
        measure {
            let expectation = XCTestExpectation(description: "Module execution")
            Task {
                do {
                    _ = try await module.execute(input: input)
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            wait(for: [expectation], timeout: 30.0)
        }
    }
}
