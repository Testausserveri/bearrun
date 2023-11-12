//
//  HealthKit.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation
import HealthKit

public struct HealthKitUtil {
    static let healthStore = HKHealthStore()
    
    public static func getHealthKitPermission(_ callback: @escaping (Bool, Error?) -> ()) {
        
            guard HKHealthStore.isHealthDataAvailable() else {
                return
            }
            
            let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            
            healthStore.requestAuthorization(toShare: [], read: [stepsCount]) { (success, error) in
                if success {
                    print("Permission accept.")
                    callback(true, nil)
                }
                else {
                    if error != nil {
                        print(error ?? "")
                    }
                    callback(false, error)
                }
            }
    }
    
    public static func enableBackground() {
        healthStore.enableBackgroundDelivery(for: .activitySummaryType(), frequency: .hourly, withCompletion: {(result, err) in
            print(result, err)
        })
    }
    
    public static func getTodaySteps(_ callback: @escaping (Double) -> ()) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
           
           let now = Date()
           let startOfDay = Calendar.current.startOfDay(for: now)
           let predicate = HKQuery.predicateForSamples(
               withStart: startOfDay,
               end: now,
               options: .strictStartDate
           )
           
           let query = HKStatisticsQuery(
               quantityType: stepsQuantityType,
               quantitySamplePredicate: predicate,
               options: .cumulativeSum
           ) { _, result, _ in
               guard let result = result, let sum = result.sumQuantity() else {
                   callback(0.0)
                   return
               }
               callback(sum.doubleValue(for: HKUnit.count()))
           }
           
           healthStore.execute(query)
    }
}
