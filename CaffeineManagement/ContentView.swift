import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingSheet = false
    @State private var showingSettingSheet = false
    @State private var testSheet = false
    
    var a: Int
    
    // MARK: データの取得処理
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Drink.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Drink.timestamp, ascending: false)],
        predicate: nil
    ) private var drinks: FetchedResults<Drink>
    @State var goalCaffeine = UserDefaults.standard.integer(forKey: "goalCaffeiene")
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                Spacer()
                // ここバグ
                // DayGraphViewに問題アリ
//                DayGraphView(goalCaffeine: goalCaffeine)
//                    .padding(.bottom, 50)
                
                
                List {
                    ForEach(drinks) { drink in
                        VStack(alignment: .leading) {
                            Text("\(drink.name!)")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("\(drink.caffeine) mg")
                                .foregroundColor(.gray)
                            Text("\(minuteFormatterDay(date: drink.timestamp!) )")
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: deleteDrinks)
                }
                .frame(height: 470)
            }
            
            // MARK: [記録する], [目標設定]　ボタン
            HStack {
                Button(action: {
                    self.showingSheet.toggle()
                }) {
                    Text("記録する")
                        .foregroundColor(.white)
                        .fontWeight(.black)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .cornerRadius(30)
                        )
                }
                .sheet(isPresented: $showingSheet) {
                    AddDrinkView()
                }
                
                Button(action: {
                    self.showingSettingSheet.toggle()
                }) {
                    Text("目標設定")
                        .foregroundColor(.white)
                        .fontWeight(.black)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                .cornerRadius(30)
                        )
                }
                .sheet(isPresented: $showingSettingSheet) {
                    GoalSettingView()
                }
            }.offset(y: -90)
        }
    }
    
    // MARK: タスク削除
    func deleteDrinks(offsets: IndexSet) {
        for index in offsets {
            context.delete(drinks[index])
        }
        try? context.save()
    }
}

// MARK: ドリンク情報の入力
struct AddDrinkView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context
    @State private var name: String = ""
    @State private var caffeine: String = ""
    @State private var timestamp: Date = Date()
    
    var body: some View {
        VStack {
            Group {
                Text("Drink name")
                    .font(.title2)
                    .fontWeight(.semibold)
                TextField("ドリンク名を入力", text: $name)
                    .padding(.bottom, 50)
            }
            .frame(width: 300, alignment: .leading)
            
            Group {
                Text("Amount of caffeine (mg)")
                    .font(.title2)
                    .fontWeight(.semibold)
                TextField("カフェイン量を入力", text: $caffeine)
                    .keyboardType(.numberPad)
                    .padding(.bottom, 50)
            }
            .frame(width: 300, alignment: .leading)
            
            Group {
                
                let goalDate = Date()
                let startDate = goalDate.addingTimeInterval(-60*60*24*7)
                
                Text("Time")
                    .font(.title2)
                    .fontWeight(.semibold)
                DatePicker("", selection: $timestamp, in: startDate...goalDate)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                    .labelsHidden()
            }
            .frame(width: 300, alignment: .leading)
            
            // MARK: ドリンク情報の保存ボタン
            Button(action: {
                let newDrink = Drink(context: context)
                newDrink.timestamp = timestamp
                newDrink.caffeine = stringToInt32(stringValue: caffeine)
                newDrink.name = name
                
                try? context.save()
                
                dismiss()
            }) {
                Text("Save")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .background(
                        Rectangle()
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                            .cornerRadius(30)
                    )
                    .opacity(saveButtonEnable(nameEnable: name, caffeineEnable: caffeine) ? 1 : 0.5)
                    .padding()
            }.disabled(!saveButtonEnable(nameEnable: name, caffeineEnable: caffeine))
        }
    }
    
    
}

// MARK: 目標設定ビュー
struct GoalSettingView: View {
    @Environment(\.dismiss) var dismiss
    @State var goalCaffeine = ""
    
    var body: some View {
        VStack {
            
            
            
            VStack(alignment: .leading) {
                Text("Amount of Caffeine Goal (mg)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("1日のカフェイン摂取量の目標を入力してください。")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("カフェイン量", text: $goalCaffeine)
                    .keyboardType(.numberPad)
                    .padding(.bottom, 50)
                    
                
            }.frame(width: 300, alignment: .leading)
            
            Button(action: {
                UserDefaults.standard.set(
                    stringToInt32(stringValue: goalCaffeine),
                    forKey: "goalCaffeiene"
                )
                dismiss()
            }) {
                Text("Save")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .background(
                        Rectangle()
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                            .cornerRadius(30)
                    )
                    .opacity(goalSaveButtonEnable(goalCaffeine: goalCaffeine) ? 1 : 0.5)
                    .padding()
            }.disabled(!goalSaveButtonEnable(goalCaffeine: goalCaffeine))
        }
        
    }
}

// MARK: saveButtonがタップ可能か
func saveButtonEnable(nameEnable: String, caffeineEnable: String) -> Bool {
    if nameEnable != "" && caffeineEnable != "" {
        if Int32(caffeineEnable)! >= 0 && Int32(caffeineEnable)! <= 1000 {
            return true
        }
    }
    return false
}

// MARK: caffeineGoalSaveButtonがタップ可能か
func goalSaveButtonEnable(goalCaffeine: String) -> Bool {
    if goalCaffeine != "" {
        if Int32(goalCaffeine)! >= 0 && Int32(goalCaffeine)! <= 1000 {
            return true
        }
    }
    return false
}

// MARK: stringからInt32へ変換
func stringToInt32(stringValue: String) -> Int32 {
    guard let c = Int32(stringValue) else {
        return 0
    }
    return c
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
