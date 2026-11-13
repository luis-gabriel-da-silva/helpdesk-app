import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restaura o token antes da primeira tela para que as requisições usem a sessão salva.
  await AuthService().getToken();
  runApp(const HelpDeskApp());
}
