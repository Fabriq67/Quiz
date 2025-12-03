import 'package:flutter/material.dart';
import '../screens/percepcion_menu.dart';

class RetroBackButton extends StatelessWidget {
  const RetroBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              // Si podemos hacer pop en el Navigator más cercano -> pop
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                return;
              }

              // Si estamos ya dentro del menú, no hacemos nada
              final bool isInPercepcionMenu =
                  context.findAncestorWidgetOfExactType<PercepcionMenuScreen>() != null;
              if (isInPercepcionMenu) return;

              // Si la ruta actual es la raíz del Navigator y no es el menú,
              // reemplazamos la pila con el menú (evita duplicados)
              final route = ModalRoute.of(context);
              if (route != null && route.isFirst) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PercepcionMenuScreen()),
                  (r) => false,
                );
                return;
              }

              // Por seguridad, intenta un maybePop -> si no hay nada, abre el menú
              Navigator.maybePop(context).then((popped) {
                if (!popped) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const PercepcionMenuScreen()),
                    (r) => false,
                  );
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF24133D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.cyanAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}