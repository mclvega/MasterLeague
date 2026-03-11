# Master League Football

Una aplicación Flutter diseñada para gestionar y organizar ligas master de fútbol. Proporciona herramientas integrales para la gestión de jugadores, equipos y competiciones.

## Características

### 🗂️ Importación de Archivos
- Lectura de datos de jugadores desde archivos de texto o Excel
- Soporte para archivos locales y URLs remotas
- Detección automática de formatos (.xlsx, .xls, .txt, .csv)
- Análisis inteligente de columnas con nombres en español e inglés

### 👥 Gestión de Jugadores
- Visualización y organización de plantillas de jugadores para cada equipo
- Seguimiento de jugadores libres no asignados a ningún equipo
- Búsqueda y filtrado avanzado por posición, nombre, club, etc.
- Información detallada: precios, valoraciones, edad, nacionalidad

### 🏆 Gestión de Competiciones
- Organización de varias copas, ligas y torneos
- Estados de competición: próximas, en curso, finalizadas
- Seguimiento de equipos participantes y premios
- Información detallada de reglas y fechas

### 👨‍💼 Gestión de Equipos
- Vista integral de equipos y asignación de jugadores
- Seguimiento de presupuestos y valores de plantilla
- Información de propietarios y estadísticas del equipo

## Stack Tecnológico

- **Flutter**: Framework multiplataforma para desarrollo móvil
- **Provider**: Gestión de estado reactivo
- **Excel**: Capacidades de lectura de archivos Excel
- **HTTP/Dio**: Solicitudes HTTP para importación desde URLs
- **File Picker**: Selección de archivos locales
- **Material Design**: UI responsiva y moderna

## Estructura del Proyecto

```
lib/
├── models/           # Modelos de datos (Player, Team, Competition)
├── providers/        # Gestión de estado con Provider
├── screens/          # Pantallas de la aplicación
│   ├── home_screen.dart
│   ├── players/
│   ├── teams/
│   ├── competitions/
│   ├── free_agents/
│   └── import/
├── services/         # Servicios (importación de archivos)
├── utils/            # Utilidades (tema, constantes)
├── widgets/          # Widgets reutilizables
└── main.dart         # Punto de entrada
```

## Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd master_league
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## Uso

### Importación de Datos

1. **Desde archivo local:**
   - Toca el ícono de importación en la barra superior
   - Selecciona "Seleccionar Archivo"
   - Elige tu archivo Excel o CSV

2. **Desde URL:**
   - Introduce la URL del archivo en el campo correspondiente
   - Toca "Importar desde URL"

### Formato de Archivo Esperado

Los archivos deben incluir las siguientes columnas (el orden no importa):
- **Name/Nombre**: Nombre del jugador
- **Position/Posición**: Posición del jugador (GK, DEF, MID, FW, etc.)
- **Price/Precio**: Precio del jugador
- **Overall/OVR**: Valoración general (0-100)
- **Club/Equipo**: Club actual del jugador
- **Nationality/Nacionalidad**: Nacionalidad del jugador
- **Age/Edad**: Edad del jugador

### Navegación

- **Dashboard**: Vista general con estadísticas y actividad reciente
- **Jugadores**: Lista completa con búsqueda y filtros
- **Equipos**: Gestión de equipos y plantillas
- **Competiciones**: Organización de ligas, copas y torneos
- **Libres**: Jugadores disponibles sin equipo

## Funcionalidades Principales

### Búsqueda y Filtros
- Búsqueda por nombre, posición, club o nacionalidad
- Filtrado por posición específica
- Ordenación por nombre, precio, overall o edad
- Orden ascendente/descendente

### Gestión de Estado
- Actualización reactiva de la UI
- Persistencia de datos durante la sesión
- Manejo de errores y estados de carga

### Interfaz de Usuario
- Diseño Material Design responsive
- Tarjetas informativas para jugadores y equipos
- Códigos de colores por posición
- Diálogos detallados para información adicional

## Dependencias Principales

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.1           # Gestión de estado
  excel: ^4.0.0              # Lectura Excel
  file_picker: ^6.1.1        # Selección archivos
  http: ^1.1.0               # Solicitudes HTTP
  dio: ^5.3.2                # Cliente HTTP avanzado
  sqflite: ^2.3.0            # Base datos local
  shared_preferences: ^2.2.2  # Preferencias
  intl: ^0.18.1              # Internacionalización
  flutter_spinkit: ^5.2.0   # Indicadores carga
```

## Configuración de Desarrollo

### Extensiones VS Code Recomendadas
- Flutter
- Dart
- Flutter Widget Snippets

### Comandos Útiles

```bash
# Análisis de código
flutter analyze

# Formateo de código
flutter format lib/

# Construcción para producción
flutter build apk

# Tests
flutter test
```

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Contacto

Para soporte o consultas, please contact [tu-email@ejemplo.com]

---

**¡Disfruta gestionando tu liga master de fútbol! ⚽**