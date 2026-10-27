# Sistema de Gestión de Inventario — API REST + Flutter

**Electiva Profesional I — Desarrollo de Aplicaciones Móviles**  
**Segundo Parcial Práctico — UCEVA**  
**Estudiante:** Johan Eliu Salgado Castro — **Código:** 230232033  

---

## 1. Descripción General de la Solución

Este proyecto corresponde al desarrollo de una solución integral para la administración y control de inventario de productos de un establecimiento comercial. La solución consta de dos componentes principales, funcionales y desacoplados:

1. **Backend (API REST):** Desarrollado con **Node.js** y **Express**, utilizando **SQLite** como motor de persistencia relacional en archivo local (`inventario.db`). Proporciona un CRUD completo, validaciones de reglas de negocio (campos requeridos, código único, precio mayor a cero y cantidad válida) y manejo adecuado de códigos de estado HTTP (200, 201, 404, 422, 500).
2. **Frontend (Aplicación Móvil Flutter):** Desarrollado con **Flutter**, estructurado bajo una separación de responsabilidades (modelos, servicios, router y pantallas). Consume la API REST con el paquete **Dio**, navega mediante **go_router**, gestiona la URL base con **flutter_dotenv** y ofrece una barra de navegación inferior. Incluye un Dashboard que calcula métricas del inventario con datos reales provenientes de la API.

**Despliegue:** no se realizó despliegue en la nube (es opcional según el enunciado). La API y la aplicación se ejecutan de forma local.

---

## 2. Tecnologías Utilizadas

### Backend
* **Entorno de ejecución:** Node.js (v18 o superior)
* **Framework web:** Express.js 4.x
* **Base de datos:** SQLite3 (tablas creadas automáticamente y 12 productos semilla)
* **CORS:** middleware para permitir peticiones desde Flutter (móvil, emulador, web)
* **Dotenv:** carga de variables de entorno desde `.env` (solo el puerto)

### Frontend (Móvil)
* **Framework:** Flutter 3.x / Dart 3.x
* **Cliente HTTP:** `dio` (llamadas asíncronas y manejo de `DioException`)
* **Enrutamiento:** `go_router` (rutas declarativas)
* **Variables de entorno:** `flutter_dotenv` (URL base configurable)
* **Formato de moneda y números:** `intl`
* **Diseño:** Material Design 3

---

## 3. Estructura del Repositorio

```text
inventario-flutter-api/
│
├── backend/                               # Proyecto de la API REST
│   ├── routes/
│   │   └── productos.js                   # Endpoints CRUD y validaciones
│   ├── database.js                        # Conexión SQLite y datos semilla
│   ├── server.js                          # Servidor Express principal
│   ├── peticiones.http                    # Pruebas de endpoints (REST Client / Thunder Client)
│   ├── Postman_Coleccion_Inventario.json  # Colección exportada para Postman
│   ├── package.json                       # Dependencias y scripts de Node
│   ├── .env.example                       # Ejemplo de configuración del puerto
│   └── .env                               # Variables de entorno del backend
│
├── frontend/                              # Proyecto de la aplicación Flutter
│   ├── lib/
│   │   ├── models/
│   │   │   └── producto.dart              # Modelo Producto (fromJson, toJson, cálculos)
│   │   ├── services/
│   │   │   └── producto_service.dart      # Consumo HTTP con Dio y manejo de errores
│   │   ├── router/
│   │   │   └── app_router.dart            # Rutas con go_router
│   │   ├── screens/
│   │   │   ├── main_navigation_screen.dart  # Contenedor con barra de navegación inferior
│   │   │   ├── dashboard_screen.dart        # Dashboard con indicadores
│   │   │   ├── productos_screen.dart        # Listado de productos y acciones CRUD
│   │   │   ├── producto_detalle_screen.dart # Detalle de un producto
│   │   │   └── producto_form_screen.dart    # Formulario de registro y edición
│   │   └── main.dart                      # Punto de entrada e inicialización de dotenv
│   ├── .env.example                       # Ejemplo de variables de entorno de Flutter
│   ├── .env                               # URL base de la API
│   └── pubspec.yaml                       # Dependencias y assets
│
└── README.md                              # Documentación general del parcial
```

