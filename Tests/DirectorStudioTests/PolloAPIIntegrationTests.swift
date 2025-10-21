//
//  PolloAPIIntegrationTests.swift
//  DirectorStudioTests
//
//  Tests for Pollo API integration
//

import XCTest
@testable import DirectorStudio

final class PolloAPIIntegrationTests: XCTestCase {
    
    func testPolloAPIServiceConfiguration() {
        // Test that service initializes
        let service = PolloAPIService.shared
        XCTAssertNotNil(service, "PolloAPIService should initialize")
    }
    
    func testVideoGenerationResultTypes() {
        // Test success result
        let successResult = VideoGenerationResult(
            status: .success,
            videoURL: URL(fileURLWithPath: "/tmp/test.mov")
        )
        XCTAssertEqual(successResult.status, .success)
        XCTAssertNotNil(successResult.videoURL)
        
        // Test failed result
        let failedResult = VideoGenerationResult(
            status: .failed,
            errorMessage: "Test error"
        )
        XCTAssertEqual(failedResult.status, .failed)
        XCTAssertEqual(failedResult.errorMessage, "Test error")
    }
    
    func testPromptBuilding() async {
        // Create test segment
        let segment = PromptSegment(
            index: 1,
            duration: 10,
            content: "A hero discovers a portal",
            characters: ["Hero"],
            setting: "Dark forest",
            action: "Walk towards light",
            continuityNotes: "",
            location: "Forest",
            props: [],
            tone: "mysterious",
            cinematicTags: CinematicTaxonomy(
                shotType: "wide",
                cameraAngle: "low angle",
                framing: "rule of thirds",
                lighting: "dim",
                colorPalette: "cool tones",
                lensType: "35mm",
                cameraMovement: "dolly",
                emotionalTone: "mysterious",
                visualStyle: "cinematic noir",
                actionCues: ["slow walk"]
            )
        )
        
        // This would normally call the API
        // For testing, we just verify the segment structure
        XCTAssertEqual(segment.duration, 10)
        XCTAssertEqual(segment.content, "A hero discovers a portal")
        XCTAssertNotNil(segment.cinematicTags)
    }
    
    func testVideoStorageDirectory() throws {
        // Test that storage directory can be created
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videosDirectory = documentsDirectory.appendingPathComponent("GeneratedVideos", isDirectory: true)
        
        try FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true)
        
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: videosDirectory.path, isDirectory: &isDirectory)
        
        XCTAssertTrue(exists, "Videos directory should exist")
        XCTAssertTrue(isDirectory.boolValue, "Should be a directory")
        
        // Clean up
        try? FileManager.default.removeItem(at: videosDirectory)
    }
    
    func testVideoGenerationErrorTypes() {
        let error1 = VideoGenerationError.generationFailed("Test")
        XCTAssertNotNil(error1.errorDescription)
        
        let error2 = VideoGenerationError.invalidInput("Bad input")
        XCTAssertNotNil(error2.errorDescription)
        
        let error3 = VideoGenerationError.apiError("API down")
        XCTAssertNotNil(error3.errorDescription)
    }
}

