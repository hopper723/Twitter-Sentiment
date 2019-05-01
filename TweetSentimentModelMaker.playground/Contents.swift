import Cocoa
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/hopper723/Desktop/twitter-sanders-apple3.csv"))

let (training_data, testing_data) = data.randomSplit(by: 0.8, seed: 506)

let sentimentClassifier = try MLTextClassifier(trainingData: training_data, textColumn: "text", labelColumn: "class")

let evaluationMetrics = sentimentClassifier.evaluation(on: testing_data)

let evaluationAccuracy = 1.0 - evaluationMetrics.classificationError

let metadata = MLModelMetadata(author: "Hiu Man Yeung", shortDescription: "A model to classify Tweets sentiment", version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/hopper723/Desktop/TweetSentimentClassifier.mlmodel"))
