import SwiftUI

struct DataModel: Identifiable {
    var id = UUID()
    var time: Int
    var value: Int
   
}

struct TimeModel: Identifiable {
    var id = UUID()
    var time: Int
}

struct DayGraphView: View {
    
    // MARK: 目標摂取量を引数として取得する
    var goalCaffeine: Int
    
    
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Drink.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Drink.timestamp, ascending: false)],
        predicate: nil
    ) private var drinks: FetchedResults<Drink>
    
    // MARK: DataModel構造体をインスタンス化
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                
                VStack {
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.gray)
                    Text("Today")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack {
                    Text("\(totalDayCaffeine())")
                        .fontWeight(.bold)
                    + Text(" mg / ")
                        .foregroundColor(.gray)
                    + Text("\(goalCaffeine)")
                        .fontWeight(.bold)
                    + Text(" mg")
                        .foregroundColor(.gray)
                    Text("現在の摂取量   目標摂取量")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .offset(x: -7)
                }
            }.padding(10)
            
            
            ScrollView(.horizontal) {
                ZStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(goalCaffeine) mg")
                            .foregroundColor(.gray)
                        Divider()
                    }
                    .offset(y: -58)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(goalCaffeine / 2) mg")
                            .foregroundColor(.gray)
                        Divider()
                    }
                    .offset(y: 1)
                    
                    HStack(alignment: .bottom) {
                        ForEach(dataToStructArray()) { item in
                            
                            VStack {
                                if item.value != 0 {
                                    Text("\(item.value)")
                                        .fontWeight(.bold)
                                    Text("mg")
                                }
                                
                                Rectangle()
                                    .frame(width: 20, height: 120)
                                    .scaleEffect(y: Double(item.value) / Double(goalCaffeine), anchor: .bottom)
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                                Text("\(item.time)時")
                            }
                        }
                    }
                    
                    
                    
                }
                
                
            }
            .font(.caption)
        }
        
    }
    
    func dataToArrayInt() -> [[Int]]{
        // [i][0] -> 時間
        // [i][1] -> 値（[i][0]時に摂取したカフェイン量）
        var graphData: [[Int]] = []
        for drink in drinks {
            if dateFormatterDay(date: drink.timestamp!) == dateFormatterDay(date: Date()){
                let data: [Int] = [hourToInt(date: drink.timestamp!), Int(exactly: drink.caffeine)!]
                graphData.append(data)
            }
        }
        return graphData
    }
    
    // MARK: フェッチしたデータを構造体配列に代入する
    func dataToStructArray() -> [DataModel]{
        var result: [DataModel] = []
        
        for drink in drinks {
            if dateFormatterDay(date: drink.timestamp!) == dateFormatterDay(date: Date()){
                let pre: DataModel = DataModel(
                    time: hourToInt(date: drink.timestamp!),
                    value: Int(exactly: drink.caffeine)!)
                    
                result.append(pre)
            }
        }
        
        if result.isEmpty {
            return result
        }
        
        result.sort(by: {$0.time < $1.time})
        
        var reallyResult: [DataModel] = []
        
        print("resultのインデックス数: \(result.count)")
        print(result)
        // jはresultのindex番号を表してる
        var j = 0
        
        // iは0~23まで　時間を表してる
        for i in 0...23 {
            if result[j].time == i {
                let pre: DataModel = result[j]
                reallyResult.append(pre)
                if j != result.count - 1 {
                    j += 1
                } else {
                    j = result.count - 1
                }
            } else {
                let pre: DataModel = DataModel(
                    time: i,
                    value: 0)
                reallyResult.append(pre)
                
            }
        }
//        print(reallyResult)
        return reallyResult
    }
    
    func totalDayCaffeine() -> Int {
        let data = dataToStructArray()
        var result = 0
        
        for i in data {
            result += i.value
        }
        
        return result
    }
    
    func timeToStruct() -> [TimeModel] {
        var result: [TimeModel] = []
        
        for time in 1...24 {
            result.append(TimeModel(time: time))
        }
        
        return result
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
        .font(.caption)
        .foregroundColor(.gray)
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

func minuteFormatterDay(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JA")
    dateFormatter.dateStyle = .medium
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
    
    return dateFormatter.string(from: date)
}

struct DayGraphView_Previews: PreviewProvider {
    static var previews: some View {
        DayGraphView(goalCaffeine: 150)
    }
}
