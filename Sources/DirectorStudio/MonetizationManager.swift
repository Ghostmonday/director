//
//  MonetizationManager.swift
//  DirectorStudio
//
//  MODULE: MonetizationManager
//  VERSION: 1.0.0
//  PURPOSE: Credits and monetization system
//

import Foundation

// MARK: - Monetization Manager Protocol

public protocol MonetizationManagerProtocol {
    // Credits Management
    var currentCredits: Int { get }
    func addCredits(_ amount: Int) async throws -> Int
    func useCredits(_ amount: Int) async throws -> Int
    func canAfford(_ amount: Int) -> Bool
    
    // Product Management
    func getAvailableProducts() async throws -> [Product]
    func purchaseProduct(_ productId: String) async throws -> PurchaseResult
    func restorePurchases() async throws -> [PurchaseResult]
    
    // Subscription Management
    func getActiveSubscription() async throws -> Subscription?
    func cancelSubscription() async throws -> Bool
    
    // Transaction History
    func getTransactionHistory() async throws -> [Transaction]
    func getTransaction(id: String) async throws -> Transaction?
    
    // Credits Pricing
    func getCreditsPricing() async throws -> [CreditsPricing]
    
    // Feature Access
    func hasAccessToFeature(_ feature: Feature) async -> Bool
}

// MARK: - Supporting Types

public struct Product: Codable, Identifiable, Sendable {
    public let id: String
    public let type: ProductType
    public let name: String
    public let description: String
    public let price: Decimal
    public let currencyCode: String
    public let credits: Int?
    public let features: [Feature]?
    public let duration: TimeInterval?
    
    public init(
        id: String,
        type: ProductType,
        name: String,
        description: String,
        price: Decimal,
        currencyCode: String,
        credits: Int? = nil,
        features: [Feature]? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.price = price
        self.currencyCode = currencyCode
        self.credits = credits
        self.features = features
        self.duration = duration
    }
    
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? "$\(price)"
    }
}

public enum ProductType: String, Codable, Sendable, CaseIterable {
    case credits
    case subscription
    case feature
}

public struct CreditsPricing: Codable, Identifiable, Sendable {
    public let id: String
    public let credits: Int
    public let price: Decimal
    public let currencyCode: String
    public let bonusCredits: Int
    public let isPromotional: Bool
    
    public init(
        id: String,
        credits: Int,
        price: Decimal,
        currencyCode: String,
        bonusCredits: Int = 0,
        isPromotional: Bool = false
    ) {
        self.id = id
        self.credits = credits
        self.price = price
        self.currencyCode = currencyCode
        self.bonusCredits = bonusCredits
        self.isPromotional = isPromotional
    }
    
    public var totalCredits: Int {
        return credits + bonusCredits
    }
    
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? "$\(price)"
    }
    
    public var creditsPerDollar: Double {
        let priceDouble = NSDecimalNumber(decimal: price).doubleValue
        guard priceDouble > 0 else { return 0 }
        return Double(totalCredits) / priceDouble
    }
}

public struct Subscription: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let startDate: Date
    public let expirationDate: Date
    public let isAutoRenewing: Bool
    public let features: [Feature]
    public let monthlyCredits: Int
    public let price: Decimal
    public let currencyCode: String
    public let status: SubscriptionStatus
    
    public init(
        id: String,
        name: String,
        startDate: Date,
        expirationDate: Date,
        isAutoRenewing: Bool,
        features: [Feature],
        monthlyCredits: Int,
        price: Decimal,
        currencyCode: String,
        status: SubscriptionStatus
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.expirationDate = expirationDate
        self.isAutoRenewing = isAutoRenewing
        self.features = features
        self.monthlyCredits = monthlyCredits
        self.price = price
        self.currencyCode = currencyCode
        self.status = status
    }
    
    public var isActive: Bool {
        return status == .active && Date() < expirationDate
    }
    
    public var daysRemaining: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }
    
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? "$\(price)"
    }
}

public enum SubscriptionStatus: String, Codable, Sendable, CaseIterable {
    case active
    case expired
    case cancelled
    case onHold
    case gracePeriod
}

