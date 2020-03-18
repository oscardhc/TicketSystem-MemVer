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
    
    func query(for dd: Int) {
        if dd < date.0 || dd > date.1 {
            print("-1")
        } else {
            let d = dd - date.0
            var time = startTime + DateTime(dd, 0)
            print(trainID, type)
            
            for i in 0..<stations.count {
                print(stations[i],
                      i == 0 ? "xx-xx xx:xx" : time.combined(rhs: DateTime(0, travelTimes[i - 1])),
                      "->",
                      i == stations.count - 1 ? "xx-xx xx:xx" : time.combined(rhs: DateTime(0, stopoverTimes[i])),
                      prices[i] - prices[0],
                      i == stations.count - 1 ? "x" : seatNums[d][i])
            }
        }
    }
    
}
