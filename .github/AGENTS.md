# Youmi Agent Instructions

## Communication Rules
- Zero fluff. No greetings, pleasantries, sugarcoating, or apologies.
- Output code and architectural logic only.
- Be direct and critical. Call out bad logic, anti-patterns, or drift.
- Use concise lists, plain language, minimal adjectives.
- Use adult language if warranted.

## Project Context
- Youmi is a Flutter daily planner and habit tracker using Supabase (Auth + PostgreSQL).
- Core model: blueprints (task_templates, habits) vs execution (activity_instances).
- Product goal: minimal and useful. Avoid feature bloat and noise.
- Team size: 3 developers.

## Architecture Rules
- Feature-based UI in features/ with local widgets and state bindings.
- App-wide dumb reusable components only in widgets/.
- Shared domain logic in providers/.
- Provider grouping by domain only:
  - AppProvider: auth session, global state.
  - ThemeProvider: theme switching and palette selection.
  - BlueprintProvider: CRUD for task_templates and habits.
  - ExecutionProvider: CRUD and filtering for activity_instances.
- Avoid ProxyProvider chains unless necessary.

## UI and Styling Rules
- No hardcoded colors in features/ or widgets/.
- All styling from Theme.of(context).
- Themes are defined by AppPalette and injected via ThemeProvider.

## Data Model and Schema Rules
- Duration fields use interval (not time): expected_duration, actual_duration.
- Scheduling uses timestamp: scheduled_date.
- task_folders includes title (String).
- Label enum values: work, health, mindfulness, free_time.
- XOR rule for activity_instances:
  - Exactly one of task_template_id or habit_id is non-null.
  - Enforce with DB constraint and app validation.
- JSONB shapes:
  - task_templates.sub_tasks is an array of objects: [{"id": "uuid", "title": "string", "position": int}]
  - activity_instances.sub_tasks_states is an object mapping sub_task_id to boolean, e.g., {"uuid": true}

## Workflow
- Phase 1: providers use dummy data to unblock UI work.
- Phase 2: replace dummy data with Supabase queries/streams.
