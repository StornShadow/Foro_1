CREATE OR ALTER PROC [SQM_CATALOGS].[USP_Status]
(
    @i_statusId INT = NULL,
    @i_statusName VARCHAR(80) = NULL,
    @i_statusCreationDate DATETIME = NULL,
    @i_statusCreatorId INT = NULL,
    @i_statusModificationDate DATETIME = NULL,
    @i_statusModificatorId INT = NULL,
    @i_statusEnable BIT = NULL,
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

    -- Si no se recibe fecha de creación, se asigna la fecha actual del servidor.
    IF @i_statusCreationDate IS NULL
        SET @i_statusCreationDate = GETDATE();

    -- Si no se recibe fecha de modificación, se asigna la fecha actual del servidor.
    IF @i_statusModificationDate IS NULL
        SET @i_statusModificationDate = GETDATE();



    --INSERTAR ESTADO   --
    IF @w_Accion = 'I'
    BEGIN

        -- Validación: Nombre obligatorio
        IF ISNULL(@i_statusName,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL NOMBRE DEL ESTADO ES OBLIGATORIO';
        END

        -- Validación: Usuario creador obligatorio
        ELSE IF ISNULL(@i_statusCreatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL MODIFICADOR ES OBLIGATORIO';
        END

        -- Validación: Evitar nombres duplicados
        ELSE IF EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
            WHERE statusName = @i_statusName
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ESTADO YA EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_INS_STATUS;

            BEGIN TRY

                INSERT INTO [SQM_CATALOGS].[TBL_Status]
                (
                    statusName,
                    statusCreationDate,
                    statusCreatorId,
                    statusModificationDate,
                    statusModificatorId,
                    statusEnable
                )
                VALUES
                (
                    @i_statusName,
                    @i_statusCreationDate,
                    @i_statusCreatorId,
                    @i_statusModificationDate,
                    NULL,
                    1
                );

                COMMIT TRANSACTION TRX_INS_STATUS;

                SET @o_Numero = 201;
                SET @o_MensajeUsuario = 'ESTADO REGISTRADO CORRECTAMENTE';

            END TRY

            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_INS_STATUS;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL REGISTRAR EL ESTADO';

                SET @o_MensajeTecnico =
                CONCAT_WS
                (
                    ' - ',
                    'ERROR AL REGISTRAR EL ESTADO',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END



    --  ACTUALIZAR ESTADO--
    ELSE IF @w_Accion = 'U'
    BEGIN

        -- Validación: ID obligatorio
        IF ISNULL(@i_statusId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL ESTADO ES OBLIGATORIO';
        END

        -- Validación: Usuario modificador obligatorio
        ELSE IF ISNULL(@i_statusModificatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL MODIFICADOR DE ESTADO ES OBLIGATORIO';
        END

        -- Validación: Verificar existencia
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
            WHERE statusId = @i_statusId
        )
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL ESTADO NO EXISTE';
        END

        -- Validación: Evitar duplicados
        ELSE IF @i_statusName IS NOT NULL
            AND EXISTS
            (
                SELECT 1
                FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
                WHERE statusName = @i_statusName
                AND statusId <> @i_statusId
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ESTADO YA EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_UPD_STATUS;

            BEGIN TRY

                UPDATE [SQM_CATALOGS].[TBL_Status]
                SET
                    statusName = COALESCE(@i_statusName,statusName),
                    statusModificationDate = @i_statusModificationDate,
                    statusModificatorId = @i_statusModificatorId,
                    statusEnable = COALESCE(@i_statusEnable,statusEnable)
                WHERE statusId = @i_statusId;

                COMMIT TRANSACTION TRX_UPD_STATUS;

                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'ESTADO ACTUALIZADO CORRECTAMENTE';

            END TRY

            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_UPD_STATUS;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR EL ESTADO';

                SET @o_MensajeTecnico =
                CONCAT_WS
                (
                    ' - ',
                    'ERROR AL ACTUALIZAR EL ESTADO',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END





    --  LISTAR STATUS--    

    ELSE IF @w_Accion = 'S'
    BEGIN

        -- Validaciones de paginación
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
                    statusId,
                    statusName,
                    statusCreationDate,
                    statusCreatorId,
                    statusModificationDate,
                    statusModificatorId,
                    statusEnable
                FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
                ORDER BY statusId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;

                SET @w_totalRows = @@ROWCOUNT;

                IF @w_totalRows > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'ESTADOS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END

            END TRY

            BEGIN CATCH

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR LOS ESTADOS';

                SET @o_MensajeTecnico =
                CONCAT_WS
                (
                    ' - ',
                    'ERROR AL LISTAR LOS ESTADOS',
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