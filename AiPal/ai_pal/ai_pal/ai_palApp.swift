//
//  ai_palApp.swift
//  ai_pal
//
//  Created by Luka Kaučić on 14.09.2023..
//

import SwiftUI

@main
struct ai_palApp: App {
    
    @ObservedObject var appState: AppState = AppState()
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                NavigationStack(path: $appState.navigationPath){
                    ChatListView()
                        .environmentObject(appState)
                }
            } else {
                AuthView()
                    .environmentObject(appState)
            }
        }
    }
}
