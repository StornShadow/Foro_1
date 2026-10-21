CREATE OR ALTER PROC [SQM_GENERAL].[USP_Initiatives]
(
    @i_initiativeId INT = NULL,
    @i_initiativeSummary VARCHAR(200) = NULL,
    @i_initiativeDescription VARCHAR(2000) = NULL,
    @i_initiativeOwner INT = NULL,
    @i_initiativeGoals VARCHAR(255) = NULL,
    @i_initiativeBusinessValue INT = NULL,
    @i_initiativeTargetStart DATE = NULL,
    @i_initiativeTargetEnd DATE = NULL,
    @i_initiativeCreationDate DATETIME = NULL,
    @i_initiativeCreatorId INT = NULL,
    @i_initiativeModificationDate DATETIME = NULL,
    @i_initiativeModificatorId INT = NULL,
    @i_initiativeStatus INT = NULL,
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

    IF @i_initiativeCreationDate IS NULL
        SET @i_initiativeCreationDate = GETDATE();

    IF @i_initiativeModificationDate IS NULL
        SET @i_initiativeModificationDate = GETDATE();




    --INSERTAR INITIATIVE--
    IF @w_Accion = 'I'
    BEGIN

        -- Validar resumen obligatorio
        IF ISNULL(@i_initiativeSummary,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL RESUMEN ES OBLIGATORIO';
        END

        -- Validar descripción obligatoria
        ELSE IF ISNULL(@i_initiativeDescription,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA DESCRIPCION ES OBLIGATORIA';
        END

        -- Validar owner obligatorio
        ELSE IF ISNULL(@i_initiativeOwner,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL OWNER ES OBLIGATORIO';
        END

        -- Validar Business Value obligatorio
        ELSE IF ISNULL(@i_initiativeBusinessValue,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL BUSINESS VALUE ES OBLIGATORIO';
        END

        -- Validar Creator obligatorio
        ELSE IF ISNULL(@i_initiativeCreatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL CREADOR ES OBLIGATORIO';
        END

        -- Validar Status obligatorio
        ELSE IF ISNULL(@i_initiativeStatus,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL STATUS ES OBLIGATORIO';
        END

        -- Validar fechas
        ELSE IF @i_initiativeTargetStart IS NOT NULL
            AND @i_initiativeTargetEnd IS NOT NULL
            AND @i_initiativeTargetStart > @i_initiativeTargetEnd
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA FECHA INICIO NO PUEDE SER MAYOR A LA FECHA FIN';
        END

        -- Validar Owner
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_initiativeOwner
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL OWNER NO EXISTE';
        END

        -- Validar Business Value
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_BusinessValues] (NOLOCK)
            WHERE businessValueId = @i_initiativeBusinessValue
                AND businessValueEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL BUSINESS VALUE NO EXISTE';
        END

        -- Validar Creator
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_initiativeCreatorId
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL USUARIO CREADOR NO EXISTE';
        END

        -- Validar Status
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
            WHERE statusId = @i_initiativeStatus
                AND statusEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL STATUS NO EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_INS_INITIATIVE;

            BEGIN TRY

                INSERT INTO [SQM_GENERAL].[TBL_Initiatives]
                (
                    initiativeSummary,
                    initiativeDescription,
                    initiativeOwner,
                    initiativeGoals,
                    initiativeBusinessValue,
                    initiativeTargetStart,
                    initiativeTargetEnd,
                    initiativeCreationDate,
                    initiativeCreatorId,
                    initiativeStatus
                )
                VALUES
                (
                    @i_initiativeSummary,
                    @i_initiativeDescription,
                    @i_initiativeOwner,
                    @i_initiativeGoals,
                    @i_initiativeBusinessValue,
                    @i_initiativeTargetStart,
                    @i_initiativeTargetEnd,
                    @i_initiativeCreationDate,
                    @i_initiativeCreatorId,
                    @i_initiativeStatus
                );

                COMMIT TRANSACTION TRX_INS_INITIATIVE;

                SET @o_Numero = 201;
                SET @o_MensajeUsuario = 'INITIATIVE REGISTRADA CORRECTAMENTE';

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_INS_INITIATIVE;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL REGISTRAR LA INITIATIVE';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL REGISTRAR LA INITIATIVE',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END




    --ACTUALIZAR INITIATIVE--
    ELSE IF @w_Accion = 'U'
    BEGIN

        IF ISNULL(@i_initiativeId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DE LA INITIATIVE ES OBLIGATORIO';
        END

        ELSE IF ISNULL(@i_initiativeModificatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL MODIFICADOR ES OBLIGATORIO';
        END

        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_GENERAL].[TBL_Initiatives] (NOLOCK)
            WHERE initiativeId = @i_initiativeId
        )
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'LA INITIATIVE NO EXISTE';
        END

        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_initiativeModificatorId
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL USUARIO MODIFICADOR NO EXISTE';
        END

        ELSE IF @i_initiativeOwner IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
                WHERE userId = @i_initiativeOwner
                    AND userEnable = 1
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL OWNER NO EXISTE';
        END

        ELSE IF @i_initiativeBusinessValue IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_CATALOGS].[TBL_BusinessValues] (NOLOCK)
                WHERE businessValueId = @i_initiativeBusinessValue
                    AND businessValueEnable = 1
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL BUSINESS VALUE NO EXISTE';
        END

        ELSE IF @i_initiativeStatus IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
                WHERE statusId = @i_initiativeStatus
                    AND statusEnable = 1
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL STATUS NO EXISTE';
        END

        ELSE IF @i_initiativeTargetStart IS NOT NULL
            AND @i_initiativeTargetEnd IS NOT NULL
            AND @i_initiativeTargetStart > @i_initiativeTargetEnd
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA FECHA INICIO NO PUEDE SER MAYOR A LA FECHA FIN';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_UPD_INITIATIVE;

            BEGIN TRY

                UPDATE [SQM_GENERAL].[TBL_Initiatives]
                SET
                    initiativeSummary = COALESCE(@i_initiativeSummary, initiativeSummary),
                    initiativeDescription = COALESCE(@i_initiativeDescription, initiativeDescription),
                    initiativeOwner = COALESCE(@i_initiativeOwner, initiativeOwner),
                    initiativeGoals = COALESCE(@i_initiativeGoals, initiativeGoals),
                    initiativeBusinessValue = COALESCE(@i_initiativeBusinessValue, initiativeBusinessValue),
                    initiativeTargetStart = COALESCE(@i_initiativeTargetStart, initiativeTargetStart),
                    initiativeTargetEnd = COALESCE(@i_initiativeTargetEnd, initiativeTargetEnd),
                    initiativeModificationDate = @i_initiativeModificationDate,
                    initiativeModificatorId = @i_initiativeModificatorId,
                    initiativeStatus = COALESCE(@i_initiativeStatus, initiativeStatus)
                WHERE initiativeId = @i_initiativeId;

                COMMIT TRANSACTION TRX_UPD_INITIATIVE;

                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'INITIATIVE ACTUALIZADA CORRECTAMENTE';

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_UPD_INITIATIVE;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR LA INITIATIVE';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL ACTUALIZAR LA INITIATIVE',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END




    --LISTAR INITIATIVES--
    ELSE IF @w_Accion = 'S'
    BEGIN

        BEGIN TRY

            SELECT
                initiativeId,
                initiativeSummary,
                initiativeDescription,
                initiativeOwner,
                initiativeGoals,
                initiativeBusinessValue,
                initiativeTargetStart,
                initiativeTargetEnd,
                initiativeCreationDate,
                initiativeCreatorId,
                initiativeModificationDate,
                initiativeModificatorId,
                initiativeStatus
            FROM [SQM_GENERAL].[TBL_Initiatives] (NOLOCK)
            ORDER BY initiativeId
            OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
            FETCH NEXT @i_RowsPerPage ROWS ONLY;

            SET @w_totalRows = @@ROWCOUNT;

            IF @w_totalRows > 0
            BEGIN
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'INITIATIVES LISTADAS CORRECTAMENTE';
            END
            ELSE
            BEGIN
                SET @o_Numero = 204;
                SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
            END

        END TRY
        BEGIN CATCH

            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL LISTAR LAS INITIATIVES';

            SET @o_MensajeTecnico = CONCAT_WS(
                ' - ',
                'ERROR AL LISTAR LAS INITIATIVES',
                ERROR_PROCEDURE(),
                ERROR_LINE(),
                ERROR_MESSAGE()
            );

        END CATCH

    END



    --ACCION INVALIDA--
    ELSE
    BEGIN

        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'METODO NO HABILITADO';
        SET @o_MensajeTecnico = 'EL PROCEDIMIENTO ALMACENADO NO TIENE HABILITADA ESA OPCION';

    END

END;
GO