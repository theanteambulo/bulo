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

/// An enum to support safe localization of the app to multiple languages.
enum Strings: LocalizedStringKey {
    // GENERAL
    case okCallToAction
    case deleteCallToAction
    case dismissCallToAction

    // TABS
    case homeTab
    case openTab
    case closedTab
    case awardsTab

    // HOME VIEW
    case upNextSectionHeader
    case moreToExploreSectionHeader
    case landscapePlaceholder

    // PROJECTS VIEW
    case openProjects
    case closedProjects
    case noProjectsPlaceholder
    case addProject
    case addItem

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
    case projectRemindersSectionHeader
    case projectRemindersErrorTitle
    case projectRemindersErrorMessage
    case settingsButtonText
    case showReminders
    case reminderTime
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

    // UNLOCK PREMIUM
    case getUnlimitedProjectsTitle
    case getUnlimitedProjectsTerms
    case restoreUnlimitedProjects
    case buyButton
    case restoreButton
    case storeLoadingError
    case storeLoading
    case purchaseThankYouMessage
    case deferredPurchaseThankYouMessage

    // WIDGETS
    case widgetUpNext
    case widgetNoItems
    case widgetTopPrioritySingle
    case widgetTopPriorityMultiple

    // Without knowing how to extend other types of view beyond Text, such as Label, this computed property
    // was necessary to be able to reference the raw value of a case of the Strings enum as required.
    var localized: LocalizedStringKey {
        self.rawValue
    }
}
