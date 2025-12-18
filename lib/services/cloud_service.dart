import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/progress_manager.dart'; 

class CloudService {
  // Singleton
  static final CloudService _instance = CloudService._internal();
  factory CloudService() => _instance;
  CloudService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getters
  bool get isLinked => _auth.currentUser != null;
  User? get user => _auth.currentUser;

  // 1. INICIAR SESIÓN CON GOOGLE (CORREGIDO Y BLINDADO)
  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // Usuario canceló

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      
      // Sincronizar apenas se conecta
      await syncData(); 
      return true;

    } catch (e) {
      // 🔥🔥🔥 AQUÍ ESTÁ EL ARREGLO 🔥🔥🔥
      // Este bloque detecta si el usuario SÍ entró a pesar del error de Pigeon
      if (_auth.currentUser != null) {
        print("⚠️ Error visual ignorado (Bug Pigeon). El usuario SÍ entró correctamente.");
        await syncData(); // Forzamos el guardado
        return true; // <--- ESTO HARÁ QUE EL BOTÓN SE PONGA VERDE
      }

      print("❌ Error real en login Cloud: $e");
      return false;
    }
  }

  // 2. CERRAR SESIÓN
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 3. SINCRONIZACIÓN DE PROGRESO (FUSIÓN INTELIGENTE)
  Future<void> syncData() async {
    if (!isLinked) return;

    final String uid = user!.uid;
    final userRef = _db.collection('users').doc(uid);

    try {
      // A. Obtener datos locales
      final localP = await ProgressManager.loadProgress();

      // B. Obtener datos nube
      final doc = await userRef.get();

      if (doc.exists) {
        // --- FUSIONAR DATOS ---
        final cloudJson = doc.data() as Map<String, dynamic>;
        final cloudP = PlayerProgress.fromJson(cloudJson);

        // Lógica de fusión: quedarse con lo mejor de los dos mundos
        int finalCoins = (localP.coins > cloudP.coins) ? localP.coins : cloudP.coins;

        List<String> mergeLists(List<String> local, List<String> cloud) {
          final set = <String>{...local, ...cloud};
          return set.toList();
        }

        final mergedProgress = PlayerProgress(
          coins: finalCoins,
          currentLevel: (localP.currentLevel > cloudP.currentLevel) ? localP.currentLevel : cloudP.currentLevel,
          currentBlock: (localP.currentBlock > cloudP.currentBlock) ? localP.currentBlock : cloudP.currentBlock,
          
          unlockedPowerUps: mergeLists(localP.unlockedPowerUps, cloudP.unlockedPowerUps),
          selectedPowerUps: localP.selectedPowerUps, 
          defeatedBosses: mergeLists(localP.defeatedBosses, cloudP.defeatedBosses),
          unlockedBlocks: mergeLists(localP.unlockedBlocks, cloudP.unlockedBlocks),
          completedBlocks: mergeLists(localP.completedBlocks, cloudP.completedBlocks),
          unlockedLevels: mergeLists(localP.unlockedLevels, cloudP.unlockedLevels),
        );

        // Guardar la versión fusionada en ambos lados
        await ProgressManager.saveProgress(mergedProgress); // Celular
        
        final jsonToUpload = mergedProgress.toJson();
        jsonToUpload['last_sync'] = FieldValue.serverTimestamp();
        
        await userRef.set(jsonToUpload, SetOptions(merge: true)); // Nube
        
        print("✅ Progreso sincronizado y fusionado.");

      } else {
        // --- USUARIO NUEVO EN NUBE ---
        final jsonToUpload = localP.toJson();
        jsonToUpload['created_at'] = FieldValue.serverTimestamp();
        
        await userRef.set(jsonToUpload);
        print("☁️ Respaldo inicial creado en la nube.");
      }
    } catch (e) {
      print("❌ Error sincronizando: $e");
    }
  }

  // 4. GUARDADO AUTOMÁTICO
  Future<void> autoSave() async {
    if (!isLinked) return;
    
    try {
      final localP = await ProgressManager.loadProgress();
      final jsonToUpload = localP.toJson();
      jsonToUpload['last_update'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(user!.uid).set(jsonToUpload, SetOptions(merge: true));
      print("☁️ Auto-guardado exitoso.");
    } catch (e) {
      print("Error en autosave: $e");
    }
  }
}