public struct Transaction: Codable, Identifiable, Sendable {
    public let id: String
    public let type: TransactionType
    public let date: Date
    public let amount: Decimal
    public let currencyCode: String
    public let credits: Int?
    public let productId: String?
    public let description: String
    public let status: TransactionStatus
    
    public init(
        id: String,
        type: TransactionType,
        date: Date,
        amount: Decimal,
        currencyCode: String,
        credits: Int? = nil,
        productId: String? = nil,
        description: String,
        status: TransactionStatus
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.amount = amount
        self.currencyCode = currencyCode
        self.credits = credits
        self.productId = productId
        self.description = description
        self.status = status
    }
    
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$\(amount)"
    }
}

public enum TransactionType: String, Codable, Sendable, CaseIterable {
    case purchase
    case subscription
    case creditsAdded
    case creditsUsed
    case refund
    case reward
}

public enum TransactionStatus: String, Codable, Sendable, CaseIterable {
    case completed
    case pending
    case failed
    case refunded
    case cancelled
}

public struct PurchaseResult: Codable, Sendable {
    public let success: Bool
    public let productId: String
    public let transaction: Transaction?
    public let error: PurchaseError?
    
    public init(
        success: Bool,
        productId: String,
        transaction: Transaction? = nil,
        error: PurchaseError? = nil
    ) {
        self.success = success
        self.productId = productId
        self.transaction = transaction
        self.error = error
    }
}

public enum PurchaseError: String, Error, Codable, Sendable, CaseIterable {
    case paymentCancelled
    case paymentInvalid
    case paymentNotAllowed
    case productNotAvailable
    case networkError
    case unknown
}

public enum Feature: String, Codable, Sendable, CaseIterable {
    case videoGeneration
    case highQualityExport
    case advancedEffects
    case batchProcessing
    case customBranding
    case aiStoryEnhancement
    case priorityProcessing
    case unlimitedProjects
    case cloudStorage
    case teamCollaboration
}

// MARK: - Mock Monetization Manager

public class MockMonetizationManager: MonetizationManagerProtocol {
    private var credits: Int
    private let persistenceManager: PersistenceManagerProtocol
    
    public init(persistenceManager: PersistenceManagerProtocol) {
        self.persistenceManager = persistenceManager
        
        // Load initial credits
        do {
            self.credits = try persistenceManager.getCreditsBalance()
        } catch {
            print("Failed to load credits: \(error.localizedDescription)")
            self.credits = 100 // Default starting credits
        }
    }
    
    // MARK: - Credits Management
    
    public var currentCredits: Int {
        return credits
    }
    
    public func addCredits(_ amount: Int) async throws -> Int {
        guard amount > 0 else {
            throw MonetizationError.invalidAmount
        }
        
        credits += amount
        try persistenceManager.saveCreditsBalance(credits)
        
        return credits
    }
    
    public func useCredits(_ amount: Int) async throws -> Int {
        guard amount > 0 else {
            throw MonetizationError.invalidAmount
        }
        
        guard canAfford(amount) else {
            throw MonetizationError.insufficientCredits
        }
        
        credits -= amount
        try persistenceManager.saveCreditsBalance(credits)
        
        return credits
    }
    
    public func canAfford(_ amount: Int) -> Bool {
        return credits >= amount
    }
    
    // MARK: - Product Management
    
    public func getAvailableProducts() async throws -> [Product] {
        // Mock products
        return [
            Product(
                id: "com.directorstudio.credits.small",
                type: .credits,
                name: "100 Credits",
                description: "100 credits for video generation",
                price: 4.99,
                currencyCode: "USD",
                credits: 100
            ),
            Product(
                id: "com.directorstudio.credits.medium",
                type: .credits,
                name: "500 Credits",
                description: "500 credits for video generation",
                price: 19.99,
                currencyCode: "USD",
                credits: 500
            ),
            Product(
                id: "com.directorstudio.credits.large",
                type: .credits,
                name: "1000 Credits",
                description: "1000 credits for video generation",
                price: 34.99,
                currencyCode: "USD",
                credits: 1000
            ),
            Product(
                id: "com.directorstudio.subscription.pro",
                type: .subscription,
                name: "Pro Subscription",
                description: "Monthly subscription with premium features",
                price: 14.99,
                currencyCode: "USD",
                credits: 200,
                features: [.highQualityExport, .advancedEffects, .aiStoryEnhancement],
                duration: 30 * 24 * 60 * 60 // 30 days in seconds
            ),
            Product(
                id: "com.directorstudio.subscription.premium",
                type: .subscription,
                name: "Premium Subscription",
                description: "Monthly subscription with all features",
                price: 29.99,
                currencyCode: "USD",
                credits: 500,
                features: [.highQualityExport, .advancedEffects, .aiStoryEnhancement, .batchProcessing, .customBranding, .priorityProcessing],
                duration: 30 * 24 * 60 * 60 // 30 days in seconds
            )
        ]
    }
    
