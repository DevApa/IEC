USE [EcuadDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_enroll_course]    Script Date: 7/5/2024 9:07:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CARLOS APARICIO
-- Create date: 25-04-2024
-- Description:	REGISTER COURSE
-- =============================================
--EXEC sp_enroll_course @json='{"Accion":"C","IdRecord":0,"Status":0,"UserCreate":2,"Record":{"IdRecord":0,"IdStudent":1,"IdCourse":1,"Secuential":"0000000000011","Status":false,"DateRegister":"0001-01-01T00:00:00"}}'
--EXEC sp_enroll_course @json='{"Accion":"R","IdRecord":0,"Status":1,"UserCreate":2,"Record":{"IdRecord":0,"IdStudent":0,"IdCourse":0,"Secuential":null,"Status":false,"DateRegister":"0001-01-01T00:00:00"}}'
--EXEC sp_enroll_course @json='{"Accion":"U","IdRecord":2,"Status":0,"UserCreate":1,"Record":{"IdRecord":2,"IdStudent":2,"IdCourse":2,"Secuential":"0000000000022","Status":false,"DateRegister":"0001-01-01T00:00:00"}}'
                            --'{"Accion":"U","IdRecord":1,"Status":0,"UserCreate":2,"Record":{"IdRecord":1,"IdStudent":1,"IdCourse":1,"Secuential":"0000000000011","Status":false,"DateRegister":"0001-01-01T00:00:00"}}'

--EXEC sp_enroll_course @json='{"Accion":"R","IdRecord":0,"Status":1,"UserCreate":1,"Record":{"IdRecord":0,"IdStudent":0,"IdCourse":0,"Secuential":null,"Status":false,"DateRegister":"0001-01-01T00:00:00"}}'
ALTER PROCEDURE [dbo].[sp_enroll_course]
	@json NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Accion CHAR(1)=''
			,@IdRecord INT
			,@UserCreate INT
			,@Status INT
			,@Message VARCHAR(MAX)
			,@IdCourse INT
			,@IdStudent INT;
	DECLARE @tmp_record TABLE
	(
		IdRecord BIGINT
		,IdStudent BIGINT
		,IdCourse BIGINT
		,Secuential VARCHAR(200)
		,UserCreate INT
	);
	SELECT @Accion = Accion,
		@IdRecord = IdRecord,
		@UserCreate = UserCreate,
		@Status = Status
	FROM OPENJSON(@json) WITH (Accion CHAR(1) '$.Accion', IdRecord INT '$.IdRecord', UserCreate INT '$.UserCreate',Status INT '$.Status');	
	SELECT @IdStudent=IdStudent, @IdCourse=IdCourse
			FROM
				OPENJSON(@json)
				WITH
				(
					student NVARCHAR(MAX) '$.Record' AS JSON
				)
				OUTER APPLY
				OPENJSON(student)
				WITH
				(
					IdStudent INT '$.IdStudent',
					IdCourse INT '$.IdCourse',								
					Secuential VARCHAR(200) '$.Secuential'
				);
	
	
	IF @Accion='C'
		BEGIN
			IF EXISTS(SELECT DISTINCT r.IdRecord FROM Record r
				  WHERE r.IdStudent = @IdStudent
					AND r.IdCourse = @IdCourse
					AND r.Status = 1)
				BEGIN
					SET @Message = 'The student is already enrolled..!';
				END
			ELSE
				BEGIN  
    				BEGIN TRY
						BEGIN TRANSACTION INSERTAR
							INSERT INTO Record
								(
									IdStudent
									,IdCourse
									,Secuential
									,UserCreate
								)
								SELECT
									IdStudent
									,IdCourse
									,Secuential
									,@UserCreate
								FROM
									OPENJSON(@json)
									WITH
									(
										student NVARCHAR(MAX) '$.Record' AS JSON
									)
									OUTER APPLY
									OPENJSON(student)
									WITH
									(
										IdStudent INT '$.IdStudent',
										IdCourse INT '$.IdCourse',								
										Secuential VARCHAR(200) '$.Secuential'
									);
							SET @IdRecord = SCOPE_IDENTITY();
							SET @Message = CONCAT('Registro ', @IdRecord, '. Creado correctamente...!');
							COMMIT TRANSACTION INSERTAR							
					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION INSERTAR
						SET @Message = 'Error: ' + ERROR_MESSAGE()
					END CATCH			
				END
		END
	IF @Accion='R' 
		BEGIN  
    		SELECT record.IdRecord
				  ,record.Secuential
				  ,record.IdCourse
				  ,course.Code
				  ,course.Condition
				  ,course.CourseStart
				  ,course.CourseEnd
				  ,course.QR
				  ,record.IdStudent
				  ,student.FirstName + ' ' + student.Middle + ' ' + student.LastName AS FullName
				  ,student.DNI
				  ,student.PhoneNumber
				  ,student.Email
				  ,student.EyeColor
				  ,student.height
				  ,student.Path
				  ,student.Photo
			FROM Record AS record
			INNER JOIN Students AS student ON record.IdStudent = student.IdStudent
			INNER JOIN Courses AS course ON record.IdCourse = course.IdCourse
			WHERE record.Status = 1
				--AND  record.UserCreate = @UserCreate;
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
					INSERT INTO @tmp_record
					( 
					   IdRecord
					  ,IdStudent
					  ,IdCourse
					  ,Secuential
					  ,UserCreate
					 )
						SELECT
							IdRecord
							,IdStudent
							,IdCourse
							,Secuential
							,@UserCreate
						FROM
							OPENJSON(@json)
							WITH
							(
								student NVARCHAR(MAX) '$.Record' AS JSON
							)
							OUTER APPLY
							OPENJSON(student)
							WITH
							(
								IdRecord  BIGINT '$.IdRecord',
								IdStudent INT '$.IdStudent',
								IdCourse INT '$.IdCourse',								
								Secuential VARCHAR(200) '$.Secuential'
							);
						
						UPDATE record
						SET  record.IdStudent = tmp.IdStudent
						    ,record.IdCourse = tmp.IdCourse
							,record.Secuential = tmp.Secuential
							,record.UserUpdate = tmp.UserCreate
							,record.DateUpdate = GETDATE()
						FROM Record AS record
						INNER JOIN @tmp_record AS tmp ON record.IdRecord = tmp.IdRecord
						WHERE record.IdRecord = @IdRecord
							  AND record.Status = 1;

						SET @Message = CONCAT('Registro ', @IdRecord, '. Actualizado correctamente...!');
				COMMIT TRANSACTION ACTUALIZAR
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION ACTUALIZAR
				SET @Message = 'Error: ' + ERROR_MESSAGE()
			END CATCH			
		END
	IF @Accion='D' 
		BEGIN  
    		BEGIN TRY
				BEGIN TRANSACTION ELIMINAR
					UPDATE record
					SET record.Status = 0
					FROM Record AS record
					WHERE record.IdRecord = @IdRecord;

					SET @Message = CONCAT('Registro ', @IdRecord, '. Eliminado correctamente...!');
				COMMIT TRANSACTION ELIMINAR
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION ELIMINAR
				SET @Message = 'Error: ' + ERROR_MESSAGE()
			END CATCH			
		END	
    SELECT @Message AS Mensaje;
END
