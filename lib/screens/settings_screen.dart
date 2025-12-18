import 'package:flutter/material.dart';
import '../services/cloud_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CloudService _cloud = CloudService();
  bool _isLoading = false; // Variable para saber si está cargando

  @override
  Widget build(BuildContext context) {
    // Verificamos estado de conexión
    bool isConnected = _cloud.isLinked;
    String userName = _cloud.user?.displayName?.toUpperCase() ?? "JUGADOR";

    // Colores del tema
    const colorBg = Color(0xFF1B0E2E);
    const colorCyan = Color(0xFF00FFF0);
    const colorPink = Color(0xFFFF4B82);

    return Scaffold(
      backgroundColor: colorBg,
      appBar: AppBar(
        title: const Text(
          "AJUSTES", 
          style: TextStyle(fontFamily: 'PressStart2P', fontSize: 16, color: Colors.white)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: colorCyan),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_sync, size: 80, color: colorCyan),
              const SizedBox(height: 20),
              
              const Text(
                "RESPALDO EN LA NUBE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 14,
                  color: colorPink,
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                "Conecta tu cuenta para guardar tus monedas y nivel. Si borras la app, podrás recuperarlos.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 22,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 50),
              
              // --- BOTÓN PRINCIPAL CON ESTADO DE CARGA ---
              Container(
                width: double.infinity, // Para que ocupe el ancho y se vea bien
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: isConnected ? Colors.green.withOpacity(0.4) : colorCyan.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConnected ? Colors.green[700] : Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isConnected ? Colors.lightGreenAccent : colorCyan,
                        width: 2
                      )
                    ),
                  ),
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true); // Empieza carga

                    if (isConnected) {
                      // --- DESCONECTAR ---
                      await _cloud.signOut();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Desconectado correctamente", style: TextStyle(fontFamily: 'VT323', fontSize: 18)),
                        ));
                      }
                    } else {
                      // --- CONECTAR ---
                      bool success = await _cloud.signIn();
                      
                      if (mounted) {
                        if (success) {
                          // REFRESCAR EL NOMBRE
                          String newName = _cloud.user?.displayName?.toUpperCase() ?? "JUGADOR";
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("¡BIENVENIDO, $newName!", style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 10)),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          // ERROR
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("ERROR DE CONEXIÓN (Revisa internet o SHA-1)", style: TextStyle(fontFamily: 'VT323', fontSize: 18)),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }

                    setState(() => _isLoading = false); // Termina carga
                  },
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isConnected ? Icons.check_circle : Icons.gamepad),
                          const SizedBox(width: 10),
                          Flexible( // Evita error si el nombre es muy largo
                            child: Text(
                              isConnected 
                                  ? "CONECTADO: $userName" 
                                  : "CONECTAR CON GOOGLE",
                              style: const TextStyle(
                                fontFamily: 'PressStart2P', 
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
              
              const SizedBox(height: 20),

              // --- BOTÓN SECUNDARIO ---
              if (isConnected)
                TextButton.icon(
                  icon: const Icon(Icons.save, size: 18, color: Colors.white54),
                  label: const Text(
                    "Forzar Guardado Manual",
                    style: TextStyle(
                      fontFamily: 'VT323',
                      fontSize: 18,
                      color: Colors.white54,
                    ),
                  ),
                  onPressed: () async {
                     await _cloud.autoSave();
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Guardado completado", style: TextStyle(fontFamily: 'VT323', fontSize: 18)),
                            backgroundColor: colorPink,
                          ),
                       );
                     }
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}