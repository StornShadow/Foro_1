CREATE OR ALTER PROC [SQM_CATALOGS].[USP_BusinessValues]
(
    @i_businessValueId INT = NULL,
    @i_businessValueName VARCHAR(80) = NULL,
    @i_businessValueCreationDate DATETIME = NULL,
    @i_businessValueCreatorId INT = NULL,
    @i_businessValueModificationDate DATETIME = NULL,
    @i_businessValueModificatorId INT = NULL,
    @i_businessValueEnable BIT = NULL,
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

    IF @i_businessValueCreationDate IS NULL
        SET @i_businessValueCreationDate = GETDATE();

    IF @i_businessValueModificationDate IS NULL
        SET @i_businessValueModificationDate = GETDATE();




    --INSERTAR --
    IF @w_Accion = 'I'
    BEGIN

        -- Validar nombre obligatorio
        IF ISNULL(@i_businessValueName,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL NOMBRE ES OBLIGATORIO';
        END

        -- Validar usuario creador obligatorio
        ELSE IF ISNULL(@i_businessValueCreatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL CREADOR ES OBLIGATORIO';
        END

        -- Validar que el usuario creador exista
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_businessValueCreatorId
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL USUARIO CREADOR NO EXISTE';
        END

        -- Evitar nombres duplicados
        ELSE IF EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_BusinessValues] (NOLOCK)
            WHERE businessValueName = @i_businessValueName
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL BUSINESS VALUE YA EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_INS_BUSINESS_VALUE;

            BEGIN TRY

                INSERT INTO [SQM_CATALOGS].[TBL_BusinessValues]
                (
                    businessValueName,
                    businessValueCreationDate,
                    businessValueCreatorId,
                    businessValueModificationDate,
                    businessValueModificatorId,
                    businessValueEnable
                )
                VALUES
                (
                    @i_businessValueName,
                    @i_businessValueCreationDate,
                    @i_businessValueCreatorId,
                    NULL,
                    NULL,
                    1
                );

                COMMIT TRANSACTION TRX_INS_BUSINESS_VALUE;

                SET @o_Numero = 201;
                SET @o_MensajeUsuario = 'BUSINESS VALUE REGISTRADO CORRECTAMENTE';

            END TRY

            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_INS_BUSINESS_VALUE;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL REGISTRAR EL BUSINESS VALUE';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL REGISTRAR EL BUSINESS VALUE',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END



    --ACTUALIZAR BUSINESS VALUE--
    ELSE IF @w_Accion = 'U'
    BEGIN

        -- El ID es obligatorio para actualizar
        IF ISNULL(@i_businessValueId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL BUSINESS VALUE ES OBLIGATORIO';
        END

        -- El usuario modificador es obligatorio
        ELSE IF ISNULL(@i_businessValueModificatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL MODIFICADOR ES OBLIGATORIO';
        END

        -- Verificar que el Business Value exista
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_BusinessValues] (NOLOCK)
            WHERE businessValueId = @i_businessValueId
        )
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL BUSINESS VALUE NO EXISTE';
        END

        -- Verificar que el usuario modificador exista
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_businessValueModificatorId
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL USUARIO MODIFICADOR NO EXISTE';
        END

        -- Evitar nombres duplicados
        ELSE IF @i_businessValueName IS NOT NULL
            AND EXISTS
            (
                SELECT 1
                FROM [SQM_CATALOGS].[TBL_BusinessValues] (NOLOCK)
                WHERE businessValueName = @i_businessValueName
                    AND businessValueId <> @i_businessValueId
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL BUSINESS VALUE YA EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_UPD_BUSINESS_VALUE;

            BEGIN TRY

                UPDATE [SQM_CATALOGS].[TBL_BusinessValues]
                SET
                    businessValueName = COALESCE(@i_businessValueName,businessValueName),
                    businessValueModificationDate = @i_businessValueModificationDate,
                    businessValueModificatorId = @i_businessValueModificatorId,
                    businessValueEnable = COALESCE(@i_businessValueEnable,businessValueEnable)
                WHERE businessValueId = @i_businessValueId;

                COMMIT TRANSACTION TRX_UPD_BUSINESS_VALUE;

                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'BUSINESS VALUE ACTUALIZADO CORRECTAMENTE';

            END TRY

            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_UPD_BUSINESS_VALUE;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR EL BUSINESS VALUE';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL ACTUALIZAR EL BUSINESS VALUE',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END
