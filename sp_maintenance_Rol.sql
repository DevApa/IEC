USE [EcuadDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_maintenance_Rol]    Script Date: 7/5/2024 9:07:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Carlos Aparicio
-- Create date: 24-04-2024
-- Description:	Get all rol the system
-- =============================================
--EXEC sp_maintenance_rol @json='{"Accion":"R","IdRol":1,"Status":0,"UserCreation":1,"Rol":{"IdRol":1,"Name":"operator"}}'
--EXEC sp_maintenance_Rol @json ='{"Accion":"A","IdRol":0,"Status":0,"UserCreation":1,"Rol":{"IdRol":0,"Name":"employee"}}'
ALTER PROCEDURE [dbo].[sp_maintenance_Rol]
	@json NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Message NVARCHAR(MAX)
		    ,@Accion CHAR(1)
			,@Name VARCHAR(30)
			,@IdRol INT
			,@Status BIT
			,@UserCreation INT
			,@Code INT;
	DECLARE @tmp_rol TABLE
	(
		IdRol INT
		,Name VARCHAR(200)
		,Status VARCHAR(30)		
	);	
	
	--Get Head json
	SELECT @Accion = Accion 
		  ,@IdRol  = IdRol		  
		  ,@Status = Status
		  ,@UserCreation = UserCreation
	FROM OPENJSON(@json) WITH 
	( 
		Accion CHAR(1) '$.Accion'
		,IdRol INT '$.IdRol'
		,Status INT '$.Status'
		,UserCreation VARCHAR(50) '$.UserCreation'
	);
		
	--Get object Rol
	SELECT @Name = UPPER(Name)
	FROM OPENJSON(@json) WITH ( sourse NVARCHAR(MAX) '$.Rol' AS JSON )
		OUTER APPLY OPENJSON(sourse)WITH ( Name VARCHAR(50) '$.Name');

	IF @Accion = 'C'
		BEGIN
			IF EXISTS(SELECT * FROM Rol r WHERE r.Name = @Name)
				BEGIN
					SET @Message = 'Ya existe un rol con el mismo nombre, renombrar..!';
					SET @Code = 1;
				END
			ELSE
				BEGIN
					BEGIN TRY
						BEGIN TRANSACTION INSERTAR
							INSERT INTO Rol
							(
								Name
								,UserCreation
								,CreationDate
							)
							SELECT UPPER(Name)
								  ,@UserCreation
								  ,GETDATE()
							FROM OPENJSON(@json) WITH ( sourse NVARCHAR(MAX) '$.Rol' AS JSON )
								OUTER APPLY OPENJSON(sourse) WITH ( Name VARCHAR(50) '$.Name');

							SET @IdRol = SCOPE_IDENTITY();
							SET @Message = CONCAT('Rol ', @IdRol, ', creado correctamente..!');
							SET @Code = 0;
						COMMIT TRANSACTION INSERTAR;
					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION INSERTAR;
						SET @Code = 1;
						SET @Message = 'ERROR: ' + ERROR_MESSAGE();
					END CATCH
				END
		END
	IF @Accion = 'R'
		BEGIN
			INSERT INTO @tmp_rol(IdRol, Name, Status)
				SELECT r.IdRol,r.Name ,R.Status
				FROM Rol r
				WHERE r.IdRol = @IdRol;	

			IF (SELECT COUNT(*) AS rows FROM @tmp_rol) > 0
				BEGIN  
            		SELECT rol.IdRol, rol.Name, rol.Status FROM @tmp_rol AS rol;
					SET @Message = 'Datos devueltos correctamente..!';	
					SET @Code = 0;
				END
            ELSE 
				BEGIN
					SET @Message = 'La consulta no devolvió registros..!';
					SET @Code = 1;
				END
		END
	IF @Accion = 'U'
		IF EXISTS(SELECT * FROM Rol r WHERE r.Name = @Name AND r.IdRol != @IdRol)
			BEGIN
				SET @Message = 'Ya existe un rol con el mismo nombre, renombrar..!';
			END
		ELSE
			BEGIN
				BEGIN TRY
					BEGIN TRANSACTION ACTUALIZAR
					UPDATE rol
					SET rol.Name = UPPER(@Name)
					FROM Rol AS rol
					WHERE rol.IdRol = @IdRol;
					IF @@rowcount > 0
						BEGIN  
                    		SET @Message = 'Rol actualizado correctamente..!';
							SET @Code = 0;
						END
                    ELSE
						BEGIN
							SET @Message = 'Rol no se actualizado correctamente..!';
							SET @Code = 1;
						END					
					COMMIT TRANSACTION ACTUALIZAR;
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION ACTUALIZAR;
					SET @Message = 'ERROR: ' + ERROR_MESSAGE();
				END CATCH
			END
	IF @Accion = 'D'
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION ELIMINAR
					UPDATE rol
					SET rol.Status = 0,
						rol.UserUpDate = @UserCreation,
						rol.DateUpdate = GETDATE()
					FROM Rol AS rol
					WHERE rol.IdRol = @IdRol;

					SELECT @Name = r.Name FROM Rol r WHERE r.IdRol=@IdRol;

					SET @Message = CONCAT('Rol (', @Name, '), eliminado correctamente..!');
					SET @Code = 0;
				COMMIT TRANSACTION ELIMINAR;
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION ELIMINAR;
				SET @Message = 'ERROR: ' + ERROR_MESSAGE();
				SET @Code = 1;
			END CATCH
		END
	IF @Accion = 'A'
		BEGIN
			--SET ALL ROL ACTIVE
			INSERT INTO @tmp_rol(IdRol, Name, Status)
				SELECT r.IdRol,r.Name ,R.Status
				FROM Rol r
				WHERE r.Status = 1;

			IF (SELECT COUNT(*) AS rows FROM @tmp_rol) > 0
				BEGIN  
            		SELECT rol.IdRol, rol.Name, rol.Status FROM @tmp_rol AS rol;
					SET @Message = 'Datos devueltos correctamente..!';	
					SET @Code = 0;
				END
            ELSE 
				BEGIN
					SET @Message = 'La consulta no devolvió registros..!';
					SET @Code = 1;
				END			
		END
	SELECT @Code AS Codigo, @Message AS Mensaje;
END
