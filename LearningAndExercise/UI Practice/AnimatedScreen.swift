//
//  AnimatedScreen.swift
//  LearningAndExercise
//
//  Created by hb on 08/12/25.
//

import SwiftUI

enum PurchaseType {
    case boost1, boost12, boost24, superBoost, none
}

//struct Boost: View {
//    
//    @State private var animateOnAppear: Bool = true
//    @State private var expandDivider: Bool = true
//    @State private var selectedBoost: PurchaseType = .none
//    
//    let buttonWidth: CGFloat = UIScreen.main.bounds.width / 1.5
//    
//    var body: some View {
//        ZStack(alignment: .top) {
//            LinearGradient(colors: [Color.purchaseGradiantOne, Color.purchaseGradiantTwo], startPoint: .top, endPoint: .bottom)
//                .ignoresSafeArea()
//            
//            Image("purchaseFish")
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: .infinity)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                Spacer()
//                if !animateOnAppear {
//                    Image(.boosts)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100, height: 100)
//                        .transition(.move(edge: .top).combined(with: .opacity))
//                    
//                    header
//                    // purchase items
//                    purchaseItems
//                    // Divider
//                    divider
//                    // Supper Boosted Botton
//                    superBoostButton
//                    Spacer()
//                    
//                    Text("Enhance your likelihood of receiving additional likes with a 24-hour superboost. By selecting superboost, you consent to being charged, and one Superboost will be activated right away.")
//                        .font(Font.font(.FigtreeRegular, size: 12))
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 20)
//                        .ignoresSafeArea(.all, edges: .bottom)
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                    
//                    Spacer()
//                    Spacer()
//                }
//            }
//            .padding(.horizontal, 15)
//            .animation(.bouncy(duration: 0.45, extraBounce: 0.0001), value: animateOnAppear)
//            .onAppear { // Default on main thred
//                withAnimation {
//                    animateOnAppear.toggle()
//                }
//                
//                Task {
//                    try? await Task.sleep(for: .seconds(0.6))
//                    expandDivider.toggle()
//                }
//            }
//            .onChangeCompat(of: selectedBoost) { oldValue, newValue in
//                switch newValue {
//                case .boost1:
//                    print("Purchasing boost 1")
//                case .boost12:
//                    print("Purchasing boost 12")
//                case .boost24:
//                    print("Purchasing boost 24")
//                case .superBoost:
//                    print("Purchasing super boost")
//                default:
//                    return
//                }
//            }
//        }
//    }
//    
//    /// Header
//    private var header: some View {
//        VStack(spacing: 20) {
//            Text("Boost your profile for more views")
//                .multilineTextAlignment(.center)
//                .font(Font.font(.FigtreeSemiBold, size: 24))
//                .padding(.horizontal, 40)
//            
//            Text("Get seen by more people near you!")
//                .multilineTextAlignment(.center)
//                .font(Font.font(.FigtreeRegular, size: 14))
//                .padding(.horizontal, 40)
//                .padding(.bottom, 20)
//        }
//        .transition(.move(edge: .trailing).combined(with: .opacity))
//    }
//    
//    /// Purchase Items
//    private var purchaseItems: some View {
//        HStack(spacing: 15) {
//            BalanceView(amount: "$2.99/ea", title: "Boosts", boostCoutn: "1", showTopTag: false, titleTextSize: 16) {
//                selectedBoost = .boost1
//            }
//            BalanceView(amount: "$1.49/ea", title: "Boosts", boostCoutn: "12", showTopTag: false, titleTextSize: 16) {
//                selectedBoost = .boost12
//            }
//            BalanceView(amount: "$0.99/ea", title: "Boosts", boostCoutn: "24", showTopTag: true, titleTextSize: 16) {
//                selectedBoost = .boost24
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .fixedSize(horizontal: false, vertical: false)
//        .transition(
//            .move(edge: .leading).combined(with: .opacity)
//        )
//    }
//    
//    // Divider
//    private var divider: some View {
//        HStack(spacing: 35) {
//            RoundedRectangle(cornerRadius: 0)
//                .foregroundStyle(.black.opacity(0.4))
//                .frame(height: 0.5)
//                .frame(maxWidth: expandDivider ? 0 : 300)
//            
//            Text("Or")
//                .font(Font.font(.FigtreeSemiBold, size: 14))
//            
//            RoundedRectangle(cornerRadius: 0)
//                .foregroundStyle(.black.opacity(0.4))
//                .frame(height: 0.5)
//                .frame(maxWidth: expandDivider ? 0 : 300)
//        }
//        .transition(.move(edge: .top).combined(with: .opacity))
//        .padding(.horizontal, 20)
//        .animation(.easeOut(duration: 0.3), value: expandDivider)
//    }
//    
//    // Super Boost Button
//    private var superBoostButton: some View {
//        Button {
//            selectedBoost = .superBoost
//        } label: {
//            Text("Get Super Boosted $33")
//                .font(Font.font(.FigtreeSemiBold, size: 16))
//                .foregroundStyle(.black)
//                .padding(.vertical, 16)
//                .frame(maxWidth: .infinity)
//                .background(
//                    Capsule(style: .continuous)
//                        .fill(Color.white)
//                )
//                .clipShape(.capsule)
//            
//        }
//        .padding(.horizontal, 20)
//        .buttonStyle(.plain)
//        .transition(.move(edge: .trailing).combined(with: .opacity))
//    }
//}

//#Preview {
//    Boost()
//}
//
//
//struct BalanceView: View {
//    let amount: String
//    let title: String
//    let boostCoutn: String
//    let showTopTag: Bool
//    let titleTextSize: CGFloat
//    let onClick: (() -> Void)?
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Text(boostCoutn)
//                .font(Font.font(.FigtreeSemiBold, size: 32))
//            
//            Text(title)
//                .font(Font.font(.FigtreeSemiBold, size: titleTextSize))
//            
//            Text(amount)
//                .font(Font.font(.FigtreeSemiBold, size: 18))
//        }
//        .padding(.vertical, 15)
//        .padding(.horizontal, 14)
//        .background(
//            RoundedRectangle(cornerRadius: 14)
//                .foregroundStyle(.thinMaterial)
//                .overlay(content: {
//                    RoundedRectangle(cornerRadius: 14)
//                        .stroke(Color.white, lineWidth: 1)
//                })
//        )
//        .if(showTopTag) { content in
//            content
//                .overlay(alignment: .top) {
//                    Text("Most popular")
//                        .font(Font.font(.FigtreeRegular, size: 12))
//                        .padding(.horizontal, 8.5)
//                        .padding(.vertical, 2)
//                        .background(
//                            Capsule(style: .continuous)
//                                .fill(Color.white)
//                        )
//                        .offset(y: -12)
//                }
//        }
//        .background(Color.black.opacity(0.001))
//        .onTapGesture {
//            if let onClick = onClick {
//                onClick()
//            }
//        }
//        
//    }
//}
