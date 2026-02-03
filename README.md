# Personal Finance Tracker

Build a simple personal finance tracker app that allows users to log expenses and income, view their balance,
and categorize transactions. Made in 3-4 hours.

## Environment
- Go to Flutter [original installation guide here] (https://flutter.dev/docs/get-started/install)
- Choose your OS and follow the installation guide
- Run `flutter doctor` and make sure you've installed all missing components
- [Set up an editor you like](https://flutter.dev/docs/get-started/editor). Android Studio is preferable choice.

## Technical Tools
- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)


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
│    │          UI<>BLOCs<>Services            │    │ 
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

This project is implemented using Layered Architecture, which separates the application into distinct layers with specific responsibilities. The main layers are:

**App Layer:** `app` package.
- This layer serves as the entry point of the application. It initializes the necessary dependencies and sets up the application environment.
- May contain data and service-related classes implementations, that can be unique for each platform or app variant (controlled by dependency injection).
- This layer has dependencies on all other layers.

**Presentation Layer:** `presentation` **package.**
- This layer is responsible for the UI components and user interactions. It includes screens, BLOCs, and UI state management.
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

- UI knows about BLOCs. BLOCs does not know about UI, instead it works with States and Events only.
- BLOCs knows about Interactors (if available), Entities, Repositories (Interfaces), Infrastructure Services (Interfaces).
- Interactors knows about Repositories(Interfaces), Infrastructure Services (Interfaces), Entities.
- Repositories knows about Data Sources (Interfaces), Entities.