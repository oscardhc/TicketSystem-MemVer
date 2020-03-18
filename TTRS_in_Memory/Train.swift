//
//  Train.swift
//  TTRS_in_Memory
//
//  Created by Haichen Dong on 2020/3/18.
//  Copyright © 2020 Haichen Dong. All rights reserved.
//

import Foundation

struct Train {
    
    let trainID: String
    let type: Character
    let stationNum: Int
    let startTime: DateTime
    let stations: [String]
    var seatNums: [[Int]]
    let prices, travelTimes, stopoverTimes: [Int]
    let date: (Int, Int)
    var sumTimes = [(DateTime, DateTime)]()
    
    mutating func initialized() -> Self {
        var time = startTime
        for i in 0..<stations.count {
            sumTimes.append((i == 0 ? DateTime(-10000, 0) : time.combined(rhs: DateTime(0, travelTimes[i - 1])),
                             i == stations.count - 1 ? DateTime(-10000, 0) : time.combined(rhs: DateTime(0, stopoverTimes[i]))))
        }
        return self
    }
    
    func query(for dd: Int) {
        if dd < date.0 || dd > date.1 {
            print("-1")
        } else {
            let d = dd - date.0, base = DateTime(dd, 0)
            print(trainID, type)
            for i in 0..<stations.count {
                print(stations[i],
                      sumTimes[i].0 + base,
                      "->",
                      sumTimes[i].1 + base,
                      prices[i],
                      i == stations.count - 1 ? "x" : seatNums[d][i])
            }
        }
    }
    
    func queryPrint(from: String, to: String, at: Int) {
        let sIdx = stations.firstIndex(of: from)!, tIdx = stations.firstIndex(of: to)!
        let base = DateTime(at - sumTimes[sIdx].1.val[2], 0)
        print(trainID,
              from, sumTimes[sIdx].1 + base, "->",
              to, sumTimes[tIdx].0 + base,
              prices[tIdx] - prices[sIdx],
              seatNums[at - date.0][sIdx..<tIdx].min()!)
    }
    
    func getTime(from: String, to: String) -> Int {
        (sumTimes[stations.firstIndex(of: to)!].0 - sumTimes[stations.firstIndex(of: from)!].1).inMinutes
    }
    
    func getPrice(from: String, to: String) -> Int {
        prices[stations.firstIndex(of: to)!] - prices[stations.firstIndex(of: from)!]
    }
    
}
