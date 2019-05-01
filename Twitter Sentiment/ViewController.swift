//
//  ViewController.swift
//  Twitter Sentiment
//
//  Created by Hiu Man Yeung on 4/30/19.
//  Copyright © 2019 Hiu Man Yeung. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    var swifter: Swifter?
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.placeholder = "How do people feel about..."
        
        guard let (Consumer_API_Key,Consumer_API_Secret_Key) = getAPI() else {
            fatalError("No twitter API")
        }

        swifter = Swifter(consumerKey: Consumer_API_Key, consumerSecret: Consumer_API_Secret_Key)
    }

    @IBAction func predictPressed(_ sender: Any) {
        swifter!.searchTweet(using: inputTextField.text!, lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
            
            var tweets = [TweetSentimentClassifierInput]()
            
            for i in 0..<100 {
                if let tweet = results[i]["full_text"].string {
                    let classifierInput = TweetSentimentClassifierInput(text: tweet)
                    tweets.append(classifierInput)
                }
            }
            
            do {
                let classifierOutput = try self.sentimentClassifier.predictions(inputs: tweets)
                
                var sentiScore = 0
                
                for prediction in classifierOutput {
                    switch (prediction.label) {
                    case "Pos":
                        sentiScore += 1
                    case "Neg":
                        sentiScore -= 1
                    default:
                        break
                    }
                }
                
                if sentiScore > 20 {
                    self.sentimentLabel.text = "😍"
                } else if sentiScore > 10 {
                    self.sentimentLabel.text = "😀"
                } else if sentiScore > 0 {
                    self.sentimentLabel.text = "🙂"
                } else if sentiScore == 0 {
                    self.sentimentLabel.text = "😐"
                } else if sentiScore > -10 {
                    self.sentimentLabel.text = "😕"
                } else if sentiScore > -20 {
                    self.sentimentLabel.text = "😟"
                } else  {
                    self.sentimentLabel.text = "🤬"
                }
                
            } catch {
                print("Error with prediction: \(error)")
            }
            
        }) { (error) in
            print("Error with API request: \(error)")
        }
    }
    
    func getAPI() -> (String, String)?
    {
        if  let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            let TwitterAPI = (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String: String]
            
            if let Consumer_API_Key = TwitterAPI?["Consumer_API_Key"], let Consumer_API_Secret_Key = TwitterAPI?["Consumer_API_Secret_Key"] {
                return (Consumer_API_Key, Consumer_API_Secret_Key)
            }
            
        }
        
        return nil
    }
}

