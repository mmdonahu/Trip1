//
//  Rule Description.swift
//  Trip Collector
//
//  Created by 香川隼也 on 2024/03/06.
//

import SwiftUI

struct RuleDescriptionView: View {
    let rules = [
        "1, Visiting designated checkpoints will earn you special Cards unique to you.",
        "2, Collecting badges will increase your Hunter Rank.",
        "3, The HUNTER Rank goes from : Zero, Single, Double, Triple, Master",
        "4, There are Global Hunter Ranks and Country-specific Hunter Ranks.",
        "5, Start with Japan and gradually more checkpoints around the world will become available."
    ]
    
    @AppStorage("hasViewedRuleDescription") private var isFirstTime = true
    @State private var showMainTabView = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VideoBackgroundView()
                
                VStack(spacing: 0) {
                    Spacer(minLength: geometry.safeAreaInsets.top)
                    
                    Text("Rule Book")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer(minLength: 40)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(rules, id: \.self) { rule in
                                Text(rule)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                            }
                            // 初回表示時のみボタンを表示
                            if isFirstTime {
                                Button("Start your journey!") {
                                    isFirstTime = false
                                    showMainTabView = true
                                }
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer(minLength: geometry.safeAreaInsets.bottom)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $showMainTabView) {
            MainTabView()
        }
    }
}

struct RuleDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        RuleDescriptionView()
    }
}

