//
//  ViewController.swift
//  CognativeFlexabilityTraining
//
//  Created by Connor Reid on 15/3/18.
//  Copyright © 2018 Connor Reid. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextViewDelegate {
    
    var experimentStructure : [BlockType] = [.practice,.angryneutral, .happyneutral]
    let isEvenOddStructure : [Bool?] = [nil, true, false, nil]                  //  This is used to define the single blocks types and whether they are Task A (even,odd) or B (vowel,consonant)
    let numBlocks = 3
    
    var blockProgress : Int = 0
    var instructionsState : InstructionsTextState?
    
    var logFileMaker : LogFileMaker?
    var fileName : String?
    
    var testTimer : Timer?
    var isTest : Bool = false    //  Will automatically run through if true

    @IBOutlet weak var instructionsTextView: InstructionsTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logFileMaker = LogFileMaker(fileName: "\(StaticVars.id)-\(getDateString())")
        
        setExperimentStructure()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        instructionsTextView.addGestureRecognizer(tapRecognizer)
        
        if instructionsState == nil {
            instructionsState = .openingText
        }
        
        switch instructionsState! {
        case .openingText:
            setText("Opening")
            setTestTimer(isFinished: false)
        case .breakText:
            setText("Break")
            setTestTimer(isFinished: false)
            setText("BlockInstructions")
        case .practiceEnd:
            setText("PracticeEnd")
            setTestTimer(isFinished: false)
        case .goodbyeText:
            if !logFileMaker!.saveData() {
                print("Error:  Unable to save the log file data")
            }
            setGoodbyeText()
            setTestTimer(isFinished: true)
        }
    }
    
    func setTestTimer(isFinished: Bool) {
        if isTest {
            if isFinished {
                testTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {(testTimer) in self.testTimerFunctionToLogin()})
            } else {
                testTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {(testTimer) in self.testTimerFunctionToBlock()})
            }
        }
    }
    
    func testTimerFunctionToBlock () {
        performSegue(withIdentifier: "presentBlock", sender: nil)
    }
    
    func testTimerFunctionToLogin () {
        performSegue(withIdentifier: "instructionsToLogin", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDateString () -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: date)
    }
    
    func setExperimentStructure(){
        var structure : [BlockType] = [.angryneutral, .happyneutral]
        var index : [Int] = [5, 5]
        if (StaticVars.group == 1){
            index = [0, 1]
        }else if(StaticVars.group == 2){
            index = [1, 0]
        }else{
            print("Error: InstructionViewcontroller: setExperimetnStructure: group number must be between 1 - 2")
        }
        experimentStructure = [.practice, structure[index[0]], structure[index[1]]]
    }
    
    var readyToBeginPractice = false
    @objc func viewTapped() {
        if instructionsState! == .goodbyeText {
            performSegue(withIdentifier: "instructionsToLogin", sender: nil)
        } else {
            performSegue(withIdentifier: "presentBlock", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentBlock" {
            if let blockViewController = segue.destination as? BlockViewController {
                blockViewController.blockType = experimentStructure[blockProgress]
                blockViewController.isEvenOdd = isEvenOddStructure[blockProgress]
                blockViewController.blockProgress = blockProgress
            }
        }
    }
    
    // The Goodbye text takes gives feedback for percentage correct so it needs a different method to the setText func
    func setGoodbyeText() {
        //instructionsTextView.text = "Great job! Thank you for completing this session!\n\n You got \(Int(logFileMaker!.perCorr))% Correct"
        instructionsTextView.text = "Great job! Thank you for completing this session!"
    }
    
    // Returns true if succeeded
    @discardableResult func setText(_ fName:  String) -> Bool{
        let url = Bundle.main.url(forResource: fName, withExtension: "html")
        if (url == nil){
            print("Where dat Url @ brah!")
            return false
        }
        var d : NSDictionary? = nil
        let s = try! NSAttributedString(url: url!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: &d)
        self.instructionsTextView.attributedText = s
        //self.instructionsTextView.font = UIFont(name: "Helvetica", size: 24)
        return true
    }

}

