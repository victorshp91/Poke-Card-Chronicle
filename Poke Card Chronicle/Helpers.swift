//
//  Helpers.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/19/24.
//
import Foundation
import SwiftUI

// Helper function to get columns based on device type
func getGridColumns() -> [GridItem] {
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    let numberOfColumns = isPad ? 4 : 2
    return Array(repeating: GridItem(.flexible(), spacing: 5), count: numberOfColumns)
}
