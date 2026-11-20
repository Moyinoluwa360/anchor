import 'dart:math';

import 'package:drift/drift.dart';

import '../models/dates.dart';
import '../models/enums.dart';
import 'database.dart';

/// Fills an empty database with realistic sample data so the app looks alive
/// on first launch: the owner's four goals, milestones, this week's targets,
/// today's tasks and blocks, and ~5 months of past activity for the heat map,
/// streaks and trends. Everything is editable or deletable.
class Seeder {
  Seeder(this.db, {DateTime? now, int randomSeed = 7})
      : now = now ?? DateTime.now(),
        rnd = Random(randomSeed);

  final AppDatabase db;
  final DateTime now;
  final Random rnd;

  Future<bool> isEmpty() async {
    final count = await db.goals.count().getSingle();
    final tasks = await db.tasks.count().getSingle();
    return count == 0 && tasks == 0;
  }

  Future<void> seed() => db.transaction(() async {
        final t0 = today(now);
        final ws = weekStartOf(t0);

        // Goals ------------------------------------------------------------
        Future<int> goal(String title, LifeArea a, String why, int months, double x, double y) =>
            db.into(db.goals).insert(GoalsCompanion.insert(
                  title: title,
                  area: a,
                  why: Value(why),
                  targetDate: Value(DateTime(t0.year, t0.month + months, t0.day)),
                  posX: Value(x),
                  posY: Value(y),
                ));

        final gStartup = await goal(
            'Grow the startup to 1,000 daily users',
            LifeArea.startup,
            'Hundreds already use it every day. A bigger base means it pays for itself.',
            9, 380, 320);
        final gCloud = await goal('Learn cloud engineering', LifeArea.cloud,
            'Skills that compound: better systems for the startup and better-paid work.', 6, 820, 420);
        final gGigs = await goal('Earn short-term income from clipping gigs', LifeArea.sideGigs,
            'Cash runway now so the startup can take its time.', 3, 560, 760);
        final gOutfit = await goal('Ship the AI outfit search system', LifeArea.startup,
            'Search clothes by photo or vibe. The feature people keep asking for.', 5, 200, 640);

        // Milestones -------------------------------------------------------
        Future<void> ms(int g, String title, int dueInDays, {bool done = false}) =>
            db.into(db.milestones).insert(MilestonesCompanion.insert(
                  goalId: g,
                  title: title,
                  dueDate: Value(addDays(t0, dueInDays)),
                  done: Value(done),
                  doneAt: Value(done ? addDays(t0, dueInDays) : null),
                ));
        await ms(gStartup, 'Ship the referral loop', -20, done: true);
        await ms(gStartup, 'Reach 500 daily users', 25);
        await ms(gStartup, 'Launch on Product Hunt', 70);
        await ms(gStartup, '1,000 daily users', 260);
        await ms(gCloud, 'Finish Cloud Practitioner course', -35, done: true);
        await ms(gCloud, 'Pass Solutions Architect Associate', 45);
        await ms(gCloud, 'Deploy a project with Terraform', 90);
        await ms(gCloud, 'Build a CI/CD pipeline', 150);
        await ms(gGigs, 'Land 3 regular clients', -10, done: true);
        await ms(gGigs, 'Deliver 30 clips', 20);
        await ms(gGigs, 'Hit first monthly income target', 60);
        await ms(gOutfit, 'Collect 2,000 outfit images', -5, done: true);
        await ms(gOutfit, 'Embedding search prototype', 12);
        await ms(gOutfit, 'Beta with 20 users', 55);
        await ms(gOutfit, 'Public launch', 140);

        // This week's targets ---------------------------------------------
        Future<int> target(int g, String title, int order) => db.into(db.weeklyTargets).insert(
            WeeklyTargetsCompanion.insert(goalId: Value(g), weekStart: ws, title: title, sortOrder: Value(order)));
        final tRef = await target(gStartup, 'Referral loop live for all users', 0);
        final tIam = await target(gCloud, 'Finish IAM and VPC modules', 1);
        final tClips = await target(gGigs, 'Deliver 6 clips', 2);
        final tEmb = await target(gOutfit, 'Prototype returns first results', 3);

        // Today's tasks ----------------------------------------------------
        Future<int> task(String title, LifeArea a,
            {int? goal,
            int? target,
            int mins = 25,
            String? step,
            int prio = 2,
            Effort effort = Effort.medium,
            DateTime? day,
            bool done = false,
            DateTime? doneAt}) {
          return db.into(db.tasks).insert(TasksCompanion.insert(
                title: title,
                area: a,
                goalId: Value(goal),
                weeklyTargetId: Value(target),
                estimatedMinutes: Value(mins),
                firstStep: Value(step),
                priority: Value(prio),
                effort: Value(effort),
                scheduledDate: Value(day ?? t0),
                status: Value(done ? TaskStatus.done : TaskStatus.todo),
                completedAt: Value(done ? (doneAt ?? now) : null),
              ));
        }

        final email = await task('Write the onboarding email for new users', LifeArea.startup,
            goal: gStartup, target: tRef, mins: 45, prio: 1, effort: Effort.heavy,
            step: 'Open a blank draft and write only the subject line');
        final iam = await task('IAM module: users, roles and policies', LifeArea.cloud,
            goal: gCloud, target: tIam, mins: 50, effort: Effort.medium,
            step: 'Open the course and press play on the first video');
        final clips = await task('Edit 2 clips for the gaming client', LifeArea.sideGigs,
            goal: gGigs, target: tClips, mins: 60, effort: Effort.medium,
            step: 'Import the raw footage into the editor');
        await task('Fix the sign-up bug reported yesterday', LifeArea.startup,
            goal: gStartup, target: tRef, mins: 30, prio: 1, effort: Effort.light,
            step: 'Reproduce it once on your phone');
        await task('Label 100 outfit images', LifeArea.startup,
            goal: gOutfit, target: tEmb, mins: 40, effort: Effort.light,
            step: 'Label just the first 10');
        final walk = await task('20-minute walk', LifeArea.health,
            mins: 20, effort: Effort.light, step: 'Put your shoes on');
        await task('Reply to messages from family', LifeArea.personal,
            mins: 15, prio: 3, effort: Effort.light, step: 'Open the first unread chat');
        // Someday pile.
        await task('Sketch pricing page ideas', LifeArea.startup, goal: gStartup, mins: 30, prio: 3)
            .then((id) => (db.update(db.tasks)..where((t) => t.id.equals(id)))
                .write(const TasksCompanion(scheduledDate: Value(null))));

        // Done earlier this week (so targets show progress).
        for (var i = 0; i < 4; i++) {
          final d = addDays(ws, i);
          if (!d.isBefore(t0)) break;
          await task(['Referral copy draft', 'VPC basics notes', 'Clip: podcast highlight', 'Set up vector DB'][i],
              [LifeArea.startup, LifeArea.cloud, LifeArea.sideGigs, LifeArea.startup][i],
              goal: [gStartup, gCloud, gGigs, gOutfit][i],
              target: [tRef, tIam, tClips, tEmb][i],
              day: d, done: true, doneAt: d.add(const Duration(hours: 15)));
        }

        // Today's blocks ---------------------------------------------------
        Future<void> block(int h, int m, int mins, BlockType type, String label, {int? taskId}) async {
          final s = t0.add(Duration(hours: h, minutes: m));
          final id = await db.into(db.timeBlocks).insert(TimeBlocksCompanion.insert(
                startAt: s,
                endAt: s.add(Duration(minutes: mins)),
                type: type,
                label: Value(label),
                taskId: Value(taskId),
              ));
          if (taskId != null) {
            await (db.update(db.tasks)..where((t) => t.id.equals(taskId)))
                .write(TasksCompanion(timeBlockId: Value(id)));
          }
        }

        await block(8, 0, 90, BlockType.focus, 'Deep work', taskId: email);
        await block(9, 30, 15, BlockType.breakTime, 'Stretch');
        await block(10, 0, 60, BlockType.focus, 'Cloud study', taskId: iam);
        await block(12, 30, 60, BlockType.fixed, 'Lunch');
        await block(14, 0, 60, BlockType.focus, 'Clipping', taskId: clips);
        await block(15, 0, 15, BlockType.breakTime, 'Break');
        await block(16, 0, 30, BlockType.admin, 'Messages and email');
        await block(18, 0, 20, BlockType.rest, 'Walk', taskId: walk);
        await block(23, 0, 420, BlockType.rest, 'Sleep');

        // History ----------------------------------------------------------
        await _history(t0, {
          LifeArea.startup: gStartup,
          LifeArea.cloud: gCloud,
          LifeArea.sideGigs: gGigs,
        });

        // Highlights, brain dump, a reminder ------------------------------
        await db.into(db.highlights).insert(HighlightsCompanion.insert(
            title: 'Shipped the referral loop', date: addDays(t0, -20)));
        await db.into(db.highlights).insert(HighlightsCompanion.insert(
            title: 'Passed Cloud Practitioner', date: addDays(t0, -35)));
        await db.into(db.highlights).insert(HighlightsCompanion.insert(
            title: 'Signed a third clipping client', date: addDays(t0, -10)));
        await db.into(db.brainDumps).insert(BrainDumpsCompanion.insert(
            body: 'Idea: let users save outfits to a board'));
        await db.into(db.brainDumps).insert(BrainDumpsCompanion.insert(
            body: 'Ask the gaming client about a monthly retainer'));
        await db.into(db.reminders).insert(RemindersCompanion.insert(
            title: 'Weekly invoice to clipping clients',
            at: addDays(ws, 4).add(const Duration(hours: 17)),
            repeat: const Value(RepeatRule.weekly)));
      });

