//
//  RollingCounter.swift
//  Wheel_Prac
//
//  Created by user on 2022/7/8.
//

import SwiftUI

struct RollingCounter: View {
    
    @Binding var value:Int
    @State var valueShowed:[Int] = []
    @State private var digit = 0
    let font:Font = .system(size: 100, weight: .bold, design: .rounded)
    
    var body: some View {
        HStack(spacing:0) {
            ForEach(0..<valueShowed.count,id: \.self) { index in
                Text("0")
                    .font(font)
                    .opacity(0)
                    .overlay {
                        GeometryReader { geo in
                            let size = geo.size
                            VStack(spacing:0) {
                                ForEach(0...9,id: \.self) {num in
                                    Text("\(num)")
                                        .font(font)
                                    
                                }
                                .frame(width: size.width, height: size.height, alignment: .center)
                            }
                            .offset(y:-size.height*CGFloat(valueShowed[index]))
                            
                        }
                    }
                    .clipped()
                
            }
        }
        .onAppear{
            let valueString = "\(value)"
            digit = "\(value)".count
            valueShowed = Array(repeating: 0, count: valueString.count)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.06) {
                updateValue()
            }
        }
        .onChange(of: value) { newValue in
            let extra = "\(value)".count - valueShowed.count
            if extra>0 {
                for _ in 0..<extra {
                    withAnimation(.easeIn(duration: 0.1)) {
                        valueShowed.append(9)
                    }
                }
            } else {
                for _ in 0..<(-extra) {
//                    withAnimation(.easeIn(duration: 0.1)) {
//                        valueShowed.removeFirst()
//                    }
                    valueShowed.removeFirst()
                }
            }
            updateValue()
        }
    }
    
    func updateValue() {
        //位數補零
        //let valueString = String(format: "%0\(digit)d", value)
        //不補零
        let valueString = "\(value)"

        for (index,value) in zip(0..<valueString.count, valueString) {
            withAnimation(.spring(response: 0.75, dampingFraction: 1, blendDuration: 1)) {
                valueShowed[index] = (String(value) as NSString).integerValue
            }
        }
    }
}

struct RollingCounter_Previews: PreviewProvider {
    static var previews: some View {
        RollingCounter(value: Binding.constant(982))

        
    }
}
