//
//  ContentView.swift
//  betterrest
//
//  Created by pushkar mondal on 17/12/22.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepamount = 8.0
    @State private var wakeup = Date.now
    @State private var coffeeamount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    var body: some View {
        NavigationView{
            Form{
            VStack(alignment: .leading, spacing: 0){
                    Text("WHEN DO YOU WANT TO WAKE UP ?")
                        .font(.headline)
                    DatePicker("PLEASE ENTER A TIME",selection: $wakeup,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("DESIRE AMOUNT OF SLEEP")
                        .font(.headline)
                    Stepper("\(sleepamount.formatted())HOURS",value: $sleepamount,in: 4...10,step: 0.20 )
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("DAILY COFFEE INTAKE BECAUSE WE ARE DEVELOPER")
                        .font(.headline)
                    Stepper(coffeeamount == 1 ? "1 CUP" : "\(coffeeamount) CUPS", value: $coffeeamount, in: 1...10)
                }
            }
            .navigationTitle("BETTERREST")
            .toolbar{
                Button("CALCULATE",action: calculatebedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK") { }
            }message: {
                Text(alertMessage)
            }
            
        }
    }
    func calculatebedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute],from: wakeup)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour+minute),estimatedSleep:sleepamount,coffee:Double(coffeeamount))
            
            let sleeptime = wakeup - prediction.actualSleep
            alertTitle = "YOUR BEDTIME IS"
            alertMessage = sleeptime.formatted(date: .omitted, time: .shortened)
            
            
        }catch{
            alertTitle = "ERROR"
            alertMessage = "SORRY THERE WAS SOME PROBLEM CALCULATING YOUR BEDTIME "
            
        }
        showingAlert = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
