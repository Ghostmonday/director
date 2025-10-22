import SwiftUI
import DirectorStudio

@MainActor
public class AppState: ObservableObject {
    // MARK: - Project Management
    @Published public var projects: [Project] = []
    @Published public var currentProject: Project?
    
    // MARK: - Pipeline State
    @Published public var storyInput: String = ""
    @Published public var moduleSettings = ModuleSettings()
    @Published public var isProcessingPipeline: Bool = false
    @Published public var pipelineProgress: Double = 0.0
    @Published public var currentPipelineModule: String = ""
    @Published public var generatedPromptSegments: [PromptSegment] = []
    
    // MARK: - Video Generation
    @Published public var videoLibrary: [GUIVideo] = []
    
    // MARK: - UI State
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let gui = GUIAbstraction()
    
    public init() {
        // Load initial data
        loadProjects()
    }
    
    // MARK: - Project Functions
    
    public func loadProjects() {
        isLoading = true
        Task {
            do {
                projects = try await gui.fetchProjects()
                isLoading = false
            } catch {
                errorMessage = "Failed to load projects: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    public func createProject(name: String, description: String) {
        Task {
            do {
                let newProject = try await gui.createProject(name: name, description: description)
                projects.append(newProject)
            } catch {
                errorMessage = "Failed to create project: \(error.localizedDescription)"
            }
        }
    }
    
    public func setCurrentProject(_ project: Project) {
        currentProject = project
    }
    
    // MARK: - Pipeline Functions
    
    public func runPipeline() {
        isProcessingPipeline = true
        errorMessage = nil
        pipelineProgress = 0.0
        currentPipelineModule = ""
        generatedPromptSegments = []
        
        Task {
            do {
                let segments = try await gui.runPipeline(story: storyInput, settings: moduleSettings)
                generatedPromptSegments = segments
                isProcessingPipeline = false
            } catch {
                errorMessage = "Pipeline failed: \(error.localizedDescription)"
                isProcessingPipeline = false
            }
        }
    }
    
    // MARK: - Video Generation Functions
    
    @available(iOS 15.0, *)
    public func generateVideo(for segment: PromptSegment) {
        Task {
            do {
                let result = try await gui.generateVideo(for: segment)
                let newVideo = GUIVideo(
                    id: UUID(),
                    title: "Segment \(segment.index)",
                    description: segment.content,
                    duration: TimeInterval(segment.duration),
                    createdAt: Date(),
                    thumbnailURL: nil, // Placeholder
                    videoURL: result.videoURL,
                    fileSize: Int(result.fileSize),
                    resolution: .zero, // Placeholder
                    tags: []
                )
                videoLibrary.append(newVideo)
            } catch {
                errorMessage = "Video generation failed: \(error.localizedDescription)"
            }
        }
    }
}
