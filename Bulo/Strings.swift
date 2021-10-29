//
//  Strings.swift
//  Bulo
//
//  Created by Jake King on 29/10/2021.
//

import SwiftUI

extension Text {
    init(_ localizedString: Strings) {
        self.init(localizedString.rawValue)
    }
}

enum Strings: LocalizedStringKey {
    // GENERAL
    case okCallToAction
    case deleteCallToAction
    
    // TABS
    case homeTab
    case openTab
    case closedTab
    case awardsTab
    
    // HOME VIEW
    case upNextSectionHeader
    case moreToExploreSectionHeader
    case landscapePlaceholder
//    case projectSummaryVoiceOverLabel
    
    // PROJECTS VIEW
    case openProjects
    case closedProjects
//    case newProject // needs to be a String
//    case newItem // needs to be a String
    case noProjectsPlaceholder
    case addProject
    case addItem
//    case completedVoiceOverLabel // not sure how to do string interpolation yet
//    case priorityVoiceOverLabel // not sure how to do string interpolation yet
    
    // PROJECT ITEM SORTING
    case sortItemsTitle
    case sortItemsMessage
    case sortOrderOptimised
    case sortOrderDateCreated
    case sortOrderAlphabetical
    
    // EDITING A PROJECT
    case editProject
    case basicSettingsSectionHeader
    case projectName
    case projectDescription
    case projectColorSectionHeader
    case closeProject
    case reopenProject
    case deleteProject
    case warningFooter
    case deleteProjectAlertTitle
    case deleteProjectAlertMessage
    
    // EDITING AN ITEM
    case editItem
    case itemName
    case itemDescription
    case itemPriority
    case itemPriorityHigh
    case itemPriorityMedium
    case itemPriorityLow
    case markCompletedToggleLabel
    
    // AWARDS VIEW
    case lockedAlertTitle
//    case unlockedAlertTitle // how to do with string interpolation?
    
    var localized: LocalizedStringKey {
        self.rawValue
    }
}
