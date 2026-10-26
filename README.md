# Sistema de Gestión de Inventario — API REST + Flutter

**Electiva Profesional I — Desarrollo de Aplicaciones Móviles**  
**Segundo Parcial Práctico — UCEVA**  
**Estudiante:** Johan Eliu Salgado Castro  

---

## 1. Descripción General de la Solución

Este proyecto corresponde al desarrollo de una solución integral para la administración y control de inventario de productos de un establecimiento comercial. La solución consta de dos componentes principales completamente funcionales y desacoplados:

1. **Backend (API REST):** Desarrollado con **Node.js** y **Express**, utilizando **SQLite** como motor de persistencia relacional en archivo local (`inventario.db`). Proporciona una arquitectura CRUD completa, validaciones de reglas de negocio (campos requeridos, código único, validación de stock y precios mayores a cero) y manejo adecuado de códigos de estado HTTP (200, 201, 404, 422, 500).
2. **Frontend (Aplicación Móvil Flutter):** Desarrollado con **Flutter**, estructurado bajo una separación limpia de responsabilidades (Modelos, Servicios y Pantallas). Consume la API REST utilizando obligatoriamente el paquete **Dio**, navega entre pantallas mediante **GoRouter**, gestiona las variables de entorno con **flutter_dotenv** y ofrece una navegación intuitiva mediante una barra inferior (**BottomNavigationBar**). Incluye un Dashboard interactivo que calcula en tiempo real métricas clave del inventario.

---

## 2. Tecnologías Utilizadas

### Backend
* **Entorno de ejecución:** Node.js (v20+)
* **Framework Web:** Express.js 4.x
* **Base de Datos:** SQLite3 (con inicialización automática de tablas y 12 productos semilla)
* **CORS:** Middleware para permitir peticiones entre orígenes (Flutter Web / Móvil / Emulador)
* **Dotenv:** Carga de variables de entorno desde `.env`

### Frontend (Móvil)
* **Framework:** Flutter 3.x / Dart 3.x
* **Cliente HTTP:** `dio: ^5.11.1` (gestión de llamadas asíncronas y excepciones de red `DioException`)
* **Enrutamiento:** `go_router: ^18.1.1` (rutas declarativas)
* **Variables de Entorno:** `flutter_dotenv: ^6.0.1` (configuración de URL base dinámica)
* **Formateo de Moneda y Números:** `intl: ^0.20.2`
* **Diseño:** Material Design 3 con componentes adaptativos

---

## 3. Estructura del Repositorio

El proyecto se encuentra organizado en dos directorios principales:

```text
inventario-flutter-api/
│
├── backend/                               # Proyecto de la API REST
│   ├── routes/
│   │   └── productos.js                   # Endpoints CRUD y validaciones
│   ├── database.js                        # Conexion SQLite y datos semilla iniciales
│   ├── server.js                          # Servidor Express principal
│   ├── peticiones.http                    # Archivo para probar endpoints con REST Client / Thunder Client
│   ├── Postman_Coleccion_Inventario.json  # Coleccion exportada para Postman
│   ├── package.json                       # Dependencias y scripts de Node
│   ├── .env.example                       # Ejemplo de configuracion de puerto
│   └── .env                               # Variables de entorno del backend
│
├── frontend/                              # Proyecto de la aplicacion Flutter
│   ├── lib/
│   │   ├── models/
│   │   │   └── producto.dart              # Modelo Producto (fromJson, toJson, calculos)
│   │   ├── services/
│   │   │   └── producto_service.dart      # Capa de consumo HTTP con Dio y manejo de errores
│   │   ├── router/
│   │   │   └── app_router.dart            # Definicion de rutas con go_router
│   │   ├── screens/
│   │   │   ├── main_navigation_screen.dart# Contenedor con BottomNavigationBar
│   │   │   ├── dashboard_screen.dart      # Dashboard con indicadores en tiempo real
│   │   │   ├── productos_screen.dart      # Listado de productos y acciones CRUD
│   │   │   ├── producto_detalle_screen.dart # Consulta detallada de producto
│   │   │   └── producto_form_screen.dart  # Formulario para registrar y editar
│   │   └── main.dart                      # Punto de entrada e inicializacion de dotenv
│   ├── .env.example                       # Ejemplo de variables de entorno de Flutter
│   ├── .env                               # URL base configurada (localhost / 10.0.2.2 / IP)
│   └── pubspec.yaml                       # Dependencias de paquetes y assets
│
└── README.md                              # Documentacion general del parcial
```

---

## 4. Descripción de la Base de Datos

Se utiliza una base de datos relacional SQLite almacenada en el archivo `backend/inventario.db`. La tabla principal es `productos`:

