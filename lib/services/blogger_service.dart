import 'package:googleapis/blogger/v3.dart' as blogger;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

class BloggerService {
  blogger.BloggerApi? _bloggerApi;

  void initialize(auth.AccessCredentials credentials) {
    final client = auth.authenticatedClient(http.Client(), credentials);
    _bloggerApi = blogger.BloggerApi(client);
  }

  // 블로그 목록 가져오기
  Future<List<blogger.Blog>> getBlogs(String userId) async {
    if (_bloggerApi == null) throw Exception('Blogger API not initialized');

    final response = await _bloggerApi!.blogs.listByUser(userId);
    return response.items ?? [];
  }

  // 포스트 작성
  Future<blogger.Post> createPost({
    required String blogId,
    required String title,
    required String content,
    List<String>? labels,
    bool isDraft = false,
  }) async {
    if (_bloggerApi == null) throw Exception('Blogger API not initialized');

    final post = blogger.Post()
      ..title = title
      ..content = content
      ..labels = labels;

    return await _bloggerApi!.posts.insert(post, blogId, isDraft: isDraft);
  }

  // 포스트 목록 가져오기
  Future<List<blogger.Post>> getPosts(String blogId, {int maxResults = 20}) async {
    if (_bloggerApi == null) throw Exception('Blogger API not initialized');

    final response = await _bloggerApi!.posts.list(blogId, maxResults: maxResults);
    return response.items ?? [];
  }

  // 포스트 업데이트
  Future<blogger.Post> updatePost({
    required String blogId,
    required String postId,
    required String title,
    required String content,
    List<String>? labels,
  }) async {
    if (_bloggerApi == null) throw Exception('Blogger API not initialized');

    final post = blogger.Post()
      ..id = postId
      ..title = title
      ..content = content
      ..labels = labels;

    return await _bloggerApi!.posts.update(post, blogId, postId);
  }

  // 포스트 삭제
  Future<void> deletePost(String blogId, String postId) async {
    if (_bloggerApi == null) throw Exception('Blogger API not initialized');
    await _bloggerApi!.posts.delete(blogId, postId);
  }
}
