//
//  testResearch.swift
//  Login
//
//  Created by Kimberly Townsend on 9/18/22.
//

import SwiftUI

struct testResearch: View {
    var body: some View {
        VStack{
            
            let myStep = ORKInstructionStep(identifier: "intro")
            myStep.title = "Welcome to ResearchKit"
            
            let task = ORKOrderedTask(identifier: "task", steps: [myStep])
            
            //create a task view controller
            let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
            taskViewController.delegate = self
            present(taskViewController, animated: true, completion: nil)
            
            func taskViewController(_ taskViewController: ORKTaskViewController,
                            didFinishWith reason: ORKTaskViewControllerFinishReason,
                                                error: Error?) {
                let taskResult = taskViewController.result
                // You could do something with the result here.

                // Then, dismiss the task view controller.
                dismiss(animated: true, completion: nil)
            }
            
        }
    }
}

struct testResearch_Previews: PreviewProvider {
    static var previews: some View {
        testResearch()
    }
}
