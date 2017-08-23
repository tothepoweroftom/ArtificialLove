//
//  ViewController.swift
//  Haiku4u
//
//  Created by Tom Power on 15/08/2017.
//  Copyright © 2017 MOBGEN:Lab. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
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
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var titleText: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var poet: Poet?
    var charCount = 0
    var timer: Timer!
    var timer2: Timer!
    var seedIndex = 0
    var prevCharCount = 0
    var seedText = " "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = "haiku59"

        guard let path = Bundle.main.path(forResource: model, ofType: "h5") else {
            fatalError("Weights file not found")
        }
        poet = Poet(pathToTrainedWeights: path, chars: appDelegate.chars)
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: .UIKeyboardWillHide, object: nil)

        
        
        
        
        #if arch(i386) || arch(x86_64)
            preconditionFailure("This app will not function on the iOS Simulator because of Metal-dependent functionality.")
        #endif
    }
    
    func fadeViewIn(view: UIView) {
        let aniDur = 1.0
        view.alpha = 0.0
        view.isHidden = false
        
        UIView.animate(withDuration: aniDur, animations: {() -> Void in
            
            view.alpha = 1.0
            
        })
        
    }
    
    func fadeViewOut(view: UIView) {
        let aniDur = 1.0
        view.alpha = 0.0
        
        UIView.animate(withDuration: aniDur, animations: {() -> Void in
            
            view.alpha = 0.0
            
        })
        
        view.isHidden = true
        
        
    }
    
 
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        titleText.text = textInput.text
        
        guard let text = textInput.text else {
            //RAISE ALERT
            return
        }
        seedText = text
        
        fadeViewIn(view: titleText)
        fadeViewIn(view: startStopButton)
        fadeViewIn(view: textView)
        fadeViewIn(view: infoButton)
        fadeViewIn(view: refreshButton)
        fadeViewOut(view: questionLabel)
        fadeViewOut(view: textInput)

        view.endEditing(true)
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
        startStopButton.setTitle("STOP", for: .normal)

        if !poet.isPrepared {
            prepare {
                self.start()
            }
            return
        }

        var buffer: String = ""
        var count = 0

        textView.text = textInput.text?.lowercased()
        poet.temperature = 0.25
        poet.startEvaluating(seedText) { string in
            buffer = buffer + string
            count += 1
                
                if count > 5 {
                    let bufferCopy = buffer
                    DispatchQueue.main.async() {
                        self.textView.text = self.textView.text + bufferCopy
                        self.charCount = self.textView.text.characters.count
                        print(self.charCount)
                        if (self.charCount > 500) {
                            self.charCount = 0
                            
                            self.stop()
                            return
                        }
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
        startStopButton.setTitle("START", for: .normal)
    }


    func disableControls() {
        startStopButton.isEnabled = false
        refreshButton.isEnabled = false
    }
    
    func enableControls() {
        startStopButton.isEnabled = true
        refreshButton.isEnabled = true
    }
    
    @IBAction func refresh(_ sender: UIButton) {

        fadeViewOut(view: titleText)
        fadeViewOut(view: textView)
        fadeViewOut(view: startStopButton)

        fadeViewOut(view: infoButton)
        fadeViewOut(view: refreshButton)
        fadeViewIn(view: questionLabel)
        fadeViewIn(view: textInput)

    }
    
    @IBAction func infoPressed(_ sender: UIButton) {
        fadeViewOut(view: titleText)
        fadeViewOut(view: textView)
        fadeViewOut(view: infoButton)
        fadeViewOut(view: startStopButton)

        fadeViewOut(view: refreshButton)
        fadeViewIn(view: closeButton)
        fadeViewIn(view: infoText)
    }
    @IBAction func closeInfoPressed(_ sender: UIButton) {
        fadeViewIn(view: titleText)
        fadeViewIn(view: textView)
        fadeViewIn(view: infoButton)
        fadeViewIn(view: startStopButton)
        fadeViewIn(view: refreshButton)
        fadeViewOut(view: closeButton)
        fadeViewOut(view: infoText)
    }
    
}

