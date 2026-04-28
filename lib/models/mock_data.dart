import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';
import 'package:youmi_dev/models/user.dart';

class MockData {
  static final users = <AppUser>[
    const AppUser(
      id: '11111111-1111-1111-1111-111111111111',
      email: 'alex@youmi.dev',
      themePref: 'gruvbox',
    ),
  ];

  static final taskFolders = <TaskFolder>[
    TaskFolder(
      id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      userId: users[0].id,
      title: 'Work',
    ),
    TaskFolder(
      id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      userId: users[0].id,
      title: 'Personal',
    ),
  ];

  static final taskTemplates = <TaskTemplate>[
    TaskTemplate(
      id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      userId: users[0].id,
      title: 'Deep Work Block',
      label: TaskLabel.work,
      expectedDuration: const Duration(hours: 1, minutes: 30),
      subTasks: const [
        SubTask(
          id: 'st-001',
          title: 'Define outcome',
          position: 0,
        ),
        SubTask(
          id: 'st-002',
          title: 'Focus sprint',
          position: 1,
        ),
      ],
      taskFolderId: taskFolders[0].id,
    ),
    TaskTemplate(
      id: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
      userId: users[0].id,
      title: 'Gym Session',
      label: TaskLabel.health,
      expectedDuration: const Duration(hours: 1),
      subTasks: const [
        SubTask(
          id: 'st-003',
          title: 'Warm up',
          position: 0,
        ),
        SubTask(
          id: 'st-004',
          title: 'Main lifts',
          position: 1,
        ),
      ],
      taskFolderId: taskFolders[1].id,
    ),
    TaskTemplate(
      id: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
      userId: users[0].id,
      title: 'Read Fiction',
      label: TaskLabel.freeTime,
      expectedDuration: const Duration(minutes: 40),
      subTasks: const [
        SubTask(
          id: 'st-005',
          title: 'Pick chapter',
          position: 0,
        ),
      ],
      taskFolderId: taskFolders[1].id,
    ),
  ];

  static final habits = <Habit>[
    Habit(
      id: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
      userId: users[0].id,
      title: 'Hydrate',
      label: TaskLabel.health,
      recurrenceMask: 01111100,
      currentStreak: 6,
    ),
    Habit(
      id: '99999999-9999-9999-9999-999999999999',
      userId: users[0].id,
      title: 'Meditate',
      label: TaskLabel.mindfulness,
      recurrenceMask: 1111111,
      currentStreak: 12,
    ),
  ];

  static final activityInstances = <ActivityInstance>[
    ActivityInstance(
      id: 'aaaa1111-2222-3333-4444-555555555555',
      userId: users[0].id,
      taskTemplateId: taskTemplates[0].id,
      scheduledDate: DateTime(2026, 4, 28, 9, 0),
      status: ActivityStatus.pending,
      subTaskStates: {
        taskTemplates[0].subTasks[0].id: false,
        taskTemplates[0].subTasks[1].id: false,
      },
    ),
    ActivityInstance(
      id: 'bbbb1111-2222-3333-4444-666666666666',
      userId: users[0].id,
      habitId: habits[0].id,
      scheduledDate: DateTime(2026, 4, 28, 7, 30),
      status: ActivityStatus.success,
      actualDuration: const Duration(minutes: 8),
      note: 'Morning water.',
    ),
    ActivityInstance(
      id: 'cccc1111-2222-3333-4444-777777777777',
      userId: users[0].id,
      taskTemplateId: taskTemplates[1].id,
      scheduledDate: DateTime(2026, 4, 28, 18, 0),
      status: ActivityStatus.missed,
      subTaskStates: {
        taskTemplates[1].subTasks[0].id: true,
        taskTemplates[1].subTasks[1].id: false,
      },
      note: 'Time got eaten by meetings.',
    ),
  ];
}
