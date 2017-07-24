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
    var totalQuestions = 10;
    var currentQuestion = 1;
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    

    @IBOutlet weak var questionNumberLabel: UILabel!
    
    
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    override func viewDidLoad() {
        
        let font = UIFont.systemFont(ofSize: 20)
    segmentedControl.setTitleTextAttributes([NSFontAttributeName: font],for: .normal)
    
        
        
        do {
            FileManager.default.changeCurrentDirectoryPath(Bundle.main.bundlePath)
            //print(FileManager.default.currentDirectoryPath)
            
            let audioFolderURL = URL(fileURLWithPath: "audio", relativeTo: Bundle.main.bundleURL)
            /*
            let audioFileURL = URL(fileURLWithPath: "test.wav", relativeTo: audioFilesFolderURL)
            
            let audioFile = try AKAudioFile(forReading: audioFileURL)
            
            playerA = try AKAudioPlayer(file: audioFile);
            playerB = try AKAudioPlayer(file: audioFile);
            playerReference = try AKAudioPlayer(file: audioFile);
            playerA.looping = true
            playerB.looping = true
            playerReference.looping = true
            */
            
            let folderList = try FileManager.default.contentsOfDirectory(atPath: audioFolderURL.path)
            
            for folderName in folderList {
                print(folderName)
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
//        do {
//            let fileURL =
//            file = try AKAudioFile(forReading: fileURL);
//            player = try AKAudioPlayer(file: file)
//        } catch {
//            AKLog("File Not Found")
//            return
//        }
       

        
        super.viewDidLoad()

        mixer = AKMixer(playerA, playerB, playerReference)
        AudioKit.output = mixer
        AudioKit.start()
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
    }
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        if(currentQuestion < totalQuestions) {
            currentQuestion += 1
        }
        updateQuestionLabel()
    }

    @IBAction func backButtonTouched(_ sender: Any) {
    }
    
    
}
