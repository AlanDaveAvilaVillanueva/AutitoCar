# Blueprint: Aplicación de Control Remoto Bluetooth

## Resumen

Esta aplicación permitirá a los usuarios controlar un vehículo a control remoto basado en Arduino a través de una conexión Bluetooth. La interfaz proporcionará controles direccionales básicos y botones para gestionar la conexión.

## Estilo y Diseño

- **Tema:** Moderno y limpio, utilizando Material Design 3.
- **Paleta de Colores:** Se utilizará un esquema de colores basado en un color semilla primario (por ejemplo, `Colors.blue`) para generar modos claro y oscuro consistentes.
- **Tipografía:** Se usarán fuentes de `google_fonts` para una apariencia pulida y legible (por ejemplo, Oswald para títulos y Roboto para el cuerpo del texto).
- **Iconografía:** Se utilizarán iconos de Material para los botones de control (flechas para la dirección, play/stop para la conexión) para una comprensión intuitiva.
- **Diseño:** Un diseño centrado y responsivo que se adapta bien a diferentes tamaños de pantalla. Los controles direccionales estarán dispuestos en una formación de cruceta (D-pad).

## Características Implementadas

### Versión Inicial
- **UI de Control:**
    - Botón "CONECTAR" para iniciar el escaneo y la conexión Bluetooth.
    - Botón "DESCONECTAR" para finalizar la conexión.
    - Botones direccionales (Arriba, Abajo, Izquierda, Derecha) dispuestos en una cruceta.
    - Indicador de estado para mostrar si la aplicación está conectada al dispositivo.
- **Lógica de Estado:**
    - Los botones de control direccional estarán deshabilitados hasta que se establezca una conexión Bluetooth exitosa.

## Plan Actual

1.  **Configurar el Proyecto:**
    - Añadir las dependencias necesarias al archivo `pubspec.yaml`:
        - `flutter_blue_plus`: Para la comunicación Bluetooth.
        - `provider`: Para la gestión del estado de la conexión.
        - `google_fonts`: Para la tipografía personalizada.
2.  **Crear la Interfaz de Usuario (UI):**
    - Modificar `lib/main.dart` para establecer el tema de la aplicación y la estructura principal.
    - Crear una nueva pantalla (`control_screen.dart`) que contenga:
        - La cruceta de control direccional.
        - Los botones de conexión y desconexión.
        - Un indicador de estado visual (por ejemplo, un texto que diga "Conectado" o "Desconectado").
3.  **Implementar la Lógica de Conexión Bluetooth:**
    - Crear un servicio (`bluetooth_service.dart`) para encapsular toda la lógica de `flutter_blue_plus`.
    - Implementar las siguientes funcionalidades en el servicio:
        - Escanear dispositivos Bluetooth LE cercanos.
        - Mostrar una lista de dispositivos encontrados para que el usuario seleccione uno.
        - Conectar al dispositivo seleccionado.
        - Desconectar del dispositivo.
        - Enviar datos (comandos de control) a través de una característica Bluetooth.
4.  **Integrar la UI con la Lógica:**
    - Usar `provider` para gestionar el estado de la conexión (escaneando, conectado, desconectado).
    - Vincular los botones de la UI a las funciones del `bluetooth_service`.
    - Actualizar la UI en función de los cambios de estado de la conexión (por ejemplo, habilitar/deshabilitar botones).
    - Al presionar los botones de dirección, enviar el comando correspondiente (por ejemplo, 'F', 'B', 'L', 'R') al dispositivo Arduino.
5.  **Pruebas y Refinamiento:**
    - Ejecutar la aplicación y probar la conexión con el dispositivo Arduino.
    - Asegurar que los comandos se envían y reciben correctamente.
    - Formatear y analizar el código para garantizar la calidad.
