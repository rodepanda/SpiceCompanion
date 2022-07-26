//
//  Rc4.swift
//  Spice
//
//  Created by Gianni on 14/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//


import Foundation

class Rc4 {
    struct ByteStream {
        typealias Element = UInt8
        
        var i = 0
        var j = 0
        var key: [UInt8]
        
        init(key: [UInt8]) {
            self.key = key
        }
        
        mutating func next() -> Element? {
            i = (i + 1) % 256
            j = (j + Int(key[i])) % 256
            (key[i], key[j]) = (key[j], key[i])
            return key[(Int(key[i]) + Int(key[j])) % 256]
        }
    }
    
    var byteStream: ByteStream
    
    init(password: [UInt8]){
        let key = Rc4.keyInit(key: password)
        byteStream = ByteStream(key: key)
    }

    static func keyInit(key: [UInt8]) -> [UInt8] {
        var K = [UInt8]()
        for i in 0..<256 {
            K.append(UInt8(i))
        }
        
        var j = 0
        for i in 0..<256 {
            let index = Int(K[i])
            j = (j + index + Int(key[i % key.count])) % 256
            (K[i], K[j]) = (K[j], K[i])
        }
        
        return K
    }

    func encrypt(text: [UInt8]) -> [UInt8] {
        var cipherText = [UInt8]()
        
        for ch in text {
            let cipherByte = ch ^ byteStream.next()!
            cipherText.append(cipherByte)
        }
        
        return cipherText
    }
}
