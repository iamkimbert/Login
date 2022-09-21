//
//  CareFeedViewController.swift
//  Login
//
//  Created by Kimberly Townsend on 9/18/22.
//

import CareKit
import CareKitStore
import CareKitUI
import ResearchKit
import UIKit
import os.log

final class CareFeedViewController: OCKDailyPageViewController,
                                    OCKSurveyTaskViewControllerDelegate {
    
    override func dailyPageViewController(
        _ dailyPageViewController: OCKDailyPageViewController,
        prepare listViewController: OCKListViewController,
        for date: Date) {
            
        //Check if onboarding is complete.
        checkIfOnboardingIsComplete{ isOnboarded in}
            
            //1.4 If isn't, show all onboarding cards.
            guard isOnboarded else {
                
                let onboardCard = OCKSurveyTaskViewController(
                    taskID: TaskIDs.onboarding,
                    eventQuery: OCKEventQuery(for: date),
                    storeManager: self.storeManager,
                    survey: Survey.onboardingSurvey(),
                    extractOutcome: {_ in [OCKOutcomeValue(Date())] }
                    
                )
                
                onboardCard.surveyDelegate = self
                
                listViewController.appendViewController(
                    onboardCard,
                    animated: false
                )
                
                return
            }
            
            // 1.5 If it is, show all the other cards.
            let isFuture = Calender.current.compare(
                date,
                to: Date(),
                toGranularity: .day) == .orderedDescending
            
            self.fetchTasks(on: date) { tasks in
                tasks.compactMap {
                    
                    let card = self.taskViewController(for: $0, on: date)
                    card?.view.isUserInteractionEnabled = !isFuture
                    card?.view.alpha = isFuture ? 0.4 : 1.0
                    
                    return card
                }.forEach {
                    listViewController.appendViewController($0, animated: false)
                }
            }
        }
    }
//1.2 Define a method that checks if onboarding is complete
    private func checkIfOnboardingIsComplete(_ completion: @escaping (Bool)-> Void) {
    
        var query = OCKOutcomeQuery()
        query.taskIDs = [TaskIDs.onboarding]
    
        storeManager.store.fetchAnyOutcomes(
            query: query,
            callbackQueue: .main) { result in
            
            switch result {
                
            case .failure:
                Logger.feed.error("Failed to fetch onboarding outcomes!")
                completion(false)
                
            case let .success(outcomes):
                completion(!outcomes.isEmpty)
            }
                
        }
        
    }
                
    private func fetchTasks(
        on date: Date,
        completion: @escaping([OCKAnyTask]) -> Void) {
            var query = OCKTaskQuery(for: date)
            query.excludesTasksWithNoEvents = true
            
            storeManager.store.fetchAnyTasks(
                query: query,
                callbackQueue: .main) { result in
            
            switch result {
                
            case .failure:
                Logger.feed.error("Failed to fetch tasks for date \(date)")
                completion([])
            
            case let .success(tasks):
                completion(tasks)
            }
        }
    }

    private func taskViewController(
        for task: OCKAnyTask,
        on date: Date) -> UIViewController? {
            
            switch task.id {
                
            case TaskIDs.checkIn:
                
                let survey = OCKSurveyTaskViewController(
                    task: task,
                    eventQuery: OCKEventQuery(for: date),
                    storeManager: storeManager,
                    viewSynchronizer: SurveyViewSynchronizer(),
                    extractOutcome: Surveys.extractAnswersFromCheckInSurvey
                )
                survey.surveyDelegate = self
    
                return survey
                
            case TaskIDs.rangeOfMotionCheck:
                let survey = OCKSurveyTaskViewController(
                    task: task,
                    eventQuery: OCKEventQuery(for: date),
                    storeManager: storeManager,
                    survey: Surveys.rangeOfMotionCheck(),
                    extractOutcome: Surveys.extractRangeOfMotionOutcome
                )
                survey.surveyDelegate = self
                
               return survey
                
            default:
                return nil
        }
    }
                
    func surveyTask(
        viewControlller: OCKSurveyTaskViewController,
        for task: OCKAnyTask,
        didFinish result: Result<ORKTaskViewControllwerFinishReason, Error>){
        
        if case let .success(reason) = result, reason == .completed {
            relode()
        }
    }

    // 1.6 Refresh the content when onboarding completes
    func surveyTask(
        viewController: OCKSurveyTaskViewController,
        shouldAllowDeletingOutcomeForEvent event: OCKAnyEvent) -> Bool {
        
        event.scheduleEvent.start >= Calender.current.startOfDay(for: Date())
    }
}

final class SurveyViewSynchronizer: OCKSurveyTaskViewSynchronizer {
    
    override func updateView(
        _ view: OCKInstructionsTaskView,
        context: OCKSynchronizationContext<OCKTaskEvents>) {
            
        super.updateView(view, context: context)
            
        if let event = context.viewModel.first?.first, event.outcome != nil {
            view.instructionsLabel.isHidden = false
                
            let pain = event.answewr(kind: Surveys.checkInPainItemIdentifier)
            let sleep = event.answer(kind: Surverys.checkInSleepItemIdentifier)
                
            view.instructionsLabel.text = """
                Pain: \(Int(pain))
                Sleep: \(Int(sleep)) hours
                """
        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}

