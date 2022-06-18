<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
	<body>
		<table>
			<tr>
				<td>
					<jsp:include page="queryMenu.html" />
				</td>
				<td>
				<%-- Set the scripting language to java and --%>
				<%-- import the java.sql package --%>
				<%@ page language="java" import="java.sql.*" %>
				<%
					try {
					// Load Oracle Driver class file
					DriverManager.registerDriver(new org.postgresql.Driver());
					
					// Make a connection to the Oracle datasource
					Connection conn = DriverManager.getConnection
					("jdbc:postgresql:tritonlink?user=postgres");
				%>
				
				<%
				String action = request.getParameter("action");
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				// gets all students ever enrolled
				ResultSet rs = statement.executeQuery("SELECT DISTINCT STUDENT_ID FROM academic_history");
				%>
				
				<table>
					<tr>
						<form action="queryC.jsp" method="get">
							<input type="hidden" value="get" name="action">
							<label for="student-select">Choose a Student:</label>

							<select name="STUDENT_ID" id="student-select">
							  <option value="">--Please choose an  Student--</option>
							
				<%
					// Iterate over all students ever enrolled
					while ( rs.next() ) {
						PreparedStatement pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
						pstmt.setInt(1, rs.getInt("STUDENT_ID"));
						ResultSet rs2 = pstmt.executeQuery();
						rs2.next();

				%>
								<option value="<%= rs.getInt("STUDENT_ID") %>">ID: <%= rs2.getInt("STUDENT_ID") %> Name: <%= rs2.getString("FIRST_NAME") %> <%= rs2.getString("MIDDLE_NAME") %> <%= rs2.getString("LAST_NAME") %> SSN: <%= rs2.getInt("SSN") %></option>
				<%

					}
				%>
							</select>
							<th><input type="submit" value="Get"></th>
						</form>
					</tr>
				</table>

				<%
				// Check if an get is requested
				if (action != null && action.equals("get")){

					PreparedStatement pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					ResultSet rs2 = pstmt.executeQuery();
					rs2.next();
				%>
				<!-- PART 1 DISPLAY STUDENT ATTRS -->
				<table>
					<tr>
						<th>Student ID</th>
						<th>First Name</th>
						<th>Middle Name</th>
						<th>Last Name</th>
						<th>SSN</th>
					</tr>
					<tr>
						<td><%= request.getParameter("STUDENT_ID") %></td>
						<td><%= rs2.getString("FIRST_NAME") %></td>
						<td><%= rs2.getString("MIDDLE_NAME") %></td>
						<td><%= rs2.getString("LAST_NAME") %></td>
						<td><%= rs2.getInt("SSN") %></td>
					</tr>
				</table>

				<!-- PART 2 DISPLAY CLASS ATTRS -->
				<table>
					<tr>
						<th>Section ID</th>
						<th>Year</th>
						<th>Qtr</th>
						<th>Course ID</th>
						<th>Title</th>
						<th>Enroll Limit</th>
						<th>Instructor Name</th>
						<th>Grade</th>
						<th>Units</th>
					</tr>
				<%
					//rs2.close();
					// display * classes taken
					pstmt = conn.prepareStatement("SELECT * from academic_history where STUDENT_ID = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();
					System.out.println(rs);

					// for each class the student has taken (each entry in academic_history) 
					while(rs.next()){
						// get class attributes from the current class that student took
						PreparedStatement pstmt2 = conn.prepareStatement("SELECT * from class where COURSE_ID = ? and YEAR = ? and QTR = ? and ENROLL_LIST_ID IN (SELECT enroll_list_id from enroll_list where STUDENT_ID = ?)");
						pstmt2.setString(1, rs.getString("COURSE_ID"));
						pstmt2.setInt(2, rs.getInt("YEAR"));
						pstmt2.setString(3, rs.getString("QTR"));
						pstmt2.setInt(4, Integer.parseInt(request.getParameter("STUDENT_ID"))); 
						rs2 = pstmt2.executeQuery();
						rs2.next();

						// get the grade and units of the student for current class
						PreparedStatement pstmt3 = conn.prepareStatement("SELECT UNITS from enroll_list where ENROLL_LIST_ID = ? and STUDENT_ID = ?");
						pstmt3.setInt(1, rs2.getInt("ENROLL_LIST_ID"));
						pstmt3.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
						ResultSet rs3 = pstmt3.executeQuery();
						rs3.next();
				%>
					<tr>
						<td><%= rs2.getString("SECTION_ID") %></td>
						<td><%= rs2.getInt("YEAR") %></td>
						<td><%= rs2.getString("QTR") %></td>
						<td><%= rs2.getString("COURSE_ID") %></td>
						<td><%= rs2.getString("TITLE") %></td>
						<td><%= rs2.getInt("ENROLL_LIMIT") %></td>
						<td><%= rs2.getString("NAME") %></td>
						<td><%= rs.getString("GRADE") %></td>
						<td><%= rs3.getInt("UNITS") %></td>
					</tr>
				<%
						//rs2.close();
						rs3.close();
					}
				%>
				</table>
				<table>
					<tr>
						<th>Year</th>
						<th>Qtr</th>
						<th>GPA</th>
					</tr>

				<!-- PART 3 QTR GPA -->
				<%
					statement.executeUpdate("DROP TABLE IF EXISTS temp"); 
					statement.executeUpdate("CREATE TABLE temp (year int, qtr varchar(255), grade DECIMAL(2,1))");

					pstmt = conn.prepareStatement("SELECT QTR, YEAR, GRADE from academic_history where STUDENT_ID = ? and UPPER(GRADE) != 'IN' and UPPER(GRADE) != 'P' and UPPER(GRADE) != 'NP' ");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();

					// iterate over all the grades recieved 
					while(rs.next()){
						// do conversion
						PreparedStatement pstmt2 = conn.prepareStatement("SELECT NUMBER_GRADE from grade_conversion where LETTER_GRADE = ?");
						pstmt2.setString(1, rs.getString("GRADE"));
						rs2 = pstmt2.executeQuery();
						rs2.next();

						// insert conversion into temp
						pstmt2 = conn.prepareStatement("INSERT into temp values (?,?,?)");
						pstmt2.setInt(1, rs.getInt("YEAR"));
						pstmt2.setString(2, rs.getString("QTR"));
						pstmt2.setDouble(3, rs2.getDouble("NUMBER_GRADE"));
						pstmt2.executeUpdate();

						//rs2.close();
					}

					rs = statement.executeQuery("SELECT QTR, YEAR, AVG(GRADE) as GPA from temp GROUP BY QTR, YEAR");

					while(rs.next()){
				%>
					<tr>
						<td><%= rs.getInt("YEAR") %></td>
						<td><%= rs.getString("QTR") %></td>
						<td><%= rs.getDouble("GPA") %></td>
					</tr>
				<%
					}

					statement.executeUpdate("DROP TABLE IF EXISTS temp"); 
					// end of processing if statement
				}


				// Close the ResultSet
				rs.close();
				// Close the Statement
				statement.close();
				// Close the Connection
				conn.close();
				} catch (SQLException sqle) {
				out.println(sqle.getMessage());
				} catch (Exception e) {
				out.println(e.getMessage());
				}
				%>
				</table>
				</td>
			</tr>
		</table>
	</body>
</html>
