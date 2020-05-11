public class Interval<T: Comparable> {
    private (set) var start: T
    private (set) var end: T
    var max: T
    
    var patches: [Patch]
    
    var left: Interval<T>?
    var right: Interval<T>?
    
    init(start: T, end: T) {
        precondition(start <= end)
        
        self.start = start
        self.end = end
        self.max = end
        self.patches = [Patch]()
    }
}

extension Interval: Comparable {
    public static func ==(lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    public static func <(lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return lhs.start < rhs.start
    }
    public static func <=(lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    public static func >=(lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    public static func >(lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return lhs.start > rhs.start
    }
}

extension Interval: CustomStringConvertible {
    public var description: String {
        return "(\(start),\(end)):{\(max)}"
    }
}

public struct AugmentedIntervalTree<T: Comparable> {
    private (set) var root: Interval<T>? = nil
    
    private func insert(_ node: Interval<T>?, _ newNode: Interval<T>) -> Interval<T> {
        guard let tmp = node else {
            return newNode
        }
        
        if newNode.end > tmp.max {
            tmp.max = newNode.end
        }
        
        if (tmp < newNode) {
            if tmp.right == nil {
                tmp.right = newNode
            } else {
                _ = insert(tmp.right, newNode)
            }
        } else {
            if tmp.left == nil {
                tmp.left = newNode
            } else {
                _ = insert(tmp.left, newNode)
            }
        }
        return tmp
    }
    
    func overlaps(acc: inout [Interval<T>], node: Interval<T>?, _ interval: Interval<T>) {
        guard let tmp = node else {
            return
        }
        
        if !((tmp.start > interval.end) || (tmp.end < interval.start)) {
            acc.append(tmp)
        }
        
        if let l = tmp.left, l.max >= interval.start {
            overlaps(acc: &acc, node: l, interval)
        }
        overlaps(acc: &acc, node: tmp.right, interval)
    }
    
    public mutating func insert(_ node: Interval<T>) {
        root = insert(root, node)
    }
    
    public func overlaps(with interval: Interval<T>) -> [Interval<T>]{
        var res = [Interval<T>]()
        overlaps(acc: &res, node: root, interval)
        return res
    }
}

//print("--- Tree ---")
//var ait = AugmentedIntervalTree<Int>()
//ait.insert(Interval<Int>(start: 5, end: 10))
//ait.insert(Interval<Int>(start: 15, end: 25))
//ait.insert(Interval<Int>(start: 1, end: 12))
//ait.insert(Interval<Int>(start: 8, end: 16))
//ait.insert(Interval<Int>(start: 14, end: 20))
//ait.insert(Interval<Int>(start: 18, end: 21))
//ait.insert(Interval<Int>(start: 2, end: 8))
//ait.printTree()
//
//print("--- Intersection ---")
//let queries = [Interval<Int>(start: 8, end: 10), Interval<Int>(start: 20, end: 22)]
//
//var overlaps = [Interval<Int>]()
//
//for query in queries {
//    print("Intersections with \(query): \(ait.overlaps(with:query))")
//}
//print(overlaps)