  /// ~150 days of past completions, focus sessions and check-ins. Some days
  /// are quiet on purpose (it is a real life), and the last stretch is
  /// consistent so the streak looks healthy.
  Future<void> _history(DateTime t0, Map<LifeArea, int> goals) async {
    const pool = {
      LifeArea.startup: [
        'Ship onboarding tweak', 'User interview', 'Fix push notification bug', 'Write changelog',
        'Review analytics', 'Plan next sprint', 'Improve search speed', 'Reply to user feedback'
      ],
      LifeArea.cloud: [
        'S3 and IAM lab', 'EC2 deep dive', 'Practice exam 1', 'Terraform tutorial',
        'Networking notes', 'Docker basics', 'Kubernetes intro video'
      ],
      LifeArea.sideGigs: [
        'Edit podcast clip', 'Deliver 3 shorts', 'Client revisions', 'Invoice client', 'Find new client leads'
      ],
      LifeArea.health: ['Gym session', 'Morning run', '20-minute walk', 'Cooked a proper meal'],
      LifeArea.personal: ['Call mum', 'Read 20 pages', 'Tidy the room', 'Plan the weekend'],
    };
    const weights = {
      LifeArea.startup: 0.85,
      LifeArea.cloud: 0.6,
      LifeArea.sideGigs: 0.5,
      LifeArea.health: 0.45,
      LifeArea.personal: 0.15, // the neglected one, on purpose
    };

    final rows = <TasksCompanion>[];
    final sessions = <FocusSessionsCompanion>[];
    final checkins = <EnergyCheckInsCompanion>[];

    for (var back = 150; back >= 1; back--) {
      final d = addDays(t0, -back);
      final recent = back <= 12; // keep a clean recent run for the streak
      // A 6-day trip ~6 weeks ago, so current and best streak differ.
      final trip = back >= 41 && back <= 46;
      final quiet = trip || (!recent && rnd.nextDouble() < 0.16);
      if (!quiet) {
        for (final a in LifeArea.values) {
          if (rnd.nextDouble() > weights[a]!) continue;
          final n = 1 + rnd.nextInt(a == LifeArea.startup ? 3 : 2);
          for (var i = 0; i < n; i++) {
            final list = pool[a]!;
            final at = d.add(Duration(hours: 9 + rnd.nextInt(10), minutes: rnd.nextInt(60)));
            final mins = [15, 25, 30, 45, 50, 60][rnd.nextInt(6)];
            rows.add(TasksCompanion.insert(
              title: list[rnd.nextInt(list.length)],
              area: a,
              goalId: Value(goals[a]),
              estimatedMinutes: Value(mins),
              scheduledDate: Value(d),
              status: const Value(TaskStatus.done),
              completedAt: Value(at),
            ));
          }
        }
        final focusBlocks = 1 + rnd.nextInt(4);
        for (var i = 0; i < focusBlocks; i++) {
          final mins = [25, 50, 50, 90][rnd.nextInt(4)];
          final s = d.add(Duration(hours: 8 + i * 2, minutes: rnd.nextInt(30)));
          sessions.add(FocusSessionsCompanion.insert(
            plannedMinutes: mins,
            actualSeconds: Value(mins * 60 - rnd.nextInt(4) * 60),
            startAt: s,
            endAt: Value(s.add(Duration(minutes: mins))),
            completed: const Value(true),
          ));
        }
      }
      if (back <= 60 && rnd.nextDouble() < 0.8) {
        // Energy mostly 3–4 with natural dips; never a low run at the end.
        final e = (back <= 4) ? 3 + rnd.nextInt(2) : 2 + rnd.nextInt(4).clamp(0, 3);
        final m = (back <= 4) ? 3 + rnd.nextInt(2) : 2 + rnd.nextInt(4).clamp(0, 3);
        checkins.add(EnergyCheckInsCompanion.insert(date: d, energy: e, mood: m));
      }
    }
    await db.batch((b) {
      b.insertAll(db.tasks, rows);
      b.insertAll(db.focusSessions, sessions);
      b.insertAll(db.energyCheckIns, checkins);
    });
  }
}
