//
//  ViewController.swift
//  ListeningTest
//
//  Created by Aurelius Prochazka on 12/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController {

    var oscillator1 = AKOscillator()
    var oscillator2 = AKOscillator()
    var mixer = AKMixer()
    var file: AKAudioFile!
    var playerA: AKAudioPlayer!
    var playerB: AKAudioPlayer!
    var playerReference: AKAudioPlayer!
    var audioFolderURL: URL!
    var folderList: [String]!
    var totalQuestions = 0
    var currentQuestion = 1
    var correctAnswers = [answerChoice]()
    var userAnswers = [answerChoice]()
    var orangeColour = UIColor(hue: 38.0/360.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    var blueColour = UIColor(hue: 196.0/360.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var resultsView: UITextView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var BButton: UIButton!
    @IBOutlet weak var AButton: UIButton!
    @IBOutlet weak var questionDataLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    enum answerChoice {
        case A, B, unknown
    }
    
    
    
    func segmentedControlIndex(ac: answerChoice) -> Int {
        
        switch ac {
        case .A:
            return 0
        case .unknown:
            return 1
        case .B:
            return 2
        }
    }
    
    
    
    func indexToAnswerChoice(idx: Int) -> answerChoice {
        switch idx {
        case 0:
            return answerChoice.A
        case 1:
            return answerChoice.unknown
        case 2:
            return answerChoice.B
        default:
            return answerChoice.unknown
        }
    }
    
    
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    func sortFunc(num1: String, num2: String) -> Bool {
        return num1 < num2
    }
    
    
    
    func randomiseCorrectAnswers() {
        correctAnswers.removeAll()
        for _ in 1...totalQuestions {
            
            // set correct answers randomly
            let randomAnswer = Int(arc4random_uniform(2));
            correctAnswers.append(indexToAnswerChoice(idx: randomAnswer));
            
            // initialise all user answers to choice 2
            // 0=A, 1=B, 2=?
            userAnswers.append(answerChoice.unknown);
        }
    }
    
    
    
    
    
    func updateResults(copy: Bool = false) {
        var results = "";
        for i in 1...totalQuestions{
            
            // generate a right or wrong string
            var correctQ = String(userAnswers[i-1]==correctAnswers[i-1])
            
            // don't show anyresult if the user didn't answer the question
            if (userAnswers[i-1] == answerChoice.unknown){
                correctQ = " ";
            }
            
            // append the result of question i
            results.append(String(i) + ": " + correctQ + "\n")
        }
        
        // update the results text view
        resultsView.text = results
        
        // copy to pasteboard
        if(copy){
            UIPasteboard.general.setValue(results, forPasteboardType: "public.plain-text");
        }
    }
    
    
    
    
    
    
    func updateQuestion(){
        // update the label text at the top of the screen
        updateQuestionLabel()
        
        // load the answer previously given by the user into the
        // segmented control
        loadAnswer()
        
        // update results page to show how the user scored
        updateResults()
        
        // if at the end of the test,
        // show the results
        if(currentQuestion > totalQuestions){

        
        // otherwise load the audio
        } else {
            AudioKit.stop()
            
            let questionFolderURL = URL(fileURLWithPath: folderList[currentQuestion-1], relativeTo: audioFolderURL)
            let referenceAudioURL = URL(fileURLWithPath: "reference.wav", relativeTo: questionFolderURL)
            let whiteAudioURL = URL(fileURLWithPath: "white.wav", relativeTo: questionFolderURL)
            let filteredAudioURL = URL(fileURLWithPath: "filtered.wav", relativeTo: questionFolderURL)
            
            questionDataLabel.text = questionFolderURL.relativeString
            
            do {
                // load the reference audio file
                let referenceAudioFile = try AKAudioFile(forReading: referenceAudioURL)
                playerReference = try AKAudioPlayer(file: referenceAudioFile)
                
                let audioFileA: AKAudioFile!
                let audioFileB: AKAudioFile!
                
                // switch the order of samples A and B according to the random
                // selection determined at the start of the test
                if (correctAnswers[currentQuestion-1] == answerChoice.A) {
                    audioFileB = try AKAudioFile(forReading: whiteAudioURL)
                    audioFileA = try AKAudioFile(forReading: filteredAudioURL)
                } else {
                    audioFileA = try AKAudioFile(forReading: whiteAudioURL)
                    audioFileB = try AKAudioFile(forReading: filteredAudioURL)
                }
                
                // load the A and B audio files
                playerA = try AKAudioPlayer(file: audioFileA)
                playerB = try AKAudioPlayer(file: audioFileB)
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
            
            mixer = AKMixer(playerA, playerB, playerReference)
            AudioKit.output = mixer
            AudioKit.start()
        }
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        
        let font = UIFont.systemFont(ofSize: 20)
    segmentedControl.setTitleTextAttributes([NSFontAttributeName: font],for: .normal)
        
        // set the colour for buttons in disabled state
        //backButton.setTitleColor(UIColor.darkGray, for: .disabled)
        //nextButton.setTitleColor(UIColor.darkGray, for: .disabled)
    
        // hide the question data label
        questionDataLabel.alpha = 0.0;
        
        
        // get the list of subfolders in the audio folder
//        audioFolderURL = URL(fileURLWithPath: "audio", relativeTo: Bundle.main.bundleURL)
        audioFolderURL = URL(fileURLWithPath: "audio_Q_extensive", relativeTo: Bundle.main.bundleURL)
        
        do {
            folderList = try FileManager.default.contentsOfDirectory(atPath: audioFolderURL.path) as [String]
            folderList = folderList.sorted { $0.localizedStandardCompare($1) == ComparisonResult.orderedAscending }
            print (folderList);
        } catch let error {
            print("Error loading audio files: \(error.localizedDescription)")
        }
        
        
        // each folder is one question; update the question label
        // to show the correct number of questions
        totalQuestions = folderList.count
        updateQuestionLabel()
        
        // randomly generate correct answers
        randomiseCorrectAnswers()
        
        // start the test
        updateQuestion()

        
        super.viewDidLoad()
    }
    
    
    
    
    
    
    @IBAction func playReferenceSound(_ sender: Any) {
        if !playerReference.isPlaying {
            playerReference.start()
        }
    }

    @IBAction func stopReferenceSound(_ sender: Any) {
        if playerReference.isPlaying {
            playerReference.stop()
        }
    }
    
    @IBAction func playSoundA(_ sender: UIButton) {
        
        if !playerA.isPlaying {
            //sender.setTitle("Stop", for: .normal)
            playerA.start()
        }
    }
    
    @IBAction func stopSoundA(_ sender: UIButton) {
        
        if playerA.isPlaying {
            //sender.setTitle("Play", for: .normal)
            playerA.stop()
        }
    }
    
    @IBAction func playSoundB(_ sender: UIButton) {
        
        if !playerB.isPlaying {
            //sender.setTitle("Stop", for: .normal)
            playerB.start()
        }
    }
    
    @IBAction func stopSoundB(_ sender: UIButton) {
        
        if playerB.isPlaying {
            //sender.setTitle("Play", for: .normal)
            playerB.stop()
        }
    }
    
    func updateQuestionLabel(){
        questionNumberLabel.text = String(currentQuestion) + " / " + String(totalQuestions)
        
        // show results at the end
        if(currentQuestion == totalQuestions + 1){
            questionNumberLabel.text = "results";
        }
        
    }
    
    
    
    func recordAnswer() {
        if (currentQuestion <= totalQuestions){
            userAnswers[currentQuestion - 1] = indexToAnswerChoice(idx: segmentedControl.selectedSegmentIndex)
        }
    }
    
    
    func loadAnswer() {
        if (currentQuestion <= totalQuestions){
            segmentedControl.selectedSegmentIndex = segmentedControlIndex(ac: userAnswers[currentQuestion - 1]);
        }
    }
    
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        
        // record the answer to the current question
        recordAnswer()
        
        // increment the question number
        currentQuestion += 1
        
        // wrap back to the beginning when we reach the end
        if(currentQuestion > totalQuestions + 1){
            currentQuestion = 1
        }
        
        // show results when we reach the end
        resultsView.isHidden = !(currentQuestion == totalQuestions+1)
        copyButton.isHidden = resultsView.isHidden
        
        updateQuestion()
    }

    @IBAction func backButtonTouched(_ sender: Any) {
        
        // record the answer to the current question
        recordAnswer()
        
        // decrement the question number
        currentQuestion -= 1
        
        // wrap to the end if we are at the beginning
        if (currentQuestion < 1){
            currentQuestion = totalQuestions + 1
        }
        
        // hide results when we are not yet at the end
        resultsView.isHidden = !(currentQuestion == totalQuestions+1)
        copyButton.isHidden = resultsView.isHidden
        
        updateQuestion()
    }
    
    
    @IBAction func showAnswer(_ sender: Any) {
        if correctAnswers[currentQuestion-1] == answerChoice.A {
            AButton.backgroundColor = orangeColour
        } else {
            BButton.backgroundColor = orangeColour
        }
        
        questionDataLabel.alpha = 1.0
    }
    
    
    @IBAction func hideAnswer(_ sender: Any) {
        AButton.backgroundColor = blueColour
        BButton.backgroundColor = blueColour
        questionDataLabel.alpha = 0.0
    }
    
    
    @IBAction func copyResults(_ sender: Any) {
        updateResults(copy: true);
    }
    
    
}
