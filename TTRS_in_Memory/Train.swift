//
//  Train.swift
//  TTRS_in_Memory
//
//  Created by Haichen Dong on 2020/3/18.
//  Copyright © 2020 Haichen Dong. All rights reserved.
//

import Foundation

class Object: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    static func == (lhs: Object, rhs: Object) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}

class User: Object, Codable {
    let username: String
    var password: String
    var name: String
    var mailAddr: String
    var privilege: Int
    
    init(username: String, password: String, name: String, mailAddr: String, privilege: Int) {
        (self.username, self.password, self.name, self.mailAddr, self.privilege) = (username, password, name, mailAddr, privilege)
    }
}

class Order: Object, Codable {
    let user: User
    let train: Train
    let from, to: String
    let date: Int
    var number: Int
    var status: Int
    
    init(user: User, train: Train, from: String, to: String, date: Int, number: Int, status: Int) {
        (self.user, self.train, self.from, self.to, self.date, self.number, self.status) = (user, train, from, to, date, number, status)
    }
}

class Train: Object, Codable {
    
    let trainID: String
    let type: String
    let stationNum: Int
    let startTime: DateTime
    let stations: [String]
    var seatNums: [[Int]]
    let prices, travelTimes, stopoverTimes: [Int]
    let date: [Int]
    var sumTimes = [[DateTime]]()
    
    init(trainID: String, type: String, stationNum: Int, startTime: DateTime, stations: [String] ,seatNums: [[Int]], prices: [Int], travelTimes: [Int], stopoverTimes: [Int], date: [Int]) {
        (self.trainID, self.type, self.stationNum, self.startTime, self.stations, self.seatNums, self.prices, self.travelTimes, self.stopoverTimes, self.date) = (trainID, type, stationNum, startTime, stations, seatNums, prices, travelTimes, stopoverTimes, date)
        var time = startTime
        for i in 0..<stations.count {
            sumTimes.append([i == 0 ? DateTime(-10000, 0) : time.combined(rhs: DateTime(0, travelTimes[i - 1])),
                             i == stations.count - 1 ? DateTime(-10000, 0) : time.combined(rhs: DateTime(0, stopoverTimes[i]))])
        }
    }
    
    func query(for dd: Int) {
        if dd < date[0] || dd > date[1] {
            print("-1")
        } else {
            let d = dd - date[0], base = DateTime(dd, 0)
            print(trainID, type)
            for i in 0..<stations.count {
                print(stations[i],
                      sumTimes[i][0] + base,
                      "->",
                      sumTimes[i][1] + base,
                      prices[i],
                      i == stations.count - 1 ? "x" : seatNums[d][i])
            }
        }
    }
    
    func queryPrint(from: String, to: String, at: Int, for order: Order? = nil) {
        let sIdx = stations.firstIndex(of: from)!, tIdx = stations.firstIndex(of: to)!
        let base = DateTime(at - sumTimes[sIdx][1].val[2], 0)
        print(trainID,
              from, sumTimes[sIdx][1] + base, "->",
              to, sumTimes[tIdx][0] + base,
              prices[tIdx] - prices[sIdx],
              order?.number ?? seatNums[base.val[2] - date[0]][sIdx..<tIdx].min()!)
    }
    
    func getTime(from: String, to: String) -> Int {
        (sumTimes[stations.firstIndex(of: to)!][0] - sumTimes[stations.firstIndex(of: from)!][1]).inMinutes
    }
    
    func getPrice(from: String, to: String) -> Int {
        prices[stations.firstIndex(of: to)!] - prices[stations.firstIndex(of: from)!]
    }
    
    func modifyTicket(order: Order) -> Bool {
        let sIdx = stations.firstIndex(of: order.from)!, tIdx = stations.firstIndex(of: order.to)!
        if seatNums[order.date - date[0] - sumTimes[sIdx][1].val[2]][sIdx..<tIdx].min()! - order.number < 0 {
            return false
        }
        for i in sIdx..<tIdx {
            seatNums[order.date - date[0] - sumTimes[sIdx][1].val[2]][i] -= order.number
        }
        return true
    }
    
}
