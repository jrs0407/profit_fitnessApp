# 🏋️‍♀️ ProFit - Entrenamientos Online por Niveles

**ProFit** es una app móvil desarrollada con **Flutter** que ofrece programas de entrenamiento online estructurados según el nivel de experiencia del usuario. Utiliza **Firebase** para autenticación, base de datos en la nube y almacenamiento, brindando una experiencia personalizada, segura y escalable.

## 🚀 Funcionalidades principales

- 🔐 Autenticación con Firebase (email y Google)
- 🧭 Planes de entrenamiento desbloqueables por nivel
- 📆 Entrenamiento diario/semanal 
- 🧠 Gráficas interactivas que muestran el historial del usuario
- 📹 Instrucciones detalladas con imágenes y/o videos
- 🔄 Sincronización en tiempo real con Firestore

## 💎 Versión Premium

La versión **ProFit Premium** desbloquea funcionalidades exclusivas:

- 👨‍🏫 **Asignación de entrenador personal**: los usuarios premium son emparejados con un entrenador que diseña rutinas personalizadas según sus objetivos, nivel y progreso.
- 📝 **Rutinas personalizadas**: cada plan es ajustado semanalmente según el rendimiento del usuario.
- 📈 **Seguimiento individualizado**: el entrenador puede monitorear el progreso y ajustar cargas, repeticiones y descansos.
- 🛠️ **Panel de gestión para entrenadores**: los entrenadores tienen acceso a un panel donde pueden crear, asignar, editar y revisar las rutinas de sus clientes de forma simple y rápida.


## 🧱 Tecnologías utilizadas

- [Flutter]– SDK multiplataforma para el desarrollo móvil junto con Android Studio
- [Firebase Authentication]– Registro e inicio de sesión
- [Cloud Firestore] – Base de datos en tiempo real
- [StatelessWidget / StatefulWidget] - Gestión del Estado

## 📲 Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/jrs0407/profit_fitnessApp.git
   cd profit-app

2. Descarga el apk:

    Realiza el siguiente comando y tras completarse dirigete a build\app\outputs\flutter-apk\app-release.apk 
    
    ```bash
    flutter build apk --release

    
