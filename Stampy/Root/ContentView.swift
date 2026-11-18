//
//  ContentView.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        if authVM.userSession != nil {
            HomeView()
                
        } else {
            AuthSwitcher()
               
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
