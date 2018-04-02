//
//  HealthManager.swift
//  Heart Calendar
//
//  Created by Andrew Finke on 2/7/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import HealthKit
import UIKit

class HealthManager {

    // MARK: - Types

    struct HeartRateMeasure: Equatable {

        // MARK: - Properties

        let average: Int

        // MARK: - Initialization

        fileprivate init?(statistics: HKStatistics) {
            let unit = HKUnit.count().unitDivided(by: HKUnit.minute())

            guard let average = statistics.averageQuantity()?.doubleValue(for: unit) else {
                return nil
            }

            self.average = Int(average)
        }

        //swiftlint:disable:next operator_whitespace
        static func ==(lhs: HeartRateMeasure, rhs: HeartRateMeasure) -> Bool {
            return lhs.average == rhs.average
        }
    }

    // MARK: - Properties

    private let healthStore = HKHealthStore()
    private let heartQuantityType: HKQuantityType = {
        guard let object = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            fatalError()
        }
        return object
    }()

    // MARK: - Methods

    func authorize(completion: @escaping (Bool, Error?) -> Void) {
        let set: Set = [heartQuantityType]
        healthStore.requestAuthorization(toShare: nil, read: set) { (success, error) in
            completion(success, error)
        }
    }

    func measure(completion: @escaping (Int?) -> Void) {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-60 * 60)
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: [.strictStartDate, .strictEndDate])

        let query = HKStatisticsQuery(quantityType: heartQuantityType,
                                      quantitySamplePredicate: predicate,
                                      options: [.discreteAverage]) { (_, statistics, error) in

                                                    guard error == nil, let statistics = statistics else {
                                                        completion(nil)
                                                        return
                                                    }

                                                    let measure = HeartRateMeasure(statistics: statistics)
                                                    completion(measure?.average)

        }
        healthStore.execute(query)
    }

}
