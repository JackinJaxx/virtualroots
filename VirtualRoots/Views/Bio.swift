//
//  SimulacionHome.swift
//  VirtualRoots
//
//  Created by ADMIN UNACH on 04/03/24.
//

import Foundation
import SwiftUI

struct Bio: View {
    @Binding var navigationPath: NavigationPath
    
    public init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("22")
        }
        .padding(0)
        .frame(width: 834, alignment: .center)
        .background(Color(red: 0.96, green: 0.98, blue: 0.92))
        .toolbar(.hidden)
        
    }
}






