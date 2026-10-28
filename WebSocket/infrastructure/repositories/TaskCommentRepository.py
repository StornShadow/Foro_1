from infrastructure.database.connection import get_connection
from domain.entities.TaskCommentsModels import TaskCommentCreate, TaskCommentUpdate # Ajusta tu ruta de importación

class TaskCommentRepository:
    
    def insert_task_comment(self, task_comment: TaskCommentCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_TaskComments]
                    @i_taskCommentParentLink = ?,
                    @i_taskCommentOwner = ?,
                    @i_taskCommentText = ?,
                    @i_taskCommentCreatorId = ?,
                    @i_taskCommentStatus = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                task_comment.taskCommentParentLink,
                task_comment.taskCommentOwner,
                task_comment.taskCommentText,
                task_comment.taskCommentCreatorId,
                task_comment.taskCommentStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al registrar el comentario de la tarea"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_task_comment(self, task_comment: TaskCommentUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_TaskComments]
                    @i_taskCommentId = ?,
                    @i_taskCommentText = ?,
                    @i_taskCommentModificationDate = ?,
                    @i_taskCommentModificatorId = ?,
                    @i_taskCommentStatus = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                task_comment.taskCommentId,
                task_comment.taskCommentText,
                task_comment.taskCommentModificationDate,
                task_comment.taskCommentModificatorId,
                task_comment.taskCommentStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar el comentario de la tarea"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_task_comments(self, page_number: int = 1, rows_per_page: int = 10):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_TaskComments]
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

            # Extraemos los nombres de las columnas
            columns = [col[0] for col in cursor.description]
            
            # Mapeamos los datos a un diccionario
            data = [dict(zip(columns, row)) for row in cursor.fetchall()]

            # IMPORTANTE: Consumir los conjuntos de resultados para poder leer los OUTPUT
            while cursor.nextset():
                pass

            return {
                "status_code": 200 if len(data) > 0 else 204, 
                "message": "Comentarios listados correctamente" if len(data) > 0 else "No hay más registros para listar", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()