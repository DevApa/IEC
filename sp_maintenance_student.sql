USE [EcuadDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_maintenance_student]    Script Date: 7/5/2024 9:07:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CARLOS APARICIO
-- Create date: 24-04-2024
-- Description:	MANTENIMIENTO ESTUDIANTE
-- =============================================
--exec sp_maintenance_student @json='{"Accion":"C","IdStudent":0,"DNI":null,"Status":1,"Student":{"IdStudent":0,"FirstName":"Christopher Alexander","Middle":"Schwarzenegger","LastName":"Schweinsteiger ","DNI":"0999999999","DateOfBirth":"6/5/1995 22:11:24","StreetAddress":"Brittany Hall 55 East 10th Street, New York, NY 10003, United States","PhoneNumbre":"0952145215","Email":"chris.sw@gmail.com","Height":"1.65\"","EyeColor":"Marrón","Gender":"1","Path":null,"Status":false,"Photo":"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"}}'
--exec sp_maintenance_student @json='{"Accion":"R","IdStudent":-1,"DNI":"","Status":1,"Student":{"IdStudent":0,"FirstName":null,"Middle":null,"LastName":null,"DNI":null,"DateOfBirth":null,"StreetAddress":null,"PhoneNumbre":null,"Email":null,"Height":null,"EyeColor":null,"Gender":null,"Path":null,"Status":false}}'
--EXEC sp_maintenance_student @json='{"Accion":"D","IdStudent":2,"DNI":null,"Status":0,"Student":{"IdStudent":2,"FirstName":null,"Middle":null,"LastName":null,"DNI":null,"DateOfBirth":null,"StreetAddress":null,"PhoneNumbre":null,"Email":null,"Height":null,"EyeColor":null,"Gender":null,"Path":null,"Status":false}}'
ALTER PROCEDURE [dbo].[sp_maintenance_student]
	@json NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Message VARCHAR(100),
			@Accion CHAR(1),
			@IdStudent INT,
			@DNI VARCHAR(13),
			@Status INT;
	DECLARE @tmp_estudent TABLE(
		IdStudent bigint
		,FirstName varchar(100)
		,Middle varchar(100)
		,LastName varchar(100)
		,DateOfBirth date
		,DNI varchar(13)
		,StreetAddress varchar(1000)
		,PhoneNumber varchar(20)
		,Email varchar(200)
		,height varchar(200)
		,EyeColor varchar(200)
		,Gender varchar(200)
		,Path NVARCHAR(MAX)
		,Status BIT
		,Photo VARBINARY(MAX)
	);
	SELECT @Accion = Accion,
			@IdStudent = IdStudent,
			@DNI = DNI,
			@Status = Status
	FROM OPENJSON(@json) WITH (
		Accion CHAR(1) '$.Accion', 
		IdStudent INT '$.IdStudent', 
		DNI VARCHAR(13) '$.DNI', 
		Status INT '$.Status'
	);

	IF @Accion='C' 
		BEGIN  
			BEGIN TRY
				BEGIN TRANSACTION INSERTAR
    			INSERT INTO Students(
					FirstName
					,Middle
					,LastName
					,DateOfBirth
					,DNI
					,StreetAddress
					,PhoneNumber
					,Email
					,height
					,EyeColor
					,Gender
					,Path
					,Photo
				)
				SELECT 
					FirstName
					,Middle
					,LastName
					,TRY_CONVERT(DATE, DateOfBirth, 103) AS DateOfBirth
					,DNI
					,StreetAddress
					,PhoneNumbre
					,Email
					,height
					,EyeColor
					,Gender
					,Path
					,Photo
				FROM
						OPENJSON(@json)
						WITH
						(
							student NVARCHAR(MAX) '$.Student' AS JSON
						)
						OUTER APPLY
						OPENJSON(student)
						WITH
						(
							FirstName VARCHAR(100) '$.FirstName',
							Middle VARCHAR(100) '$.Middle',
							LastName VARCHAR(100) '$.LastName',
							DateOfBirth VARCHAR(20) '$.DateOfBirth',
							DNI VARCHAR(13) '$.DNI',
							StreetAddress VARCHAR(1000) '$.StreetAddress',
							PhoneNumbre VARCHAR(20) '$.PhoneNumbre',
							Email VARCHAR(200) '$.Email',
							height VARCHAR(5) '$.Height',
							EyeColor VARCHAR(200) '$.EyeColor',
							Gender INT '$.Gender',
							Path NVARCHAR(MAX),
							Photo VARBINARY(MAX) '$.Photo'
						);
				SET @Message = 'Estudiante creado correctamente..!';
				COMMIT TRANSACTION INSERTAR;				
			END TRY
			BEGIN CATCH
				ROLLBACK  TRANSACTION INSERTAR;
				SET @Message = 'Error: ' + ERROR_MESSAGE();
			END CATCH  
		END;
	IF @Accion='R' 
		BEGIN
        	SELECT 
				IdStudent
				,FirstName
				,Middle
				,LastName
				,DateOfBirth
				,DNI
				,StreetAddress
				,PhoneNumber
				,Email
				,height
				,EyeColor
				,Gender
				,Path
				,Status
				,Photo
			FROM Students
			WHERE Status = @Status
			--(@IdStudent < 0
			--	OR IdStudent = @IdStudent)
			--	OR (@DNI = ''
			--	OR DNI = @DNI)
			--	OR (@Status < 0
			--	OR Status = @Status);

			IF @@rowcount > 0 
				BEGIN  
					SET @Message = 'Datos devueltos correctamente..!';	
				END
			ELSE
				BEGIN
					SET @Message = 'La consulta no devolvió registros..!'
				END
			
		END
	IF @Accion='U' 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION ACTUALIZAR
					INSERT INTO @tmp_estudent
						(
							IdStudent
							,FirstName
							,Middle
							,LastName
							,DateOfBirth
							,DNI
							,StreetAddress
							,PhoneNumber
							,Email
							,height
							,EyeColor
							,Gender
							,Path
							,Photo
						)
						SELECT
							@IdStudent
							,FirstName
							,Middle
							,LastName
							,TRY_CONVERT(DATE, DateOfBirth, 103) AS DateOfBirth
							,DNI
							,StreetAddress
							,PhoneNumbre
							,Email
							,height
							,EyeColor
							,Gender
							,Path
							,Photo
						FROM
								OPENJSON(@json)
								WITH
								(
									student NVARCHAR(MAX) '$.Student' AS JSON
								)
								OUTER APPLY
								OPENJSON(student)
								WITH
								(
									FirstName VARCHAR(100) '$.FirstName',
									Middle VARCHAR(100) '$.Middle',
									LastName VARCHAR(100) '$.LastName',
									DateOfBirth VARCHAR(20) '$.DateOfBirth',
									DNI VARCHAR(13) '$.DNI',
									StreetAddress VARCHAR(1000) '$.StreetAddress',
									PhoneNumbre VARCHAR(20) '$.PhoneNumbre',
									Email VARCHAR(200) '$.Email',
									height VARCHAR(5) '$.Height',
									EyeColor VARCHAR(200) '$.EyeColor',
									Gender INT '$.Gender',
									Path NVARCHAR(MAX),
									Photo VARBINARY(MAX) '$.Photo'
								);
					
        			UPDATE student
					SET student.FirstName = tmp.FirstName,
						student.Middle = tmp.Middle,
						student.LastName = tmp.LastName,
						student.DateOfBirth = tmp.DateOfBirth,
						student.DNI = tmp.DNI,
						student.StreetAddress = tmp.StreetAddress,
						student.PhoneNumber = tmp.PhoneNumber,
						student.Email = tmp.Email,
						student.height = tmp.height,
						student.EyeColor = tmp.EyeColor,
						student.Gender = tmp.Gender,
						student.Path = tmp.Path,
						student.Photo = tmp.Photo
					FROM Students AS student
					INNER JOIN @tmp_estudent AS tmp ON student.IdStudent = tmp.IdStudent
					WHERE student.IdStudent = @IdStudent;
					SET @Message = 'Estudiante actualizado correctamente..!';
				COMMIT TRANSACTION ACTUALIZAR;				
			END TRY
			BEGIN CATCH
				ROLLBACK  TRANSACTION ACTUALIZAR;
				SET @Message = 'Error: ' + ERROR_MESSAGE();
			END CATCH 
		END
	IF @Accion='D' 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION ELIMINAR
        			UPDATE student
					SET student.Status = 0
					FROM Students AS student
					WHERE student.IdStudent = @IdStudent;
					SET @Message = 'Estudiante eliminado correctamente..!';
				COMMIT TRANSACTION ELIMINAR;
			END TRY
			BEGIN CATCH
				ROLLBACK  TRANSACTION ELIMINAR;
				SET @Message = 'Error: ' + ERROR_MESSAGE();
			END CATCH 
		END
	
  SELECT @Message AS Mensaje;		  
END

