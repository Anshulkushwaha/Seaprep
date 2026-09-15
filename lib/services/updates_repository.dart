import 'package:flutter/material.dart';
import '../models/app_update.dart';

class UpdatesRepository extends ChangeNotifier {
  UpdatesRepository._internal() {
    _initializeDefaultUpdates();
  }
  static final UpdatesRepository instance = UpdatesRepository._internal();

  final List<AppUpdate> _updates = [];
  final Set<String> _readUpdateIds = {};
  final Set<String> _bookmarkedUpdateIds = {};

  List<AppUpdate> get allUpdates => List.unmodifiable(_updates);

  List<AppUpdate> getUnreadUpdates() {
    return _updates.where((u) => !_readUpdateIds.contains(u.id)).toList();
  }

  int get unreadCount => getUnreadUpdates().length;

  bool isRead(String id) => _readUpdateIds.contains(id);

  bool isBookmarked(String id) => _bookmarkedUpdateIds.contains(id);

  void markAsRead(String id) {
    if (!_readUpdateIds.contains(id)) {
      _readUpdateIds.add(id);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final update in _updates) {
      _readUpdateIds.add(update.id);
    }
    notifyListeners();
  }

  void toggleBookmark(String id) {
    if (_bookmarkedUpdateIds.contains(id)) {
      _bookmarkedUpdateIds.remove(id);
    } else {
      _bookmarkedUpdateIds.add(id);
    }
    notifyListeners();
  }

  List<AppUpdate> getUpdatesByCategory(AppUpdateCategory? category) {
    if (category == null) return allUpdates;
    return _updates.where((u) => u.category == category).toList();
  }

