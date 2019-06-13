//
//  Block.swift
//  CognativeFlexabilityTraining
//
//  Created by Connor Reid on 15/3/18.
//  Copyright © 2018 Connor Reid. All rights reserved.
//

import Foundation
import UIKit

class Block {
    
    let blockType : BlockType
    let numberOfTrials : Int?
    var trials : [TrialInfo]? = []
    var isCongruent : [Bool] = []
    var trialImageFilenames : [String] = []
    var trialIndexs : [Int] = []        //  Use thesee indexes to pull congruency and stimulus filenames
    var isLeft : [Bool] = []            //  Is the arrow and image to be displayed on the left side of the screen
    
    
    /// Builds the isGoTrialList in this class based on whether its a practice block or not
    /// Practice block will be 10 trials and not will be 60
    /// - Parameter isPractice: set true if this is a practice block
    init(blockType: BlockType){
        self.blockType = blockType
        
        if (blockType == .practice){
            numberOfTrials = 10
        }else{
            numberOfTrials = 100
        }
        
        buildCongruent()
        buildMainBlockImageFilenames()
        buildTrialIndexs()
    }
    
    func buildTrialIndexs() {
        
        for i in 0 ..< numberOfTrials! {
            trialIndexs.append(i)
        }
        
        trialIndexs.shuffle()
    }
    
    private func buildCongruent(){
        
        for i in 0 ..< numberOfTrials! {
            if (i % 2 == 0){
                isCongruent.append(true)
            }else{
                isCongruent.append(false)
            }
        }
                
    }
    
    func buildMainBlockImageFilenames(){
        var stim1Suffix = ""
        var stim2Suffix = ""
        var numStim1M = 25
        var numStim1F = 25
        var numStim2M = 25
        var numStim2F = 25
        var startSide = Bool().randomBool()     //  True for left
        
        
        switch blockType {
        case .practice:
            stim1Suffix = "N"
            stim2Suffix = "H"
            numStim1M = 0
            numStim1F = 5
            numStim2M = 0
            numStim2F = 5
        case .neutralangry:
            stim1Suffix = "N"
            stim2Suffix = "A"
        case .angryneutral:
            stim1Suffix = "A"
            stim2Suffix = "N"
        case .happyneutral:
            stim1Suffix = "H"
            stim2Suffix = "N"
        case .neutralhappy:
            stim1Suffix = "N"
            stim2Suffix = "H"
        }
        
        var stim1List : [String] = []
        var stim2List : [String] = []
        var imageNums : [Int] = [1,2,3,4,5,6]
        
        if (blockType != .practice){
            //  Set nogo male names
            imageNums.shuffle()
            for i in 1 ... numStim1M {
                stim2List.append(stim2Suffix + "M" + String(imageNums[i%6]))
                if (i%6 == 0){
                    startSide = !startSide
                }
                isLeft.append(startSide)
            }
        
            //  Set go male names
            imageNums.shuffle()
            for i in 1 ... numStim2M {
                stim1List.append(stim1Suffix + "M" + String(imageNums[i%6]))
                if (i%6 == 0){
                    startSide = !startSide
                }
                isLeft.append(startSide)
            }
        }
        
        //  set nogo female names
        imageNums.shuffle()
        for i in 1 ... numStim1F {
            stim2List.append(stim2Suffix + "F" + String(imageNums[i%6]))
            if (i%6 == 0){
                startSide = !startSide
            }
            isLeft.append(startSide)
        }
        
        //  set go female names
        imageNums.shuffle()
        for i in 1 ... numStim2F {
            stim1List.append(stim1Suffix + "F" + String(imageNums[i%6]))
            if (i%6 == 0){
                startSide = !startSide
            }
            isLeft.append(startSide)
        }
        
        //  Put the stimulus in list in order
        for i in stim1List {
            trialImageFilenames.append(i)
        }
        
        for i in stim2List {
            trialImageFilenames.append(i)
        }
        
    }
    
}
