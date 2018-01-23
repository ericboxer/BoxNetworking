//
//  Extensions.swift
//  BoxNetworking
//
//  Created by Eric Boxer on 1/17/18.
//  Copyright © 2018 Eric Boxer. All rights reserved.
//

import Foundation

extension String {
    
    /// Public function to remove the null characters from a String.
    public func removeNullCharacters()-> String{
        return self.replacingOccurrences(of: "\0", with: "")
    }
    
}
