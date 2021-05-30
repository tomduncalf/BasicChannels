//
//  BasicChannelsApp.swift
//  Shared
//
//  Created by Tom Duncalf on 26/05/2021.
//

import SwiftUI

@main
struct BasicChannelsApp: App {
    let persistenceController = PersistenceController.shared
    
    let engine = BasicEngine()

    var body: some Scene {
        WindowGroup {
            ContentView(engine)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
