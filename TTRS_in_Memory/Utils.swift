//
//  Utils.swift
//  TTRS_in_Memory
//
//  Created by Haichen Dong on 2020/3/18.
//  Copyright © 2020 Haichen Dong. All rights reserved.
//

import Foundation

let days = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
let daysSum: [Int] = {
    var ar = [Int]()
    var sm = 0
    for d in days {
        sm += d
        ar.append(sm)
    }
    return ar
}()

extension String {
    func getDate() -> Int {
        let ar = self.components(separatedBy: "-")
        return dateToInt((Int(ar[0])!, Int(ar[1])!))
    }
}

extension Int {
    func withWidth(_ w: Int) -> String {
        String(format: "%0\(w)d", self)
    }
}

extension Array where Element == Int {
    func preSum() -> [Int] {
        var sum = 0
        return self.map {sum += $0; return sum;}
    }
}

func dateToInt(_ d: (Int, Int)) -> Int {
    daysSum[d.0 - 1] + d.1
}
func intToDate(_ c: Int) -> (Int, Int) {
    for i in 0..<daysSum.count where daysSum[i + 1] > c {
        return (i + 1, c - daysSum[i])
    }
    return (-1, -1)
}

struct DateTime: CustomStringConvertible {
    
    static var digits = [60, 24]
    var val = [Int]()
    init(_ d: Int, _ h: Int, _ m: Int) {
        val = [m, h, d]
        simplify()
    }
    init(_ d: Int, _ t: String) {
        let arr = t.components(separatedBy: ":")
        val = [Int(arr[1])!, Int(arr[0])!, d]
        simplify()
    }
    init(_ d: Int, _ t: Int) {
        var cur = t
        for dig in DateTime.digits {
            val.append(cur % dig)
            cur /= dig
        }
        val.append(cur + d)
    }
    var description: String {
        if val[2] < 0 {
            return "xx-xx xx:xx"
        } else {
            let date = intToDate(val[2])
            return "\(date.0.withWidth(2))-\(date.1.withWidth(2)) \(val[1].withWidth(2)):\(val[0].withWidth(2))"
        }
    }
    var inMinutes: Int {
        var ret = val[0]
        for i in 1..<val.count {
            ret += val[i] * DateTime.digits[i - 1]
        }
        return ret
    }
    
    
    private mutating func simplify() {
        for i in 0..<DateTime.digits.count {
            val[i + 1] += val[i] / DateTime.digits[i]
            val[i] %= DateTime.digits[i]
            if val[i] < 0 {
                val[i] += DateTime.digits[i]
                val[i + 1] -= 1
            }
        }
    }
    
    mutating func combined(rhs: DateTime, fun: (Int, Int) -> Int = (+)) -> Self {
        for i in 0..<val.count {
            val[i] = fun(val[i], rhs.val[i])
        }
        simplify()
        return self
    }
    
    static func + (lhs: DateTime, rhs: DateTime) -> DateTime {
        var ret = lhs
        return ret.combined(rhs: rhs, fun: (+))
    }
    static func - (lhs: DateTime, rhs: DateTime) -> DateTime {
        var ret = lhs
        return ret.combined(rhs: rhs, fun: (-))
    }
    
}


