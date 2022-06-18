<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
	<body>
		<table>
			<tr>
				<td>
					<jsp:include page="menu.html" />
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
					("jdbc:postgresql:project?user=postgres&password=Poseidon123@");
				%>
				
				<%
				// Check if an insertion is requested
				String action = request.getParameter("action");
				if (action != null && action.equals("insert")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// INSERT the student attrs INTO the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					("INSERT INTO student VALUES (?,?,?,?,?,?,?,?,?)"));
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					pstmt.setString(2, request.getParameter("FIRST_NAME"));
					pstmt.setString(3, request.getParameter("MIDDLE_NAME"));
					pstmt.setString(4, request.getParameter("LAST_NAME"));
					pstmt.setInt(5, Integer.parseInt(request.getParameter("SSN")));
					pstmt.setString(6, request.getParameter("RESIDENCE"));
					pstmt.setString(7, request.getParameter("USERNAME"));
					pstmt.setString(8, request.getParameter("DEPT_NAME"));
					pstmt.setInt(9, Integer.parseInt(request.getParameter("ATTENDANCE_ID")));
					
					pstmt.executeUpdate();
					
					conn.commit();
					conn.setAutoCommit(true);
				}
				
				// Check if an update is requested
				if (action != null && action.equals("update")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// UPDATE the student attributes in the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					"UPDATE student SET FIRST_NAME = ?, MIDDLE_NAME = ?, LAST_NAME = ?, SSN = ?, RESIDENCE = ?, USERNAME = ?, DEPT_NAME = ?, ATTENDANCE_ID = ?, WHERE STUDENT_ID = ?");
					
					pstmt.setString(1, request.getParameter("FIRST_NAME"));
					pstmt.setString(2, request.getParameter("MIDDLE_NAME"));
					pstmt.setString(3, request.getParameter("LAST_NAME"));
					pstmt.setInt(4, Integer.parseInt(request.getParameter("SSN")));
					pstmt.setString(5, request.getParameter("RESIDENCE"));
					pstmt.setString(6, request.getParameter("USERNAME"));
					pstmt.setString(7, request.getParameter("DEPT_NAME"));
					pstmt.setInt(8, Integer.parseInt(request.getParameter("ATTENDANCE_ID")));
					pstmt.setInt(9, Integer.parseInt(request.getParameter("STUDENT_ID")));
					
					int rowCount = pstmt.executeUpdate();
					
					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				
				// Check if a delete is requested
				if (action != null && action.equals("delete")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// DELETE the student FROM the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					"DELETE FROM student WHERE STUDENT_ID = ?");
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					int rowCount = pstmt.executeUpdate();
					
					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				%>
				
				<%
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				ResultSet rs = statement.executeQuery("SELECT * FROM student");
				%>
				
				<table>
					<tr>
						<th>Student ID</th>
						<th>First Name</th>
						<th>Middle Name</th>
						<th>Last Name</th>
						<th>SSN</th>
						<th>Residence</th>
						<th>Username</th>
						<th>Department Name</th>
						<th>Attendance ID</th>
					</tr>
					
					<tr>
						<form action="student.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="STUDENT_ID"></th>
							<th><input value="" name="FIRST_NAME"></th>
							<th><input value="" name="MIDDLE_NAME"></th>
							<th><input value="" name="LAST_NAME"></th>
							<th><input value="" name="SSN"></th>
							<th><input value="" name="RESIDENCE"></th>
							<th><input value="" name="USERNAME"></th>
							<th><input value="" name="DEPT_NAME"></th>
							<th><input value="" name="ATTENDANCE_ID"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action=""student.jsp"" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getInt("STUDENT_ID") %>" name="STUDENT_ID"></td>
							<td><input value="<%= rs.getString("FIRST_NAME") %>" name="FIRST_NAME"></td>
							<td><input value="<%= rs.getString("MIDDLE_NAME") %>" name="MIDDLE_NAME"></td>
							<td><input value="<%= rs.getString("LAST_NAME") %>" name="LAST_NAME"></td>
							<td><input value="<%= rs.getInt("SSN") %>" name="SSN"></td>
							<td><input value="<%= rs.getString("RESIDENCE") %>" name="RESIDENCE"></td>
							<td><input value="<%= rs.getString("USERNAME") %>" name="USERNAME"></td>
							<td><input value="<%= rs.getString("DEPT_NAME") %>" name="DEPT_NAME"></td>
							<td><input value="<%= rs.getInt("ATTENDANCE_ID") %>" name="ATTENDANCE_ID"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action=""student.jsp"" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getInt("STUDENT_ID") %>" name="STUDENT_ID">
							<td><input type="submit" value="Delete"></td>
						</form>
					</tr>
				<%
					}
				%>
				</table>
				
				<%
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
				</td>
			</tr>
		</table>
	</body>
</html>