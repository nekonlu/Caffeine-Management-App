//
//  DayGraphView.swift
//  CaffeineManagement
//
//  Created by Ohara Yoji on 2022/02/13.
//

import SwiftUI

// MARK: Model
struct DateModel: Identifiable {
    var id = UUID()
    var value: Int
    var time: Int
}

struct DayGraphViewMVVM: View {
    
    // MARK: 目標摂取量を引数として取得する
    var goalCaffeine: Int
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Drink.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Drink.timestamp, ascending: false)],
        predicate: nil
    ) private var drinks: FetchedResults<Drink>
    
    var body: some View {
        VStack {
            Text("\(goalCaffeine)")
            
            ScrollView(.horizontal) {
                HStack {
                    TimeView()
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                
                
            }
            .frame(height: 250)
            
            .font(.caption)
            
            Button(action: {
                print(dataToInt())
            }) {
                Text("グラフを描画する")
            }
        }
        
    }
    
    func dataToInt() -> [[Int]]{
        // [i][0] -> 時間
        // [i][1] -> 値（[i][0]時に摂取したカフェイン量）
        var graphData: [[Int]] = []
        var i = 0
        for drink in drinks {
            if dateFormatterDay(date: drink.timestamp!) == dateFormatterDay(date: Date()){
                let data: [Int] = [hourToInt(date: drink.timestamp!), Int(exactly: drink.caffeine)!]
                graphData.append(data)
                i += 1
            }
        }
        return graphData
    }
}

struct TimeView: View {
    var body: some View {
        HStack(spacing: 0) {
            Group {
                Text("1")
                Text("2")
                Text("3")
                Text("4")
                Text("5")
                Text("6")
            }
            .frame(width: 20)
            Group {
                Text("7")
                Text("8")
                Text("9")
                Text("10")
                Text("11")
                Text("12")
            }
            .frame(width: 20)
            Group {
                Text("13")
                Text("14")
                Text("15")
                Text("16")
                Text("17")
                Text("18")
            }
            .frame(width: 20)
            Group {
                Text("19")
                Text("20")
                Text("21")
                Text("22")
                Text("23")
                Text("24")
            }
            .frame(width: 20)
        }
    }
}

func hourToInt(date: Date) -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JA")
    dateFormatter.dateStyle = .medium
    dateFormatter.dateFormat = "HH"
    
    return Int(dateFormatter.string(from: date))!
}

func dateFormatterDay(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JA")
    dateFormatter.dateStyle = .medium
    dateFormatter.dateFormat = "yyyy年MM月dd日"
    
    return dateFormatter.string(from: date)
}

struct DayGraphView_Previews: PreviewProvider {
    static var previews: some View {
        DayGraphView(goalCaffeine: 150)
    }
}
