//
//  main.swift
//  TTRS_in_Memory
//
//  Created by Haichen Dong on 2020/3/18.
//  Copyright © 2020 Haichen Dong. All rights reserved.
//

import Foundation

class TTRS {
    
    var trains = [String: Train]()
    var args = [String: String]()
    var functionMap: [String: () -> Void]!
    
    init() {
        functionMap = [
            "query_train": self.queryTrain,
            "add_train": self.addTrain,
            "query_ticket": self.queryTicket
        ]
    }
    
    func execute(cmd: String) {
        let arr = cmd.components(separatedBy: " ")
        args.removeAll()
        for i in 0..<arr.count/2 {
            args[String(arr[i*2 + 1].dropFirst())] = arr[i*2 + 2]
        }
        functionMap[arr[0]]!()
    }
    
    func queryTrain() {
        trains[args["i"]!]!.query(for: args["d"]!.getDate())
    }
    
    func addTrain() {
        let stationNum = Int(args["n"]!)!
        let dates = args["d"]!.components(separatedBy: "|")
        let sDate = dates[0].getDate(), tDate = dates[1].getDate()
        var train = Train(trainID: args["i"]!,
                          type: Character(args["y"]!),
                          stationNum: stationNum,
                          startTime: DateTime(0, args["x"]!),
                          stations: args["s"]!.components(separatedBy: "|"),
                          seatNums: [[Int]](repeating: [Int](repeating: Int(args["m"]!)!,
                                                             count: stationNum - 1), count: tDate - sDate + 1),
                          prices: [0] + args["p"]!.components(separatedBy: "|").map {Int($0)!}.preSum(),
                          travelTimes: args["t"]!.components(separatedBy: "|").map {Int($0)!},
                          stopoverTimes: [0] + args["o"]!.components(separatedBy: "|").map {Int($0)!},
                          date: (sDate, tDate))
        trains[args["i"]!] = train.initialized()
    }
    
    func deleteTrain() {
        trains.removeValue(forKey: args["i"]!)
    }
    
    func queryTicket() {
        let s = args["s"]!, t = args["t"]!
        let res = trains.values.filter {$0.stations.contains(s) && $0.stations.contains(t)}
        print(res.count)
        zip(res.map {$0.getTime(from: s, to: t)}, res).sorted {
            $0.0 < $1.0
        }.forEach {$0.1.queryPrint(from: s, to: t, at: args["d"]!.getDate())}
    }
    
}


let prog = TTRS()
prog.execute(cmd: "add_train -i HAPPY_TRAIN -n 3 -m 1000 -s 上院|中院|下院 -p 114|514 -x 19:19 -t 600|600 -o 5 -d 06-01|08-17 -y G")
prog.execute(cmd: "query_train -d 07-01 -i HAPPY_TRAIN")
prog.execute(cmd: "query_ticket -s 中院 -t 下院 -d 08-17")
