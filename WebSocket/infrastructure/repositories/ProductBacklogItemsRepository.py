from infrastructure.database.connection import get_connection
from domain.entities.ProductBacklogItemsModels import ProductBacklogItemCreate, ProductBacklogItemUpdate # Ajusta tu ruta de importación

class ProductBacklogItemRepository:
    
    def insert_pbi(self, pbi: ProductBacklogItemCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_ProductBacklogItems]
                    @i_PBISummary = ?,
                    @i_PBIDescription = ?,
                    @i_PBIsAcceptanceCriteria = ?,
                    @i_PBIOwner = ?,
                    @i_PBIParentLink = ?,
                    @i_PBIStoryPoint = ?,
                    @i_PBIStartDate = ?,
                    @i_PBIDueDate = ?,
                    @i_PBIPriority = ?,
                    @i_PBICreatorId = ?,
                    @i_PBIStatus = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                pbi.PBISummary,
                pbi.PBIDescription,
                pbi.PBIsAcceptanceCriteria,
                pbi.PBIOwner,
                pbi.PBIParentLink,
                pbi.PBIStoryPoint,
                pbi.PBIStartDate,
                pbi.PBIDueDate,
                pbi.PBIPriority,
                pbi.PBICreatorId,
                pbi.PBIStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al registrar el Product Backlog Item"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_pbi(self, pbi: ProductBacklogItemUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_ProductBacklogItems]
                    @i_PBIId = ?,
                    @i_PBISummary = ?,
                    @i_PBIDescription = ?,
                    @i_PBIsAcceptanceCriteria = ?,
                    @i_PBIOwner = ?,
                    @i_PBIParentLink = ?,
                    @i_PBIStoryPoint = ?,
                    @i_PBIStartDate = ?,
                    @i_PBIDueDate = ?,
                    @i_PBIPriority = ?,
                    @i_PBIModificationDate = ?,
                    @i_PBIModificatorId = ?,
                    @i_PBIStatus = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                pbi.PBIId,
                pbi.PBISummary,
                pbi.PBIDescription,
                pbi.PBIsAcceptanceCriteria,
                pbi.PBIOwner,
                pbi.PBIParentLink,
                pbi.PBIStoryPoint,
                pbi.PBIStartDate,
                pbi.PBIDueDate,
                pbi.PBIPriority,
                pbi.PBIModificationDate,
                pbi.PBIModificatorId,
                pbi.PBIStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar el Product Backlog Item"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_pbis(self, page_number: int = 1, rows_per_page: int = 10):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_ProductBacklogItems]
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
                "message": "Product Backlog Items listados correctamente" if len(data) > 0 else "No hay más registros para listar", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()