---

## 4. Descripción de la Base de Datos

Se utiliza una base de datos relacional SQLite almacenada en el archivo `backend/inventario.db`. La tabla principal es `productos`:

| Campo | Tipo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Identificador único y autogenerado |
| `nombre` | TEXT | NOT NULL | Nombre comercial del producto |
| `codigo` | TEXT | NOT NULL UNIQUE | Código único de referencia |
| `descripcion` | TEXT | NULLABLE | Descripción adicional (opcional) |
| `precio` | REAL | NOT NULL | Precio unitario (debe ser mayor a 0) |
| `cantidad` | INTEGER | NOT NULL | Unidades disponibles (debe ser mayor o igual a 0) |
| `categoria` | TEXT | NOT NULL | Categoría del producto |

> Al ejecutar el servidor por primera vez, si la tabla está vacía se cargan automáticamente **12 productos de prueba** de diversas categorías (Computadores, Accesorios, Audio, Monitores, Redes, etc.).

---

## 5. Endpoints de la API REST

La API implementa los siguientes endpoints bajo el prefijo `/api/productos`:

| Método | Endpoint | Descripción | Códigos HTTP |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/productos` | Lista todos los productos, del más reciente al más antiguo. | `200`, `500` |
| **GET** | `/api/productos/:id` | Consulta el detalle de un producto por su ID. | `200`, `404`, `500` |
| **POST** | `/api/productos` | Registra un producto validando campos obligatorios, código único y valores numéricos. | `201`, `422`, `500` |
| **PUT** | `/api/productos/:id` | Actualiza un producto existente, verificando que el código no colisione con otro. | `200`, `404`, `422`, `500` |
| **DELETE** | `/api/productos/:id` | Elimina un producto tras verificar que existe. | `200`, `404`, `500` |

---

## 6. Ejemplos de Peticiones y Respuestas JSON

### 6.1. Listar productos
* **Petición:** `GET /api/productos`
* **Respuesta (`200 OK`):**
```json
[
  {
    "id": 1,
    "nombre": "Laptop Lenovo ThinkPad",
    "codigo": "PROD-001",
    "descripcion": "Intel Core i5, 16GB RAM, 512GB SSD",
    "precio": 2850000,
    "cantidad": 15,
    "categoria": "Computadores"
  },
  {
    "id": 2,
    "nombre": "Mouse Inalambrico Logitech",
    "codigo": "PROD-002",
    "descripcion": "Conexion Bluetooth y USB 2.4Ghz",
    "precio": 75000,
    "cantidad": 40,
    "categoria": "Accesorios"
  }
]
```

### 6.2. Consultar el detalle de un producto
* **Petición:** `GET /api/productos/1`
* **Respuesta (`200 OK`):**
```json
{
  "id": 1,
  "nombre": "Laptop Lenovo ThinkPad",
  "codigo": "PROD-001",
  "descripcion": "Intel Core i5, 16GB RAM, 512GB SSD",
  "precio": 2850000,
  "cantidad": 15,
  "categoria": "Computadores"
}
```
* **Respuesta si no existe (`404 Not Found`):**
```json
{
  "error": "No se encontro ningun producto con el ID 9999"
}
```

### 6.3. Registrar un producto
* **Petición:** `POST /api/productos`
* **Headers:** `Content-Type: application/json`
* **Cuerpo:**
```json
{
  "nombre": "Monitor Curvo 34 Pulgadas",
  "codigo": "MON-340",
  "descripcion": "Resolucion WQHD 144Hz panel VA",
  "precio": 1850000,
  "cantidad": 7,
  "categoria": "Monitores"
}
```
* **Respuesta (`201 Created`):**
```json
{
  "id": 13,
  "nombre": "Monitor Curvo 34 Pulgadas",
  "codigo": "MON-340",
  "descripcion": "Resolucion WQHD 144Hz panel VA",
  "precio": 1850000,
  "cantidad": 7,
  "categoria": "Monitores"
}
```

### 6.4. Error de validación (código duplicado o campos faltantes)
* **Petición:** `POST /api/productos`
* **Cuerpo (código ya existente):**
```json
{
  "nombre": "Otra Laptop",
  "codigo": "PROD-001",
  "precio": 2000000,
  "cantidad": 4,
  "categoria": "Computadores"
}
```
* **Respuesta (`422 Unprocessable Entity`):**
```json
{
  "error": "El codigo \"PROD-001\" ya se encuentra registrado para otro producto"
}
```

### 6.5. Actualizar un producto
* **Petición:** `PUT /api/productos/1`
* **Cuerpo:**
```json
{
  "nombre": "Laptop Lenovo ThinkPad T14",
  "codigo": "PROD-001",
  "descripcion": "Intel Core i7, 32GB RAM, 1TB SSD",
  "precio": 3200000,
  "cantidad": 18,
  "categoria": "Computadores"
}
```
* **Respuesta (`200 OK`):**
```json
{
  "id": 1,
  "nombre": "Laptop Lenovo ThinkPad T14",
  "codigo": "PROD-001",
  "descripcion": "Intel Core i7, 32GB RAM, 1TB SSD",
  "precio": 3200000,
  "cantidad": 18,
  "categoria": "Computadores"
}
```

### 6.6. Eliminar un producto
* **Petición:** `DELETE /api/productos/12`
* **Respuesta (`200 OK`):**
```json
{
  "mensaje": "Producto \"Router TP-Link WiFi 6\" eliminado correctamente",
  "idEliminado": 12
}
```

---

## 7. Instrucciones de Instalación y Ejecución

### Prerrequisitos
* Node.js v18 o superior.
* Flutter SDK 3.x o superior, configurado en el PATH.
* **JDK 17 o 21** para compilar la app en Android. Las versiones muy recientes de Java (por ejemplo 25) no son compatibles con Gradle y producen errores de compilación. Se puede indicar el JDK con:
  ```bash
  flutter config --jdk-dir "<ruta-al-jdk>"
  ```
* Android Studio con un emulador creado (o un dispositivo físico) si se ejecuta en Android.

---

### Paso 1: Ejecutar el backend

1. Abre una terminal y entra a la carpeta `backend`:
   ```bash
   cd backend
   ```
2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Copia el archivo de ejemplo de variables de entorno (si no existe `.env`):
   ```bash
   cp .env.example .env
   ```
4. Inicia el servidor:
   ```bash
   npm start
   # O en modo desarrollo con recarga automática:
   npm run dev
   ```
5. El servidor queda disponible en `http://localhost:3000` y debe mostrar `Servidor iniciado en puerto 3000`. **Déjalo corriendo** mientras usas la app.

