import 'package:supabase/supabase.dart';

abstract class FileChooser{
  Future<void> uploadContent(User user, String path, String fileName);
  Future<List<Map<String, dynamic>>> getContent(User user, String table, String field);
}