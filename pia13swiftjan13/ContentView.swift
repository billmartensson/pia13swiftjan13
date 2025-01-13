//
//  ContentView.swift
//  pia13swiftjan13
//
//  Created by BillU on 2025-01-13.
//

import SwiftUI
import PhotosUI


struct ContentView: View {
    
    @State var domodel = DoModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var image: Image?

    @State var userbeds = ""
    @State var userbaths = ""
    @State var usersqft = ""

    
    
    var body: some View {
        VStack {
            
            TextField("BEDS",text: $userbeds)
            TextField("BATHS",text: $userbaths)
            TextField("SQFT",text: $usersqft)

            
            Button(action: {
                domodel.testRealestate(inbeds: Int(userbeds)!, inbaths: Int(userbaths)!, insqft: Int(usersqft)!)
            }) {
                Text("GET PRICE")
            }
            
            Text("\(domodel.resultprice)")
            
            Text(domodel.resultText)
            
            image?
                                .resizable()
                                .scaledToFit()
            
            PhotosPicker(selection: $selectedPhoto) {
                                Text("Välj bild")
                            }
            
            if(domodel.outimg != nil) {
                Image(uiImage: domodel.outimg!)
                    .resizable()
                    .scaledToFit()
            }
        }
        .padding()
        .task(id: selectedPhoto) {
            image = try? await selectedPhoto?.loadTransferable(type: Image.self)
            
            if image != nil {
                domodel.doImage(theimageIn: image!)

            }

        }
    }
}

#Preview {
    ContentView()
}
