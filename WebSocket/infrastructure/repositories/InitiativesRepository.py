from infrastructure.database.connection import get_connection
from domain.entities.InitiativesModels import InitiativeCreate, InitiativeUpdate

class InitiativeRepository:
    
    def insert_initiative(self, initiative: InitiativeCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Initiatives]
                    @i_initiativeSummary = ?,
                    @i_initiativeDescription = ?,
                    @i_initiativeOwner = ?,
                    @i_initiativeGoals = ?,
                    @i_initiativeBusinessValue = ?,
                    @i_initiativeTargetStart = ?,
                    @i_initiativeTargetEnd = ?,
                    @i_initiativeCreatorId = ?,
                    @i_initiativeStatus = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                initiative.initiativeSummary,
                initiative.initiativeDescription,
                initiative.initiativeOwner,
                initiative.initiativeGoals,
                initiative.initiativeBusinessValue,
                initiative.initiativeTargetStart,
                initiative.initiativeTargetEnd,
                initiative.initiativeCreatorId,
                initiative.initiativeStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al registrar la initiative"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_initiative(self, initiative: InitiativeUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Initiatives]
                    @i_initiativeId = ?,
                    @i_initiativeSummary = ?,
                    @i_initiativeDescription = ?,
                    @i_initiativeOwner = ?,
                    @i_initiativeGoals = ?,
                    @i_initiativeBusinessValue = ?,
                    @i_initiativeTargetStart = ?,
                    @i_initiativeTargetEnd = ?,
                    @i_initiativeModificationDate = ?,
                    @i_initiativeModificatorId = ?,
                    @i_initiativeStatus = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                initiative.initiativeId,
                initiative.initiativeSummary,
                initiative.initiativeDescription,
                initiative.initiativeOwner,
                initiative.initiativeGoals,
                initiative.initiativeBusinessValue,
                initiative.initiativeTargetStart,
                initiative.initiativeTargetEnd,
                initiative.initiativeModificationDate,
                initiative.initiativeModificatorId,
                initiative.initiativeStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar la initiative"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_initiatives(self, page_number: int = 1, rows_per_page: int = 50):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Initiatives]
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

            # Obtener los nombres de las columnas para armar el diccionario
            columns = [col[0] for col in cursor.description] if cursor.description else []
            data = [dict(zip(columns, row)) for row in cursor.fetchall()] if columns else []

            # Avanzar los result sets (si los hay) para asegurar la limpieza del cursor
            while cursor.nextset():
                pass

            return {
                "status_code": 200 if len(data) > 0 else 204, 
                "message": "Initiatives listadas correctamente" if len(data) > 0 else "No hay más registros para listar", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()