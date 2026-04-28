# Product Requirements Document (PRD): Habit & Day Planner

## Table of Contents

- [Product Requirements Document (PRD): Habit \& Day Planner](#product-requirements-document-prd-habit--day-planner)
  - [Table of Contents](#table-of-contents)
  - [1. Doc Overview](#1-doc-overview)
  - [2. Technical Stack \& Architecture](#2-technical-stack--architecture)
  - [3. Folder Structure](#3-folder-structure)
  - [4. Theme Implementation Strategy](#4-theme-implementation-strategy)
    - [4.1 Architecture Components](#41-architecture-components)
      - [Palette Interface (style/palettes.dart)](#palette-interface-stylepalettesdart)
      - [Concrete Palettes](#concrete-palettes)
      - [Theme Factory (style/theme\_factory.dart)](#theme-factory-styletheme_factorydart)
      - [Theme Provider (providers/theme\_provider.dart)](#theme-provider-providerstheme_providerdart)
    - [4.2 Implementation Rules](#42-implementation-rules)
  - [5. Collaboration \& Workflow](#5-collaboration--workflow)
  - [6. Database Schema (Entities)](#6-database-schema-entities)
    - [users](#users)
    - [task\_folders](#task_folders)
    - [task\_templates](#task_templates)
    - [habits](#habits)
    - [activity\_instances](#activity_instances)
  - [7. Core Views (Feature Scope)](#7-core-views-feature-scope)
    - [7.1 Auth Page](#71-auth-page)
    - [7.2 Dashboard (Execution View)](#72-dashboard-execution-view)
    - [7.3 Planner / Calendar](#73-planner--calendar)
    - [7.4 Library (Template \& Habit Editor)](#74-library-template--habit-editor)
    - [7.5 Analytics](#75-analytics)
    - [7.6 Settings \& Profile](#76-settings--profile)
  - [Future](#future)

## 1. Doc Overview

This document outlines the architecture, database schema, and feature scope for a Flutter-based daily planner and habit tracker. The system functions as a streamlined execution and planning tool, decoupling the definition of tasks/habits from their scheduled occurrences. This allows for quick adding, template reuse, and accurate execution tracking.

## 2. Technical Stack & Architecture

- Frontend: Flutter
- Backend: Supabase (Auth, PostgreSQL DB)
- State Management: Provider
- Architecture Pattern: Feature-based folder structure (MVVM-adjacent). No page-specific MVC controllers. Shared Providers handle domain logic.
- Styling Strategy: Data-driven Custom Theme Factory. Strict prohibition on hardcoded hex colors in UI files. All views must derive styling from Theme.of(context).

## 3. Folder Structure

The project uses a feature-based structure rather than a strictly layered architecture (like traditional MVC). This isolates feature-specific UI from shared domain logic, minimizing merge conflicts for multiple developers.

```text
lib/
├── core/
│   ├── constants/          # App-wide static values (e.g., API keys, route names)
│   └── utils/              # Helper functions (e.g., date formatters, validators)
├── models/
│   ├── habit.dart          # Shared data structures mapping to Supabase tables
│   └── task_template.dart
├── providers/
│   ├── app_provider.dart        # Global state, Supabase auth session
│   ├── blueprint_provider.dart  # CRUD for task_templates and habits (Library)
│   ├── execution_provider.dart  # CRUD and filtering for activity_instances (Dashboard/Planner)
│   └── theme_provider.dart      # The theme switcher logic
├── style/
│   ├── palettes.dart       # Theme definitions (Nordic, Gruvbox, etc.)
│   └── theme_factory.dart  # Logic converting a palette to ThemeData
├── features/               # Member-specific workspaces
│   ├── auth/               # UI and local logic for login/signup
│   ├── dashboard/          # UI and local widgets for the execution view
│   ├── planner/            # UI for calendar and scheduling
│   ├── library/            # UI for task and habit blueprint editing
│   ├── analytics/          # UI and local widgets for charts and logs
│   └── settings/           # UI for profile and theme switching
├── widgets/                # Reusable widgets; only put stuff here when reused
└── main.dart               # App entry point and top-level Provider scope setup
```

## 4. Theme Implementation Strategy

To achieve modular, swappable themes (e.g., Dark, Light, Gruvbox, Nordic) without hardcoding values in UI files, the styling system relies on an interface-driven factory pattern.

### 4.1 Architecture Components

#### Palette Interface (style/palettes.dart)

An abstract class that forces every theme to implement identical color properties.

```dart
abstract class AppPalette {
  Color get background;
  Color get surface;
  Color get primary;
  Color get text;
}
```

#### Concrete Palettes

Classes implementing AppPalette with specific hex codes (e.g., `GruvboxPalette`).

#### Theme Factory (style/theme_factory.dart)

A single function that accepts an AppPalette and returns a complete Flutter ThemeData object. This ensures button shapes, font weights, and spacing remain identical regardless of active color scheme.

#### Theme Provider (providers/theme_provider.dart)

A ChangeNotifier that holds the currently active AppPalette. When a user selects a new theme in settings, this provider updates the palette and calls notifyListeners(), triggering a global UI rebuild.

### 4.2 Implementation Rules

- Strict UI Compliance: Developers must never use hardcoded colors (`Colors.red`, `Color(0xFF...)`) in `features/` or `widgets/` directories.
- Context Retrieval: All styling must be retrieved via context, e.g., `Theme.of(context).colorScheme.primary` or `Theme.of(context).textTheme.bodyLarge`.
- Adding Themes: To add a new theme, a developer only needs to create a new AppPalette implementation and add it to the ThemeProvider selection list. UI files remain untouched.

## 5. Collaboration & Workflow

- Work Distribution: Feature ownership. Each of the 3 members owns specific pages end-to-end (UI, widgets, and Provider logic integration) within `features/`.
- Git Strategy: Branch per feature (e.g., `feature/dashboard`, `feature/analytics`).
- Phase 1 Execution: All Providers must be initialized with dummy data lists. UI development must not block on Supabase integration.
- Phase 2 Execution: Swap dummy lists in Providers with `supabase.from().select()` streams.

## 6. Database Schema (Entities)

The data model separates blueprints (templates/habits) from instances (activity instances) to prevent data duplication and enable historical analytics.

### users

| Column | Type | Description |
| --- | --- | --- |
| id | UUID | Primary key, linked to Supabase Auth |
| email | String | User contact/login |
| theme_pref | String | e.g., `gruvbox`, `nordic` |

### task_folders

| Column | Type | Description |
| --- | --- | --- |
| id | UUID | Primary key |
| user_id | UUID | Foreign key -> users.id |
| title | String | Display name for grouping templates |

### task_templates

| Column | Type | Description |
| --- | --- | --- |
| id | UUID | Primary key |
| user_id | UUID | Foreign key -> users.id |
| title | String | Name of the reusable task |
| label | Enum | Enforced category (`work`, `health`, `mindfulness`, `free_time`) |
| expected_duration | Interval | Expected completion time |
| sub_tasks | JSONB | Array of objects: [{"id": "uuid", "title": "string", "position": int}] |
| task_folder_id | UUID | Foreign key -> task_folders.id |

### habits

| Column | Type | Description |
| --- | --- | --- |
| id | UUID | Primary key |
| user_id | UUID | Foreign key -> users.id |
| title | String | Name of the habit |
| label | Enum | Enforced category (`work`, `health`, `mindfulness`, `free_time`) |
| recurrence_mask | Bitmask | Days of week bitmask (e.g., `0b01111100` for Mon-Fri) |
| current_streak | Int | Integer tracking consecutive completions |

### activity_instances

| Column | Type | Description |
| --- | --- | --- |
| id | UUID | Primary key |
| user_id | UUID | Foreign key -> users.id |
| task_template_id | UUID | Foreign key -> task_templates.id (nullable; XOR with habit_id via DB constraint) |
| habit_id | UUID | Foreign key -> habits.id (nullable; XOR with task_template_id via DB constraint) |
| scheduled_date | Timestamp | Timestamp the item is scheduled for |
| status | Enum | `success`, `missed`, `pending` |
| actual_duration | Interval | Actual time spent (populated on completion) |
| note | String | Localized execution diary/notes |
| sub_tasks_states | JSONB | Object mapping sub_task_id to boolean (e.g., {"uuid": true}) |

Constraint: Exactly one of `task_template_id` or `habit_id` must be non-null. Enforce with a DB constraint and app-level validation.

## 7. Core Views (Feature Scope)

The frontend is consolidated into 6 primary views.

### 7.1 Auth Page

**Use Case Description**

Entry point for user identification and session management. Connects local application state to Supabase Auth.

**Use Cases**

- User registers a new account using email and password.
- User logs into an existing account.
- User requests a password reset link.
- System intercepts valid session tokens and redirects authenticated users to Dashboard automatically.

### 7.2 Dashboard (Execution View)

**Use Case Description**

Primary operational interface, focused strictly on executing today's scheduled items with minimal friction. Modifications to blueprints (`task_templates` or `habits`) are restricted here.

**Use Cases**

- User views a chronological list of today's tasks and habits (`activity_instances`).
- User marks an entire item as completed.
- User toggles individual `sub_tasks` within a composite task.
- User inputs `actual_duration` and note upon marking a task completed.
- User defers an item (updates `scheduled_date` to tomorrow).
- User views a top-level daily progress metric (completion percentage).

### 7.3 Planner / Calendar

**Use Case Description**

Centralized scheduling interface used to convert blueprints into actionable instances by assigning them to specific dates and times.

**Use Cases**

- User toggles between daily, weekly, and monthly timeline views.
- User selects a `task_template` from a quick-add repository and plots it onto a specific calendar slot (creating an `activity_instance`).
- User adjusts the scheduled time block of an existing `activity_instance`.
- User removes an `activity_instance` from the schedule without deleting the source `task_template`.

### 7.4 Library (Template & Habit Editor)

**Use Case Description**

Management interface for reusable blueprints. Defines structural properties of tasks and habits before they enter scheduling.

**Use Cases**

- User creates, reads, updates, or deletes a `task_template` (title, label, expected duration, optional `sub_tasks`).
- User creates, reads, updates, or deletes a `habit` (title, label, recurrence bitmask).
- User creates and organizes `task_folders` for grouping templates.
- System automatically generates future `activity_instances` based on habit recurrence mask modifications.

### 7.5 Analytics

**Use Case Description**

Data visualization interface for reviewing historical execution data, assessing time estimation accuracy, and tracking consistency.

**Use Cases**

- User filters the execution log by date range or label to review completed tasks.
- User reads localized notes attached to past completed tasks.
- User views aggregated charts (bar/pie) displaying completion distributions by label.
- User views delta charts comparing average `expected_duration` against logged `actual_duration`.
- User tracks consecutive completion consistency via habit streaks.

### 7.6 Settings & Profile

**Use Case Description**

Configuration interface for user-specific preferences, visual customization, and account management.

**Use Cases**

- User views current profile details.
- User selects a new visual theme (e.g., Gruvbox, Nordic), triggering a global UI rebuild via ThemeProvider.
- User terminates the current session (log out).

## Future

- User triggers OAuth flow to sync with external calendar APIs.