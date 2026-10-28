from infrastructure.database.connection import get_connection
from domain.entities.TaskModels import TaskCreate, TaskUpdate

class TaskRepository:
    
    def insert_task(self, task: TaskCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Tasks]
                    @i_taskSummary = ?,
                    @i_taskDescription = ?,
                    @i_taskOwner = ?,
                    @i_taskParentLink = ?,
                    @i_taskOriginalEstimate = ?,
                    @i_taskRemaningWork = ?,
                    @i_taskStartDate = ?,
                    @i_taskDueDate = ?,
                    @i_taskActivityType = ?,
                    @i_taskCreatorId = ?,
                    @i_taskStatus = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                task.taskSummary,
                task.taskDescription,
                task.taskOwner,
                task.taskParentLink,
                task.taskOriginalEstimate,
                task.taskRemaningWork,
                task.taskStartDate,
                task.taskDueDate,
                task.taskActivityType,
                task.taskCreatorId,
                task.taskStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al registrar la tarea"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_task(self, task: TaskUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Tasks]
                    @i_taskId = ?,
                    @i_taskSummary = ?,
                    @i_taskDescription = ?,
                    @i_taskOwner = ?,
                    @i_taskParentLink = ?,
                    @i_taskOriginalEstimate = ?,
                    @i_taskCompletedWork = ?,
                    @i_taskRemaningWork = ?,
                    @i_taskStartDate = ?,
                    @i_taskCompletedDate = ?,
                    @i_taskDueDate = ?,
                    @i_taskActivityType = ?,
                    @i_taskModificationDate = ?,
                    @i_taskModificatorId = ?,
                    @i_taskStatus = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                task.taskId,
                task.taskSummary,
                task.taskDescription,
                task.taskOwner,
                task.taskParentLink,
                task.taskOriginalEstimate,
                task.taskCompletedWork,
                task.taskRemaningWork,
                task.taskStartDate,
                task.taskCompletedDate,
                task.taskDueDate,
                task.taskActivityType,
                task.taskModificationDate,
                task.taskModificatorId,
                task.taskStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar la tarea"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_tasks(self, page_number: int = 1, rows_per_page: int = 10):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Tasks]
                    @i_PageNumber = ?,
                    @i_RowsPerPage = ?,
                    @w_Accion = 'S',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                page_number, 
                rows_per_page, 
                o_Numero, 
                o_MensajeTecnico, 
                o_MensajeUsuario
            ))

            columns = [col[0] for col in cursor.description] if cursor.description else []
            data = [dict(zip(columns, row)) for row in cursor.fetchall()] if columns else []

            while cursor.nextset():
                pass

            return {
                "status_code": 200 if len(data) > 0 else 204, 
                "message": "Tareas listadas correctamente" if len(data) > 0 else "No hay más registros para listar", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()