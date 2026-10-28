from infrastructure.database.connection import get_connection
from domain.entities.StatusModels import StatusCreate, StatusUpdate

class StatusRepository:
    
    def insert_status(self, status: StatusCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_CATALOGS].[USP_Status]
                    @i_statusName = ?,
                    @i_statusCreatorId = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                status.statusName,
                status.statusCreatorId,
                # status.statusEnable no se envía porque el SP lo fuerza a 1 internamente
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al registrar el estado"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_status(self, status: StatusUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_CATALOGS].[USP_Status]
                    @i_statusId = ?,
                    @i_statusName = ?,
                    @i_statusModificatorId = ?,
                    @i_statusEnable = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                status.statusId,
                status.statusName,
                status.statusModificatorId,
                status.statusEnable,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar el estado"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_status(self, page_number: int = 1, rows_per_page: int = 10):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_CATALOGS].[USP_Status]
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
                "message": "Estados listados correctamente" if len(data) > 0 else "No hay más registros para listar", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()