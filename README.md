# Personal Finance Tracker

A simple personal finance tracker app that allows users to log expenses and income, view their balance,
and categorize transactions.

## Environment
- Go to Flutter [original installation guide here] (https://flutter.dev/docs/get-started/install)
- Choose your OS and follow the installation guide
- Run `flutter doctor` and make sure you've installed all missing components
- [Set up an editor you like](https://flutter.dev/docs/get-started/editor). Android Studio is preferable choice.

## Technical Tools
- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)


## Architecture
### Architecture Diagram
```
┌───────────────────────────────────────────────────┐
│                      App                          │     
│      Intro point, Dependencies Managment          │
│       Concreate Services Implementation           │
│               (depends on all)                    │
│                                                   │
│    ┌─────────────────────────────────────────┐    │
│    │          Presentation Layer             │    │
│    │          UI<>Bloc<>Services             │    │ 
│    └─────────────────────────────────────────┘    │ 
│                       ↓                           │
│    ┌─────────────────────────────────────────┐    │
│    │              Core Layer                 │    │
│    │ Domain<>Entities<>Data<>Infrastructure  │    │
│    └─────────────────────────────────────────┘    │
│                                                   │
│               (Shared between all)                │
│    ┌─────────────────────────────────────────┐    │
│    │            Common Layer                 │    │
│    │       Utils, Constants, Extentions      │    │
│    └─────────────────────────────────────────┘    │
│                                                   │ 
└───────────────────────────────────────────────────┘
```

### Architecture Overview

This project is implemented using Layered Architecture, which separates the application into distinct layers with specific responsibilities.
It was chosen mainly due to its simplicity, ease of understanding and small project scope. Even though it is simple, it still provides a clear separation of concerns and promotes maintainability and testability.
The main layers are:

**App Layer:** `app` package.
- This layer serves as the entry point of the application. It initializes the necessary dependencies and sets up the application environment.
- May contain data and service-related classes implementations, that can be unique for each platform or app variant (controlled by dependency injection).
- This layer has dependencies on all other layers.

**Presentation Layer:** `presentation` **package.**
- This layer is responsible for the UI components and user interactions. It includes screens, Bloc, and UI state management.
- It contains of sub-packages like `screens`, `widgets`, and `theme`.
- This layer depends on the Data Layer and Common Layer.

**Core Layer:** `core` **package.**
- This layer has all other responsibilities, including data management, business logic and infrastructure interaction.
- It contains (or may be contained) of sub-packages like `entity`, `repository`, and `service`, `storage`, `api`, `interactors`.
- Even though it has a lot of responsibilities, it is using Dependency Inversion Principle to depend only on abstractions. So everything inside this layer, all its subpackages are decoupled, testable and reusable.

**Common Layer:** `common` **package.**
- This layer contains shared utilities, constants, and helper functions that are used across multiple layers of the application.
- It promotes code reusability and reduces duplication.

### Key Principles Followed

- UI knows about Bloc. Bloc do not know about UI, instead it works with States and Events only.
- Bloc knows about Interactors (if available), Entities, Repositories (Interfaces), Infrastructure Services (Interfaces).
- Interactors knows about Repositories(Interfaces), Infrastructure Services (Interfaces), Entities.
- Repositories knows about Data Sources (preferably Interfaces), Entities.

### Overview

## Trade-offs

This project was made in 4 hours. Due to the limited time, some trade-offs were made:
- UI was made mainly with AI assistance to speed up the process;
- Because of this, there may be hardcoded values in the UI layer, which is not a good practice;
- Even though I've added Localization support, not all strings are localized, and localization was not tested with multiple languages;
- Tests were not written due to time constraints;
- Screen states was implemented with error handling in mind, but not all cases were covered, and not all of them were properly tested;
- Navigation was implemented in a simple way, without using any advanced techniques or libraries;
- Could miss to clean up some mocked implementations or unused code parts.

### What you would improve with more time

- Better testing with multiple devices and screen sizes, screen rotations and error cases;
- Write tests for all layers, especially for Bloc;
- Review all UI Code, move all hardcoded values to constants or theme. Move similar widgets to separate files;
- Improve error handling and screen states coverage;
- Improve performance by optimizing database queries and data loading, I've used Hive for simplicity, but for larger datasets, a more robust solution like SQLite would be better;
- Add category management (add, edit, delete categories), at the moment they are just text labels;
- Could think of adding some pincode/biometric authentication for better security. Basing on this, database could be encrypted as well.
- For a full offline solution - backup option would be a nice addition, to prevent data loss in case of device failure.
- Filtering option could be improved, date filter reset added, showing selected filters in the UI above the list (at the moment user must open filter pop up again to check what is selected, its bas UX - easy to miss). Chart cold have a filter by period too.
- Overall UI/UX and code schemas could be reviewed and improved.


### Estimated time spent on the task

_(Out of scope)_ 
Preparation and planning - couple of hours.
As I did not use Flutter for a while - I've spent some time thinking about the architecture and tools to use, as well as planning the features and UI.
Then updating Flutter and Dart SDK to the latest versions, setting up the new project structure and dependencies.

Development +- 4 hours:
1. Setting up the project structure, architecture skeleton, localisation and some of dependencies - 1 hour.
2. Implementing main UI screens, navigation, DI and mocked data layer. Testing UI/UX - 1.5 hour.
3. Implementing data store layer with Hive database, preferences, repositories. - 1 hour.
4. Final testing, bug fixing and code cleanup - 0.5 hour.

### AI Tools Used

- GitHub Copilot - used for code suggestions and completions.
- Claude - used for brainstorming, code snippets, and problem-solving.
- ChatGPT - for small code snippets and explanations.
