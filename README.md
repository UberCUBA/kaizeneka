# Kaizeneka

Aplicación móvil Flutter para el desarrollo personal y hábitos saludables.

## Arquitectura del Proyecto

Este proyecto incluye:
- **Aplicación Flutter**: Interfaz móvil principal
- **API .NET**: Backend API desarrollado en ASP.NET Core
- **Base de datos Supabase**: Almacenamiento y autenticación

## Despliegue de la API en Render.com

### Preparación
1. Asegúrate de que el código esté en un repositorio Git (GitHub, GitLab, etc.)
2. La API está configurada para usar Docker y Render.com detectará automáticamente el archivo `render.yaml`

### Configuración en Render.com
1. Ve a [Render.com](https://render.com) y crea una nueva cuenta o inicia sesión
2. Selecciona **"Web Service"** como tipo de servicio (no Static Site, ya que es una API dinámica)
3. Conecta tu repositorio Git
4. Render.com detectará el archivo `render.yaml` y configurará el servicio automáticamente

### Variables de Entorno Sensibles
Configura las siguientes variables de entorno en el dashboard de Render.com:

#### JWT Configuration
- `JWT_SECRET`: Clave secreta para JWT (genera una nueva segura para producción)
  - **Cómo generar**: Ejecuta `openssl rand -base64 32` en terminal Linux/Mac, o usa un generador online de claves seguras
  - **Ejemplo**: `tu-clave-secreta-jwt-super-segura-generada-aleatoriamente-aqui`
- `JWT_ISSUER`: Emisor del token (por defecto: KaizenekaApi)
- `JWT_AUDIENCE`: Audiencia del token (por defecto: KaizenekaApi)

#### QvaPay Configuration
- `QVAPAY_BEARER_TOKEN`: Token de autenticación de QvaPay
- `QVAPAY_APP_UUID`: UUID de la aplicación QvaPay
- `QVAPAY_APP_SECRET`: Secreto de la aplicación QvaPay

#### Otras Configuraciones
- `ASPNETCORE_ENVIRONMENT`: Production (ya configurado en render.yaml)
- `PORT`: Puerto asignado automáticamente por Render.com

### Pasos para el Despliegue
1. **Subir código**: Push el código actualizado a tu repositorio
2. **Crear servicio**: En Render.com, selecciona "Web Service" y conecta tu repo
3. **Configurar variables**: Agrega las variables de entorno sensibles en la sección "Environment"
   - JWT_SECRET: Tu clave JWT generada
   - QVAPAY_BEARER_TOKEN: Token de QvaPay
   - QVAPAY_APP_UUID: UUID de la app QvaPay
   - QVAPAY_APP_SECRET: Secreto de la app QvaPay
4. **Desplegar**: Render.com construirá y desplegará automáticamente usando Docker
5. **Verificar**: Una vez desplegado, prueba los endpoints de la API

### Verificación
Una vez desplegado, la API estará disponible en la URL proporcionada por Render.com (ej: https://kaizeneka-api.onrender.com)

## Desarrollo Local

### Flutter App
```bash
flutter pub get
flutter run
```

### API .NET
```bash
cd api-dotnet
docker-compose up --build
```

## Recursos Adicionales

- [Documentación de Flutter](https://docs.flutter.dev/)
- [Documentación de ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/)
- [Documentación de Render.com](https://docs.render.com/)
- [Documentación de Supabase](https://supabase.com/docs)
