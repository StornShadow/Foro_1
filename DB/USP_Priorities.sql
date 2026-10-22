CREATE OR ALTER PROC [SQM_CATALOGS].[USP_Priorities]
(
    @i_priorityId INT = NULL,
    @i_priorityName VARCHAR(80) = NULL,
    @i_priorityCreationDate DATETIME = NULL,
    @i_priorityCreatorId INT = NULL,
    @i_priorityModificationDate DATETIME = NULL,
    @i_priorityModificatorId INT = NULL,
    @i_priorityEnable BIT = NULL,
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

    IF @i_priorityCreationDate IS NULL
        SET @i_priorityCreationDate = GETDATE();

    IF @i_priorityModificationDate IS NULL
        SET @i_priorityModificationDate = GETDATE();




    --INSERTAR PRIORIDAD--
    IF @w_Accion = 'I'
    BEGIN

        -- Validar nombre obligatorio
        IF ISNULL(@i_priorityName,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL NOMBRE DE LA PRIORIDAD ES OBLIGATORIO';
        END

        -- Validar usuario creador obligatorio
        ELSE IF ISNULL(@i_priorityCreatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL CREADOR ES OBLIGATORIO';
        END

        -- Validar existencia del creador
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_priorityCreatorId
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL USUARIO CREADOR NO EXISTE';
        END

        -- Evitar prioridades duplicadas
        ELSE IF EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_Priorities] (NOLOCK)
            WHERE priorityName = @i_priorityName
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA PRIORIDAD YA EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_INS_PRIORITY;

            BEGIN TRY

                INSERT INTO [SQM_CATALOGS].[TBL_Priorities]
                (
                    priorityName,
                    priorityCreationDate,
                    priorityCreatorId,
                    priorityModificationDate,
                    priorityModificatorId,
                    priorityEnable
                )
                VALUES
                (
                    @i_priorityName,
                    @i_priorityCreationDate,
                    @i_priorityCreatorId,
                    NULL,
                    NULL,
                    1
                );

                COMMIT TRANSACTION TRX_INS_PRIORITY;

                SET @o_Numero = 201;
                SET @o_MensajeUsuario = 'PRIORIDAD REGISTRADA CORRECTAMENTE';

            END TRY

            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_INS_PRIORITY;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL REGISTRAR LA PRIORIDAD';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL REGISTRAR LA PRIORIDAD',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END





    --ACTUALIZAR PRIORIDAD--
  ELSE IF @w_Accion = 'U'
BEGIN

    -- Validar ID obligatorio
    IF ISNULL(@i_priorityId,0) = 0
    BEGIN
        SET @o_Numero = 400;
        SET @o_MensajeUsuario = 'EL ID DE LA PRIORIDAD ES OBLIGATORIO';
    END

    -- Validar modificador obligatorio
    ELSE IF ISNULL(@i_priorityModificatorId,0) = 0
    BEGIN
        SET @o_Numero = 400;
        SET @o_MensajeUsuario = 'EL ID DEL MODIFICADOR ES OBLIGATORIO';
    END

    -- Verificar que exista la prioridad
    ELSE IF NOT EXISTS
    (
        SELECT 1
        FROM [SQM_CATALOGS].[TBL_Priorities] (NOLOCK)
        WHERE priorityId = @i_priorityId
    )
    BEGIN
        SET @o_Numero = 404;
        SET @o_MensajeUsuario = 'LA PRIORIDAD NO EXISTE';
    END

    -- Verificar existencia del modificador
    ELSE IF NOT EXISTS
    (
        SELECT 1
        FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
        WHERE userId = @i_priorityModificatorId
          AND userEnable = 1
    )
    BEGIN
        SET @o_Numero = 400;
        SET @o_MensajeUsuario = 'EL USUARIO MODIFICADOR NO EXISTE';
    END

    -- Evitar duplicidad de nombre
    ELSE IF @i_priorityName IS NOT NULL
        AND EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_Priorities] (NOLOCK)
            WHERE LOWER(priorityName) = LOWER(@i_priorityName)
              AND priorityId <> @i_priorityId
        )
    BEGIN
        SET @o_Numero = 409;
        SET @o_MensajeUsuario = 'YA EXISTE OTRA PRIORIDAD REGISTRADA CON ESE NOMBRE';
    END

    ELSE
    BEGIN

        BEGIN TRANSACTION TRX_UPD_PRIORITY;

        BEGIN TRY

            UPDATE [SQM_CATALOGS].[TBL_Priorities]
            SET
                priorityName = COALESCE(@i_priorityName, priorityName),
                priorityModificationDate = @i_priorityModificationDate,
                priorityModificatorId = @i_priorityModificatorId,
                priorityEnable = COALESCE(@i_priorityEnable, priorityEnable)
            WHERE priorityId = @i_priorityId;

            COMMIT TRANSACTION TRX_UPD_PRIORITY;

            SET @o_Numero = 200;
            SET @o_MensajeUsuario = 'PRIORIDAD ACTUALIZADA CORRECTAMENTE';

        END TRY

        BEGIN CATCH

            ROLLBACK TRANSACTION TRX_UPD_PRIORITY;

            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR LA PRIORIDAD';

            SET @o_MensajeTecnico = CONCAT_WS
            (
                ' - ',
                'ERROR AL ACTUALIZAR LA PRIORIDAD',
                ERROR_PROCEDURE(),
                ERROR_LINE(),
                ERROR_MESSAGE()
            );

        END CATCH

    END






    --LISTAR PRIORIDADES--
    ELSE IF @w_Accion = 'S'
    BEGIN

        -- Validación de parámetros de paginación
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
                    priorityId,
                    priorityName,
                    priorityCreationDate,
                    priorityCreatorId,
                    priorityModificationDate,
                    priorityModificatorId,
                    priorityEnable
                FROM [SQM_CATALOGS].[TBL_Priorities] (NOLOCK)
                ORDER BY priorityId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;

                SET @w_totalRows = @@ROWCOUNT;

                IF @w_totalRows > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'PRIORIDADES LISTADAS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END

            END TRY

            BEGIN CATCH

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR LAS PRIORIDADES';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL LISTAR LAS PRIORIDADES',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END





    --ACCION NO CONFIGURADA--
    ELSE
    BEGIN

        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'METODO NO HABILITADO';
        SET @o_MensajeTecnico = 'EL PROCEDIMIENTO ALMACENADO NO TIENE HABILITADA ESA OPCION';

    END

END;
GO