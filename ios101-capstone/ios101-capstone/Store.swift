//
//  Store.swift
//  ios101-capstone
//
//  Created by Grace P on 8/12/25.
//

import UIKit

enum Store {
    static func docs() -> URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    static func dayKey(_ date: Date = Date()) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Calendar.current.startOfDay(for: date))
    }

    static func pathForToday() -> URL { docs().appendingPathComponent("\(dayKey()).jpg") }

    static func saveTodayImage(_ image: UIImage) throws {
        guard let data = image.jpegData(compressionQuality: 0.85) else { throw NSError(domain: "img", code: 0) }
        try data.write(to: pathForToday(), options: .atomic)
    }

    static func loadTodayImage() -> UIImage? {
        UIImage(contentsOfFile: pathForToday().path)
    }
}
