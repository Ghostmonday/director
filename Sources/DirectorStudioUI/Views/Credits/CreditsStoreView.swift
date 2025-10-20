//
//  CreditsStoreView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI

/// Credits & Store UI with payment integration
struct CreditsStoreView: View {
    @State private var currentCredits: Int = 100
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var purchaseHistory: [PurchaseRecord] = []
    @State private var showingPurchaseHistory: Bool = false
    
    private let guiAbstraction = GUIAbstraction()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Credits Display
                    creditsDisplaySection
                    
                    // Credit Packages
                    creditPackagesSection
                    
                    // Usage Statistics
                    usageStatisticsSection
                    
                    // Purchase History
                    purchaseHistorySection
                }
                .padding()
            }
            .navigationTitle("Credits & Store")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadCreditsData()
            }
            .sheet(isPresented: $showingPurchaseHistory) {
                PurchaseHistoryView(history: purchaseHistory)
            }
        }
    }
    
    // MARK: - Credits Display Section
    
    private var creditsDisplaySection: some View {
        VStack(spacing: 16) {
            // Current Credits
            VStack(spacing: 8) {
                Text("Current Credits")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(currentCredits)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text("credits available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Quick Actions
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "gift.fill")
                        Text("Redeem Code")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
                
                Button(action: { showingPurchaseHistory = true }) {
                    HStack {
                        Image(systemName: "clock.fill")
                        Text("History")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Credit Packages Section
    
    private var creditPackagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Credit Packages")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 12)
            ], spacing: 12) {
                ForEach(creditPackages, id: \.id) { package in
                    CreditPackageView(package: package) {
                        purchaseCredits(package)
                    }
                }
            }
        }
    }
    
    // MARK: - Usage Statistics Section
    
    private var usageStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Usage Statistics")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                StatisticRowView(
                    title: "Videos Generated",
                    value: "12",
                    icon: "video.fill",
                    color: .blue
                )
                
                StatisticRowView(
                    title: "Credits Used This Month",
                    value: "45",
                    icon: "creditcard.fill",
                    color: .orange
                )
                
                StatisticRowView(
                    title: "Average Cost per Video",
                    value: "3.75",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Purchase History Section
    
    private var purchaseHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Purchases")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showingPurchaseHistory = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if purchaseHistory.isEmpty {
                Text("No purchases yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(purchaseHistory.prefix(3), id: \.id) { purchase in
                        PurchaseHistoryRowView(purchase: purchase)
                    }
                }
            }
        }
    }
    
    // MARK: - Credit Packages Data
    
    private var creditPackages: [CreditPackage] {
        [
            CreditPackage(
                id: "starter",
                name: "Starter",
                credits: 50,
                price: "$4.99",
                description: "Perfect for trying out DirectorStudio",
                popular: false
            ),
            CreditPackage(
                id: "creator",
                name: "Creator",
                credits: 200,
                price: "$14.99",
                description: "Great for regular content creation",
                popular: true
            ),
            CreditPackage(
                id: "pro",
                name: "Pro",
                credits: 500,
                price: "$29.99",
                description: "For professional content creators",
                popular: false
            ),
            CreditPackage(
                id: "enterprise",
                name: "Enterprise",
                credits: 1000,
                price: "$49.99",
                description: "Maximum value for heavy users",
                popular: false
            )
        ]
    }
    
    // MARK: - Actions
    
    private func loadCreditsData() {
        isLoading = true
        
        Task {
            do {
                let credits = try await guiAbstraction.getCreditsBalance()
                
                await MainActor.run {
                    currentCredits = credits
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func purchaseCredits(_ package: CreditPackage) {
        // Simulate purchase process
        print("Purchasing \(package.name) package...")
        
        // In a real app, this would integrate with StoreKit
        // For now, just simulate adding credits
        currentCredits += package.credits
        
        // Add to purchase history
        let purchase = PurchaseRecord(
            id: UUID(),
            packageName: package.name,
            credits: package.credits,
            price: package.price,
            date: Date()
        )
        purchaseHistory.insert(purchase, at: 0)
    }
}

/// Credit Package View
struct CreditPackageView: View {
    let package: CreditPackage
    let onPurchase: () -> Void
    
    var body: some View {
        Button(action: onPurchase) {
            VStack(spacing: 12) {
                // Popular Badge
                if package.popular {
                    Text("POPULAR")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(4)
                }
                
                // Package Name
                Text(package.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Credits Amount
                Text("\(package.credits)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("credits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Price
                Text(package.price)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                // Description
                Text(package.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                // Purchase Button
                Text("Purchase")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(package.popular ? Color.orange : Color(.systemGray4), lineWidth: package.popular ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Statistic Row View
struct StatisticRowView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

/// Purchase History Row View
struct PurchaseHistoryRowView: View {
    let purchase: PurchaseRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(purchase.packageName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(purchase.credits) credits")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(purchase.price)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(purchase.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Purchase History View
struct PurchaseHistoryView: View {
    let history: [PurchaseRecord]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(history, id: \.id) { purchase in
                    PurchaseHistoryRowView(purchase: purchase)
                }
            }
            .navigationTitle("Purchase History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Data Models
struct CreditPackage {
    let id: String
    let name: String
    let credits: Int
    let price: String
    let description: String
    let popular: Bool
}

struct PurchaseRecord {
    let id: UUID
    let packageName: String
    let credits: Int
    let price: String
    let date: Date
}

/// Preview
struct CreditsStoreView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsStoreView()
    }
}
