# AutitoCar Control Blueprint

## Visión General

**AutitoCar Control** es una aplicación móvil moderna, diseñada en Flutter, para controlar un vehículo robotizado (como un coche Arduino) a través de WiFi. La aplicación ofrece una interfaz de usuario elegante, profesional e intuitiva, optimizada para un control preciso y en tiempo real.

---

## Diseño y Estilo

La aplicación sigue los principios de Material Design 3, con un enfoque en la claridad, la elegancia y la experiencia de usuario.

*   **Paleta de Colores:** Combinación de tonos oscuros y grisáceos (`#1E1E1E`, `#2D2D2D`) con un color de acento vibrante y moderno como el verde eléctrico (`#00FF00`) para indicar estados activos y resaltar elementos interactivos.
*   **Tipografía:** Se utiliza la fuente "Roboto", estándar de Material Design, para garantizar la legibilidad y una apariencia limpia.
*   **Iconografía:** Iconos de Material Icons, claros y consistentes, para representar acciones como conectar, avanzar, retroceder, etc.
*   **Estilo de Componentes:**
    *   **Botones:** Grandes, con esquinas redondeadas y un sutil efecto de sombra para dar una sensación de profundidad. El color de acento se usa para indicar el estado presionado.
    *   **Tarjetas:** La tarjeta de estado de conexión tiene un fondo que coincide con el tema, bordes redondeados y una sombra suave para destacarla del fondo.

---

## Características Implementadas

### 1. Conectividad WiFi

*   **Conexión a Host Local:** Al presionar "CONECTAR", la aplicación intenta establecer una conexión con el host local del Arduino a través de una dirección IP predefinida.
*   **Indicador de Estado:** Una tarjeta prominente en la parte superior muestra claramente si el dispositivo está **"CONECTADO"** (verde) o **"DESCONECTADO"** (rojo), con iconos y colores intuitivos.

### 2. Sistema de Control Avanzado

*   **Panel de Control Principal:** Un D-pad (cruceta de control direccional) prominente y sensible para un control preciso del movimiento del vehículo.
*   **Controles Direccionales:**
    *   **Avanzar (`W`):** Mueve el vehículo hacia adelante.
    *   **Retroceder (`S`):** Mueve el vehículo hacia atrás.
    *   **Izquierda (`A`):** Gira el vehículo hacia la izquierda.
    *   **Derecha (`D`):** Gira el vehículo hacia la derecha.
*   **Acciones Adicionales:**
    *   **Bocina (`H`):** Activa una bocina en el vehículo.
    *   **Luces (`L`):** Enciende o apaga las luces del vehículo.

### 3. Feedback Visual y Táctil

*   **Respuesta a la Pulsación:** Los botones del D-pad cambian de color o tamaño al ser presionados, proporcionando una respuesta visual inmediata.
*   **Vibración (Haptic Feedback):** Se activa una sutil vibración al presionar los botones, mejorando la experiencia táctil del usuario.

## Arquitectura y Estado

*   **Gestión de Estado:** Se utiliza el paquete `provider` para gestionar el estado de la conexión WiFi de manera eficiente. Un `ChangeNotifier` (`ConnectionProvider`) centraliza la lógica de conexión y notifica a la UI sobre cualquier cambio.
*   **Lógica de Negocio Separada:** La lógica de conexión WiFi y el envío de comandos están encapsulados en el `ConnectionProvider`, manteniendo la UI (`ControlScreen`) limpia y centrada en la presentación.
