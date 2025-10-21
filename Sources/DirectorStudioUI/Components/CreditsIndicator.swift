//
//  CreditsIndicator.swift
//  DirectorStudioUI
//
//  Shows current credit balance with estimated cost preview
//  UX FIX #4: Quick access to credits with cost awareness
//

import SwiftUI

/// Displays current credit balance with estimated cost and warnings
public struct CreditsIndicator: View {
    let currentBalance: Int
    let estimatedCost: Int?
    let onTap: () -> Void
    
    public init(
        currentBalance: Int,
        estimatedCost: Int? = nil,
        onTap: @escaping () -> Void
    ) {
        self.currentBalance = currentBalance
        self.estimatedCost = estimatedCost
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "creditcard.fill")
                    .font(.caption)
                
                Text("\(currentBalance)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let cost = estimatedCost, cost > 0 {
                    Text("(-\(cost))")
                        .font(.caption)
                        .foregroundColor(insufficientCredits ? .red : .orange)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
        }
        .accessibilityLabel("Credits balance: \(currentBalance)")
        .accessibilityHint(estimatedCost != nil ? "Estimated cost: \(estimatedCost!) credits" : "Tap to view credit store")
    }
    
    // MARK: - Computed Properties
    
    private var insufficientCredits: Bool {
        if let cost = estimatedCost {
            return currentBalance < cost
        }
        return false
    }
    
    private var backgroundColor: Color {
        if insufficientCredits {
            return Color.red.opacity(0.1)
        } else if currentBalance < 50 {
            return Color.orange.opacity(0.1)
        } else {
            return Color.blue.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        if insufficientCredits {
            return .red
        } else if currentBalance < 50 {
            return .orange
        } else {
            return .blue
        }
    }
}

/// Shows estimated cost before running an action
public struct CostPreviewBanner: View {
    let estimatedCost: Int
    let currentBalance: Int
    let actionName: String
    let onBuyMore: () -> Void
    
    public init(
        estimatedCost: Int,
        currentBalance: Int,
        actionName: String,
        onBuyMore: @escaping () -> Void
    ) {
        self.estimatedCost = estimatedCost
        self.currentBalance = currentBalance
        self.actionName = actionName
        self.onBuyMore = onBuyMore
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Estimated Cost")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "creditcard")
                        .font(.caption)
                    
                    Text("\(estimatedCost)")
                        .font(.headline)
                        .foregroundColor(canAfford ? .primary : .red)
                    
                    Text("credits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("After \(actionName)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: canAfford ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(canAfford ? .green : .red)
                    
                    Text("\(remainingBalance)")
                        .font(.headline)
                        .foregroundColor(canAfford ? .green : .red)
                }
            }
            
            if !canAfford {
                Button(action: onBuyMore) {
                    Text("Buy More")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .frame(minWidth: 44, minHeight: 44) // Apple HIG minimum
                .accessibilityLabel("Buy more credits")
                .accessibilityHint("Opens the credit store to purchase more credits")
            }
        }
        .padding()
        .background(canAfford ? Color.blue.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var canAfford: Bool {
        currentBalance >= estimatedCost
    }
    
    private var remainingBalance: Int {
        currentBalance - estimatedCost
    }
}

// MARK: - Previews
struct CreditsComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Credits indicator states
            CreditsIndicator(currentBalance: 150, estimatedCost: 20, onTap: {})
            CreditsIndicator(currentBalance: 30, estimatedCost: 40, onTap: {})
            CreditsIndicator(currentBalance: 10, estimatedCost: nil, onTap: {})
            
            // Cost preview banners
            CostPreviewBanner(
                estimatedCost: 25,
                currentBalance: 100,
                actionName: "Pipeline Run",
                onBuyMore: {}
            )
            
            CostPreviewBanner(
                estimatedCost: 50,
                currentBalance: 30,
                actionName: "Video Generation",
                onBuyMore: {}
            )
            
            Spacer()
        }
        .padding()
    }
}

