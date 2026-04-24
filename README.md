# Parcial Flutter - Accidentes Tulua + CRUD Establecimientos

Aplicacion Flutter con dos modulos integrados:

1. Estadisticas de accidentes de transito en Tulua con procesamiento en Isolate y 4 graficas con fl_chart.
2. CRUD completo de establecimientos consumiendo API REST de parqueadero, incluyendo carga de logo.

## APIs utilizadas

### API 1: Accidentes de transito Tulua

- Fuente: https://www.datos.gov.co/resource/ezt8-5wyj.json
- Endpoint usado: GET https://www.datos.gov.co/resource/ezt8-5wyj.json?$limit=100000
- Campos relevantes:
	- clase_de_accidente
	- gravedad_del_accidente
	- barrio_hecho
	- dia
	- hora
	- area
	- clase_de_vehiculo

Ejemplo JSON:

```json
{
	"clase_de_accidente": "CHOQUE",
	"gravedad_del_accidente": "CON HERIDOS",
	"barrio_hecho": "CENTRO",
	"dia": "LUNES",
	"hora": "08:30",
	"area": "URBANA",
	"clase_de_vehiculo": "AUTOMOVIL"
}
```

### API 2: Establecimientos (Parqueadero)

- Base URL: https://parking.visiontic.com.co/api
- Documentacion: https://parking.visiontic.com.co/api/documentation
- Endpoints usados:
	- GET /establecimientos
	- GET /establecimientos/{id}
	- POST /establecimientos (multipart/form-data)
	- POST /establecimiento-update/{id} con _method=PUT (fallback a POST /establecimientos/{id})
	- DELETE /establecimientos/{id}

Campos:

- nombre
- nit
- direccion
- telefono
- logo (archivo imagen)

Ejemplo JSON:

```json
{
	"id": 1,
	"nombre": "Parking Centro",
	"nit": "900123456-7",
	"direccion": "Calle 10 # 5-20",
	"telefono": "3001234567",
	"logo": "https://parking.visiontic.com.co/storage/logos/logo.png"
}
```

## Paquetes obligatorios implementados

- dio
- go_router
- flutter_dotenv
- fl_chart
- skeletonizer
- image_picker
- Isolate.run()

## Variables de entorno

Archivo [.env](.env):

```env
BASE_URL=https://www.datos.gov.co/resource
PARKING_URL=https://parking.visiontic.com.co/api
```

## Arquitectura del proyecto

Estructura por capas:

- [lib/models/accidente.dart](lib/models/accidente.dart)
- [lib/models/accidentes_stats.dart](lib/models/accidentes_stats.dart)
- [lib/models/establecimiento.dart](lib/models/establecimiento.dart)
- [lib/services/accidentes_service.dart](lib/services/accidentes_service.dart)
- [lib/services/establecimientos_service.dart](lib/services/establecimientos_service.dart)
- [lib/isolates/accidentes_stats_isolate.dart](lib/isolates/accidentes_stats_isolate.dart)
- [lib/views/home_view.dart](lib/views/home_view.dart)
- [lib/views/accidentes/accidentes_view.dart](lib/views/accidentes/accidentes_view.dart)
- [lib/views/establecimientos/establecimientos_list_view.dart](lib/views/establecimientos/establecimientos_list_view.dart)
- [lib/views/establecimientos/establecimiento_detail_view.dart](lib/views/establecimientos/establecimiento_detail_view.dart)
- [lib/views/establecimientos/establecimiento_form_view.dart](lib/views/establecimientos/establecimiento_form_view.dart)
- [lib/routes/app_router.dart](lib/routes/app_router.dart)

Regla aplicada: no hay peticiones HTTP dentro de widgets; toda logica de datos esta en services.

## Future/async/await vs Isolate

- Future/async/await: se usa para operaciones IO (HTTP, lectura de respuestas, envio de formularios).
- Isolate: se usa para procesamiento pesado de miles de registros (estadisticas) fuera del hilo principal.

Motivo de Isolate: evitar bloqueos en UI al procesar la carga masiva ($limit=100000).

Mensajes de consola solicitados en isolate:

- [Isolate] Iniciado — N registros recibidos
- [Isolate] Completado en X ms

## Funcionalidades implementadas

### Dashboard (Home)

- Cards de acceso a ambos modulos.
- Resumen de total accidentes y total establecimientos.
- Skeletonizer en carga de resumen.

### Estadisticas de accidentes (4 graficas)

- Distribucion por clase de accidente (PieChart)
- Distribucion por gravedad (PieChart)
- Top 5 barrios con mas accidentes (BarChart)
- Distribucion por dia de la semana (BarChart)
- Estados: cargando / exito / error
- Skeletonizer en carga

### CRUD establecimientos

- Listar establecimientos (GET)
- Ver detalle establecimiento (GET por id)
- Crear establecimiento con logo (POST multipart/form-data)
- Editar establecimiento con _method=PUT (POST multipart/form-data)
- Eliminar establecimiento (DELETE)
- Estados: cargando / exito / error
- Skeletonizer en listado

## Rutas (go_router)

Rutas con nombre y navegacion maestro-detalle:

- / (name: home)
- /accidentes (name: accidentes)
- /establecimientos (name: establecimientos-list)
- /establecimientos/nuevo (name: establecimientos-create)
- /establecimientos/:id (name: establecimientos-detail)
- /establecimientos/:id/editar (name: establecimientos-edit)

Parametros enviados entre pantallas:

- id por path param para detalle/edicion
- extra con objeto Establecimiento cuando ya esta cargado

## Capturas a incluir en el PDF

Pendiente de anexar en evidencias:

1. Dashboard con resumen y cards.
2. Pantalla de estadisticas con 4 graficas.
3. Evidencia de console logs del Isolate.
4. Listado de establecimientos con skeleton + datos.
5. Formulario crear con seleccion de imagen.
6. Formulario editar con datos precargados.
7. Confirmacion y resultado de eliminacion.

## Ejecucion del proyecto

```bash
flutter pub get
flutter run
```

## Flujo Git recomendado (entregable)

- Repositorio publico: parcial_2
- Ramas:
	- main (estable)
	- dev (integracion)
	- feature/parcial_flutter_final
- PR: feature/parcial_flutter_final -> dev, luego merge a main
- Commits atomicos: feat:, fix:, docs:, refactor:
