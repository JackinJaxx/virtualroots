//
//  ButtonBar.swift
//  VirtualRoots
//
//  Created by ADMIN UNACH on 06/03/24.
//

import Foundation
//
//  buttonBar.swift
//  VirtualRoots
//
//  Created by ADMIN UNACH on 04/03/24.
//

import Foundation
import SwiftUI

struct NavBar : View {
    @Binding var navigationPath: NavigationPath
    
    var body : some View {
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "camera.metering.matrix")
                    .foregroundColor(Color(red: 0.24, green: 0.35, blue: 0.11))
                    .font(.system(size: 110))
                    .frame(width: 80, height: 70.76923)
                
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 30)
            .frame(width: 128, alignment: .center)
            .background(Color(red: 0.96, green: 0.98, blue: 0.92))
           /* .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .inset(by: 2.5)
                    .stroke(Color(red: 0.24, green: 0.35, blue: 0.11), lineWidth: 5)
            )*/
            .onTapGesture {
                navigationPath.append("Simulation")
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .center)
        .overlay(
            Rectangle()
                .inset(by: 1)
                .stroke(Color(red: 0.29, green: 0.43, blue: 0.11), lineWidth: 2)
        )
    }
}

