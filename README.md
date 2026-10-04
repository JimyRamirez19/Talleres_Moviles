# Taller 2 - Programación asíncrona en Flutter

## Estudiante

**Jimy Fabián Ramírez Tinjacá**

## Descripción

Este proyecto corresponde al Taller 2 de la asignatura Creación de Aplicaciones Móviles.

El objetivo es demostrar el uso de mecanismos de programación asíncrona en Flutter mediante tres componentes principales:

- Future + async/await
- Timer
- Isolate

La aplicación permite observar diferentes estados de ejecución y comprobar el comportamiento de cada mecanismo mediante la interfaz gráfica y los mensajes mostrados en la consola.

---

## 1. Future + async/await

Un `Future` representa un valor que estará disponible en el futuro. Es útil para operaciones que pueden tardar un tiempo, como consultar un servicio, leer información o realizar una operación asíncrona.

En este proyecto se simula un servicio utilizando:

`Future.delayed(const Duration(seconds: 3))`

De esta manera se representa una operación que tarda aproximadamente tres segundos en responder.

Se utiliza `async/await` para esperar el resultado sin bloquear la ejecución de la interfaz.

### Estados de la interfaz

El componente Future presenta tres estados principales:

1. **Cargando:** se muestra mientras se espera la respuesta.
2. **Éxito:** aparece cuando el servicio devuelve correctamente los datos.
3. **Error:** se muestra cuando ocurre una excepción.

También se agregó una opción para simular un error y comprobar el manejo de excepciones.

### Flujo

```text
Usuario presiona "Ejecutar Future"
              ↓
        Estado Cargando
              ↓
      Servicio simulado
              ↓
       Espera 3 segundos
              ↓
        ┌─────┴─────┐
        ↓           ↓
      Éxito        Error
        ↓           ↓
   Resultado     Mensaje de error