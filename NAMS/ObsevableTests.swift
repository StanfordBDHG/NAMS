//
//  ObsevableTests.swift
//  NAMS
//
//  Created by Andreas Bauer on 06.02.24.
//

import SwiftUI

@Observable
class SomeModel {
    var counter: Int = 0

    func task() {
        Task {
            for _ in 1...1000 {
                withMutation(keyPath: \.counter) {
                    print("changed to \(counter + 1)")
                    _counter += 1
                //    counter += 1
                }
            }
        }
    }
}

struct ObsevableTests: View {
    @State var myModel = SomeModel()
    var body: some View {
        let ssa = print("Refreshed with \(myModel.counter)")
        Text("Counter: \(myModel.counter)")
            .onChange(of: myModel.counter) {
                print("Changed with \(myModel.counter)")
            }

        Button("Start") {
            myModel.counter = 0
            myModel.task()
        }
    }
}

#Preview {
    ObsevableTests()
}
