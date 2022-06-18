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
					("INSERT INTO degree VALUES (?,?,?,?,?)"));
					
					pstmt.setString(1, request.getParameter("DEGREE_TYPE"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
					pstmt.setInt(3, Integer.parseInt(request.getParameter("DEGREE_REQUIREMENT_ID")));
					pstmt.setString(4, request.getParameter("DEPT_NAME"));
					pstmt.setString(5, request.getParameter("DEGREE_NAME"));
					
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
					"UPDATE degree SET DEGREE_REQUIREMENT_ID = ?, DEPT_NAME = ?, DEGREE_TYPE = ? WHERE DEGREE_NAME = ? AND STUDENT_ID = ?");
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("DEGREE_REQUIREMENT_ID")));
					pstmt.setString(2, request.getParameter("DEPT_NAME"));
					pstmt.setString(3, request.getParameter("DEGREE_TYPE"));
					pstmt.setString(4, request.getParameter("DEGREE_NAME"));
					pstmt.setInt(5, Integer.parseInt(request.getParameter("STUDENT_ID")));
					
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
					"DELETE FROM degree WHERE DEGREE_NAME = ? AND STUDENT_ID = ?");
					
					pstmt.setString(1, request.getParameter("DEGREE_NAME"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
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
				ResultSet rs = statement.executeQuery("SELECT * FROM degree");
				%>
				
				<table>
					<tr>
						<th>Degree Type</th>
						<th>Student ID</th>
						<th>Degree Requirement ID</th>
						<th>Department</th>
						<th>Degree Name</th>
					</tr>
					
					<tr>
						<form action="degree.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="DEGREE_TYPE"></th>
							<th><input value="" name="STUDENT_ID"></th>
							<th><input value="" name="DEGREE_REQUIREMENT_ID"></th>
							<th><input value="" name="DEPT_NAME"></th>
							<th><input value="" name="DEGREE_NAME"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="degree.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getString("DEGREE_TYPE") %>" name="DEGREE_TYPE"></td>
							<td><input value="<%= rs.getInt("STUDENT_ID") %>" name="STUDENT_ID"></td>
							<td><input value="<%= rs.getInt("DEGREE_REQUIREMENT_ID") %>" name="DEGREE_REQUIREMENT_ID"></td>
							<td><input value="<%= rs.getString("DEPT_NAME") %>" name="DEPT_NAME"></td>
							<td><input value="<%= rs.getString("DEGREE_NAME") %>" name="DEGREE_NAME"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="degree.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getString("DEGREE_NAME") %>" name="DEGREE_NAME">
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