  void _initializeDefaultUpdates() {
    _updates.clear();
    _updates.addAll([
      AppUpdate(
        id: 'up_001',
        title: 'Synergy Maritime DNS & GME 2026 Exam Batch Announced',
        summary:
            'Synergy Marine Group has released online interview & written test dates for DNS and GME deck/engine cadet sponsorships.',
        content: '''
Dear Maritime Cadets,

The App Team has confirmed that Synergy Marine Group has opened registrations for their 2026 Diploma in Nautical Science (DNS) and Graduate Marine Engineering (GME) sponsorship exams.

Key Details for Applicants:
- **Written Examination Date:** 15th September 2026
- **Interview Rounds:** Technical & Psychometric tests starting 22nd September.
- **Key Focus Topics:** COLREG Rules 1-19, Ship Auxiliary Systems, Electrical Safety, and English Aptitude.

💡 **App Team Tip:** Make sure to complete the "Synergy Special Practice Questions" available in our Practice Tab before taking your test!
''',
        category: AppUpdateCategory.companyNews,
        postedDate: DateTime.now().subtract(const Duration(hours: 3)),
        badgeText: 'URGENT RECRUITMENT',
        author: 'App Team • Capt. R. Sharma',
        readTime: '2 min read',
        companyId: 'comp_synergy',
        actionButtonText: 'View Synergy Questions',
        isUrgent: true,
      ),
      AppUpdate(
        id: 'up_002',
        title: 'New Module Added: MMD Engine & Deck Orals 2026 Revision',
        summary:
            'We have uploaded 85+ high-frequency MMD Class IV & Class II oral interview questions with diagrams and standard answer templates.',
        content: '''
Attention Cadets!

We are excited to announce a major course content update released by our Faculty & App Engineering Team.

What's New in this Course Update:
1. **Oily Water Separator (OWS) 15 PPM Bilge Alarm Logic:** Detailed step-by-step 3-way valve response diagrams.
2. **Emergency Generator Auto-Start Conditions:** Blackout sequence and SOLAS 45-second power restoration rules.
3. **COLREG Lights & Shapes Flashcards:** Enhanced visual interactive cards covering Head-On, Crossing, and Restricted Maneuverability vessels.
4. **Main Engine Scavenge Fire Procedure:** Immediate bridge notification, engine slowing, and CO2 flooding protocols.

Head over to the **Practice** section to attempt these freshly curated MMD Oral questions!
''',
        category: AppUpdateCategory.courseUpdate,
        postedDate: DateTime.now().subtract(const Duration(hours: 14)),
        badgeText: 'NEW CONTENT',
        author: 'App Faculty Team',
        readTime: '3 min read',
        actionButtonText: 'Start Course Practice',
        isUrgent: false,
      ),
      AppUpdate(
        id: 'up_003',
        title: 'Anglo-Eastern Maritime Academy Interview Pattern Updated',
        summary:
            'AEMA has updated their technical interview evaluation matrix for Deck and Engine Cadets for the upcoming intake.',
        content: '''
Company Update from App Team:

Anglo-Eastern Ship Management (AEMA) has introduced a revised interview grading system. Candidates are now evaluated heavily on practical safety awareness and real-time situational problem-solving.

Major Topics Added:
- IMO STCW 2026 Amendments on Marine Environmental Protection.
- Steering Gear Failure emergency helm changeover drill steps.
- Personal Survival Techniques & Life Raft Hydrostatic Release Unit (HRU) operation.

Check out Anglo-Eastern's company profile and practice their latest interview question bank now available on SeaPrep Pro.
''',
        category: AppUpdateCategory.companyNews,
        postedDate: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        badgeText: 'COMPANY NEWS',
        author: 'App Team • Tech Officer',
        readTime: '2 min read',
        companyId: 'comp_anglo_eastern',
        actionButtonText: 'View Anglo-Eastern Profile',
        isUrgent: false,
      ),
      AppUpdate(
        id: 'up_004',
        title: 'STCW & SOLAS 2026 Chapter III LSA Regulation Refresher',
        summary:
            'Updated course notes on Life Saving Appliances (LSA) Code including free-fall lifeboat releases and immersion suit inspection routines.',
        content: '''
Course Update Notice:

Our maritime curriculum team has updated the LSA & FFA safety regulation modules in line with recent IMO maritime safety committee circulars.

Updated Course Material Includes:
- **Lifeboat Falls Inspections:** 5-year wire renewal and end-for-ending rules.
- **Immersion Suit Monthly Testing:** Pressure test kit usage and zipper lubrication protocols.
- **EEBD (Emergency Escape Breathing Device):** 10-minute air duration vs SCBA differences.

Review these topics directly under the Targeted Focus Areas in your Dashboard!
''',
        category: AppUpdateCategory.courseUpdate,
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        badgeText: 'COURSE UPDATE',
        author: 'App Team • Chief Engineer V. Nair',
        readTime: '3 min read',
        actionButtonText: 'Review LSA Modules',
        isUrgent: false,
      ),
      AppUpdate(
        id: 'up_005',
        title: 'Fleet Management Ltd. (FML) Deck & Engine Cadet Walk-in Drives',
        summary:
            'Fleet Management Limited has opened off-campus assessment drives across Mumbai, Chennai, and Kolkata institutes.',
        content: '''
Recruitment Announcement:

Fleet Management Limited (FML) is conducting direct cadet selection drives for qualified DNS, B.Sc Nautical Science, and B.Tech Marine Engineering graduates.

Drive Highlights:
- **Eligible Batches:** 2025/2026 Passing Out Batches
- **Minimum Criteria:** 60% aggregate in DG Shipping approved institutes with no active backlogs.
- **Interview Rounds:** Online Technical MCQ (45 mins) followed by Panel Interview.

Study FML specific questions in the Companies tab to boost your selection chances!
''',
        category: AppUpdateCategory.companyNews,
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        badgeText: 'FLEET HIRING',
        author: 'App Team Placement Cell',
        readTime: '2 min read',
        companyId: 'comp_fleet_mgmt',
        actionButtonText: 'Explore FML Questions',
        isUrgent: false,
      ),
      AppUpdate(
        id: 'up_006',
        title: 'SeaPrep Pro v2.4 Feature Release: Interactive Flashcards',
        summary:
            'We have launched dynamic color-coded revision flashcards and weak-topic tracking algorithm for personalized learning.',
        content: '''
App Team Platform Release:

We are thrilled to bring you SeaPrep Pro Version 2.4! This update introduces several requested features to assist deck and engine cadets:

🚀 **Key Platform Features:**
1. **Interactive Revision Flashcards:** Flip cards to instantly review key definitions, SOLAS rules, and auxiliary engine functions.
2. **Weak Topic Summary Modal:** Click on weak topics to instantly filter and review matching practice questions.
3. **App Team Updates Feed:** Stay updated on company hiring announcements and new study material additions directly on your Home screen.

Thank you for preparing with SeaPrep Pro! Fair winds and following seas.
''',
        category: AppUpdateCategory.appNews,
        postedDate: DateTime.now().subtract(const Duration(days: 4)),
        badgeText: 'PLATFORM NEWS',
        author: 'App Team Developers',
        readTime: '1 min read',
        actionButtonText: 'Try Flashcards',
        isUrgent: false,
      ),
    ]);
  }
}
