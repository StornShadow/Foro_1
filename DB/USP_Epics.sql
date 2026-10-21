CREATE OR ALTER PROC [SQM_GENERAL].[USP_Epics]
(
    @i_epicId INT = NULL,
    @i_epicName VARCHAR(100) = NULL,
    @i_epicSummary VARCHAR(500) = NULL,
    @i_epicDescription VARCHAR(4000) = NULL,
    @i_epicParentLink INT = NULL,
    @i_epicOwner INT = NULL,
    @i_epicStartDate DATE = NULL,
    @i_epicDueDate DATE = NULL,
    @i_epicPriority INT = NULL,
    @i_epicCreationDate DATETIME = NULL,
    @i_epicCreatorId INT = NULL,
    @i_epicModificationDate DATETIME = NULL,
    @i_epicModificatorId INT = NULL,
    @i_epicStatus INT = NULL,
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

    -- Si no se recibe fecha de creación,
    -- se toma la fecha actual.
    IF @i_epicCreationDate IS NULL
        SET @i_epicCreationDate = GETDATE();

    -- Si no se recibe fecha de modificación,
    -- se toma la fecha actual.
    IF @i_epicModificationDate IS NULL
        SET @i_epicModificationDate = GETDATE();



    --INSERTAR EPIC--
    IF @w_Accion = 'I'
    BEGIN

        -- Nombre obligatorio
        IF ISNULL(@i_epicName,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL NOMBRE DEL EPIC ES OBLIGATORIO';
        END

        -- Resumen obligatorio
        ELSE IF ISNULL(@i_epicSummary,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL RESUMEN DEL EPIC ES OBLIGATORIO';
        END

        -- Descripción obligatoria
        ELSE IF ISNULL(@i_epicDescription,'') = ''
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA DESCRIPCION DEL EPIC ES OBLIGATORIA';
        END

        -- Parent Link obligatorio
        ELSE IF ISNULL(@i_epicParentLink,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA INITIATIVE PADRE ES OBLIGATORIA';
        END

        -- Owner obligatorio
        ELSE IF ISNULL(@i_epicOwner,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL OWNER ES OBLIGATORIO';
        END

        -- Creator obligatorio
        ELSE IF ISNULL(@i_epicCreatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL CREADOR ES OBLIGATORIO';
        END

        -- Status obligatorio
        ELSE IF ISNULL(@i_epicStatus,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL STATUS ES OBLIGATORIO';
        END

        -- Validación de fechas
        ELSE IF @i_epicStartDate IS NOT NULL
            AND @i_epicDueDate IS NOT NULL
            AND @i_epicStartDate > @i_epicDueDate
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA FECHA INICIO NO PUEDE SER MAYOR A LA FECHA FIN';
        END

        -- Validar Initiative Padre
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_GENERAL].[TBL_Initiatives] (NOLOCK)
            WHERE initiativeId = @i_epicParentLink
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA INITIATIVE PADRE NO EXISTE';
        END

        -- Validar Owner
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_epicOwner
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL OWNER NO EXISTE';
        END

        -- Validar Creator
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_epicCreatorId
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL USUARIO CREADOR NO EXISTE';
        END

        -- Validar Prioridad
        ELSE IF @i_epicPriority IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_CATALOGS].[TBL_Priorities] (NOLOCK)
                WHERE priorityId = @i_epicPriority
                    AND priorityEnable = 1
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA PRIORIDAD NO EXISTE';
        END

        -- Validar Status
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
            WHERE statusId = @i_epicStatus
                AND statusEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL STATUS NO EXISTE';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_INS_EPIC;

            BEGIN TRY

                INSERT INTO [SQM_GENERAL].[TBL_Epics]
                (
                    epicName,
                    epicSummary,
                    epicDescription,
                    epicParentLink,
                    epicOwner,
                    epicStartDate,
                    epicDueDate,
                    epicPriority,
                    epicCreationDate,
                    epicCreatorId,
                    epicStatus
                )
                VALUES
                (
                    @i_epicName,
                    @i_epicSummary,
                    @i_epicDescription,
                    @i_epicParentLink,
                    @i_epicOwner,
                    @i_epicStartDate,
                    @i_epicDueDate,
                    @i_epicPriority,
                    @i_epicCreationDate,
                    @i_epicCreatorId,
                    @i_epicStatus
                );

                COMMIT TRANSACTION TRX_INS_EPIC;

                SET @o_Numero = 201;
                SET @o_MensajeUsuario = 'EPIC REGISTRADO CORRECTAMENTE';

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_INS_EPIC;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL REGISTRAR EL EPIC';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL REGISTRAR EL EPIC',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END





    --ACTUALIZAR EPIC--
    ELSE IF @w_Accion = 'U'
    BEGIN

        IF ISNULL(@i_epicId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID DEL EPIC ES OBLIGATORIO';
        END

        ELSE IF ISNULL(@i_epicModificatorId,0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL MODIFICADOR ES OBLIGATORIO';
        END

        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_GENERAL].[TBL_Epics] (NOLOCK)
            WHERE epicId = @i_epicId
        )
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL EPIC NO EXISTE';
        END

        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
            WHERE userId = @i_epicModificatorId
                AND userEnable = 1
        )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL USUARIO MODIFICADOR NO EXISTE';
        END

        ELSE IF @i_epicParentLink IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_GENERAL].[TBL_Initiatives] (NOLOCK)
                WHERE initiativeId = @i_epicParentLink
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA INITIATIVE PADRE NO EXISTE';
        END

        ELSE IF @i_epicOwner IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_SECURITY].[TBL_Users] (NOLOCK)
                WHERE userId = @i_epicOwner
                    AND userEnable = 1
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL OWNER NO EXISTE';
        END

        ELSE IF @i_epicPriority IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_CATALOGS].[TBL_Priorities] (NOLOCK)
                WHERE priorityId = @i_epicPriority
                    AND priorityEnable = 1
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA PRIORIDAD NO EXISTE';
        END

        ELSE IF @i_epicStatus IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM [SQM_CATALOGS].[TBL_Status] (NOLOCK)
                WHERE statusId = @i_epicStatus
                    AND statusEnable = 1
            )
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL STATUS NO EXISTE';
        END

        ELSE IF @i_epicStartDate IS NOT NULL
            AND @i_epicDueDate IS NOT NULL
            AND @i_epicStartDate > @i_epicDueDate
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LA FECHA INICIO NO PUEDE SER MAYOR A LA FECHA FIN';
        END

        ELSE
        BEGIN

            BEGIN TRANSACTION TRX_UPD_EPIC;

            BEGIN TRY

                UPDATE [SQM_GENERAL].[TBL_Epics]
                SET
                    epicName = COALESCE(@i_epicName, epicName),
                    epicSummary = COALESCE(@i_epicSummary, epicSummary),
                    epicDescription = COALESCE(@i_epicDescription, epicDescription),
                    epicParentLink = COALESCE(@i_epicParentLink, epicParentLink),
                    epicOwner = COALESCE(@i_epicOwner, epicOwner),
                    epicStartDate = COALESCE(@i_epicStartDate, epicStartDate),
                    epicDueDate = COALESCE(@i_epicDueDate, epicDueDate),
                    epicPriority = COALESCE(@i_epicPriority, epicPriority),
                    epicModificationDate = @i_epicModificationDate,
                    epicModificatorId = @i_epicModificatorId,
                    epicStatus = COALESCE(@i_epicStatus, epicStatus)
                WHERE epicId = @i_epicId;

                COMMIT TRANSACTION TRX_UPD_EPIC;

                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'EPIC ACTUALIZADO CORRECTAMENTE';

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION TRX_UPD_EPIC;

                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR EL EPIC';

                SET @o_MensajeTecnico = CONCAT_WS(
                    ' - ',
                    'ERROR AL ACTUALIZAR EL EPIC',
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                );

            END CATCH

        END

    END




    --LISTAR EPICS--
    ELSE IF @w_Accion = 'S'
    BEGIN

        BEGIN TRY

            SELECT
                epicId,
                epicName,
                epicSummary,
                epicDescription,
                epicParentLink,
                epicOwner,
                epicStartDate,
                epicDueDate,
                epicPriority,
                epicCreationDate,
                epicCreatorId,
                epicModificationDate,
                epicModificatorId,
                epicStatus
            FROM [SQM_GENERAL].[TBL_Epics] (NOLOCK)
            ORDER BY epicId
            OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
            FETCH NEXT @i_RowsPerPage ROWS ONLY;

            SET @w_totalRows = @@ROWCOUNT;

            IF @w_totalRows > 0
            BEGIN
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'EPICS LISTADOS CORRECTAMENTE';
            END
            ELSE
            BEGIN
                SET @o_Numero = 204;
                SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
            END

        END TRY
        BEGIN CATCH

            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL LISTAR LOS EPICS';

            SET @o_MensajeTecnico = CONCAT_WS(
                ' - ',
                'ERROR AL LISTAR LOS EPICS',
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