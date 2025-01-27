USE [EcuadDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_maintenance_course]    Script Date: 7/5/2024 9:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CARLOS APARICIO
-- Create date: 25-04-2024
-- Description:	COURSE MAINTENANCE
-- =============================================
--EXEC sp_maintenance_course @json ='{"Accion":"C","IdCourse":2,"Status":1,"Course":{"IdCourse":2,"Code":"001","Name":"ALCOHOL INITIAL","Condition":"40 HR","CourseStart":"25/4/2024 0:00:00","CourseEnd":"25/4/2024 0:00:00","QR":true}}'
--EXEC sp_maintenance_course @json ='{"Accion":"R","IdCourse":2,"Status":1,"Course":{"IdCourse":2,"Code":"001","Name":"ALCOHOL INITIAL","Condition":"40 HR","CourseStart":"25/4/2024 0:00:00","CourseEnd":"25/4/2024 0:00:00","QR":true}}'
--EXEC sp_maintenance_course @json ='{"Accion":"U","IdCourse":2,"Status":1,"Course":{"IdCourse":2,"Code":"001","Name":"ALCOHOL INITIAL","Condition":"40 HR","CourseStart":"25/4/2024 0:00:00","CourseEnd":"25/4/2024 0:00:00","QR":true}}'
--EXEC sp_maintenance_course @json ='{"Accion":"D","IdCourse":2,"Status":1,"Course":{"IdCourse":2,"Code":"001","Name":"ALCOHOL INITIAL","Condition":"40 HR","CourseStart":"25/4/2024 0:00:00","CourseEnd":"25/4/2024 0:00:00","QR":true}}'
--EXEC sp_maintenance_course @json='{"Accion":"R","IdRecord":0,"Status":1,"UserCreate":1,"Record":{"IdRecord":0,"IdStudent":0,"IdCourse":0,"Secuential":null,"Status":false,"DateRegister":"0001-01-01T00:00:00"}}'
--EXEC sp_maintenance_course @json ='{"Accion":"F"}'
ALTER PROCEDURE [dbo].[sp_maintenance_course]
	@json NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Message VARCHAR(100),
			@Accion CHAR(1),
			@IdCourse INT,
			@Status INT;
	DECLARE @tmp_course TABLE(
			IdCourse INT,
			Code VARCHAR(30),
			Name VARCHAR(100),
			Condition VARCHAR(100),
			CourseStart DATETIME,
			CourseEnd DATETIME,
			QR BIT
	);

	SELECT @Accion = Accion,
			@IdCourse = IdCourse,
			@Status = Status
	FROM OPENJSON(@json) WITH (Accion CHAR(1) '$.Accion', IdCourse INT '$.IdCourse',Status INT '$.Status');
	IF @Accion = 'C' 
		BEGIN  
			DECLARE @TMP_INSERT TABLE ( Code varchar(30), Name VARCHAR(100));
			
			INSERT INTO @TMP_INSERT 
			SELECT Code, Name
				FROM OPENJSON(@json) WITH ( student NVARCHAR(MAX) '$.Course' AS JSON) 
					OUTER APPLY OPENJSON(student) WITH ( Code VARCHAR(30) '$.Code', Name VARCHAR(100) '$.Name');
			--valida que no existe un curso con el mismo nombre o código
			IF EXISTS(SELECT * FROM @TMP_INSERT AS tmpCourse
				INNER JOIN Courses c ON C.Code = tmpCourse.Code OR c.Name = tmpCourse.Name) 
				BEGIN
					SET @Message = 'Ya existe un curso, con el mismo código o nombre...!';
				END
			ELSE
				BEGIN
    				BEGIN TRY
						BEGIN TRANSACTION INSERTAR
						INSERT INTO Courses
						(	Code
							,Name
							,Condition
							,CourseStart
							,CourseEnd
							,QR
						)
						SELECT
							Code
							,Name
							,Condition
							,TRY_CONVERT(DATE, CourseStart, 103) AS CourseStart
							,TRY_CONVERT(DATE, CourseEnd, 103) AS CourseEnd							
							,QR
						FROM
							OPENJSON(@json)
							WITH
							(
								student NVARCHAR(MAX) '$.Course' AS JSON
							)
							OUTER APPLY
							OPENJSON(student)
							WITH
							(
								Code VARCHAR(30) '$.Code',
								Name VARCHAR(100) '$.Name',
								Condition VARCHAR(100) '$.Condition',
								CourseStart VARCHAR(20) '$.CourseStart',
								CourseEnd VARCHAR(13) '$.CourseEnd',
								QR BIT '$.QR'
							);
						SET @Message = 'Curso creado correctamente..!';
						COMMIT TRANSACTION INSERTAR
					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION INSERTAR
						SET @Message = 'Error: ' + ERROR_MESSAGE();
					END CATCH
				END
		END
	IF @Accion = 'R'
		BEGIN
			 SELECT c.IdCourse
					,c.Code
					,c.Name
					,c.Condition
					,c.CourseStart
					,c.CourseEnd
					,c.QR
					,c.Status
			 FROM Courses c
			 WHERE c.Status = @Status;
		END
	IF @Accion = 'U'
		BEGIN  
    		BEGIN TRY
				BEGIN TRANSACTION ACTUALIZAR
					INSERT INTO @tmp_course(
						IdCourse
						,Code
						,Name
						,Condition
						,CourseStart
						,CourseEnd
						,QR
					)
					SELECT
						@IdCourse
						,Code
						,Name
						,Condition
						,TRY_CONVERT(DATE, CourseStart, 103) AS CourseStart
						,TRY_CONVERT(DATE, CourseEnd, 103) AS CourseEnd							
						,QR
					FROM
						OPENJSON(@json)
						WITH
						(
							student NVARCHAR(MAX) '$.Course' AS JSON
						)
						OUTER APPLY
						OPENJSON(student)
						WITH
						(
							Code VARCHAR(30) '$.Code',
							Name VARCHAR(100) '$.Name',
							Condition VARCHAR(100) '$.Condition',
							CourseStart VARCHAR(20) '$.CourseStart',
							CourseEnd VARCHAR(13) '$.CourseEnd',
							QR BIT '$.QR'
						);

					UPDATE course
					SET course.Code = tmp.Code,
						course.Name = tmp.NAME,
						course.Condition = tmp.Condition,
						course.CourseStart = tmp.CourseStart,
						course.CourseEnd = tmp.CourseEnd,
						course.QR = tmp.QR
					FROM Courses AS course
					INNER JOIN @tmp_course AS tmp ON course.IdCourse = tmp.IdCourse
					WHERE course.IdCourse = @IdCourse;
					
					SET @Message = 'Curso actualizado correctamente..!';
						
				COMMIT TRANSACTION ACTUALIZAR
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION ACTUALIZAR
				SET @Message = 'Error: ' + ERROR_MESSAGE();
			END CATCH
		END
	IF @Accion = 'D'
		BEGIN  
    		BEGIN TRY
				BEGIN TRANSACTION ELIMINAR
				UPDATE course
					SET course.Status = @Status
					FROM Courses AS course
					WHERE course.IdCourse = @IdCourse;
				SET @Message = 'Curso eliminado correctamente..!';
				COMMIT TRANSACTION ELIMINAR
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION ELIMINAR
				SET @Message = 'Error: ' + ERROR_MESSAGE();
			END CATCH
		END
	IF @Accion = 'F'
	BEGIN		
		SELECT 	DISTINCT		  
				course.IdCourse
				,course.Name AS Course
				,course.Code
				,course.Condition
				,course.CourseEnd AS CompletionDate
				,course.QR
				,users.Names AS Instructor
				,users.Signature
				,student.IdStudent
				,student.FirstName + ' ' + student.Middle + ' ' + student.LastName AS FullName
				,student.DNI
				,student.PhoneNumber
				,student.Email
				,student.Path
				,student.Photo
		FROM Record AS record
		INNER JOIN Students AS student ON record.IdStudent = student.IdStudent
		INNER JOIN Courses AS course ON record.IdCourse = course.IdCourse
		INNER JOIN Users AS users ON users.IdUser = course.IdInstructor 
		WHERE course.Status = 1
			AND student.Status = 1
			AND course.Status = 1;

		IF @@rowcount > 0 
			BEGIN  
				SET @Message = 'Datos devueltos correctamente..!';	
			END
		ELSE
			BEGIN
				SET @Message = 'La consulta no devolvió registros..!'
			END
	END
	IF @Accion='G'
	BEGIN		
		SELECT 			  
				course.IdCourse
				,course.Name AS Course
				,course.CourseStart AS IssueDate
				,course.CourseEnd AS ExpirateDate
				,student.IdStudent
				,student.FirstName + ' ' + student.Middle + ' ' + student.LastName AS FullName
				,student.DNI
				,student.EyeColor
				,student.height AS Height
				,student.Path
				,student.Photo
				,student.PhoneNumber
				,student.Email
				,student.StreetAddress AS Address
		FROM Record AS record
		INNER JOIN Students AS student ON record.IdStudent = student.IdStudent
		INNER JOIN Courses AS course ON record.IdCourse = course.IdCourse
		WHERE record.Status = 1;
		
		IF @@rowcount > 0 
			BEGIN  
				SET @Message = 'Datos devueltos correctamente..!';	
			END
		ELSE
			BEGIN
				SET @Message = 'La consulta no devolvió registros..!'
			END
	END

    SELECT @Message AS Mensaje;	
END

