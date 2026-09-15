import 'package:flutter/material.dart';
import '../models/company.dart';
import '../theme/app_theme.dart';

class CompaniesScreen extends StatefulWidget {
  final ValueChanged<Company> onSelectCompany;

  const CompaniesScreen({super.key, required this.onSelectCompany});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Carriers';
  List<Company> _companies = Company.sampleCompanies;
  bool _isLoading = false;

  final List<String> _categories = [
    'All Carriers',
    'Container Ships',
    'Tankers',
    'Bulk Carriers',
    'Offshore',
  ];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetched = await Company.fetchCompanies();
      if (mounted && fetched.isNotEmpty) {
        setState(() {
          _companies = fetched;
        });
      }
    } catch (e) {
      debugPrint('Error fetching companies: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCompanies = _companies.where((company) {
      final matchesSearch = company.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          company.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          company.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All Carriers' ||
          company.category.toLowerCase().contains(_selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1100
        ? 3
        : screenWidth > 680
            ? 2
            : 1;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth > 800 ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Search Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: isMobile ? 0 : 1,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover Companies',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Browse top maritime organizations, review their interview patterns, and prepare with curated question banks designed for cadet and officer roles.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: isMobile ? 16 : 0,
                    width: isMobile ? 0 : 24,
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 280,
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search shipping companies...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        fillColor: AppColors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Company Grid
          if (_isLoading && _companies.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredCompanies.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              width: double.infinity,
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: AppColors.outline),
                  SizedBox(height: 12),
                  Text(
                    'No shipping companies found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCompanies.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 230,
              ),
              itemBuilder: (context, index) {
                final company = filteredCompanies[index];
                return _buildCompanyCard(company);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo(Company company) {
    if (company.logoUrl != null && company.logoUrl!.isNotEmpty) {
      final isAsset = company.logoUrl!.startsWith('assets/');
      return Container(
        width: 52,
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 31, 63, 0.06),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: isAsset
              ? Image.asset(
                  company.logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackLogo(company),
                )
              : Image.network(
                  company.logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackLogo(company),
                ),
        ),
      );
    }
    return _buildFallbackLogo(company);
  }

  Widget _buildFallbackLogo(Company company) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        company.logoText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      child: InkWell(
        onTap: () => widget.onSelectCompany(company),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Row (Logo + Arrow Icon)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyLogo(company),
                  const Icon(
                    Icons.arrow_outward,
                    size: 20,
                    color: AppColors.actionBlue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Company Name
              Text(
                company.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              // Company Description
              Expanded(
                child: Text(
                  company.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ),
              const Divider(color: AppColors.outlineVariant, height: 16),
              // Bottom Card Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${company.questionCount} Questions',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.actionBlue,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        company.isRecommended
                            ? Icons.verified
                            : Icons.trending_up,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        company.isRecommended
                            ? 'Recommended'
                            : company.difficulty,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