    public func purchaseProduct(_ productId: String) async throws -> PurchaseResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Find product
        let products = try await getAvailableProducts()
        guard let product = products.first(where: { $0.id == productId }) else {
            return PurchaseResult(
                success: false,
                productId: productId,
                error: .productNotAvailable
            )
        }
        
        // Simulate successful purchase
        let transaction = Transaction(
            id: UUID().uuidString,
            type: product.type == .subscription ? .subscription : .purchase,
            date: Date(),
            amount: product.price,
            currencyCode: product.currencyCode,
            credits: product.credits,
            productId: productId,
            description: "Purchase of \(product.name)",
            status: .completed
        )
        
        // Add credits if applicable
        if let creditsAmount = product.credits {
            try await addCredits(creditsAmount)
        }
        
        return PurchaseResult(
            success: true,
            productId: productId,
            transaction: transaction
        )
    }
    
    public func restorePurchases() async throws -> [PurchaseResult] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Simulate no previous purchases
        return []
    }
    
    // MARK: - Subscription Management
    
    public func getActiveSubscription() async throws -> Subscription? {
        // Simulate no active subscription
        return nil
    }
    
    public func cancelSubscription() async throws -> Bool {
        // Simulate no subscription to cancel
        throw MonetizationError.noActiveSubscription
    }
    
    // MARK: - Transaction History
    
    public func getTransactionHistory() async throws -> [Transaction] {
        // Simulate empty transaction history
        return []
    }
    
    public func getTransaction(id: String) async throws -> Transaction? {
        // Simulate no transaction found
        return nil
    }
    
    // MARK: - Credits Pricing
    
    public func getCreditsPricing() async throws -> [CreditsPricing] {
        // Mock credits pricing
        return [
            CreditsPricing(
                id: "com.directorstudio.credits.small",
                credits: 100,
                price: 4.99,
                currencyCode: "USD"
            ),
            CreditsPricing(
                id: "com.directorstudio.credits.medium",
                credits: 500,
                price: 19.99,
                currencyCode: "USD",
                bonusCredits: 50
            ),
            CreditsPricing(
                id: "com.directorstudio.credits.large",
                credits: 1000,
                price: 34.99,
                currencyCode: "USD",
                bonusCredits: 150
            ),
            CreditsPricing(
                id: "com.directorstudio.credits.xlarge",
                credits: 2500,
                price: 79.99,
                currencyCode: "USD",
                bonusCredits: 500
            ),
            CreditsPricing(
                id: "com.directorstudio.credits.promo",
                credits: 200,
                price: 7.99,
                currencyCode: "USD",
                bonusCredits: 50,
                isPromotional: true
            )
        ]
    }
    
    // MARK: - Feature Access
    
    public func hasAccessToFeature(_ feature: Feature) async -> Bool {
        // In this mock implementation, all features are available
        return true
    }
}

// MARK: - Error Types

public enum MonetizationError: Error, LocalizedError {
    case insufficientCredits
    case invalidAmount
    case productNotAvailable
    case purchaseFailed(String)
    case noActiveSubscription
    case networkError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .insufficientCredits:
            return "Insufficient credits"
        case .invalidAmount:
            return "Invalid amount"
        case .productNotAvailable:
            return "Product not available"
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .noActiveSubscription:
            return "No active subscription"
        case .networkError:
            return "Network error"
        case .unknown:
            return "Unknown error"
        }
    }
}
