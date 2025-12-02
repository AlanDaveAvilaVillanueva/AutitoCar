# AutitoCar Control Blueprint

## Visión General

**AutitoCar Control** es una aplicación móvil moderna, diseñada en Flutter, para controlar un vehículo robotizado (como un coche Arduino) a través de Bluetooth Low Energy (BLE). La aplicación ofrece una interfaz de usuario elegante, profesional e intuitiva, optimizada para un control preciso y en tiempo real.

---

## Diseño y Estilo

La aplicación sigue los principios de Material Design 3, con un enfoque en la claridad, la elegancia y la experiencia de usuario.

*   **Paleta de Colores:** Se utiliza una paleta profesional basada en **azul índigo (`Colors.indigo`)**. El tema oscuro está activado por defecto para una apariencia sobria, con una alternativa de tema claro.
*   **Tipografía:** La fuente principal es **`Poppins`** de Google Fonts, que aporta un aspecto limpio, moderno y de alta calidad.
*   **Fondo:** La aplicación utiliza un sutil **degradado de fondo** para añadir profundidad y una sensación premium, eliminando los fondos planos.
*   **Componentes Visuales:**
    *   **Tarjetas:** Los elementos como el indicador de estado se presentan en tarjetas con esquinas redondeadas y sombras suaves para un efecto "elevado".
    *   **Botones:** Los botones tienen un estilo consistente, con esquinas redondeadas, sombras pronunciadas y, en el caso de la cruceta, un efecto de degradado para una apariencia táctil.

---

## Características Implementadas

### 1. Conectividad Bluetooth LE

*   **Escaneo de Dispositivos:** Al presionar "CONECTAR", la aplicación busca dispositivos Bluetooth LE cercanos.
*   **Lista de Dispositivos:** Muestra los dispositivos encontrados en un panel inferior deslizable, indicando su nombre y dirección.
*   **Conexión/Desconexión:** Permite al usuario seleccionar un dispositivo para conectarse e incluye un botón "APAGAR" para finalizar la conexión.
*   **Indicador de Estado:** Una tarjeta prominente en la parte superior muestra claramente si el dispositivo está **"CONECTADO"** (verde) o **"DESCONECTADO"** (rojo), con iconos y colores intuitivos.

### 2. Sistema de Control Avanzado

*   **Control Táctil (Pulsar y Mantener):**
    *   Al **mantener presionado** un botón de dirección (adelante, atrás, izquierda, derecha), la aplicación envía el comando de movimiento correspondiente.
    *   Al **soltar** el botón, la aplicación envía automáticamente un comando de **detención (`stop`)**, permitiendo un control preciso y en tiempo real.
    *   Esto elimina la necesidad de un botón "Stop" dedicado, simplificando la interfaz.

*   **Slider de Velocidad:**
    *   Una vez conectado, aparece un **control deslizante (slider)** que permite ajustar la velocidad del vehículo.
    *   El rango de velocidad es de **0 a 255**.
    *   El comando de velocidad (ej. `S:150`) se envía cuando el usuario termina de ajustar el slider para optimizar la comunicación.

### 3. Interfaz de Usuario

*   **Tema Dual (Claro/Oscuro):** Incluye un botón en la barra de navegación para cambiar fácilmente entre el modo claro y oscuro, adaptándose a las preferencias del usuario.
*   **Diseño Responsivo:** La interfaz está construida para adaptarse a diferentes tamaños de pantalla.
*   **Sin Banner de "DEBUG":** La cinta de depuración ha sido eliminada para una apariencia de producción limpia.

---

## Plan para la Sesión Actual

*   **Objetivo:** Añadir un slider de velocidad y un sistema de control de "pulsar y mantener" para los botones de movimiento.
*   **Pasos Realizados:**
    1.  Se convirtió la pantalla `ControlScreen` en un `StatefulWidget` para manejar el estado del slider.
    2.  Se añadió un widget `Slider` para controlar la velocidad, visible solo cuando hay una conexión activa.
    3.  Se reemplazaron los `ElevatedButton` de la cruceta por `GestureDetector` para capturar los eventos `onTapDown` (presionar) y `onTapUp` (soltar).
    4.  Se implementó la lógica para enviar el comando de movimiento al presionar y el comando `stop` al soltar.
    5.  Se eliminó el botón "Stop" central, ya que la nueva lógica lo hace innecesario.
    6.  Se documentaron todas las nuevas características en este `blueprint.md`.

