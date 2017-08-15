//
//  ViewController.swift
//  Haiku4u
//
//  Created by Tom Power on 15/08/2017.
//  Copyright © 2017 MOBGEN:Lab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    //    @IBOutlet weak var textView4: UITextView!
    //    @IBOutlet weak var textView5: UITextView!
    //
    //    @IBOutlet weak var label1: UILabel!
    //    @IBOutlet weak var label2: UILabel!
    //    @IBOutlet weak var label3: UILabel!
    //    @IBOutlet weak var label4: UILabel!
    //    @IBOutlet weak var label5: UILabel!
    
    @IBOutlet weak var textInput: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var poet: Poet?
    var charCount = 0
    var timer: Timer!
    var timer2: Timer!
    var seedIndex = 0
    var prevCharCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = "haiku29"

        guard let path = Bundle.main.path(forResource: model, ofType: "h5") else {
            fatalError("Weigths file not found")
        }
        poet = Poet(pathToTrainedWeights: path, chars: appDelegate.chars)
        
        
        startStopButton.layer.cornerRadius = 10.0
        startStopButton.layer.borderWidth = 1.0

        
        
        
        
        #if arch(i386) || arch(x86_64)
            preconditionFailure("This app will not function on the iOS Simulator because of Metal-dependent functionality.")
        #endif
    }
    
    @IBAction func tappedStartStopButton(_ sender: AnyObject?) {
        if poet?.isEvaluating ?? false {
            stop()
        } else {
            start()
        }
    }
    
       func start() {
        guard let poet = poet else {
            return
        }

        disableControls()
        startStopButton.setTitle("Stop", for: .normal)

        if !poet.isPrepared {
            prepare {
                self.start()
            }
            return
        }

        var buffer: String = ""
        var count = 0

        textView.text = textInput.text
        poet.temperature = 0.2
        poet.startEvaluating(textInput.text!) { string in
            buffer = buffer + string
            count += 1
            self.charCount = self.textView.text.characters.count
            print(self.charCount)
            if (self.charCount > 200) {
                self.charCount = 0
                
                self.stop()
                return
            }
            
            if count > 5 {
                let bufferCopy = buffer
                DispatchQueue.main.async() {
                    self.textView.text = self.textView.text + bufferCopy
                }

                count = 0
                buffer = ""
            }
        }
    }

    func prepare(completion: @escaping () -> Void) {
        textView.text = "Loading..."
        startStopButton.isEnabled = false
        poet?.prepareToEvaluate { prepared in
            DispatchQueue.main.async() {
                self.startStopButton.isEnabled = true
                if prepared {
                    completion()
                } else {
                    self.textView.text = nil
                }
            }
        }
    }

    func stop() {
        poet?.stopEvaluating()
        enableControls()
        startStopButton.setTitle("Start", for: .normal)
    }


    func disableControls() {
        startStopButton.isEnabled = false
    }
    
    func enableControls() {
        startStopButton.isEnabled = true
    }
}

