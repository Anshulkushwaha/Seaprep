import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'models/company.dart';
import 'screens/companies_screen.dart';
import 'screens/company_detail_screen.dart';
import 'screens/company_questions_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mcq_quiz_screen.dart';
import 'screens/question_practice_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }

  runApp(const SeaPrepApp());
}

class SeaPrepApp extends StatelessWidget {
  const SeaPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeaPrep Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationFlow(),
    );
  }
}

class MainNavigationFlow extends StatefulWidget {
  const MainNavigationFlow({super.key});

  @override
  State<MainNavigationFlow> createState() => _MainNavigationFlowState();
}

class _MainNavigationFlowState extends State<MainNavigationFlow> {
  int _currentNavIndex = 0;
  Company? _selectedCompanyForPractice;
  Company? _selectedCompanyForDetail;
  Company? _selectedCompanyForQuestions;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  void _onLoginSuccess() {
    setState(() {
      _currentNavIndex = 0;
      _selectedCompanyForDetail = null;
      _selectedCompanyForQuestions = null;
    });
  }

  void _handleLogout() {
    AuthService.instance.logout();
    setState(() {
      _currentNavIndex = 0;
      _selectedCompanyForPractice = null;
      _selectedCompanyForDetail = null;
      _selectedCompanyForQuestions = null;
    });
  }

  void _openCompanyDetail(Company company) {
    setState(() {
      _selectedCompanyForDetail = company;
      _selectedCompanyForQuestions = null;
    });
  }

  void _startPracticeForCompany(Company company) {
    setState(() {
      _selectedCompanyForPractice = company;
      _selectedCompanyForDetail = null;
      _selectedCompanyForQuestions = null;
      _currentNavIndex = 2; // Practice tab
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isLoggedIn) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }

    Widget bodyContent;
    switch (_currentNavIndex) {
      case 0:
        bodyContent = DashboardScreen(
          onResumePractice: () {
            setState(() {
              _currentNavIndex = 2;
            });
          },
          onOpenCompanyDetail: (companyId) {
            if (companyId != null) {
              final cleanId = companyId.replaceAll('comp_', '');
              final matching = Company.sampleCompanies.where((c) =>
                  c.id.toLowerCase() == cleanId.toLowerCase() ||
                  c.name.toLowerCase().contains(cleanId.toLowerCase())).toList();
              if (matching.isNotEmpty) {
                _openCompanyDetail(matching.first);
              }
            }
            setState(() {
              _currentNavIndex = 1;
            });
          },
        );
        break;

      case 1:
        if (_selectedCompanyForQuestions != null) {
          bodyContent = CompanyQuestionsScreen(
            company: _selectedCompanyForQuestions!,
            onProceedToPractice: _startPracticeForCompany,
            onBack: () {
              setState(() {
                _selectedCompanyForQuestions = null;
              });
            },
          );
        } else if (_selectedCompanyForDetail != null) {
          bodyContent = CompanyDetailScreen(
            company: _selectedCompanyForDetail!,
            onProceedToPractice: _startPracticeForCompany,
            onOpenQuestionsScreen: () {
              setState(() {
                _selectedCompanyForQuestions = _selectedCompanyForDetail;
              });
            },
            onBack: () {
              setState(() {
                _selectedCompanyForDetail = null;
              });
            },
          );
        } else {
          bodyContent = CompaniesScreen(
            onSelectCompany: _openCompanyDetail,
          );
        }
        break;

      case 2:
        bodyContent = QuestionPracticeScreen(
          selectedCompany: _selectedCompanyForPractice,
          onBack: () {
            setState(() {
              _currentNavIndex = 0;
            });
          },
        );
        break;

      case 3:
        bodyContent = const McqQuizScreen();
        break;

      default:
        bodyContent = const SizedBox.shrink();
    }

    return AppScaffold(
      currentIndex: _currentNavIndex,
      onNavigationIndexChanged: (index) {
        setState(() {
          _currentNavIndex = index;
          _selectedCompanyForDetail = null;
        });
      },
      onLogout: _handleLogout,
      body: bodyContent,
    );
  }
}
