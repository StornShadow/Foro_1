from infrastructure.database.connection import get_connection
from domain.entities.FeaturesModels import FeatureCreate, FeatureUpdate

class FeatureRepository:
    
    def insert_feature(self, feature: FeatureCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Features]
                    @i_featureSummary = ?,
                    @i_featureDescription = ?,
                    @i_featuresAcceptanceCriteria = ?,
                    @i_featureParentLink = ?,
                    @i_featureOwner = ?,
                    @i_featureStartDate = ?,
                    @i_featureDueDate = ?,
                    @i_featurePriority = ?,
                    @i_featureCreatorId = ?,
                    @i_featureStatus = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                feature.featureSummary,
                feature.featureDescription,
                feature.featuresAcceptanceCriteria,
                feature.featureParentLink,
                feature.featureOwner,
                feature.featureStartDate,
                feature.featureDueDate,
                feature.featurePriority,
                feature.featureCreatorId,
                feature.featureStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al registrar el feature"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_feature(self, feature: FeatureUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Features]
                    @i_featureId = ?,
                    @i_featureSummary = ?,
                    @i_featureDescription = ?,
                    @i_featuresAcceptanceCriteria = ?,
                    @i_featureParentLink = ?,
                    @i_featureOwner = ?,
                    @i_featureStartDate = ?,
                    @i_featureDueDate = ?,
                    @i_featurePriority = ?,
                    @i_featureModificationDate = ?,
                    @i_featureModificatorId = ?,
                    @i_featureStatus = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                feature.featureId,
                feature.featureSummary,
                feature.featureDescription,
                feature.featuresAcceptanceCriteria,
                feature.featureParentLink,
                feature.featureOwner,
                feature.featureStartDate,
                feature.featureDueDate,
                feature.featurePriority,
                feature.featureModificationDate,
                feature.featureModificatorId,
                feature.featureStatus,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar el feature"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_features(self, page_number: int = 1, rows_per_page: int = 50):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_GENERAL].[USP_Features]
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
                "message": "Features listados correctamente" if len(data) > 0 else "No hay más registros para listar", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()