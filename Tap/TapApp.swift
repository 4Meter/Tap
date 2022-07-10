//
//  TapApp.swift
//  Tap
//
//  Created by user on 2022/7/10.
//

import SwiftUI
import Firebase

@main
struct TapApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        FirebaseApp.configure()
        
        test()
    }
    
    
    func test() {
        let db = Firestore.firestore()
        let tap = db.collection("Tap")
        tap.getDocuments { snap, error in
            if error != nil {
                return
            }
            if let snap = snap {
                for doc in snap.documents {
                    print(doc.data())
                }
            }
        }
        
    }
    
}
