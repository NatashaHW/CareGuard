import Foundation
import HealthKit

class MeasureManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isMeasuring = false
    @Published var latestOxygenLevel: Double = 0.98
    @Published var previousOxygenLevel: Double = 0
    @Published var timeAgo: String = ""
    
    @Published var latestHeartRate: Double = 70
    @Published var previousHeartRate: Double = 0
    @Published var showEmergencyOxygen = false
    @Published var showEmergencyHeart = false
    
    private var sosTriggered = false
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                self.startObservingOxygenSaturation()
                self.startObservingHeartRate()
                self.loadPreviousOxygenSaturation()
                self.loadPreviousHeartRate()
            } else if let error = error {
                print("Failed to request authorization for health data: \(error.localizedDescription)")
            }
        }
    }
    
    private func startObservingOxygenSaturation() {
        guard let oxygenSaturationType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: oxygenSaturationType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Failed to observe oxygen saturation: \(error.localizedDescription)")
                return
            }
            
            self.fetchLatestOxygenSaturation { oxygenSaturation in
                DispatchQueue.main.async {
                    self.latestOxygenLevel = oxygenSaturation
                    self.isMeasuring = false
                    self.checkForEmergency()
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchLatestOxygenSaturation(completion: @escaping (Double) -> Void) {
        guard let oxygenSaturationType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
            completion(0)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: oxygenSaturationType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(0)
                return
            }
            
            let oxygenSaturation = sample.quantity.doubleValue(for: HKUnit.percent())
            completion(oxygenSaturation)
        }
        
        healthStore.execute(query)
    }
    
    private func loadPreviousOxygenSaturation() {
        guard let oxygenSaturationType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: oxygenSaturationType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                return
            }
            
            let oxygenSaturation = sample.quantity.doubleValue(for: HKUnit.percent())
            let timeAgo = self.timeAgoSinceDate(date: sample.endDate)
            
            DispatchQueue.main.async {
                self.previousOxygenLevel = oxygenSaturation
                self.timeAgo = timeAgo
            }
        }
        
        healthStore.execute(query)
    }
    
    private func startObservingHeartRate() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Failed to observe heart rate: \(error.localizedDescription)")
                return
            }
            
            self.fetchLatestHeartRate { heartRate in
                DispatchQueue.main.async {
                    self.latestHeartRate = heartRate
                    self.isMeasuring = false
                    self.checkForEmergency()
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchLatestHeartRate(completion: @escaping (Double) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(0)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(0)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            completion(heartRate)
        }
        
        healthStore.execute(query)
    }
    
    func checkForEmergency() {
        // Ensure SOS alert is not triggered repeatedly
        guard !sosTriggered else { return }
        
        if latestHeartRate <= 40 || latestHeartRate >= 150 {
            showEmergencyHeart = true
            showEmergencyOxygen = false
            sosTriggered = true
        } else if latestOxygenLevel * 100 <= 88 {
            showEmergencyOxygen = true
            showEmergencyHeart = false
            sosTriggered = true
        } else {
            showEmergencyHeart = false
            showEmergencyOxygen = false
            sosTriggered = false
        }
    }
    
    private func loadPreviousHeartRate() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            let timeAgo = self.timeAgoSinceDate(date: sample.endDate)
            
            DispatchQueue.main.async {
                self.previousHeartRate = heartRate
                self.timeAgo = timeAgo
            }
        }
        
        healthStore.execute(query)
    }
    
    private func timeAgoSinceDate(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func saveHeartRateToHealthKit() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let heartRateQuantity = HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: latestHeartRate)
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: Date(), end: Date())
        
        healthStore.save(heartRateSample) { success, error in
            if success {
                print("Heart rate saved to HealthKit")
            } else if let error = error {
                print("Failed to save heart rate to HealthKit: \(error.localizedDescription)")
            }
        }
    }
    
    func stopMeasuring() {
        isMeasuring = false
    }
}
