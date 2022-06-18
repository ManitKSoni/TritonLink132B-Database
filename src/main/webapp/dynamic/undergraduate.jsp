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
					("INSERT INTO undergraduate VALUES (?,?,?,?)"));
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					pstmt.setString(2, request.getParameter("COLLEGE"));
					pstmt.setString(3, request.getParameter("MAJOR_ID"));
					pstmt.setString(4, request.getParameter("MINOR_ID"));
					
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
					"UPDATE undergraduate SET COLLEGE = ?, MAJOR_ID = ?, MINOR_ID = ? WHERE STUDENT_ID = ?");
					
					pstmt.setString(1, request.getParameter("COLLEGE"));
					pstmt.setString(2, request.getParameter("MAJOR_ID"));
					pstmt.setString(3, request.getParameter("MINOR_ID"));
					pstmt.setInt(4, Integer.parseInt(request.getParameter("STUDENT_ID")));
					
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
					"DELETE FROM undergraduate WHERE STUDENT_ID = ?");
					
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
				ResultSet rs = statement.executeQuery("SELECT * FROM undergraduate");
				%>
				
				<table>
					<tr>
						<th>Student ID</th>
						<th>College</th>
						<th>Major ID</th>
						<th>Minor ID</th>
					</tr>
					
					<tr>
						<form action="undergraduate.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="STUDENT_ID"></th>
							<th><input value="" name="COLLEGE"></th>
							<th><input value="" name="MAJOR_ID"></th>
							<th><input value="" name="MINOR_ID"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="undergraduate.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getInt("STUDENT_ID") %>" name="STUDENT_ID"></td>
							<td><input value="<%= rs.getString("COLLEGE") %>" name="COLLEGE"></td>
							<td><input value="<%= rs.getString("MAJOR_ID") %>" name="MAJOR_ID"></td>
							<td><input value="<%= rs.getString("MINOR_ID") %>" name="MINOR_ID"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="undergraduate.jsp" method="get">
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