//
//  TransactionExecutionRequestView.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation
import SwiftUI

struct TransactionExecutionRequestView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: TransactionRequestViewModel

    var body: some View {
        VStack {
            Text("Just two buttons to reject or execute transaction")
                .font(.caption2)
                .foregroundColor(.red)
                .padding(12)

            Button(action: {
                Task {
                    await viewModel.execute()
                    presentationMode.wrappedValue.dismiss()
                }
            }, label: {
                Text("Execute")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            })
            .padding(12)

            Button(action: {
                viewModel.reject()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Reject")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            })
            .padding(12)
        }
    }

}
