# Mocker - Sensor Data Simulation

**Mocker** es una plataforma diseñada para simular datos de sensores de manera eficiente y flexible. Ofrece dos interfaces principales:
- **Mocker Web**: Una aplicación web construida con **Flutter** para visualizar, configurar y administrar simulaciones de datos de sensores.
- **Mocker CLI**: Una interfaz de línea de comandos construida con **Dart** para generar datos de sensores de forma rápida y controlada.

## Características

- **Simulación de datos**: Genera datos falsos para sensores IoT (temperatura, humedad, luz, etc.).
- **Interfaz Web interactiva**: Permite a los usuarios crear y administrar simulaciones de manera sencilla.
- **CLI potente**: Con comandos personalizables para automatizar la generación de datos.

## Instalación

### Requisitos previos

- **Flutter** para la aplicación web.
- **Dart** para la CLI.


### Instalación de la Aplicación Web (Flutter)

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/Pholluxion/Mocker.git
   cd mocker_web
   ```

2. **Instalar dependencias de Flutter**:
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación Web**:
   ```bash
   flutter run -d chrome
   ```

### Instalación de la CLI (Dart)

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/Pholluxion/Mocker.git
   cd mocker_cli
   ```

2. **Instalar dependencias de Dart**:
   ```bash
   dart pub get
   ```

3. **Ejecutar la aplicación CLI**:
   ```bash
   dart run
   ```

## Uso

### Mocker CLI

**Mocker CLI** permite generar datos simulados a través de la línea de comandos.

#### Comandos disponibles:

- Comming soon...

### Mocker Web

- Comming soon...

---

## Nomenclatura de Ramas

Para mantener el flujo de trabajo organizado y claro, utilizamos un sistema estándar de nomenclatura para las ramas de Git. Cada rama debe seguir una convención específica que indica su propósito.

### Convenciones de Nombres de Ramas

1. **Feature branches** (Características nuevas):
   - **Formato**: `feature/{nombre-de-la-funcionalidad}`
   - Ejemplo: `feature/generate-temperature-data`
   - Se utiliza para el desarrollo de nuevas funcionalidades o mejoras.

2. **Fix branches** (Correcciones de errores):
   - **Formato**: `fix/{nombre-del-error}`
   - Ejemplo: `fix/incorrect-sensor-data-format`
   - Se utiliza para corregir errores o fallos en el sistema.

3. **Chore branches** (Tareas de mantenimiento):
   - **Formato**: `chore/{nombre-de-la-tarea}`
   - Ejemplo: `chore/update-dependencies`
   - Se utiliza para tareas de mantenimiento que no afectan directamente la funcionalidad del sistema.

4. **Docs branches** (Documentación):
   - **Formato**: `docs/{nombre-del-documento}`
   - Ejemplo: `docs/update-readme`
   - Se utiliza para actualizaciones o mejoras en la documentación.

### Flujo de trabajo recomendado

1. **Desarrollo**:
   - Crear una rama **feature** desde `main` para agregar una nueva funcionalidad.
   - Una vez que la funcionalidad esté completada, realiza un **pull request** para fusionar con `dev`.

2. **Corrección de errores**:
   - Crear una rama **fix** desde `main` para corregir un error.
   - Una vez que el error esté corregido, realiza un **pull request** para fusionar con `dev`.

3. **Documentación**:
    - Crear una rama **docs** desde `main` para actualizar la documentación.
    - Una vez que la documentación esté actualizada, realiza un **pull request** para fusionar con `dev`.

4. **Mantenimiento**:
    - Crear una rama **chore** desde `main` para realizar tareas de mantenimiento.
    - Una vez que la tarea esté completada, realiza un **pull request** para fusionar con `dev`.

5. **Fusionar con `main`**:
    - Una vez que todas las funcionalidades han sido probadas y completadas en `dev`, realiza un **pull request** para fusionar con `main`.


### Formato de Commit

```plaintext
<tipo>(<área opcional>): <mensaje breve de cambio>

<body opcional>

<footer opcional
```

### Componentes:

1. **Tipo**: Define el tipo de cambio que se está realizando. Los tipos más comunes son:
   - `feat`: Una nueva característica (feature).
   - `fix`: Correción de un error.
   - `docs`: Cambios en la documentación.
   - `style`: Cambios en la estructura de código que no afectan la funcionalidad (espacios, formato, etc.).
   - `refactor`: Cambios en el código que no solucionan un error ni agregan una característica (mejoras internas).
   - `perf`: Cambios que mejoran el rendimiento.
   - `test`: Añadir o corregir pruebas.
   - `chore`: Tareas generales que no afectan el código funcional (actualización de dependencias, configuración, etc.).
   - `build`: Cambios en la configuración o herramientas de construcción (por ejemplo, configuración de Docker, Webpack).
   - `ci`: Cambios en los archivos de configuración de integración continua.

2. **Área (opcional)**: Una palabra opcional que indica el área del código afectada, por ejemplo, `ui`, `backend`, `db`, `auth`.

3. **Mensaje breve**: Descripción corta y clara de lo que hace el commit, en presente y de manera concisa.

4. **Cuerpo (opcional)**: Explicación más detallada de lo que hace el commit, si es necesario. Explica el "por qué" si es importante.

5. **Footer (opcional)**: Información adicional como:
   - **Fixes**: Para referenciar tickets de Jira, GitHub Issues, etc.
   - **BREAKING CHANGE**: Si el commit introduce un cambio incompatible que afecta el API.

### Ejemplos

#### 1. **Nuevo Feature**:
```plaintext
feat(auth): add user login functionality

Added login functionality using JWT for user authentication. 
Updated the authentication service to handle token generation.
```

#### 2. **Correción de Error**:
```plaintext
fix(cli): handle missing arguments in the command

Fixed a bug where the CLI would crash if required arguments were missing.
```

#### 3. **Actualización de Documentación**:
```plaintext
docs(readme): update installation instructions

Updated the README with new installation instructions for Flutter and Dart.
```

#### 4. **Tareas de Mantenimiento**:
```plaintext
chore(deps): update Flutter and Dart dependencies

Updated dependencies to the latest versions to ensure compatibility.
```

#### 5. **Cambios en la Interfaz de Usuario**:
```plaintext
style(ui): update button styles for better visibility

Improved button color contrast and increased padding for a more user-friendly UI.
```

#### 6. **Refactorización**:
```plaintext
refactor(backend): restructure user service code

Refactored the user service to separate concerns and improve readability.
```

#### 7. **Cambio que Rompe la Compatibilidad**:
```plaintext
feat(auth): change user login endpoint (BREAKING CHANGE)

The user login endpoint has been modified to require email instead of username.
```

### Reglas Generales:
- El mensaje de commit debe estar en **presente** y de forma **imperativa** (por ejemplo, “Add feature” en lugar de “Added feature”).
- Los **tipos** siempre van en minúscula, y la primera letra del mensaje breve debe ser mayúscula.
- No uses frases vagas como "update" o "change". Especifica qué se está actualizando o cambiando.
- Si un commit soluciona un problema relacionado con un **ticket**, incluye una referencia en el **footer** con la palabra **Fixes**.

### Ejemplo Completo de Commit con Footer:

```plaintext
fix(auth): fix password reset functionality

Fixed an issue where password reset wasn't working after email verification. The reset now properly invalidates expired tokens.

Fixes #45
```



## Contribuidores

- [Carlos Peñaloza](https://github.com/Pholluxion "Carlos Peñaloza")
- [Mariana Robayo](https://github.com/mariana123robayo "Mariana Robayo")
