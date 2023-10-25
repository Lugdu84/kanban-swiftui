//
//  Task.swift
//  kanban-drag-and-drop
//
//  Created by David Grammatico on 25/10/2023.
//

import SwiftUI

struct Task: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var status: Status
}


enum Status {
    case todo
    case working
    case completed
}
