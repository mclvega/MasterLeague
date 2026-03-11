# 📁 Datos de Prueba - Master League Football

Este directorio contiene la documentación para probar la funcionalidad de importación de la aplicación Master League Football desde **Google Sheets**.

## 🌐 **URL de Datos Disponible**

### 🏆 **Google Sheets - Master League Data** 
- **URL**: https://docs.google.com/spreadsheets/d/e/2PACX-1vTsm9lKG47riaFnkatYOoaTbsExVhVtlIIOBjLczg-6gAJ2Kc33s6w3_zZtC6tQQw/pubhtml
- **Contenido**: TODOS los datos organizados en **5 hojas separadas**
- **Hojas incluidas**:
  - 🌟 **Jugadores Principales** (49 estrellas mundiales)
  - 🚀 **Jovenes Talentos** (42 jóvenes promesas)
  - ⚽ **Agentes Libres** (30 jugadores sin equipo)
  - 🏟️ **Equipos** (20 clubes principales)
  - 🏆 **Competiciones** (20 torneos/ligas)
- **Ventajas**: 
  - ✅ **Acceso en línea** - sin necesidad de archivos locales
  - ✅ **Siempre actualizado** - se lee directamente desde la nube
  - ✅ **Formato Excel nativo** con colores y estilos
  - ✅ **Hojas organizadas** por categoría
  - ✅ **Fácil navegación** entre datos
  - ✅ **Acceso universal** desde cualquier dispositivo

## 🚀 Cómo Usar

### Importar desde URL de Google Sheets
1. Abre la aplicación Master League Football
2. Toca el ícono de importación (📁) en la parte superior
3. Selecciona **"Importar desde URL"**
4. Pega esta URL: 
   ```
   https://docs.google.com/spreadsheets/d/e/2PACX-1vTsm9lKG47riaFnkatYOoaTbsExVhVtlIIOBjLczg-6gAJ2Kc33s6w3_zZtC6tQQw/pubhtml
   ```
5. Confirma la importación

> **📝 Nota**: La aplicación detecta automáticamente que es una URL de Google Sheets y la convierte al formato correcto para descargar los datos.

## 📊 Datos Incluidos

### 🏃‍♂️ **Jugadores (Total: 121 jugadores)**
- **Principales (49)**: Estrellas actuales con ratings 80-91 (Messi, Haaland, Mbappé...)
- **Jóvenes (42)**: Talentos menores de 26 años (Pedri, Bellingham, Gavi...)
- **Libres (30)**: Jugadores disponibles sin contrato (Sergio Ramos, Adrien Rabiot...)

### 🏟️ **Equipos (20 clubes)**
- Presupuestos realistas (€120M - €900M)
- Principales ligas europeas (Premier League, La Liga, Serie A...)
- Información de propietarios y fundación

### 🏆 **Competiciones (20 torneos)**
- Champions League, Europa League 
- Principales ligas (Premier, LaLiga, Serie A, Bundesliga...)
- Copas nacionales y torneos internacionales

## 📈 **Columnas Incluidas**

### Jugadores
- **Name**: Nombre del jugador
- **Position**: GK, DEF, MID, FW
- **Price**: Valor de mercado (€)
- **Overall**: Rating 70-91
- **Club**: Equipo actual
- **Nationality**: País de origen
- **Age**: 18-40 años

### Equipos  
- **Team Name, Owner, Budget, League, Country, Founded**

### Competiciones
- **Competition, Type, Status, Start Date, End Date, Prize Pool, Participants**

## 🧪 Casos de Prueba Sugeridos

1. **🌐 Importación desde Google Sheets**: Usa la URL proporcionada
2. **🔍 Búsquedas**: Busca "Messi", "Real Madrid", "Champions"
3. **🎯 Filtros**: Filtra por posición (GK, DEF, MID, FW)
4. **💰 Ordenación**: Ordena por precio, edad, rating
5. **⚽ Jugadores libres**: Navega a la hoja "Agentes Libres"
6. **🏟️ Por equipos**: Ve distribución de jugadores por club
7. **📊 Navegación**: Prueba cambiar entre hojas de los datos importados
8. **🔄 Datos múltiples**: Re-importa para actualizar datos

## ⚡ **Ventajas del Google Sheets**
- ✅ **Acceso en línea** - no necesitas archivos locales
- ✅ **Siempre actualizado** - datos en tiempo real
- ✅ **Hojas separadas** por categoría (navegación fácil)
- ✅ **Formato visual** con colores y estilos
- ✅ **Columnas auto-ajustadas** para lectura óptima
- ✅ **Compatible universal** - funciona en cualquier dispositivo
- ✅ **Fácil de editar** - modifica datos directamente en Google Sheets
- ✅ **Colaborativo** - múltiples usuarios pueden actualizar los datos

## 🎮 Funcionalidades a Probar

- ✅ Importación desde URL de Google Sheets
- ✅ Detección automática de formato Excel
- ✅ Navegación entre hojas importadas
- ✅ Búsqueda por nombre de jugador
- ✅ Filtrado por posición y equipo
- ✅ Ordenación por múltiples criterios
- ✅ Vista de jugadores libres
- ✅ Detalles completos de jugadores
- ✅ Organización por equipos
- ✅ Gestión de competiciones

## 🎯 **Datos Destacados para Probar**

### ⭐ **Jugadores Estrella**
- Lionel Messi (Inter Miami) - €50M
- Kylian Mbappé (PSG) - €180M
- Erling Haaland (Man City) - €180M

### 🌟 **Jóvenes Promesas**
- Jude Bellingham (Real Madrid) - €150M
- Pedri (Barcelona) - €100M
- Warren Zaïre-Emery (PSG) - €40M

### ⚽ **Agentes Libres Destacados**
- Sergio Ramos - €5M
- Adrien Rabiot - €25M
- James Rodríguez - €10M

¡Disfruta probando la aplicación Master League Football con datos profesionales desde la nube! 🌐⚽🏆📊

## 🔧 **Información Técnica**

La aplicación detecta automáticamente URLs de Google Sheets y las convierte al formato correcto:
- **URL de edición** (la que proporcionas) → **URL de exportación** (para descargar datos)
- **Formato**: Se descarga automáticamente como Excel (.xlsx)
- **Compatibilidad**: Funciona con cualquier Google Sheets público o compartido
- **Velocidad**: Descarga directa sin intermediarios