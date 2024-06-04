import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

const Color BACKGROUND = Color.fromRGBO(45, 87, 123, 48);
const Color HINT = Color.fromRGBO(95, 138, 165, 65);
const Color TEXT = Color.fromRGBO(239, 247, 250, 98);
const Color BLACK = Colors.black;
const Color FOCUS_ORANGE = Color.fromRGBO(245, 149, 32, 96);
const Color BUTTON_BACKGROUND = Color.fromRGBO(88, 167, 237, 93);
const Color BUTTON_BACKGROUND_DISABLED = Color.fromRGBO(88, 167, 237, 25);
const Color BUTTON_BAR_BACKGROUND = Color.fromRGBO(146, 179, 207, 81);
const Color POST_BACKGROUND = Color.fromRGBO(107, 226, 200, 0.816);
const Color EVENT_BACKGROUND = Color.fromRGBO(246, 213, 159, 1);
const Color CHAT_OTHER = Color.fromRGBO(150, 118, 244, 1);
const Color CHAT_ME = Color.fromRGBO(220, 206, 82, 0.825);
const TRANSLATOR_API_KEY = 'ca9d6ebeb7msh728aa6c3563c780p194862jsnfb3d152aea91';
const supabaseURL = 'https://ybebufmjnvzatnywturc.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliZWJ1Zm1qbnZ6YXRueXd0dXJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0NzQ1MjQsImV4cCI6MjAyNzA1MDUyNH0.eyFUwoEqNnKlwgG1UjWul_uX8snw8lsmqDNvRIEzDsE';
final supabase = SupabaseClient(supabaseURL, supabaseKey,
    authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit));
