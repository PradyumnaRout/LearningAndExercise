//
//  HomeView.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var homeVM = HomeViewModel()
    
    @State private var openSheet = false
    @State private var deleteAlert = false
    @State private var deleteItem: PortfolioData?
    
    private let alertTitle = "Update Device Details"
    
    var body: some View {
        VStack {
            if !homeVM.listData.isEmpty {
                ScrollView(.vertical) {
                    VStack(spacing: 20) {
                        ForEach(homeVM.listData, id: \.id) { item in
                            PortfolioCard(item: item,
                                          onEdit: {
                                if item.id != nil {
                                    homeVM.selectedDevice = item
                                    homeVM.extractEditableData()
                                    openSheet = true
                                }
                            },
                                          onDelete: {
                                deleteItem = item
                                deleteAlert = true
                            })
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text(homeVM.isLoading ? "Loading Data..." : "No Data Found")
            }
        }
        .alert("Delete Item!", isPresented: $deleteAlert) {
            Button("Cancel") { deleteItem = nil }
            Button("OK", role: .destructive) {
                if let item = deleteItem, let id = item.id {
                    homeVM.deleteItem(id, item)
                }
                deleteItem = nil
            }
        } message: {
            Text("Are you sure you want to delete the item?")
        }
        .sheet(isPresented: $openSheet) {
            UpdateView(vm: homeVM)
                .presentationDetents([.height(450)])
        }
        // Use the stable iOS 14+ signature to keep the type-checker happy
        .onChange(of: openSheet) { newValue in
            if !newValue { homeVM.selectedDevice = nil }
        }
    }
}

private struct PortfolioCard: View {
    let item: PortfolioData
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            titleRow
            dataRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var titleRow: some View {
        HStack {
            Text(item.name ?? "No Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .onTapGesture { onDelete() }
                
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .onTapGesture { onEdit() }
            }
        }
    }
    
    private var dataRow: some View {
        let colorText = item.data?.color ?? "N/A"
        let priceValue = item.data?.price ?? 0.0
        let capacityText = item.data?.capacity ?? "N/A"
        let generationText = item.data?.generation
        let yearText: String? = {
            if let y = item.data?.year { return String(y) }
            return nil
        }()
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Color: ")
                Text(colorText).bold()
            }
            HStack {
                Text("Price: ")
                Text(String(format: "%.2f", priceValue)).bold()
            }
            HStack {
                Text("Memory: ")
                Text(capacityText).bold()
            }
            if let gen = generationText {
                HStack {
                    Text("Generation: ")
                    Text(gen).bold()
                }
            }
            if let year = yearText {
                HStack {
                    Text("Year: ")
                    Text(year).bold()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    HomeView()
}


struct UpdateView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: HomeViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            
            Text(vm.name)
                .foregroundStyle(Color(uiColor: .label))
                .font(.title)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
                .padding(.horizontal)
            
            TextField("Enter Color", text: $vm.color)
                .textContentType(.name)
                .keyboardType(.alphabet)
                .textFieldBackground()
                .shake(with: vm.errorTextType == .color ? 5.0 : 0)
            
            TextField("Enter Memory", text: $vm.memory)
                .textFieldBackground()
                .keyboardType(.decimalPad)
                .shake(with: vm.errorTextType == .memory ? 5.0 : 0)
            
            TextField("Enter Price", text: $vm.price)
                .keyboardType(.decimalPad)
                .textFieldBackground()
                .shake(with: vm.errorTextType == .price ? 3.0 : 0)
            
            Spacer()
            
            HStack(spacing: 25) {
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .backgroundButton()
                }
                
                
                Button {
                    withAnimation {
                        vm.validateFields()
                    }
                    if vm.errorTextType == .non {
                        vm.updateItem()
                        dismiss()
                    }
                    vm.errorTextType = .non
                } label: {
                    Text("OK")
                        .backgroundButton()
                }
            }
            Spacer()
        }
    }
}

