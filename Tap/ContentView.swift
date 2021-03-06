//
//  ContentView.swift
//  Tap
//
//  Created by user on 2022/7/10.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State var value:Int = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    @State var isSceneActive:Bool = true
    @State var isCounterActive:Bool = false
    
    @State var isTapActive = false
    @State var tapHistory:[Double] = []
    @State var tapCount:Int = 0
    @State var lastTap:Date = Date()
    @State var avgTap = 0.0
    @State var description = ""
    @State var feeling:Feeling = .good
    
    @State var sucessOpacity = 0.0
    
    var body: some View {
        VStack(spacing:10) {
            RollingCounter(value: $value)
                .padding(.top,20)
            
            // Button to start the counter
            Button {
                if isCounterActive == true {
                    isCounterActive = false
                } else if isCounterActive == false {
                    isCounterActive = true
                }
            } label: {
                Text(isCounterActive ?  "Pause" : "Count")
                    .foregroundColor(.white)
                    .frame(width: 100, height: 30, alignment: .center)
                    .background(
                        Capsule()
                            .foregroundColor(isCounterActive ? Color.red : Color.blue))
            }
            .padding(.bottom,20)
            
            Divider()
            
            VStack{
                Text("- Tap -")
                    .font(.title)
                    .padding(.top,20)
                
                HStack {
                    Button {
                        if isTapActive == false {
                            clearTap()
                            isTapActive = true
                        } else {
                            calculateTap()
                        }
                    } label: {
                        Text(isTapActive ? "Tap" : "Start")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 30, alignment: .center)
                            .background(
                                Capsule()
                                    .foregroundColor(isTapActive ? Color.blue : Color.green))

                    }
                    Button {
                        clearTap()
                    } label: {
                        Text("Clear")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 30, alignment: .center)
                            .background(Capsule())

                    }
                }
                
                VStack(alignment:.leading, spacing: 20) {
                    HStack {
                        VStack(alignment:.leading, spacing: 20){
                            Text("Count: \(tapCount)")
                            Text(String(format: "Avg: %.3f s", avgTap))
                        }
                        Spacer()
                        Divider()
                        VStack(alignment:.center, spacing: 3){
                            Text("history")
                                .font(.footnote)
                            ScrollView(showsIndicators: true) {
                                VStack {
                                    ForEach(tapHistory,id:\.self) { i in
                                        Text(String(format:"%.3f s", i))
                                            .font(.footnote)
                                            .frame(width: 100)
                                    }
                                }
                            }
                        }
                        .frame(width: 100)
                    }
                    TextField("Description", text: $description)
                        .padding(10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .disabled(isTapActive != true)
                    Picker("Feeling:", selection: $feeling) {
                        Text("???? Good").tag(Feeling.good)
                        Text("???? Bad").tag(Feeling.bad)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(isTapActive != true)
                }
                .padding(.top, 30)
                .padding(.bottom, 15)
                .padding(.horizontal,50)
                
                Button {
                    saveTap()
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(width: 150, height: 30, alignment: .center)
                        .background(Capsule())
                        .disabled(isTapActive != true)
                }
                Text("Save Sucessfully!")
                    .foregroundColor(Color.green)
                    .opacity(sucessOpacity)
            }
            Spacer()
        }
        // Update the counter per second
        .onReceive(timer) { newTime in
            if (isSceneActive && isCounterActive) && value > 0 {
                value -= 1
            }
        }
        // Detect the View whether the app is active
        .onChange(of: scenePhase) { newValue in

            if newValue == .active {
                isSceneActive = true
            } else {
                isSceneActive = false
            }
            switch newValue {
            case .background:
                print("Background")
            case .inactive:
                print("Inactive")
            case .active:
                print("Active")
            @unknown default:
                print("Unknown")
            }
        }
        
    }
    
    func calculateTap() {
        let now = Date()
        let tap = now.timeIntervalSince1970 - lastTap.timeIntervalSince1970
        print("\(tap)")
        if tap < 3 {
            tapHistory.append(tap)
            if tapCount == 0 {
                avgTap = tap
            } else {
                avgTap = (Double(tapCount)*avgTap + tap)/Double((tapCount+1))
            }
            tapCount += 1
        }
        
        lastTap = now
    }
    func clearTap() {
        tapCount = 0
        avgTap = 0.0
        lastTap = Date()
        isTapActive = false
        tapHistory.removeAll()
    }
    
    func saveTap() {
        if isTapActive != true { return }
        let db = Firestore.firestore()
        let app = db.collection("Tap").document("Data")
        let today = app.collection(Tool.TodayDateString())
        today.document(Tool.CurrentTimeString()).setData([
            "count" : tapCount,
            "average" : avgTap,
            "time" : Tool.CurrentTimeString(),
            "description" : description,
            "feeling" : feeling.rawValue
        ])
        clearTap()
        sucessOpacity = 1
        withAnimation(.easeIn(duration: 2)) {
            sucessOpacity = 0
        }
    }
}

enum Feeling:String {
    case good
    case bad
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
