from infrastructure.database.connection import get_connection
from domain.entities.UserModels import UserCreate, UserUpdate

class UserRepository:
    
    def insert_user(self, user: UserCreate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_SECURITY].[USP_Users]
                    @i_userFullName = ?,
                    @i_userName = ?,
                    @i_userEmail = ?,
                    @i_userPassword = ?,
                    @i_userRolId = ?,
                    @i_userCreatorId = ?,
                    @w_Accion = 'I',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                user.userFullName,
                user.userName,
                user.userEmail,
                user.userPassword,
                user.userRolId,
                user.userCreatorId,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            # Capturamos el resultado del OUTPUT
            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al insertar usuario" # result[2] es o_MensajeUsuario
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def update_user(self, user: UserUpdate):
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_SECURITY].[USP_Users]
                    @i_userId = ?,
                    @i_userFullName = ?,
                    @i_userName = ?,
                    @i_userEmail = ?,
                    @i_userPassword = ?,
                    @i_userRolId = ?,
                    @i_userModificatorId = ?,
                    @i_userEnable = ?,
                    @w_Accion = 'U',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (
                user.userId,
                user.userFullName,
                user.userName,
                user.userEmail,
                user.userPassword,
                user.userRolId,
                user.userModificatorId,
                user.userEnable,
                o_Numero,
                o_MensajeTecnico,
                o_MensajeUsuario
            ))

            result = cursor.fetchone()
            conn.commit()
            
            return {
                "status_code": result[0] if result else 500,
                "message": result[2] if result else "Error al actualizar usuario"
            }
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()

    def list_users(self, page_number: int = 1, rows_per_page: int = 10):
        """
        Lista todos los usuarios (Acción 'S').
        Se agregan los parámetros de paginación que exige el SP.
        """
        conn = get_connection()
        cursor = conn.cursor()

        o_Numero = 0
        o_MensajeTecnico = ""
        o_MensajeUsuario = ""

        try:
            cursor.execute("""
                EXEC [SQM_SECURITY].[USP_Users]
                    @i_PageNumber = ?,
                    @i_RowsPerPage = ?,
                    @w_Accion = 'S',
                    @o_Numero = ? OUTPUT,
                    @o_MensajeTecnico = ? OUTPUT,
                    @o_MensajeUsuario = ? OUTPUT
            """, (page_number, rows_per_page, o_Numero, o_MensajeTecnico, o_MensajeUsuario))

            # Extraemos los nombres de las columnas
            columns = [col[0] for col in cursor.description]
            # Mapeamos los datos a un diccionario
            data = [dict(zip(columns, row)) for row in cursor.fetchall()]

            # Si necesitamos capturar los outputs en un SELECT, hacemos nextset() en pyodbc
            while cursor.nextset():
                pass

            return {
                "status_code": 200 if len(data) > 0 else 204, 
                "message": "Usuarios listados" if len(data) > 0 else "No hay usuarios", 
                "data": data
            }
        except Exception as e:
            raise e
        finally:
            cursor.close()
            conn.close()