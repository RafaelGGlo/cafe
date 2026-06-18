import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cafeteria/main.dart';

void main() {
  testWidgets('faz login e acessa as principais telas internas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafeteriaApp());

    expect(find.text('Cafeteria Interna'), findsOneWidget);
    expect(find.text('Acesso dos funcionários'), findsOneWidget);

    await tester.enterText(find.bySemanticsLabel('E-mail'), 'admin@gmail.com');
    await tester.enterText(find.bySemanticsLabel('Senha'), 'admin');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Admin! 👋'), findsOneWidget);
    expect(find.text('Resumo da cafeteria hoje'), findsOneWidget);
    expect(find.text('Relatório do dia'), findsOneWidget);
    expect(find.text('Pedidos realizados'), findsOneWidget);

    await tester.tap(find.text('Fluxo de pedidos'));
    await tester.pumpAndSettle();
    expect(find.text('Novo pedido'), findsOneWidget);
    expect(find.text('Café Espresso'), findsOneWidget);

    await tester.tap(find.text('Novo pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Nome do cliente'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Salvar pedido'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Produtos'));
    await tester.pumpAndSettle();
    expect(find.text('Gerenciar produtos'), findsOneWidget);
    expect(find.text('Novo produto'), findsOneWidget);
    expect(find.text('Editar'), findsWidgets);
  });
}
