//
//  MasterViewController.swift
//  Word Scramble
//
//  Created by Ethan Thomas on 8/23/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {

    var allWords = [String]()
    var objects = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let guessButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWord))
        refreshButton.tintColor = UIColor.white
        guessButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = guessButton
        navigationItem.leftBarButtonItem = refreshButton
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        startGame()
    }
    
    func refreshWord() {
        let newWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords)
        title = String(describing: newWords.first!)
        objects.removeAll()
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            let answer = ac.textFields![0]
            self.submitAnswer(answer: answer.text!)
        }
        ac.addAction(submitAction)
        present(ac, animated: true, completion: nil)
    }
    
    func submitAnswer(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if wordIsPossible(word: lowerAnswer) {
            if wordIsOriginal(word: lowerAnswer) {
                if wordIsReal(word: lowerAnswer) {
                    objects.insert(answer, at: 0)
                    
                    let indexPath = NSIndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
                    return
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make the words up you know!"
                }
            } else {
                errorTitle = "Word used already!"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title!.lowercased())!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func wordIsPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word.characters {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    func wordIsReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        objects.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
}

extension MasterViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
}

