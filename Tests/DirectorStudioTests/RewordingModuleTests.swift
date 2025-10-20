import XCTest
@testable import DirectorStudio

final class RewordingModuleTests: XCTestCase {
    
    var module: RewordingModule!
    var mockAIService: MockAIService!
    
    override func setUp() {
        super.setUp()
        mockAIService = MockAIService()
        module = RewordingModule(aiService: mockAIService)
    }
    
    override func tearDown() {
        module = nil
        mockAIService = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testModuleInitialization() {
        XCTAssertEqual(module.id, "rewording")
        XCTAssertEqual(module.name, "Rewording")
        XCTAssertTrue(module.isEnabled)
    }
    
    func testModuleProtocolConformance() {
        XCTAssertTrue(module is ModuleProtocol)
    }
    
    // MARK: - Input Validation Tests
    
    func testValidateInputWithValidText() {
        let input = RewordingInput(text: "Hello world", type: .modernizeOldEnglish)
        let isValid = module.validate(input: input)
        XCTAssertTrue(isValid)
    }
    
    func testValidateInputWithEmptyText() {
        let input = RewordingInput(text: "", type: .modernizeOldEnglish)
        let isValid = module.validate(input: input)
        XCTAssertFalse(isValid)
    }
    
    func testValidateInputWithWhitespaceOnly() {
        let input = RewordingInput(text: "   ", type: .modernizeOldEnglish)
        let isValid = module.validate(input: input)
        XCTAssertFalse(isValid)
    }
    
    // MARK: - Execution Tests
    
    func testExecuteModuleWithValidInput() async throws {
        let input = RewordingInput(text: "Hello world", type: .modernizeOldEnglish)
        let output = try await module.execute(input: input)
        
        XCTAssertNotNil(output)
        XCTAssertEqual(output.originalText, "Hello world")
        XCTAssertEqual(output.transformationType, .modernizeOldEnglish)
        XCTAssertNotNil(output.transformedText)
    }
    
    func testExecuteModuleWithInvalidInput() async {
        let input = RewordingInput(text: "", type: .modernizeOldEnglish)
        
        do {
            _ = try await module.execute(input: input)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is RewordingError)
        }
    }
    
    // MARK: - Transformation Type Tests
    
    func testAllTransformationTypes() async throws {
        let inputText = "This is a test sentence."
        
        for transformationType in RewordingInput.RewordingType.allCases {
            let input = RewordingInput(text: inputText, type: transformationType)
            let output = try await module.execute(input: input)
            
            XCTAssertEqual(output.originalText, inputText)
            XCTAssertEqual(output.transformationType, transformationType)
            XCTAssertNotNil(output.transformedText)
        }
    }
    
    // MARK: - CLI Test Framework Integration
    
    func testCLITestFramework() async throws {
        let input = RewordingInput(text: "Test input", type: .cinematicMood)
        let result = try await CLITestFramework.testModule(module, input: input)
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.moduleId, "rewording")
        XCTAssertEqual(result.moduleName, "Rewording")
        XCTAssertGreaterThan(result.duration, 0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLongText() {
        let longText = String(repeating: "This is a test sentence. ", count: 100)
        let input = RewordingInput(text: longText, type: .modernizeOldEnglish)
        
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
            wait(for: [expectation], timeout: 10.0)
        }
    }
}
