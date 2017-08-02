//
//  ViewController.swift
//  swiftyWords
//
//  Created by Darren on 7/22/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subViews in view.subviews where subViews.tag == 1001 {
            
            var btn = subViews as! UIButton
            
            letterButtons.append(btn)
            
            btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
        }
        loadLevel()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func buttonTapped(button: UIButton){
        currentAnswer.text = currentAnswer.text! + (button.titleLabel?.text)!
        button.isHidden = true
        activatedButtons.append(button)
        
        
    }
    @IBAction func submitTapped(_ sender: AnyObject) {
        // the solution.index(of: code) returns the position of the string if it is found in the array of solution so it is kind of like a check to see if answerLabel exist in the solution array.
        if let solutionPosition = solutions.index(of: currentAnswer.text!){
            activatedButtons.removeAll()
            var splitClues = answersLabel.text?.components(separatedBy: "\n")
            splitClues?[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues?.joined(separator: "\n")
            currentAnswer.text = ""
            score += 1
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Cleared!", message: "Congrats! Do you want to level up?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Next Level", style: .default, handler: levelUp))
                ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                present(ac, animated: true)
            }
        } else {
            currentAnswer.text = ""
            for btn in activatedButtons {
                btn.isHidden = false
            }
            activatedButtons.removeAll()
            score -= 1
            if score < 0 {
                score = 0
            }
            
            let ac = UIAlertController(title: "Wrong!", message: "Try another combonation", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true)
            
        }
    }

    @IBAction func clearTapped(_ sender: AnyObject) {
        currentAnswer.text = ""
        for btn in activatedButtons {
            btn.isHidden = false
        }
        activatedButtons.removeAll()
        
        
        
    }
    
    func levelUp(action: UIAlertAction){
        level += 1
        solutions.removeAll(keepingCapacity: true)
        loadLevel()
        for btn in letterButtons{
            btn.isHidden = false
        }
        
    }
    
    
    func loadLevel(){
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        // you dont need to put .txt because it ignores it and look for the type txt
        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt"){
            
            if let levelContents = try? String(contentsOfFile: levelFilePath){
                // the "\n" means a line break like a new line. and when it finds each linebreak it will cut that piece and put it into an array. alt+click on compoents for more info.
                var lines = levelContents.components(separatedBy: "\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
                // enumerated means it will illterlate through the lines array we created and puts its position in the array for index and the word for that index.
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    // each time this loop runs, it will take the first word and it's clues and seperates it then do it again so this loop does one word and clue at a time.
                    let answer = parts[0]
                    let clue = parts[1]
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    letterBits += answer.components(separatedBy: "|")
                    
        
                    
                }
            }
        }
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]
        if letterBits.count == letterButtons.count {
            // ".." means 0 to 19 not including 19. "..." includes 19
            for i in 0 ..< letterBits.count{
                letterButtons[i].setTitle(letterBits[i], for: .normal)
                
            }
        }
    }
  
}

