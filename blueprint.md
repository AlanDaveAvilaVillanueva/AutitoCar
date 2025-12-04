# AutitoCar Firebase Control Blueprint

## Visión General

**AutitoCar Control** es una aplicación móvil moderna, diseñada en Flutter, para controlar un vehículo robotizado (como un coche Arduino) a través de **Firebase Realtime Database**. La aplicación ofrece una interfaz de usuario elegante y en tiempo real, eliminando la necesidad de una conexión WiFi directa y permitiendo el control desde cualquier lugar con acceso a internet.

---

## Diseño y Estilo

El diseño se mantiene consistente con la versión anterior, enfocado en Material Design 3.

*   **Paleta de Colores:** Combinación de tonos oscuros y grisáceos (`#1E1E1E`, `#2D2D2D`) con un color de acento vibrante para estados y acciones. El verde (`#00FF00`) indicará la conexión exitosa con Firebase y el rojo para el estado desconectado.
*   **Tipografía:** Se utiliza la fuente "Roboto".
*   **Iconografía:** Iconos de Material Icons para todas las acciones.

---

## Plan de Implementación: Integración con Firebase

Esta sección describe los pasos para migrar el control del vehículo de una conexión WiFi local a Firebase Realtime Database.

### 1. Arquitectura Firebase
*   **Autenticación:** La aplicación utilizará **autenticación anónima** de Firebase. Cada vez que un usuario abre la aplicación, se creará una sesión anónima y segura, permitiendo una interacción autorizada con la base de datos sin necesidad de un login tradicional.
*   **Realtime Database:** Se usará Firebase Realtime Database como puente de comunicación. La app escribirá comandos en una ruta específica (ej: `/control/command`), y el Arduino estará escuchando los cambios en esa misma ruta para actuar en consecuencia.

### 2. Modificaciones en el Proyecto

*   **Añadir Dependencias:** Se agregarán los siguientes paquetes a `pubspec.yaml`:
    *   `firebase_core`: Para inicializar la conexión con el proyecto de Firebase.
    *   `firebase_auth`: Para gestionar la autenticación anónima.
    *   `firebase_database`: Para la comunicación en tiempo real con el Arduino.

*   **Inicialización de Firebase:**
    *   Se configurará el `main.dart` para que inicialice Firebase antes de que la aplicación se inicie.
    *   Se añadirán los archivos de configuración de Firebase (`google-services.json` para Android y `GoogleService-Info.plist` para iOS) al proyecto.

*   **Refactorización del `ConnectionProvider`:**
    *   El actual `ConnectionProvider` que maneja la conexión por socket será reemplazado.
    *   El nuevo provider se llamará `FirebaseConnectionProvider`.
    *   **Funcionalidad:**
        *   Manejará el proceso de inicio de sesión anónimo con `FirebaseAuth`.
        *   Mantendrá una referencia a la base de datos de Realtime Database.
        *   Tendrá un método `sendCommand(String command)` que escribirá el comando (ej: "W", "S", "A", "D") en la ruta `/control/command` de la base de datos.
        *   Tendrá una propiedad `isConnected` que será `true` si el usuario está autenticado anónimamente y `false` en caso contrario.

### 3. Actualización de la Interfaz de Usuario (`ControlScreen`)

*   **Indicador de Estado:** La tarjeta de estado ya no dirá "CONECTAR". En su lugar, mostrará el estado de la conexión con Firebase:
    *   **"CONECTADO A FIREBASE"** (en verde) cuando la autenticación anónima sea exitosa.
    *   **"DESCONECTADO"** (en rojo) si hay un problema con la conexión o autenticación.
*   **Lógica de Botones:** Los `onPressed` y `onLongPress` de los botones de control ya no enviarán datos a través de un socket. En su lugar, llamarán al método `firebaseConnectionProvider.sendCommand('W')`, `firebaseConnectionProvider.sendCommand('H')`, etc.

Con estos cambios, la aplicación pasará de un control local y limitado a una solución robusta y escalable en la nube, permitiendo una experiencia de control mucho más flexible.