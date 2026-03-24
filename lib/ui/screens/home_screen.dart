import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../logic/quiz_controller.dart';
import '../../data/models/quiz.dart';
import '../widgets/quiz_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDifficulty = 'all';
  String _selectedCategory = 'all';
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizController>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.bgDarker,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.text),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<QuizController>(
              builder: (context, controller, _) {
                if (controller.status == QuizStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (controller.status == QuizStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage ?? AppStrings.somethingWentWrong,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.refreshQuizzes(),
                          child: const Text(AppStrings.tryAgain),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.quizzes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.quiz_outlined,
                          color: AppColors.muted,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noQuizzesFound,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshQuizzes(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppConstants.homeGridCrossAxisCount,
                      childAspectRatio: AppConstants.homeGridChildAspectRatio,
                      crossAxisSpacing: AppConstants.homeGridSpacing,
                      mainAxisSpacing: AppConstants.homeGridSpacing,
                    ),
                    itemCount: controller.quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = controller.quizzes[index];
                      return QuizCard(
                        quiz: quiz,
                        onTap: () => _navigateToQuizDetail(context, quiz),
                        onShare: () => _shareQuiz(context, quiz),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          SearchBar(
            controller: _searchController,
            onChanged: (value) {
              context.read<QuizController>().filterQuizzes(
                search: value.isNotEmpty ? value : null,
                difficulty: _selectedDifficulty != 'all' ? _selectedDifficulty : null,
                category: _selectedCategory != 'all' ? _selectedCategory : null,
                type: _selectedType != 'all' ? _selectedType : null,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Difficulty Filter
                _buildFilterSection(
                  'Difficulty',
                  [
                    FilterChip(
                    label: AppStrings.all,
                    isSelected: _selectedDifficulty == 'all',
                    onTap: () => _selectDifficulty('all'),
                  ),
                    FilterChip(
                      label: AppStrings.easy,
                      isSelected: _selectedDifficulty == 'easy',
                      onTap: () => _selectDifficulty('easy'),
                    ),
                    FilterChip(
                      label: AppStrings.medium,
                      isSelected: _selectedDifficulty == 'medium',
                      onTap: () => _selectDifficulty('medium'),
                    ),
                    FilterChip(
                      label: AppStrings.hard,
                      isSelected: _selectedDifficulty == 'hard',
                      onTap: () => _selectDifficulty('hard'),
                    ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Category Filter
                _buildFilterSection(
                  'Category',
                  [
                    FilterChip(
                      label: AppStrings.all,
                      isSelected: _selectedCategory == 'all',
                      onTap: () => _selectCategory('all'),
                    ),
                    FilterChip(
                      label: 'Programming',
                      isSelected: _selectedCategory == 'programming',
                      onTap: () => _selectCategory('programming'),
                    ),
                    FilterChip(
                      label: 'Mathematics',
                      isSelected: _selectedCategory == 'mathematics',
                      onTap: () => _selectCategory('mathematics'),
                    ),
                    FilterChip(
                      label: 'Science',
                      isSelected: _selectedCategory == 'science',
                      onTap: () => _selectCategory('science'),
                    ),
                    FilterChip(
                      label: 'History',
                      isSelected: _selectedCategory == 'history',
                      onTap: () => _selectCategory('history'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _applyFilters();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  void _applyFilters() {
    context.read<QuizController>().filterQuizzes(
      difficulty: _selectedDifficulty != 'all' ? _selectedDifficulty : null,
      category: _selectedCategory != 'all' ? _selectedCategory : null,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  void _navigateToQuizDetail(BuildContext context, Quiz quiz) {
    Navigator.pushNamed(
      context,
      '/quiz-detail',
      arguments: quiz,
    );
  }

  void _shareQuiz(BuildContext context, Quiz quiz) {
    final shareLink = AppUtils.generateShareLink(quiz.slug);
    
    // Use share_plus package to share
    // For now, just copy to clipboard
    // In a real app, you'd use the share_plus package
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Consumer<QuizController>(
                  builder: (context, controller, _) {
                    final user = controller.currentUser;
                    if (user?.avatar != null) {
                      return ClipOval(
                        child: Image.network(
                          user!.avatar!,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return Icon(
                      Icons.person,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              title: Consumer<QuizController>(
                builder: (context, controller, _) {
                  return Text(
                    controller.getDisplayName(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.settings, color: AppColors.muted),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
