//
//  main.swift
//  TTRS_in_Memory
//
//  Created by Haichen Dong on 2020/3/18.
//  Copyright © 2020 Haichen Dong. All rights reserved.
//

import Foundation

class TTRS {
    
    var users = [String: User]()
    var trains = [String: Train]()
    var orders = [User: [Order]]()
    var args = [String: String]()
    var functionMap: [String: () -> Void]!
    
    var liveList = Set<User>()
    var queue = [Train: [Order]]()
    
    init() {
        functionMap = [
            "add_user": self.addUser,
            "login": self.login,
            "logout": self.logout,
            "query_profile": self.queryProfile,
            "modify_profile": self.modifyProfile,
            "query_train": self.queryTrain,
            "add_train": self.addTrain,
            "query_ticket": self.queryTicket,
            "query_transfer": self.queryTransfer,
            "buy_ticket": self.buyTicket,
            "refund_ticket": self.refundTicket,
            "query_order": self.queryOrder,
            "exit": self.exit
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
    
    func addUser() {
        let u = User(username: args["u"]!,
                     password: args["p"]!,
                     name: args["n"]!,
                     mailAddr: args["m"]!,
                     privilege: Int(args["g"]!)!)
        users[args["u"]!] = u
        orders[u] = []
    }
    
    func login() {
        if users[args["u"]!]?.password == args["p"]! {
            liveList.insert(users[args["u"]!]!)
            print("0")
        } else {
            print("-1")
        }
    }
    
    func logout() {
        if users[args["u"]!] != nil && liveList.contains(users[args["u"]!]!) {
            liveList.remove(users[args["u"]!]!)
            print("0")
        } else {
            print("-1")
        }
    }
    
    func queryProfile() {
        if let u = users[args["u"]!] {
            print(u.username, u.name, u.mailAddr, u.privilege)
        } else {
            print("-1")
        }
    }
    
    func modifyProfile() {
        if let u = users[args["u"]!] {
            if let v = args["p"] {
                u.password = v
            }
            if let v = args["n"] {
                u.name = v
            }
            if let v = args["m"] {
                u.mailAddr = v
            }
            if let v = args["g"] {
                u.privilege = Int(v)!
            }
        } else {
            print("-1")
        }
    }
    
    func queryTrain() {
        trains[args["i"]!]!.query(for: args["d"]!.getDate())
    }
    
    func addTrain() {
        let stationNum = Int(args["n"]!)!
        let dates = args["d"]!.components(separatedBy: "|")
        let sDate = dates[0].getDate(), tDate = dates[1].getDate()
        let t = Train(trainID: args["i"]!,
                      type: args["y"]!,
                      stationNum: stationNum,
                      startTime: DateTime(0, args["x"]!),
                      stations: args["s"]!.components(separatedBy: "|"),
                      seatNums: [[Int]](repeating: [Int](repeating: Int(args["m"]!)!,
                                                         count: stationNum - 1), count: tDate - sDate + 1),
                      prices: [0] + args["p"]!.components(separatedBy: "|").map {Int($0)!}.preSum(),
                      travelTimes: args["t"]!.components(separatedBy: "|").map {Int($0)!},
                      stopoverTimes: [0] + args["o"]!.components(separatedBy: "|").map {Int($0)!},
                      date: [sDate, tDate])
        trains[args["i"]!] = t
        queue[t] = []
        
    }
    
    func deleteTrain() {
        trains.removeValue(forKey: args["i"]!)
    }
    
    func queryTicket() {
        let s = args["s"]!, t = args["t"]!
        let res = trains.values.filter {$0.stations.contains(s) && $0.stations.contains(t)}
        print(res.count)
        zip(res.map {(args["p"] ?? "time" == "time") ? $0.getTime(from: s, to: t) : $0.getPrice(from: s, to: t)}, res).sorted {
            $0.0 < $1.0
        }.forEach {$0.1.queryPrint(from: s, to: t, at: args["d"]!.getDate())}
    }
    
    func queryTransfer() {
        let s = args["s"]!, t = args["t"]!
        var res: ((Int, String, Int), Train, Train)? = nil
        for t1 in trains.values where t1.stations.contains(s) {
            for t2 in trains.values where t2.stations.contains(t) && t2.trainID != t1.trainID {
                var minTrans: (Int, String, Int)? = nil
                for sta in t1.stations where t2.stations.contains(sta) && t1.stations.firstIndex(of: sta)! > t1.stations.firstIndex(of: s)! && t2.stations.firstIndex(of: sta)! < t2.stations.firstIndex(of: t)! {
                    var transTime = t2.sumTimes[t2.stations.firstIndex(of: sta)!][1] - t1.sumTimes[t1.stations.firstIndex(of: sta)!][0]
                    let dfort1 = -transTime.val[2]
                    transTime.val[2] = 0
                    let time = transTime.inMinutes + t1.getTime(from: s, to: sta) + t2.getTime(from: sta, to: t)
                    print(t1.trainID, t2.trainID, sta, transTime.inMinutes, time)
                    if let curTime = minTrans?.0 {
                        if time < curTime {
                            minTrans = (time, sta, dfort1)
                        }
                    } else {
                        minTrans = (time, sta, dfort1)
                    }
                }
                if minTrans != nil {
                    if let curTime = res?.0.0 {
                        if minTrans!.0 < curTime {
                            res = (minTrans!, t1, t2)
                        }
                    } else {
                        res = (minTrans!, t1, t2)
                    }
                }
            }
        }
        if res != nil {
            res!.1.queryPrint(from: s, to: res!.0.1, at: args["d"]!.getDate())
            res!.2.queryPrint(from: res!.0.1, to: t, at: args["d"]!.getDate() + res!.0.2)
        } else {
            print("0")
        }
    }
    
    func buyTicket() {
        if let u = users[args["u"]!], liveList.contains(u), let t = trains[args["i"]!] {
            let o = Order(user: u, train: t, from: args["f"]!, to: args["t"]!, date: args["d"]!.getDate(), number: Int(args["n"]!)!, status: 1)
            if t.modifyTicket(order: o) {
                orders[u]!.append(o)
            } else if args["q"] ?? "false" == "true" {
                o.status = 0
                orders[u]!.append(o)
                queue[t]!.append(o)
            }
        } else {
            print("-1")
        }
    }
    
    func refundTicket() {
        if let u = users[args["u"]!] {
            let n = Int(args["n"] ?? "1")!
            let o = orders[u]![orders[u]!.count - n]
            o.status = -1
            o.number *= -1
            _ = o.train.modifyTicket(order: o)
            for q in queue[o.train]! {
                print("!!!! search", q.number)
                if o.train.modifyTicket(order: q) {
                    q.status = 1
                }
            }
            queue[o.train]!.removeAll {$0.status == 1}
        } else {
            print("-1")
        }
    }
    
    func queryOrder() {
        if let u = users[args["u"]!] {
            for o in orders[u]!.reversed() {
                print({() in switch o.status {
                case -1: return "[refunded]"
                case 0:  return "[pending]"
                default: return "[success]"
                    }}(), terminator: " ")
                o.train.queryPrint(from: o.from, to: o.to, at: o.date, for: o)
            }
        } else {
            print("-1")
        }
    }
    
    func exit() {
    }
    
    func clean() {
        users.removeAll()
        trains.removeAll()
        orders.removeAll()
        liveList.removeAll()
        queue.removeAll()
    }
    
}


let prog = TTRS()

let input =
"""
add_train -i HAPPY_TRAIN -n 3 -m 1000 -s 上院|中院|下院 -p 114|514 -x 19:19 -t 600|600 -o 5 -d 06-01|08-17 -y G
add_train -i THOMAS -n 2 -m 100 -s 中院|下院 -p 2333 -x 08:00 -t 300 -o 0 -d 06-01|08-01 -y G
query_train -d 07-01 -i HAPPY_TRAIN
query_ticket -s 中院 -t 下院 -d 07-12
query_ticket -s 中院 -t 下院 -d 07-12 -p cost
query_transfer -s 上院 -t 下院 -d 07-12
add_user -c root -u Texas -p awsl -n TEXAS -m TEXAS@wykbiss.com -g 10
add_user -c root -u Lappland -p awsl -n LAPPY -m LAPPY@wykbiss.com -g 10
login -u Texas -p awsl
login -u Lappland -p awsl
buy_ticket -u Texas -i HAPPY_TRAIN -d 08-17 -n 800 -f 中院 -t 下院
buy_ticket -u Lappland -i HAPPY_TRAIN -d 08-17 -n 500 -f 上院 -t 下院 -q true
buy_ticket -u Lappland -i HAPPY_TRAIN -d 08-16 -n 233 -f 上院 -t 下院 -q true
query_order -u Texas
query_order -u Lappland
query_train -d 08-16 -i HAPPY_TRAIN
query_train -d 08-17 -i HAPPY_TRAIN
refund_ticket -u Texas -n 1
query_order -u Texas
query_order -u Lappland
query_train -d 08-16 -i HAPPY_TRAIN
query_train -d 08-17 -i HAPPY_TRAIN
exit
"""

for cmd in input.components(separatedBy: "\n") {
    prog.execute(cmd: cmd)
}
