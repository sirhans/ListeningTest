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
    var folderList: NSArray!
    var totalQuestions = 0
    var currentQuestion = 1
    var correctAnswers = [Int]()
    var userAnswers = [Int]()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    

    @IBOutlet weak var questionNumberLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func randomiseCorrectAnswers() {
        correctAnswers.removeAll()
        for i in 1...totalQuestions {
            correctAnswers.append(Int(arc4random_uniform(1)))
        }
    }
    
    
    func updateQuestion(){
        // update the label text at the top of the screen
        updateQuestionLabel()
        
        AudioKit.stop()
//        if mixer.isStarted {
  //          mixer.disconnect()
        //    playerReference.disconnect()
        //    playerA.disconnect()
        //    playerB.disconnect()
        //}
        
        let questionFolderURL = URL(fileURLWithPath: folderList.object(at: currentQuestion-1) as! String, relativeTo: audioFolderURL)
        let referenceAudioURL = URL(fileURLWithPath: "reference.wav", relativeTo: questionFolderURL)
        let whiteAudioURL = URL(fileURLWithPath: "white.wav", relativeTo: questionFolderURL)
        let filteredAudioURL = URL(fileURLWithPath: "filtered.wav", relativeTo: questionFolderURL)
        
        do {
            // load the reference audio file
            let referenceAudioFile = try AKAudioFile(forReading: referenceAudioURL)
            playerReference = try AKAudioPlayer(file: referenceAudioFile)
            
            let audioFileA: AKAudioFile!
            let audioFileB: AKAudioFile!
            
            // switch the order of samples A and B according to the random
            // selection determined at the start of the test
            if (correctAnswers[currentQuestion-1] == 0) {
                audioFileA = try AKAudioFile(forReading: whiteAudioURL)
                audioFileB = try AKAudioFile(forReading: filteredAudioURL)
            } else {
                audioFileB = try AKAudioFile(forReading: whiteAudioURL)
                audioFileA = try AKAudioFile(forReading: filteredAudioURL)
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
    
    
    override func viewDidLoad() {
        
        let font = UIFont.systemFont(ofSize: 20)
    segmentedControl.setTitleTextAttributes([NSFontAttributeName: font],for: .normal)
    
        
        
        
        // get the list of subfolders in the audio folder
        audioFolderURL = URL(fileURLWithPath: "audio", relativeTo: Bundle.main.bundleURL)
        
        do {
            folderList = try FileManager.default.contentsOfDirectory(atPath: audioFolderURL.path) as NSArray
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
        
        // disbale back at the beginning
        backButton.isEnabled = (currentQuestion != 1)
        
        // disable next at the end
        nextButton.isEnabled = (currentQuestion != totalQuestions)
    }
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        if(currentQuestion < totalQuestions) {
            currentQuestion += 1
        }
        updateQuestion()
    }

    @IBAction func backButtonTouched(_ sender: Any) {
        if(currentQuestion > 1) {
            currentQuestion -= 1
        }
        updateQuestion()
    }
    
    
}
