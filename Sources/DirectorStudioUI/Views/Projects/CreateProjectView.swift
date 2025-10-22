import SwiftUI

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var projectName = ""
    @State private var projectDescription = ""
    var onCommit: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Name", text: $projectName)
                    TextField("Description", text: $projectDescription)
                }
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCommit(projectName, projectDescription)
                        dismiss()
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
    }
}
