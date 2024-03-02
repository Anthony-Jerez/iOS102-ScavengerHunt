//
//  Task.swift
//  project1-scavenger-hunt
//
//  Created by Anthony Jerez on 3/1/24.
//

import Foundation
import UIKit
import CoreLocation

class Task {
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Task {
    static var mockedTasks: [Task] {
        return [
            Task(title: "Your favorite hiking spot",
                 description: "Where would you like to be one with nature?"),
            Task(title: "Your favorite restaurant",
                 description: "Where do you go to seek fine dining?"),
            Task(title: "Your favorite mall",
                 description: "Where do you find yourself mostly shopping at?")
        ]
    }
}
