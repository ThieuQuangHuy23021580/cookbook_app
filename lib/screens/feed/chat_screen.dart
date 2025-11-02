import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/ai_chat_model.dart';
import '../../core/index.dart';
import '../../providers/recipe_provider.dart';
import 'post_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<AIChatSource>? sources;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
  });
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Thêm tin nhắn chào mừng
    _messages.add(Message(
      text: 'Xin chào! Tôi là trợ lý ẩm thực của bạn. Tôi có thể giúp bạn tìm công thức nấu ăn, đưa ra gợi ý món ăn, hoặc trả lời các câu hỏi về nấu nướng. Bạn muốn hỏi gì?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Call AI API
    try {
      final response = await ApiService.chatWithAI(question: text);
      
      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _messages.add(Message(
            text: response.data!.answer,
            isUser: false,
            timestamp: DateTime.now(),
            sources: response.data!.sources.isNotEmpty ? response.data!.sources : null,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _messages.add(Message(
            text: response.message ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này lúc này. Vui lòng thử lại sau.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        
        // Show error snackbar
        if (mounted && response.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _messages.add(Message(
          text: 'Xin lỗi, đã xảy ra lỗi khi kết nối với AI. Vui lòng kiểm tra kết nối mạng và thử lại.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi kết nối. Vui lòng thử lại sau.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
      ),
    );
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFEF3A16).withOpacity(0.9),
                const Color(0xFFFF5A00).withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEF3A16),
                          Color(0xFFFF6B35),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Trợ lý ẩm thực',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Đang hoạt động',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic background with particles
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF000000), // Pure black
                        const Color(0xFF0A0A0A), // Very dark gray
                        const Color(0xFF0F0F0F), // Slightly lighter dark gray
                      ]
                    : [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF1F5F9),
                      ],
              ),
            ),
          ),
          // Floating particles background
          ...List.generate(15, (index) => 
            Positioned(
              top: (index * 50.0) % MediaQuery.of(context).size.height,
              left: (index * 70.0) % MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 3000 + (index * 200)),
                curve: Curves.easeInOut,
                width: 6 + (index % 3) * 2,
                height: 6 + (index % 3) * 2,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFEF3A16).withOpacity(0.15)
                      : const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingIndicator();
                }
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Input area
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.9),
              border: isDark ? Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                  width: 2.0,
                ),
              ) : null,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
                if (isDark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE5E5E5),
                            width: isDark ? 2.0 : 1.0,
                          ),
                          boxShadow: isDark ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEF3A16),
                            Color(0xFFFF6B35),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF3A16).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _sendMessage,
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEF3A16),
                    Color(0xFFFF6B35),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF3A16).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? const Color(0xFFEF3A16) 
                        : (isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : const Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: !isUser && isDark ? Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2.0,
                    ) : null,
                    boxShadow: !isUser && isDark ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 12,
                        offset: const Offset(0, 0),
                      ),
                    ] : (isUser ? [
                      BoxShadow(
                        color: const Color(0xFFEF3A16).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : []),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser 
                          ? Colors.white 
                          : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                      height: 1.5,
                    ),
                  ),
                ),
                // Show sources if available
                if (!isUser && message.sources != null && message.sources!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.sources!.map((source) {
                        return GestureDetector(
                          onTap: () async {
                            // Show loading indicator
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              // Load full recipe detail from API
                              final recipeProvider = context.read<RecipeProvider>();
                              final recipe = await recipeProvider.getRecipeById(source.id);

                              if (!mounted) return;
                              
                              // Close loading dialog
                              Navigator.pop(context);

                              if (recipe == null) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Không thể tải chi tiết công thức'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Convert Recipe to Post format
                              final List<String> ingredientsList = [];
                              for (var ing in recipe.ingredients) {
                                ingredientsList.add(
                                  '${ing.name}${ing.quantity != null ? " ${ing.quantity}" : ""}${ing.unit != null ? " ${ing.unit}" : ""}'
                                );
                              }

                              final List<String> stepsList = [];
                              for (var step in recipe.steps) {
                                stepsList.add('${step.stepNumber}. ${step.title}: ${step.description ?? ""}');
                              }

                              final post = Post(
                                id: recipe.id.toString(),
                                title: recipe.title,
                                author: recipe.userName ?? 'Unknown',
                                minutesAgo: recipe.createdAt != null 
                                    ? DateTime.now().difference(recipe.createdAt!).inMinutes
                                    : 0,
                                savedCount: recipe.bookmarksCount,
                                imageUrl: recipe.imageUrl ?? '',
                                ingredients: ingredientsList,
                                steps: stepsList,
                                createdAt: recipe.createdAt,
                              );

                              // Navigate to recipe detail
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(post: post),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              
                              // Close loading dialog if still open
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi tải công thức: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFFEF3A16).withOpacity(0.2) 
                                  : const Color(0xFFEF3A16).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFEF3A16).withOpacity(isDark ? 0.5 : 0.3),
                                width: isDark ? 2.0 : 1.0,
                              ),
                              boxShadow: isDark ? [
                                BoxShadow(
                                  color: const Color(0xFFEF3A16).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.restaurant_menu,
                                  size: 14,
                                  color: Color(0xFFEF3A16),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    source.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFEF3A16),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 2.0,
                ) : null,
                boxShadow: isDark ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                Icons.person, 
                color: isDark ? Colors.white : const Color(0xFF1A1A1A), 
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEF3A16),
                  Color(0xFFFF6B35),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF3A16).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: const Radius.circular(4),
                bottomRight: const Radius.circular(18),
              ),
              border: isDark ? Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 2.0,
              ) : null,
              boxShadow: isDark ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? const Color(0xFFFF6B35) : const Color(0xFFEF3A16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang suy nghĩ...',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
