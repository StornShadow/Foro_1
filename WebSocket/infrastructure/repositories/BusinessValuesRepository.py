from infrastructure.database.connection import get_connection
from domain.entities.BusinessValuesModels import BusinessValueCreate, BusinessValueUpdate

class BusinessValueRepository:
    
    def insert_business_value(self, business_value: BusinessValueCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_CATALOGS].[USP_BusinessValues]
                    @i_businessValueName = ?,
                    @i_businessValueCreatorId = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                business_value.businessValueName,
                business_value.businessValueCreatorId,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al registrar el business value"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_business_value(self, business_value: BusinessValueUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_CATALOGS].[USP_BusinessValues]
                    @i_businessValueId = ?,
                    @i_businessValueName = ?,
                    @i_businessValueModificatorId = ?,
                    @i_businessValueEnable = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                business_value.businessValueId,
                business_value.businessValueName,
                business_value.businessValueModificatorId,
                business_value.businessValueEnable,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar el business value"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_business_values(self, page_number: int = 1, rows_per_page: int = 10):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_CATALOGS].[USP_BusinessValues]
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
                "message": "Business values listados correctamente" if len(data) > 0 else "No hay más registros para listar", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()