---

### Paso 2: Ejecutar la aplicación Flutter

1. Abre otra terminal y entra a la carpeta `frontend`:
   ```bash
   cd frontend
   ```
2. Copia el archivo de ejemplo de variables de entorno (si no existe `.env`):
   ```bash
   cp .env.example .env
   ```
3. Instala las dependencias de Flutter:
   ```bash
   flutter pub get
   ```
4. **Configura la URL del backend** en `frontend/.env` según dónde ejecutes la app:

   | Dónde se ejecuta | Valor de `API_BASE_URL` |
   | :--- | :--- |
   | Emulador de Android Studio | `http://10.0.2.2:3000/api` |
   | Windows Desktop o Chrome | `http://localhost:3000/api` |
   | Celular físico en la misma red WiFi | `http://TU_IP_LOCAL:3000/api` |

   > En el emulador de Android, `localhost` apunta al propio emulador y no al computador; por eso se usa `10.0.2.2`, que es la dirección del computador anfitrión.

5. Ejecuta la aplicación:
   ```bash
   # Ver los dispositivos disponibles
   flutter devices

   # Emulador o celular Android
   flutter run -d <id-del-dispositivo>

   # Windows Desktop
   flutter run -d windows

   # Chrome (Web)
   flutter run -d chrome
   ```

