import XCTest
@testable import DirectorStudio

final class DirectorStudioCoreTests: XCTestCase {
    
    var core: DirectorStudioCoreCLI!
    
    override func setUp() {
        super.setUp()
        core = DirectorStudioCoreCLI()
    }
    
    override func tearDown() {
        core = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testCoreInitialization() {
        XCTAssertEqual(core.pipelineState, .idle)
        XCTAssertEqual(core.credits, 0)
        XCTAssertFalse(core.isProcessing)
        XCTAssertEqual(core.currentModule, "")
        XCTAssertEqual(core.progress, 0.0)
        XCTAssertNil(core.currentProject)
    }
    
    func testCoreProtocolConformance() {
        XCTAssertTrue(core is DirectorStudioCoreProtocol)
    }
    
    // MARK: - State Management Tests
    
    func testUpdateProject() {
        let project = Project(name: "Test Project")
        core.updateProject(project)
        XCTAssertEqual(core.currentProject?.name, "Test Project")
    }
    
    func testUpdatePipelineState() {
        core.updatePipelineState(.running)
        XCTAssertEqual(core.pipelineState, .running)
    }
    
    func testUpdateCredits() {
        core.updateCredits(100)
        XCTAssertEqual(core.credits, 100)
    }
    
    func testUpdateProcessing() {
        core.updateProcessing(true)
        XCTAssertTrue(core.isProcessing)
    }
    
    func testUpdateCurrentModule() {
        core.updateCurrentModule("test-module")
        XCTAssertEqual(core.currentModule, "test-module")
    }
    
    func testUpdateProgress() {
        core.updateProgress(0.5)
        XCTAssertEqual(core.progress, 0.5)
    }
    
    // MARK: - Module Registration Tests
    
    func testRegisterModule() {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        
        core.registerModule(rewordModule)
        
        let retrievedModule = core.getModule(id: "rewording") as? RewordingModule
        XCTAssertNotNil(retrievedModule)
        XCTAssertEqual(retrievedModule?.id, "rewording")
    }
    
    func testGetAllModules() {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        let segmentModule = SegmentationModule()
        
        core.registerModule(rewordModule)
        core.registerModule(segmentModule)
        
        let allModules = core.getAllModules()
        XCTAssertEqual(allModules.count, 2)
    }
    
    func testGetModuleWithInvalidId() {
        let module = core.getModule(id: "nonexistent") as? RewordingModule
        XCTAssertNil(module)
    }
    
    // MARK: - Module Execution Tests
    
    func testExecuteModuleWithValidInput() async throws {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        core.registerModule(rewordModule)
        
        let input = RewordingInput(text: "Hello world", type: .modernizeOldEnglish)
        let output = try await core.executeModule(rewordModule, input: input)
        
        XCTAssertNotNil(output)
        XCTAssertEqual(output.originalText, "Hello world")
    }
    
    func testExecuteModuleWithDisabledModule() async {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        rewordModule.isEnabled = false
        core.registerModule(rewordModule)
        
        let input = RewordingInput(text: "Hello world", type: .modernizeOldEnglish)
        
        do {
            _ = try await core.executeModule(rewordModule, input: input)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is CoreError)
        }
    }
    
    // MARK: - Pipeline Execution Tests
    
    func testExecutePipelineWithValidInput() async throws {
        // Register modules
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        let segmentModule = SegmentationModule()
        
        core.registerModule(rewordModule)
        core.registerModule(segmentModule)
        
        let input = "Once upon a time, there was a princess."
        let result = try await core.executePipeline(input: input)
        
        XCTAssertTrue(result.success)
        XCTAssertFalse(result.results.isEmpty)
        XCTAssertGreaterThan(result.executionTime, 0)
    }
    
    func testExecutePipelineStateUpdates() async throws {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        core.registerModule(rewordModule)
        
        let input = "Test input"
        
        // Execute pipeline and check state updates
        let expectation = XCTestExpectation(description: "Pipeline execution")
        Task {
            _ = try await core.executePipeline(input: input)
            expectation.fulfill()
        }
        
        // Check initial state
        XCTAssertEqual(core.pipelineState, .running)
        XCTAssertTrue(core.isProcessing)
        
        wait(for: [expectation], timeout: 10.0)
        
        // Check final state
        XCTAssertEqual(core.pipelineState, .completed)
        XCTAssertFalse(core.isProcessing)
        XCTAssertEqual(core.progress, 1.0)
    }
    
    // MARK: - Health Check Tests
    
    func testHealthCheck() async {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        core.registerModule(rewordModule)
        
        let healthStatus = await core.healthCheck()
        
        XCTAssertFalse(healthStatus.isEmpty)
        XCTAssertTrue(healthStatus["aiService"] ?? false)
        XCTAssertTrue(healthStatus["module_rewording"] ?? false)
        XCTAssertTrue(healthStatus["eventBus"] ?? false)
        XCTAssertTrue(healthStatus["services"] ?? false)
        XCTAssertTrue(healthStatus["config"] ?? false)
    }
    
    // MARK: - CLI Test Framework Integration
    
    func testCLITestFramework() async throws {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        core.registerModule(rewordModule)
        
        let input = RewordingInput(text: "Test input", type: .modernizeOldEnglish)
        let result = try await CLITestFramework.testModule(rewordModule, input: input)
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.moduleId, "rewording")
        XCTAssertEqual(result.moduleName, "Rewording")
        XCTAssertGreaterThan(result.duration, 0)
    }
    
    func testCLIPipelineTestFramework() async throws {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        core.registerModule(rewordModule)
        
        let input = "Test pipeline input"
        let result = try await CLITestFramework.testPipeline(core: core, input: input)
        
        XCTAssertTrue(result.success)
        XCTAssertGreaterThan(result.duration, 0)
        XCTAssertEqual(result.input, input)
        XCTAssertNotNil(result.result)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithMultipleModules() {
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        let segmentModule = SegmentationModule()
        
        core.registerModule(rewordModule)
        core.registerModule(segmentModule)
        
        measure {
            let expectation = XCTestExpectation(description: "Pipeline execution")
            Task {
                do {
                    _ = try await core.executePipeline(input: "Performance test input")
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            wait(for: [expectation], timeout: 30.0)
        }
    }
}
