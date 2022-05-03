//
//  ActivityItem.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 5/4/22.
//

import UIKit

public struct ActivityItem {

    internal var items: [Any]
    internal var activities: [UIActivity]
    internal var excludedTypes: [UIActivity.ActivityType]


    public init(items: Any..., activities: [UIActivity] = [], excludedTypes: [UIActivity.ActivityType] = []) {
        self.items = items
        self.activities = activities
        self.excludedTypes = excludedTypes
    }
    
}
