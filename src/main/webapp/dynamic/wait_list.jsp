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
					("INSERT INTO wait_list VALUES (?,?,?,?)"));
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("WAITLIST_ID")));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
					pstmt.setString(3, request.getParameter("GRADE"));
					pstmt.setInt(4, Integer.parseInt(request.getParameter("UNITS")));
					
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
					"UPDATE wait_list SET GRADE = ?, UNITS = ? WHERE WAITLIST_ID = ? AND STUDENT_ID = ?");
					
					pstmt.setString(1, request.getParameter("GRADE"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("UNITS")));
					pstmt.setInt(3, Integer.parseInt(request.getParameter("WAITLIST_ID")));
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
					"DELETE FROM wait_list WHERE WAITLIST_ID = ? AND STUDENT_ID = ?");
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("WAITLIST_ID")));
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
				ResultSet rs = statement.executeQuery("SELECT * FROM wait_list");
				%>
				
				<table>
					<tr>
						<th>Wait List ID</th>
						<th>Student ID</th>
						<th>Grade</th>
						<th>Units</th>
					</tr>
					
					<tr>
						<form action="wait_list.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="WAITLIST_ID"></th>
							<th><input value="" name="STUDENT_ID"></th>
							<th><input value="" name="GRADE"></th>
							<th><input value="" name="UNITS"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="wait_list.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getInt("WAITLIST_ID") %>" name="WAITLIST_ID"></td>
							<td><input value="<%= rs.getInt("STUDENT_ID") %>" name="STUDENT_ID"></td>
							<td><input value="<%= rs.getString("GRADE") %>" name="GRADE"></td>
							<td><input value="<%= rs.getInt("UNITS") %>" name="UNITS"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="wait_list.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getInt("WAITLIST_ID") %>" name="WAITLIST_ID">
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