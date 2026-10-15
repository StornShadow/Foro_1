CREATE OR ALTER PROC [SQM_SECURITY].[USP_Roles]
(
    @i_rolId INT = NULL,
    @i_rolName VARCHAR(80) = NULL,
    @i_rolCreationDate DATETIME = NULL,
    @i_rolCreatorId INT = NULL,
    @i_rolModificationDate DATETIME = NULL,
    @i_rolModificatorId INT = NULL,
    @i_rolEnable BIT = NULL,
    @i_PageNumber INT = NULL,
    @i_RowsPerPage INT = NULL,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN

    DECLARE @w_totalRows INT;

    IF @i_rolCreationDate IS NULL
        SET @i_rolCreationDate = GETDATE();

    
    IF @i_rolModificationDate IS NULL
        SET @i_rolModificationDate = GETDATE();



    --INSERTAR ROL--
    IF @w_Accion = 'I'
    BEGIN

        -- Validar que el nombre del rol sea obligatorio
        IF ISNULL(@i_rolName,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL NOMBRE DEL ROL ES OBLIGATORIO';
        END

        -- Validar que exista un usuario creador
        ELSE IF ISNULL(@i_rolCreatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL CREADOR ES OBLIGATORIO';
        END

        -- Evitar registrar roles duplicados
        ELSE IF EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Roles] (NOLOCK)
            WHERE rolName = @i_rolName
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ROL YA EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_INS_ROL;

            BEGIN TRY

                INSERT INTO [SQM_SECURITY].[TBL_Roles]
                (
                    rolName,
                    rolCreationDate,
                    rolCreatorId,
                    rolModificationDate,
                    rolModificatorId,
                    rolEnable
                )
                VALUES
                (
                    @i_rolName,
                    @i_rolCreationDate,
                    @i_rolCreatorId,
                    @i_rolModificationDate,
                    NULL,
                    1
                );

                COMMIT TRANSACTION TRX_INS_ROL;

                SET @o_Numero = 201;
                SET @o_MensajeUsuario = 'ROL REGISTRADO CORRECTAMENTE';

            END TRY

            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_INS_ROL;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL REGISTRAR EL ROL';

                SET @o_MensajeTecnico = CONCAT_WS
                (
                    ' - ',
                    'ERROR AL REGISTRAR EL ROL',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END



    --ACTUALIZAR ROL--
    ELSE IF @w_Accion = 'U'
    BEGIN

        -- El ID es requerido para actualizar
        IF ISNULL(@i_rolId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL ROL ES OBLIGATORIO';
        END

        -- El usuario modificador es requerido
        ELSE IF ISNULL(@i_rolModificatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL MODIFICADOR ES OBLIGATORIO';
        END

        -- Verificar existencia del rol
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Roles] (NOLOCK)
            WHERE rolId = @i_rolId
        )
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL ROL NO EXISTE';
        END

        -- Evitar nombres duplicados
        ELSE IF @i_rolName IS NOT NULL
            AND EXISTS
            (
                SELECT 1
                FROM [SQM_SECURITY].[TBL_Roles] (NOLOCK)
                WHERE rolName = @i_rolName
                AND rolId <> @i_rolId
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ROL YA EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_UPD_ROL;

            BEGIN TRY

                UPDATE [SQM_SECURITY].[TBL_Roles]
                SET
                    rolName = COALESCE(@i_rolName,rolName),
                    rolModificationDate = @i_rolModificationDate,
                    rolModificatorId = @i_rolModificatorId,
                    rolEnable = COALESCE(@i_rolEnable,rolEnable)
                WHERE rolId = @i_rolId;

                COMMIT TRANSACTION TRX_UPD_ROL;

                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'ROL ACTUALIZADO CORRECTAMENTE';

            END TRY

            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_UPD_ROL;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR EL ROL';

                SET @o_MensajeTecnico = CONCAT_WS
                (
                    ' - ',
                    'ERROR AL ACTUALIZAR EL ROL',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END



    --LISTAR ROLES--
    ELSE IF @w_Accion = 'S'
    BEGIN

        -- Validar información de paginación
        IF ISNULL(@i_PageNumber,0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL NUMERO DE PAGINA ES OBLIGATORIO';
        END

        ELSE IF ISNULL(@i_RowsPerPage,0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA CANTIDAD DE FILAS ES OBLIGATORIA';
        END

        ELSE
        BEGIN

            BEGIN TRY

                SELECT
                    rolId,
                    rolName,
                    rolCreationDate,
                    rolCreatorId,
                    rolModificationDate,
                    rolModificatorId,
                    rolEnable
                FROM [SQM_SECURITY].[TBL_Roles] (NOLOCK)
                ORDER BY rolId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;

                SET @w_totalRows = @@ROWCOUNT;

                IF @w_totalRows > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'ROLES LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END

            END TRY

            BEGIN CATCH

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR LOS ROLES';

                SET @o_MensajeTecnico = CONCAT_WS
                (
                    ' - ',
                    'ERROR AL LISTAR LOS ROLES',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END



    --ACCIÓN NO CONFIGURADA--
    ELSE
    BEGIN

        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'METODO NO HABILITADO';
        SET @o_MensajeTecnico = 'EL PROCEDIMIENTO NO TIENE HABILITADA ESA OPCION';

    END

END;
GO