| Campo | Tipo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Identificador único y autogenerado |
| `nombre` | TEXT | NOT NULL | Nombre comercial del producto |
| `codigo` | TEXT | NOT NULL UNIQUE | Código único de referencia del producto |
| `descripcion` | TEXT | NULLABLE | Descripción adicional o detalles técnicos (opcional) |
| `precio` | REAL | NOT NULL | Precio unitario del producto (debe ser > 0) |
| `cantidad` | INTEGER | NOT NULL | Unidades disponibles en stock (debe ser >= 0) |
| `categoria` | TEXT | NOT NULL | Categoría a la que pertenece el producto |

> Al ejecutar el servidor por primera vez, si la tabla está vacía, se cargan automáticamente **12 productos de prueba** cubriendo diversas categorías (Computadores, Accesorios, Audio, Monitores, Redes, etc.).

---

## 5. Endpoints de la API REST

La API implementa los siguientes endpoints bajo el prefijo `/api/productos`:

| Método | Endpoint | Descripción | Códigos HTTP |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/productos` | Obtiene la lista completa de productos ordenados del más reciente al más antiguo. | `200 OK`, `500 Internal Error` |
| **GET** | `/api/productos/:id` | Consulta los detalles completos de un producto específico por su ID. | `200 OK`, `404 Not Found`, `500 Internal Error` |
| **POST** | `/api/productos` | Registra un nuevo producto validando campos obligatorios, código único y valores numéricos. | `201 Created`, `422 Unprocessable`, `500 Internal Error` |
| **PUT** | `/api/productos/:id` | Actualiza la información de un producto existente asegurando que el código no colisione con otro producto. | `200 OK`, `404 Not Found`, `422 Unprocessable`, `500` |
| **DELETE** | `/api/productos/:id` | Elimina permanentemente un producto de la base de datos previa verificación de su existencia. | `200 OK`, `404 Not Found`, `500 Internal Error` |

---

## 6. Ejemplos de Peticiones y Respuestas JSON

### 6.1. Listar Productos
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

### 6.2. Consultar Detalle de un Producto
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

### 6.3. Registrar Producto (POST)
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

### 6.4. Error de Validación en Registro (Campos Faltantes o Código Duplicado)
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

### 6.5. Actualizar Producto (PUT)
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

### 6.6. Eliminar Producto (DELETE)
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
* Node.js v18 o superior instalado.
* Flutter SDK (3.x o superior) instalado y configurado en el PATH.

---

### Paso 1: Ejecutar el Backend

1. Abre una terminal y navega a la carpeta `backend`:
   ```bash
   cd backend
   ```
2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Inicia el servidor:
   ```bash
   npm start
   # O en modo desarrollo con recarga automatica:
   npm run dev
   ```
4. El servidor estará disponible en `http://localhost:3000`.

---

### Paso 2: Ejecutar la Aplicación Flutter

1. Abre otra terminal y navega a la carpeta `frontend`:
   ```bash
   cd frontend
   ```
2. Instala las dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. **Configuración de la URL del Backend (`.env`):**
   Abre el archivo `frontend/.env` y ajusta según tu entorno de ejecución:
   * **Si ejecutas Flutter en Windows Desktop o Chrome:**
     ```env
     API_BASE_URL=http://localhost:3000/api
     ```
   * **Si ejecutas en el Emulador Android:**
     ```env
     API_BASE_URL=http://10.0.2.2:3000/api
     ```
   * **Si ejecutas en un dispositivo físico conectado a la misma red WiFi:**
     ```env
     API_BASE_URL=http://192.168.1.XX:3000/api
     ```
4. Ejecuta la aplicación:
   ```bash
   # Para probar en Windows Desktop:
   flutter run -d windows

   # Para probar en Chrome (Web):
   flutter run -d chrome

   # Para probar en tu emulador o celular Android:
   flutter run
   ```

---

## 8. Funcionalidades en Flutter

* **Dashboard Principal:**
  * Indicador de total de tipos de productos registrados en base de datos.
  * Indicador de total de unidades físicas disponibles (suma de stock).
  * Indicador de valor económico global del inventario ($\sum \text{precio} \times \text{cantidad}$).
  * Botones de navegación directa a productos y nuevo registro.
  * Botón y gesto de actualizar datos (`RefreshIndicator`).
* **Navegación:**
  * Barra inferior (`BottomNavigationBar`) mediante `go_router` con transiciones fluidas entre Dashboard y Gestión de Productos.
* **Gestión de Productos (CRUD):**
  * **Listado:** visualización con tarjetas, código, categoría, precio formateado y chip indicador de stock.
  * **Detalle:** pantalla dedicada con información completa, cálculo individual de valor monetario en stock y botones de acción.
  * **Registro:** formulario con validación en tiempo real (nombre, código único, categoría, precio positivo y stock válido).
  * **Edición:** precarga los datos originales del producto y actualiza mediante `PUT`.
  * **Eliminación:** modal de diálogo de confirmación (`AlertDialog`) para evitar eliminaciones accidentales.
* **Estados de la Interfaz:**
  * Estado de carga con indicador circular.
  * Estado de error de red con mensaje explicativo y botón para reintentar.
  * Estado vacío cuando no hay registros en la base de datos.
