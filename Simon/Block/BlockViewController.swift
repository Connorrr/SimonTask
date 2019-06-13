//
//  TrialViewController.swift
//  CognativeFlexabilityTraining
//
//  Created by Connor Reid on 15/3/18.
//  Copyright © 2018 Connor Reid. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class BlockViewController: UIViewController {
    
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var stimImage: UIImageView!
    @IBOutlet weak var fixationCross: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBOutlet weak var stimLabel: UILabel!
    @IBOutlet weak var leftButton: ResponseButton!
    @IBOutlet weak var fruitButton: ResponseButton!     //  This button is not used in the TS app
    @IBOutlet weak var redButton: ResponseButton!       //  This button is not used in the TS app
    @IBOutlet weak var rightButton: ResponseButton!
    
    var blockType : BlockType?
    var isEvenOdd : Bool?
    var block : Block?
    var blockProgress : Int?
    var blockData : [TrialData] = []
    var fileNames : [String]?
    var wasResponse = false
    
    var trialIndex : Int {
        return currentTrial-1
    }
    var currentTrial : Int = 1
    var congruentTrialIndex = 0
    var isTrialCongruent = false
    var isTrialLeft = false
    var isTrialLeftArrow = false
    var trialData = TrialData()
    var trialTime : Double?
    var trialStartTime : Date?
    var audioPlayer = AVAudioPlayer()
    
    private var leftLocation : CGFloat?
    private var rightLocation : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Set middle buttons to be invis in the containers
        redButton.alpha = 0.0
        fruitButton.alpha = 0.0
        
        leftLocation = view.frame.width/4
        rightLocation = view.frame.width*3/4
        
        setStimSide(isLeft: true)
        
        if StaticVars.id == "JasmineTest" {
            playEasterEgg()
        }
        
        //let random = false
        if blockType != nil {
            
            block = Block(blockType: self.blockType!)
            executeBlock()
            
        }else{
            feedbackLabel.text = "ERROR: BlockViewController: Block Type missing"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  Sets the stim and arrow side
    func setStimSide(isLeft: Bool){
        
        var multiplier : CGFloat = 1.5
        if (isLeft){
            multiplier = 0.5
        }
        
        view.constraints.forEach{constraint in
            if constraint.identifier == "ArrowCenterX" {                        // Get arrow center x constraint
                constraint.isActive = false                                     // delete it
                let newConstraint = NSLayoutConstraint(item: arrowImage,        // create new
                                                       attribute: .centerX,
                                                       relatedBy: .equal,
                                                       toItem: view,
                                                       attribute: .centerX,
                                                       multiplier: multiplier,
                                                       constant: 0.0)
                newConstraint.identifier = "ArrowCenterX"                       // rename it
                newConstraint.isActive = true                                   // add it
            }
            if constraint.identifier == "StimCenterX" {
                constraint.isActive = false
                let newConstraint = NSLayoutConstraint(item: stimImage,
                                                       attribute: .centerX,
                                                       relatedBy: .equal,
                                                       toItem: view,
                                                       attribute: .centerX,
                                                       multiplier: multiplier,
                                                       constant: 0.0)
                newConstraint.identifier = "StimCenterX"
                newConstraint.isActive = true
            }
        }
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        trialData.response = "left"
        checkCorr(pressedLeft: true, timedOut: false)
        wasResponse = true
        forceProgress()
    }
    
    //  NOT USED
    @IBAction func fruitButtonPressed(_ sender: UIButton) {
        trialData.response = "fruit"
        //checkCorr()
        forceProgress()
    }
    
    //  NOT USED
    @IBAction func redButtonPressed(_ sender: UIButton) {
        trialData.response = "red"
        //checkCorr(pressedLeft: <#T##Bool?#>, timedOut: <#T##Bool#>)
        forceProgress()
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        trialData.response = "right"
        checkCorr(pressedLeft: false, timedOut: false)
        wasResponse = true
        forceProgress()
    }
    
    func setButtonLabels() {
        rightButton.setImage(#imageLiteral(resourceName: "GoButton.png"), for: .normal)
    }
    
    //  Called after the response button is pressed
    func forceProgress () {
        responseTimer!.fire()
    }
    
    var trialTimer : Timer?
    var responseTimer : Timer?
    var blankTimer : Timer?
    var repeatTimer : Timer?
    
    
    /// This function defines the variables that set up the visual aspects of the trial
    ///
    /// - Parameters:
    ///   - isCongruent: is this trial congruent
    ///   - isLeft: is it on the image on the left side of the screen
    func setCongruency(isCongruent: Bool, isLeft: Bool){
        if isCongruent{
            if isLeft{
                isTrialLeftArrow = true         //  Which way is the arrow pointing
                arrowImage.image = #imageLiteral(resourceName: "LeftArrow.png")
            }else{
                arrowImage.image = #imageLiteral(resourceName: "RightArrow.png")
                isTrialLeftArrow = false
            }
        }else{
            if isLeft {
                arrowImage.image = #imageLiteral(resourceName: "RightArrow.png")
                isTrialLeftArrow = false
            }else{
                arrowImage.image = #imageLiteral(resourceName: "LeftArrow.png")
                isTrialLeftArrow = true
            }
        }
    }
    
    func executeBlock() {
        congruentTrialIndex = block!.trialIndexs[trialIndex]
        isTrialLeft = block!.isLeft[congruentTrialIndex]
        isTrialCongruent = block!.isCongruent[congruentTrialIndex]
        
        setStimSide(isLeft: isTrialLeft)
        setCongruency(isCongruent: isTrialCongruent, isLeft: isTrialLeft)
        self.stimImage.image = UIImage(named: block!.trialImageFilenames[congruentTrialIndex])
        
        if StaticVars.id == "JasmineTest" {
            self.stimImage.image = #imageLiteral(resourceName: "jasmine.jpg")
        }
        
        setUpTrialData()
        
        //  Display Fixation for 1400 ms
        displayFixation()
    
        //  Show trial for 5000ms or first response
        trialTimer = Timer.scheduledTimer(withTimeInterval: 1.4, repeats: false, block: { (trialTimer) in self.displayTrial() })
    
        //  25ms blank (called in displayTrial)
        
    }
    
    func displayFixation() {
        self.fixationCross.isHidden = false
        self.stimImage.isHidden = true
        self.arrowImage.isHidden = true
        self.stimLabel.isHidden = true
        //self.boarderView.isHidden = true
        self.setButtonVisibility(isHidden: true)
    }
    
    func displayTrial() {
        //self.setBoarder(isSwitch: block!.trials![trialIndex].isSwitchTrial!)
        self.fixationCross.isHidden = false
        self.stimImage.isHidden = false
        self.arrowImage.isHidden = false
        self.stimLabel.isHidden = true
        self.setButtonVisibility(isHidden: false)
        self.responseTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (responseTimer) in self.displayBlank() }) //Set to 50000 so it is essentially waiting for a response only
        self.trialStartTime = Date()
    }
    
    // THERE IS NO FEEDBACK IN THE TS APP SO THIS IS SKIPPED
    func displayResponse () {
        self.fixationCross.isHidden = false
        self.stimImage.isHidden = true
        self.arrowImage.isHidden = true
        self.stimLabel.isHidden = true
        //self.boarderView.isHidden = true
        self.setButtonVisibility(isHidden: true)
        if self.trialData.corr != 1 {
            self.feedbackLabel.isHidden = false
        }
        self.blankTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (blankTimer) in self.displayBlank() })
    }
    
    func displayBlank() {
        checkCorr(pressedLeft: nil, timedOut: true)
        getResponseTime()
        self.feedbackLabel.isHidden = true
        self.fixationCross.textColor = .black
        self.fixationCross.text = "+"
        self.fixationCross.isHidden = true
        self.stimImage.isHidden = true
        self.arrowImage.isHidden = true
        self.stimLabel.isHidden = true
        //self.boarderView.isHidden = true
        let defaults = UserDefaults.standard
        let startTime = defaults.object(forKey: "startTime") as! Date

        trialData.time = Date(timeIntervalSinceNow: 0.25).timeIntervalSince(startTime).description
        blockData.append(trialData)
        if (currentTrial < block!.numberOfTrials!) {
            self.currentTrial = self.currentTrial + 1
            repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {(repeatTimer) in self.executeBlock()})
        }else{      //MARK:  This is the end of the trials
            saveBlockData()
            
            performSegue(withIdentifier: "returnToInstructions", sender: nil)
        }
    }
    
    func saveBlockData () {

        print("put in array")
        let currentLogData = blockData.map{$0.propertyListRepresentation}      //  Return the property list compliant version of the struct
        print("appending data")
        let fullLogs = getAppendedLogData(currentLogData: currentLogData)
        if fullLogs == nil { UserDefaults.standard.set(currentLogData, forKey: "BlockData") } else {
            UserDefaults.standard.set(fullLogs, forKey: "BlockData")
        }
        print("put in defaults")
    }
    
    func getAppendedLogData (currentLogData: [[String : Any]]) -> [[String : Any]]? {
        guard var propertyListLogs = UserDefaults.standard.object(forKey: "BlockData") as? [[String:Any]] else {
            print("'BlockData' not found in UserDefaults")
            return nil
        }
        
        for data in currentLogData {
            propertyListLogs.append(data)
        }
        
        return propertyListLogs
    }
    
    func setButtonVisibility(isHidden: Bool) {
        self.leftButton.isHidden = isHidden
        self.fruitButton.isHidden = isHidden
        self.redButton.isHidden = isHidden
        self.rightButton.isHidden = isHidden
    }
    
    func getResponseTime() {
        let endTime = Date()
        let rT = endTime.timeIntervalSince(trialStartTime!)
        trialData.rt = rT
    }
    
    func checkCorr(pressedLeft: Bool?, timedOut: Bool) {
        
        if !timedOut{
            if pressedLeft!{
                if isTrialLeftArrow {
                    trialData.corr = 1
                }else{
                    trialData.corr = 0
                }
            }else{
                if isTrialLeftArrow {
                    trialData.corr = 0
                }else{
                    trialData.corr = 1
                }
            }
        }else{
            trialData.corr = 0
        }
    }
    
    /// Sets the boarder visibility around stim
    func setBoarder(isSwitch: Bool) {
        if isSwitch {
            //self.boarderView.isHidden = false
            //trialData.isSwitchTrial = 1
        } else {
            //self.boarderView.isHidden = true
            //trialData.isSwitchTrial = 0
        }
    }
    
    func setUpTrialData() {
        trialData = TrialData()
        trialData.trialNum = currentTrial
        trialData.blockNumber = blockProgress!
        
        switch blockType! {
        case .practice:
            trialData.blockType = "Practice"
        case .neutralangry:
            trialData.blockType = "NeutralAngry"
        case .angryneutral:
            trialData.blockType = "AngryNeutral"
        case .happyneutral:
            trialData.blockType = "HappyNeutral"
        case .neutralhappy:
            trialData.blockType = "NeutralHappy"
        }
        
        //  TODO:  Set the image for this trial
        
        //trialData.stim = block!.trials![trialIndex].stimLabel!
//        switch block!.trials![trialIndex].condition! {
//        case .vowel:
//            trialData.trialCondition = "vowel"
//        case .consonant:
//            trialData.trialCondition = "consonant"
//        case .even:
//            trialData.trialCondition = "even"
//        case .odd:
//            trialData.trialCondition = "odd"
//        }
    }
    
    func playEasterEgg () {
        guard let url = Bundle.main.url(forResource: "AWholeNewWorld", withExtension: "mp3") else {
            print("Couldn't find the file :(")
            return
        }
        
        do {
            print("Found It :)")
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            audioPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToInstructions" {
            print("preparing for segue")
            if let viewController = segue.destination as? ViewController {
                if blockProgress! + 1 < viewController.numBlocks {
                    viewController.instructionsState = .breakText
                }else{
                    viewController.instructionsState = .goodbyeText
                }
                
                viewController.blockProgress = blockProgress! + 1
            }
        }
    }
}
