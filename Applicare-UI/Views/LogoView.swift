//
//  LogoView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import SwiftUI

struct LogoView: View {
  var body: some View {
    VStack {
      Image("Logo")
        .resizable()
        .frame(width: 70, height: 80)
        .padding(.top, 40)
    }
  }
}