> **Importante:** el archivo `.env` se lee solo al iniciar la app. Si cambias `API_BASE_URL`, detén la app y vuelve a ejecutar `flutter run`; el hot reload no recarga el `.env`.

---

### Configuración de Android para consumir la API

La API del proyecto usa `http` (sin cifrar), por lo que `frontend/android/app/src/main/AndroidManifest.xml` incluye:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application
    android:usesCleartextTraffic="true"
    ... >
```

* `INTERNET` permite a la app realizar peticiones de red.
* `usesCleartextTraffic="true"` permite conexiones `http` durante el desarrollo local. Con una API desplegada en `https` no sería necesario.

---

## 8. Funcionalidades en Flutter

* **Dashboard principal:**
  * Total de productos registrados.
  * Total de unidades disponibles (suma del stock).
  * Valor económico total del inventario (suma de precio × cantidad de cada producto).
  * Botones de acceso a la gestión de productos y al registro de uno nuevo.
  * Actualización de datos con el botón de refrescar y el gesto de arrastre.
* **Navegación:**
  * Barra inferior con `go_router` entre el Dashboard y la gestión de productos, más rutas para el detalle y el formulario.
* **Gestión de productos (CRUD):**
  * **Listado:** tarjetas con nombre, código, categoría, precio formateado y cantidad disponible.
  * **Detalle:** pantalla con la información completa y el valor del stock de ese producto.
  * **Registro:** formulario con validación (nombre, código, categoría, precio positivo y cantidad válida), enviado con `POST`.
  * **Edición:** precarga los datos del producto y los actualiza con `PUT`.
  * **Eliminación:** diálogo de confirmación antes de enviar el `DELETE`.
* **Estados de la interfaz:**
  * Carga, con indicador circular.
  * Error de comunicación, con mensaje claro y botón **Reintentar**.
  * Ausencia de registros, con un mensaje cuando no hay productos.
  * Mensajes de éxito o fallo tras registrar, actualizar o eliminar.

---

## 9. Solución de Problemas

| Problema | Causa probable | Solución |
| :--- | :--- | :--- |
| "Ocurrió un problema al conectar con el servidor" en el emulador | `API_BASE_URL` usa `localhost`, o el backend no está corriendo | Usar `http://10.0.2.2:3000/api`, reiniciar la app (`flutter run`) y verificar que el backend muestre `Servidor iniciado en puerto 3000` |
| La app no se conecta aunque la URL es correcta | Falta el permiso de red o el tráfico `http` está bloqueado | Revisar `INTERNET` y `usesCleartextTraffic` en `AndroidManifest.xml` y recompilar |
| Error de Gradle por incompatibilidad con Java | Se usa un JDK demasiado nuevo (por ejemplo 25) | Instalar JDK 17 o 21 y configurarlo con `flutter config --jdk-dir` |
| `flutter run -d chrome` no abre el navegador | `CHROME_EXECUTABLE` apunta a otro navegador | Ejecutar en el emulador o en Windows, o ajustar la variable de entorno |

---

## 10. Control de Versiones

Los cambios se registran con commits descriptivos que siguen un estándar de prefijos:

| Prefijo | Uso |
| :--- | :--- |
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de errores |
| `docs:` | Cambios en la documentación |
| `refactor:` | Reorganización de código sin cambiar su comportamiento |
| `chore:` | Configuración y tareas de mantenimiento |

Ejemplo: `docs: actualiza README con ejecución en emulador Android y solución de problemas`.

---

## 11. Seguridad

No se incluyen contraseñas, credenciales ni secretos en el repositorio. Los archivos `.env` contienen únicamente la URL base de la API (Flutter) y el puerto (backend).
