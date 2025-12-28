import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/blogger_service.dart';
import 'post_editor_screen.dart';
import 'package:googleapis/blogger/v3.dart' as blogger;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BloggerService _bloggerService = BloggerService();
  List<blogger.Blog> _blogs = [];
  blogger.Blog? _selectedBlog;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final accessToken = authService.accessToken;

      if (accessToken != null) {
        final credentials = auth.AccessCredentials(
          accessToken,
          null,
          ['https://www.googleapis.com/auth/blogger'],
        );

        _bloggerService.initialize(credentials);

        // 사용자 ID는 'self'로 현재 사용자를 나타냄
        _blogs = await _bloggerService.getBlogs('self');

        if (_blogs.isNotEmpty) {
          setState(() {
            _selectedBlog = _blogs.first;
          });
        }
      }
    } catch (e) {
      debugPrint('블로그 로딩 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('블로그를 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogger 포스팅'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // 블로그 선택 드롭다운
          if (_blogs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<blogger.Blog>(
                value: _selectedBlog,
                dropdownColor: Colors.orange.shade700,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: _blogs.map((blog) {
                  return DropdownMenuItem(
                    value: blog,
                    child: Text(
                      blog.name ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (blog) {
                  setState(() {
                    _selectedBlog = blog;
                  });
                },
              ),
            ),

          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _blogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.article_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        '블로그가 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'blogger.com에서 블로그를 먼저 생성하세요',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadBlogs,
                        icon: const Icon(Icons.refresh),
                        label: const Text('새로고침'),
                      ),
                    ],
                  ),
                )
              : _buildBlogInfo(),
      floatingActionButton: _selectedBlog != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostEditorScreen(
                      bloggerService: _bloggerService,
                      blogId: _selectedBlog!.id!,
                      blogName: _selectedBlog!.name ?? '',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('새 포스트'),
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }

  Widget _buildBlogInfo() {
    if (_selectedBlog == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBlog!.name ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_selectedBlog!.description != null)
                    Text(
                      _selectedBlog!.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.article, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '포스트: ${_selectedBlog!.posts?.totalItems ?? 0}개',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '최근 포스트',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildRecentPosts(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPosts() {
    return FutureBuilder<List<blogger.Post>>(
      future: _bloggerService.getPosts(_selectedBlog!.id!, maxResults: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return const Center(
            child: Text(
              '포스트가 없습니다.\n첫 포스트를 작성해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.article, color: Colors.orange),
                title: Text(post.title ?? 'Untitled'),
                subtitle: Text(
                  post.published != null
                      ? '게시일: ${post.published!.toLocal().toString().split(' ')[0]}'
                      : '',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 포스트 상세보기/수정
                },
              ),
            );
          },
        );
      },
    );
  }
}
