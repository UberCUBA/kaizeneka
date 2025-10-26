# Kaizeneka

Aplicación móvil Flutter para el desarrollo personal y hábitos saludables.

## Arquitectura del Proyecto

Este proyecto incluye:
- **Aplicación Flutter**: Interfaz móvil principal
- **API .NET**: Backend API desarrollado en ASP.NET Core
- **Base de datos Supabase**: Almacenamiento y autenticación

## Despliegue de la API en Render.com

### Planes y Limitaciones de Render.com
Render.com ofrece un **plan gratuito** con las siguientes características:
- **750 horas/mes** de uptime (aprox. 31 días)
- **750 GB-horas/mes** de ancho de banda
- **Servicio web gratuito** con límites de recursos
- **No soporta servicios web gratuitos ilimitados** - requieren pago mínimo

### Alternativas Gratuitas para Despliegue
Si Render.com no permite despliegue gratuito, considera estas opciones:

#### 1. Railway.app (Recomendado)
- **Plan gratuito**: 512MB RAM, 1GB storage
- **URL personalizada** gratuita
- **Soporte Docker** nativo
- **Base de datos PostgreSQL** gratuita incluida
- **Configuración**: Railway detecta automáticamente `railway.json` y `Dockerfile`

#### 2. Fly.io
- **Plan gratuito**: 256MB RAM, 1GB storage
- **Regiones globales** disponibles
- **Soporte Docker** excelente

#### 3. Vercel (para APIs)
- **Plan gratuito**: 100GB bandwidth/mes
- **Soporte para APIs** con Serverless Functions
- **Integración Git** automática

#### 4. Heroku (con límites)
- **Plan gratuito**: 550 horas/mes dyno
- **Base de datos PostgreSQL** gratuita pequeña

#### 5. DigitalOcean App Platform
- **Plan gratuito**: Primeros $200 en créditos
- **Soporte Docker** completo
- **Base de datos PostgreSQL** gratuita pequeña

#### 6. AWS Elastic Beanstalk (con Free Tier)
- **Free Tier**: 750 horas EC2 t2.micro/mes
- **Más complejo** de configurar inicialmente

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

### 🚀 Despliegue en Railway.app (Opción Recomendada)

#### Pasos para Railway:
1. **Crear cuenta gratuita**: Ve a [Railway.app](https://railway.app) y regístrate con GitHub
2. **Conectar repositorio**: Haz clic en "New Project" → "Deploy from GitHub repo"
3. **Seleccionar repositorio**: Elige tu repositorio `kaizeneka`
4. **Configurar variables de entorno** (Environment Variables):
   ```
   JWT_SECRET=tu-clave-jwt-generada-aqui
   QVAPAY_BEARER_TOKEN=146631|$2b$10$MCYH7AOUif/E2CEo4Y3jOOzA.0NLO3w6XZ8hVQExSTuuhWqOOJSSq
   QVAPAY_APP_UUID=9d17b1cf-e57f-4a09-91e7-756e20b92142
   QVAPAY_APP_SECRET=EQeoVvshL7wGXMpm3F61ffDwEJL1ghAi6ZdOPOE5OdSDREUXIQ
   ```
5. **Desplegar automáticamente**: Railway detectará el `Dockerfile` y `railway.json` y comenzará el build
6. **Base de datos**: Railway incluye PostgreSQL gratuito automáticamente (opcional para tu API actual)

#### Verificación del Despliegue:
- Una vez desplegado, obtendrás una URL como: `https://kaizeneka-production.up.railway.app`
- Prueba la API: `https://tu-url-railway.app/swagger` para ver la documentación
- Verifica logs en el dashboard de Railway para cualquier error

#### Recursos Gratuitos en Railway:
- **512MB RAM**
- **1GB Storage**
- **URL personalizada** gratuita
- **Despliegues automáticos** desde Git

### Pasos para el Despliegue en Render.com (si decides continuar)
1. **Subir código**: Push el código actualizado a tu repositorio
2. **Crear servicio**: En Render.com, selecciona "Web Service" y conecta tu repo
3. **Configurar variables**: Agrega las variables de entorno sensibles en la sección "Environment"
   - JWT_SECRET: Tu clave JWT generada
   - QVAPAY_BEARER_TOKEN: `146631|$2b$10$MCYH7AOUif/E2CEo4Y3jOOzA.0NLO3w6XZ8hVQExSTuuhWqOOJSSq`
   - QVAPAY_APP_UUID: `9d17b1cf-e57f-4a09-91e7-756e20b92142`
   - QVAPAY_APP_SECRET: `EQeoVvshL7wGXMpm3F61ffDwEJL1ghAi6ZdOPOE5OdSDREUXIQ`
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
