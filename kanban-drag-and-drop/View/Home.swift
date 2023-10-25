//
//  Home.swift
//  kanban-drag-and-drop
//
//  Created by David Grammatico on 25/10/2023.
//

import SwiftUI

struct Home: View {
    @State private var todo: [Task] = [
        .init(title: "Edit video", status: .todo)
    ]
    @State private var working: [Task] = [
        .init(title: "Record video", status: .working)
    ]
    @State private var completed: [Task] = [
        .init(title: "Implement Drag & Drop", status: .completed),
        .init(title: "Update Mockview App !", status: .completed)
    ]
    
    @State private var currentlyDragging: Task?
    
    var body: some View {
        HStack(spacing: 2) {
            TodoView()
                
            WorkingView()
                
            CompletedView()
                
        }
    }
    
    @ViewBuilder
    func TasksView(_ tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(tasks) { task in
                GeometryReader(content: { geometry in
                    TaskRow(task, geometry.size)
                })
                .frame(height: 45)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    func TaskRow(_ task: Task, _ size: CGSize) -> some View {
        Text(task.title)
            .font(.callout)
            .foregroundStyle(.blue)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: size.height)
            .background(.white, in: .rect(cornerRadius: 10))
            .contentShape(.dragPreview, .rect(cornerRadius: 10))
            .draggable(task.id.uuidString) {
                Text(task.title)
                    .font(.callout)
                    .padding(.horizontal, 15)
                    .frame(width: size.width, height: size.height, alignment: .leading)
                    .background(.white)
                    .contentShape(.dragPreview, .rect(cornerRadius: 10))
                    .onAppear(perform: {
                        currentlyDragging = task
                    })
            }
            .dropDestination(for: String.self) { items, location in
                currentlyDragging = nil
                return false
            } isTargeted: { status in
                if let currentlyDragging, status, currentlyDragging.id != task.id {
                    withAnimation(.snappy) {
                        appenTask(task.status)
                        switch task.status {
                        case .todo:
                            replaceItem(tasks: &todo, droppingTask: task, status: .todo)
                        case .working:
                            replaceItem(tasks: &working, droppingTask: task, status: .working)
                        case .completed:
                            replaceItem(tasks: &completed, droppingTask: task, status: .completed)
                        }
                    }
                }
            }
    }
    
    func appenTask(_ status: Status) {
        if let currentlyDragging {
            switch status {
            case .todo:
                if !todo.contains(where: { $0.id == currentlyDragging.id }) {
                    var updatedTask = currentlyDragging
                    updatedTask.status = .todo
                    todo.append(updatedTask)
                    working.removeAll(where: { $0.id == currentlyDragging.id })
                    completed.removeAll(where: { $0.id == currentlyDragging.id })
                }
            case .working:
                if !working.contains(where: { $0.id == currentlyDragging.id }) {
                    var updatedTask = currentlyDragging
                    updatedTask.status = .working
                    working.append(updatedTask)
                    todo.removeAll(where: { $0.id == currentlyDragging.id })
                    completed.removeAll(where: { $0.id == currentlyDragging.id })
                }
            case .completed:
                if !completed.contains(where: { $0.id == currentlyDragging.id }) {
                    var updatedTask = currentlyDragging
                    updatedTask.status = .completed
                    completed.append(updatedTask)
                    todo.removeAll(where: { $0.id == currentlyDragging.id })
                    working.removeAll(where: { $0.id == currentlyDragging.id })
                }
                
            }
        }
    }
    
    func replaceItem(tasks: inout [Task], droppingTask: Task, status: Status) {
        if let currentlyDragging {
            if let sourceIndex = tasks.firstIndex(where: { $0.id == currentlyDragging.id}),
               let destinationIndex = tasks.firstIndex(where: {$0.id == droppingTask.id}) {
                var sourceItem = tasks.remove(at: sourceIndex)
                sourceItem.status = status
                tasks.insert(sourceItem, at: destinationIndex)
            }
        }
    }
    
    @ViewBuilder
    func TodoView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(todo)
            }
            .navigationTitle("Todo")
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .contentShape(.rect)
            .dropDestination(for: String.self) { items, location in
                withAnimation(.snappy) {
                    appenTask(.todo)
                }
                return true
            } isTargeted: { _ in
                
            }
        }
    }
    func WorkingView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(working)
            }
            .navigationTitle("Working")
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .contentShape(.rect)
            .dropDestination(for: String.self) { items, location in
                withAnimation(.snappy) {
                    appenTask(.working)
                }
                return true
            } isTargeted: { _ in
                
            }
        }
    }
    func CompletedView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(completed)
            }
            .navigationTitle("Completed")
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .contentShape(.rect)
            .dropDestination(for: String.self) { items, location in
                withAnimation(.snappy) {
                    appenTask(.completed)
                }
                return true
            } isTargeted: { _ in
                
            }
        }
    }
}

#Preview {
    Home()
}
